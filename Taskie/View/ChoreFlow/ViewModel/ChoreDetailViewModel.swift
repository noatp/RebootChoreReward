
//  ChoreDetailViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/21/24.
//

import Combine
import FirebaseFirestoreInternal

class ChoreDetailViewModel: ObservableObject {
    @Published var choreDetail: ChoreForDetailView? = .empty
    private var cancellables: Set<AnyCancellable> = []
    private let choreService: ChoreService
    private let userService: UserService
    private let authService: AuthService
    
    init(
        choreService: ChoreService,
        userService: UserService,
        authService: AuthService
    ) {
        self.choreService = choreService
        self.userService = userService
        self.authService = authService
        subscribeToChoreFirestoreService()
    }
    
    private func subscribeToChoreFirestoreService() {
        choreService.selectedChore.sink { [weak self] chore in
            LogUtil.log("From ChoreService -- chore -- \(chore)")
            self?.updateChoreDetail(chore: chore)
        }
        .store(in: &cancellables)
    }
    
    private func updateChoreDetail(chore: Chore?) {
        guard let chore = chore else {
            self.choreDetail = nil
            return
        }
        Task {
            do {
                
                guard let requestor = try await userDetail(withId: chore.requestorID),
                      let actionButtonType = determineActionType(
                        requestorId: chore.requestorID,
                        acceptorId: chore.acceptorID,
                        finishedDate: chore.finishedDate
                      )
                else {
                    return
                }
                let acceptor = try await userDetail(withId: chore.acceptorID)
                let choreStatus = self.determineChoreStatus(acceptorId: chore.acceptorID, finishedDate: chore.finishedDate)
                   
                DispatchQueue.main.async { [weak self] in
                    self?.choreDetail = ChoreForDetailView(
                        name: chore.name,
                        requestorName: requestor.name ?? "",
                        acceptorName: acceptor?.name,
                        description: chore.description,
                        rewardAmount: chore.rewardAmount,
                        imageUrls: chore.imageUrls,
                        createdDate: chore.createdDate.toRelativeString(),
                        finishedDate: chore.finishedDate?.toRelativeString(), 
                        actionButtonType: actionButtonType,
                        choreStatus: choreStatus
                    )
                }
            } catch {
                LogUtil.log("Failed to fetch family member: \(error)")
            }
        }
    }
    
    private func determineActionType(requestorId: String, acceptorId: String?, finishedDate: Timestamp?) -> ChoreForDetailView.actionButtonType? {
        if finishedDate != nil {
            return .nothing
        }
        else {
            guard let currentUserId = authService.currentUserId else {
                return nil
            }
            
            if currentUserId == requestorId {
                return .withdraw
            }
            else {
                if let acceptorId = acceptorId {
                    if acceptorId == currentUserId {
                        return .finish
                    }
                    else {
                        return .nothing
                    }
                }
                else {
                    return .accept
                }
            }
        }
    }
    
    private func determineChoreStatus(acceptorId: String?, finishedDate: Timestamp?) -> String {
        if let finishedDate = finishedDate {
            return "Finished"
        }
        else if let acceptorId = acceptorId {
            return "Pending"
        }
        else {
            return ""
        }
    }
    
    func userDetail(withId lookUpId: String?) async throws -> DecentrailizedUser? {
        guard let lookUpId = lookUpId,
              let currentUserId = authService.currentUserId
        else {
            return nil
        }
        
        var userDetail: DecentrailizedUser? = nil
        
        if let familyMember = try await userService.readFamilyMember(withId: lookUpId) {
            if lookUpId == currentUserId {
                userDetail = .init(id: familyMember.id, name: "You", profileColor: familyMember.profileColor)
            }
            else {
                userDetail = familyMember
            }
        }

        return userDetail
    }
    
    func acceptSelectedChore() {
        guard let currentUserId = authService.currentUserId else {
            return
        }
        choreService.acceptSelectedChore(acceptorId: currentUserId)
    }
    
    func finishedSelectedChore() {
        choreService.finishedSelectedChore()
    }
    
    func withdrawSelectedChore() {
        choreService.withdrawSelectedChore()
    }
}

extension Dependency.ViewModel {
    func choreDetailViewModel() -> ChoreDetailViewModel {
        return ChoreDetailViewModel(
            choreService: service.choreService,
            userService: service.userService,
            authService: service.authService
        )
    }
}