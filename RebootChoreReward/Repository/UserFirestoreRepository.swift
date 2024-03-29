//
//  UserFirestoreRepository.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/18/24.
//

import FirebaseFirestore
import Combine

enum UserFetchingError: Error {
    case userNotFound
}

class UserFirestoreRepository {
    private let db = Firestore.firestore()
    private var userCollectionListener: ListenerRegistration?
    
    var user: AnyPublisher<User, Never> {
        _user.eraseToAnyPublisher()
    }
    private let _user = CurrentValueSubject<User, Never>(.empty)
    
    init() {}
    
    func createUser(from userObject: User) {
        do {
            try db.collection("users").document(userObject.id).setData(from: userObject)
        }
        catch let error {
            LogUtil.log("Error writing user to Firestore: \(error)")
        }
    }
    
    func readUser(withId userId: String) {
        self.userCollectionListener = db.collection("users").document(userId).addSnapshotListener { [weak self] documentSnapshot, error in
            guard let document = documentSnapshot, document.exists else {
                if let error = error {
                    LogUtil.log("Error fetching user document: \(error)")
                }
                else {
                    LogUtil.log("User document does not exist")
                }
                self?._user.send(.empty)
                return
            }
            
            do {
                if let user = try documentSnapshot?.data(as: User.self) {
                    self?._user.send(user)
                }
                else {
                    LogUtil.log("Error decoding user document")
                    self?._user.send(.empty)
                }
            }
            catch {
                LogUtil.log("Error decoding user document \(error)")
                self?._user.send(.empty)
                return
            }
        }
    }
    
    func readUser(withId userId: String) async throws -> User {
        let documentSnapshot = try await db.collection("users").document(userId).getDocument()
        if let user = try? documentSnapshot.data(as: User.self) {
            return user
        } else {
            throw UserFetchingError.userNotFound
        }
    }
    
    deinit {
        userCollectionListener?.remove()
    }
}
