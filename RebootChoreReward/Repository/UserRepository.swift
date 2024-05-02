//
//  UserRepository.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/18/24.
//

import FirebaseFirestore
import Combine

enum UserRepositoryError: Error {
    case userNotFound
    case encodingError
    case fetchingError
    case decodingError
    case creatingError
    case updatingError
}

class UserRepository {
    private let db = Firestore.firestore()
    private var householdMemberCollectionListener: ListenerRegistration?
    private var userDocumentListener: ListenerRegistration?
    
    var members: AnyPublisher<(members: [DecentrailizedUser]?, error: Error?), Never> {
        _members.eraseToAnyPublisher()
    }
    private let _members = CurrentValueSubject<(members: [DecentrailizedUser]?, error: Error?), Never>((nil, nil))
    
    var user: AnyPublisher<(user: User?, error: Error?), Never> {
        _user.eraseToAnyPublisher()
    }
    private let _user = CurrentValueSubject<(user: User?, error: Error?), Never>((nil, nil))
    
    func createUser(from userObject: User) async {
        let userDocRef = db.collection("users").document(userObject.id)
        
        do {
            try await userDocRef.setDataAsync(from: userObject)
        } catch {
            LogUtil.log("Error creating user: \(error.localizedDescription)")
            self._user.send((nil, UserRepositoryError.creatingError))
        }
    }
    
    func createUserInHouseholdSub(householdId: String, withUser decentralizedUserObject: DecentrailizedUser) async {
        let userDocRef = db
            .collection("households")
            .document(householdId)
            .collection("users")
            .document(decentralizedUserObject.id)
        
        do {
            try await userDocRef.setDataAsync(from: decentralizedUserObject)
        }
        catch {
            LogUtil.log("Error creating user: \(error.localizedDescription)")
            self._user.send((nil, UserRepositoryError.creatingError))
        }
    }
    
    func readUser(withId userId: String) {
        let userDocRef = db.collection("users").document(userId)
        self.userDocumentListener = userDocRef.addSnapshotListener { [weak self] userDocSnapshot, error in
            guard let userDoc = userDocSnapshot else {
                LogUtil.log("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                self?._user.send((nil, UserRepositoryError.fetchingError))
                return
            }
            
            do {
                let user = try userDoc.data(as: User.self)
                self?._user.send((user, nil))
            } catch {
                LogUtil.log("Error decoding document: \(error.localizedDescription)")
                self?._user.send((nil, UserRepositoryError.decodingError))
            }
        }
    }
    
    func readMembers(inHousehold householdId: String) {
        let householdMemberCollectionRef = db.collection("households").document(householdId).collection("users")
        self.householdMemberCollectionListener = householdMemberCollectionRef
        //.orderByage
            .addSnapshotListener { [weak self] collectionSnapshot, error in
                guard let collectionSnapshot = collectionSnapshot else {
                    if let error = error {
                        LogUtil.log("\(error)")
                        self?._members.send((nil, error))
                    }
                    return
                }
                
                let members = collectionSnapshot.documents.compactMap { documentSnapshot in
                    do {
                        return try documentSnapshot.data(as: DecentrailizedUser.self)
                    }
                    catch {
                        LogUtil.log("\(error)")
                        self?._members.send((nil, error))
                        return nil
                    }
                }
                
                self?._members.send((members, nil))
            }
    }
    
    func updateUser(atUserId userId: String, withHouseholdId householdId: String) async {
        let userDocRef = db.collection("users").document(userId)
        
        do {
            try await userDocRef.updateData(["householdId": householdId])
        } catch {
            LogUtil.log("Error updating user household ID: \(error.localizedDescription)")
            self._user.send((nil, UserRepositoryError.updatingError))
        }
    }
    
    //    func readUserForHouseholdId(userId: String) {
    //        LogUtil.log("attaching listener for userId \(userId)")
    //        userDocumentListener = db.collection("users")
    //            .document(userId)
    //            .addSnapshotListener { [weak self] documentSnapshot, error in
    //                if let error = error {
    //                    LogUtil.log("Error: \(error.localizedDescription)")
    //                    self?._userHouseholdId.send(nil)
    //                    return
    //                }
    //
    //                guard let document = documentSnapshot else {
    //                    LogUtil.log("Error fetching document")
    //                    self?._userHouseholdId.send(nil)
    //                    return
    //                }
    //
    //                guard let data = document.data() else {
    //                    LogUtil.log("Document data was empty")
    //                    self?._userHouseholdId.send(nil)
    //                    return
    //                }
    //
    //                guard let householdId = data["householdId"] as? String else {
    //                    LogUtil.log("Failed to get householdId as String")
    //                    self?._userHouseholdId.send(nil)
    //                    return
    //                }
    //
    //                LogUtil.log("Got householdId \(householdId)")
    //                self?._userHouseholdId.send(householdId)
    //            }
    //    }
    
    //    func currentHouseholdId() -> String? {
    //        _userHouseholdId.value
    //    }
    
    func currentUserId() -> String? {
        _user.value.user?.id
    }
    
    func reset() {
        LogUtil.log("UserRepository -- resetting")
        householdMemberCollectionListener?.remove()
        householdMemberCollectionListener = nil
        userDocumentListener?.remove()
        userDocumentListener = nil
        _members.send((nil, nil))
        _user.send((nil, nil))
    }
    
    deinit {
        householdMemberCollectionListener?.remove()
        userDocumentListener?.remove()
    }
}
