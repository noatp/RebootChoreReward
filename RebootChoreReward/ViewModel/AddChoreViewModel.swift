
//  AddChoreViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Combine
import UIKit
import FirebaseFirestore

class AddChoreViewModel: ObservableObject {
    @Published var images: [UIImage?] = [nil]
    var choreName: String?
    var choreDescription: String?
    var choreRewardAmount: String?
    private var authService: AuthService
    private var storageService: StorageService
    private var choreService: ChoreService
    
    init(
        authService: AuthService,
        storageService: StorageService,
        choreService: ChoreService
    ) {
        self.authService = authService
        self.storageService = storageService
        self.choreService = choreService
    }
    
    func createChore(completion: @escaping (_ errorMessage: String?) -> Void) {
        guard let choreName = choreName, !choreName.isEmpty else {
            completion("Please enter a name for this chore.")
            return
        }
        guard let choreRewardAmount = choreRewardAmount?.stripDollarSign(),
              choreRewardAmount != StringConstant.emptyString,
              let choreRewardAmountDouble = Double(choreRewardAmount.stripDollarSign()) else {
            completion("Please enter a reward amount for this chore.")
            return
        }
        guard let choreDescription = choreDescription else {
            completion(StringConstant.emptyString)
            return
        }
        
        guard let uid = authService.getCurrentUserCache(key: "uid") else {
            completion("Something went wrong. Please try again later!")
            return
        }
        
        Task {
            do {
                let imageURLs = try await storageService.uploadImages(images.compactMap{$0})
                let choreImageUrls = imageURLs.map { $0.absoluteString }
                let choreId = UUID().uuidString
                
                try await choreService.createChore(from: Chore(
                    id: choreId,
                    name: choreName,
                    creator: uid,
                    description: choreDescription,
                    rewardAmount: choreRewardAmountDouble,
                    imageUrls: choreImageUrls,
                    createdDate: .init()
                ))
                completion(nil)
            } catch {
                completion("Error creating chore: \(error)")
            }
        }
    }
    
    func add(image: UIImage) {
        images.insert(image, at: 0)
    }
}

extension Dependency.ViewModel {
    func addChoreViewModel() -> AddChoreViewModel {
        return AddChoreViewModel(
            authService: service.authService,
            storageService: service.storageService,
            choreService: service.choreService
        )
    }
}
