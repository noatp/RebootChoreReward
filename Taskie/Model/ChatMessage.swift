//
//  ChatMessage.swift
//  Taskie
//
//  Created by Toan Pham on 6/1/24.
//

import FirebaseFirestoreInternal

struct ChatMessage: Codable {
    static let empty = ChatMessage(
        id: "",
        message: "",
        sender: .init(id: "", name: "", profileColor: ""),
        isFromCurrentUser: false,
        imageUrls: [],
        sendDate: ""
    )
    
    static let mock = ChatMessage(
        id: "some id",
        message: "This is a very very long message",
        sender: .init(id: "some id", name: "some name", profileColor: "#FF00FF"), 
        isFromCurrentUser: false,
        imageUrls: [],
        sendDate: "0 seconds ago"
    )
    
    let id: String
    let message: String
    let sender: DenormalizedUser
    let isFromCurrentUser: Bool
    let imageUrls: [String]
    let sendDate: String
}