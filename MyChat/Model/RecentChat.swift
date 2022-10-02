//
//  RecentChat.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 25.08.2022.
//

import Foundation
import FirebaseFirestoreSwift

struct RecentChat: Codable {
    
    var id = ""
    var chatRoomId = ""
    var senderId = ""
    var senderName = ""
    var receiverID = ""
    var receiverName = ""
    @ServerTimestamp var date = Date()
    var memberIds = [""]
    var lastMessage = ""
    var unreadCounter = 0
    var avatarLink = ""
    
}
