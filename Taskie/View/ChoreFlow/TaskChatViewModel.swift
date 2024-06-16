
//  TaskChatViewModel.swift
//  Taskie
//
//  Created by Toan Pham on 6/1/24.
//

import Combine
import UIKit

class TaskChatViewModel: ObservableObject {
    @Published var choreDetail: Chore?
    @Published var chatMessages: [ChatMessage] = []
    @Published var chatInputText: String = ""
    @Published var images: [UIImage] = []

    private var cancellables: Set<AnyCancellable> = []
    private let choreService: ChoreService
    private let userService: UserService
    private let chatMessageService: ChatMessageService
    private let chatMessageMapper: ChatMessageMapper
    private let choreMapper: ChoreMapper
    
    init(
        userService: UserService,
        choreService: ChoreService,
        chatMessageService: ChatMessageService,
        chatMessageMapper: ChatMessageMapper,
        choreMapper: ChoreMapper
    ) {
        self.choreService = choreService
        self.userService = userService
        self.chatMessageService = chatMessageService
        self.chatMessageMapper = chatMessageMapper
        self.choreMapper = choreMapper
        subscribeToChoreService()
        subscribeToChatMessageService()
    }
    
    private func subscribeToChoreService() {
        choreService.selectedChore.sink { [weak self] choreDto in
            guard let choreDto = choreDto else {
                return
            }
            self?.chatMessageService.readChatMessages(ofChore: choreDto.id)
            self?.choreDetail = self?.choreMapper.getChoreFrom(choreDto)
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToChatMessageService() {
        chatMessageService.chatMessages
            .sink { [weak self] chatMessagesDto in
                guard let chatMessagesDto = chatMessagesDto,
                      let self = self else {
                    return
                }
                let chatMessages = chatMessagesDto.compactMap {
                    self.chatMessageMapper.getChatMessageFrom($0)
                }
                self.chatMessages = self.groupChatMessages(chatMessages)
            }
            .store(in: &cancellables)
    }


    
    func createNewMessage() {
        guard let currentUserId = userService.getCurrentUser()?.id,
              let currentChoreId = choreDetail?.id,
              !chatInputText.isEmpty
        else {
            return
        }
        
        Task {
            await chatMessageService.createNewMessage(
                chatInputText,
                byUserId: currentUserId,
                atChoreId: currentChoreId
            )
        }
        chatInputText = ""
    }
    
    private func groupChatMessages(_ chatMessages: [ChatMessage]) -> [ChatMessage] {
        var groupedChatMessages = chatMessages
        let count = chatMessages.count
        
        for (index, message) in chatMessages.enumerated() {
            if index == 0 || chatMessages[index - 1].sender.id != message.sender.id {
                groupedChatMessages[index].isFirstInSequence = true
            } else {
                groupedChatMessages[index].isFirstInSequence = false
            }
            
            if index == count - 1 || chatMessages[index + 1].sender.id != message.sender.id {
                groupedChatMessages[index].isLastInSequence = true
            } else {
                groupedChatMessages[index].isLastInSequence = false
            }
        }
        
        return groupedChatMessages
    }
    
    deinit {
        LogUtil.log("deinit")
    }
}

extension Dependency.ViewModel {
    func taskChatViewModel() -> TaskChatViewModel {
        return TaskChatViewModel(
            userService: service.userService,
            choreService: service.choreService,
            chatMessageService: service.chatMessageService,
            chatMessageMapper: mapper.chatMessageMapper, 
            choreMapper: mapper.choreMapper
        )
    }
}
