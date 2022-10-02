//
//  StartChat.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 27.08.2022.
//

import Foundation
import FirebaseFirestore

//MARK: - StartChat
func startChat(user1: User, user2: User) -> String {
    
    let chatRoomID = chatRoomIDFrom(user1ID: user1.id, user2ID: user2.id)
    createRecentItems(chatRoomID: chatRoomID, users: [user1, user2])
    return chatRoomID
    
}

func restartChat(chatRoomID: String, memberIDs: [String]) {
    
    FirebaseUserListener.shared.downloadUsersFromFirebase(withIDs: memberIDs) { users in
        
        if users.count > 0 {
            createRecentItems(chatRoomID: chatRoomID, users: users)
        }
    }
}

func createRecentItems(chatRoomID: String, users: [User]) {
    
    var memberIDsToCreateRecent = [users.first!.id, users.last!.id]
    
    //does user have recent?
    FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomID).getDocuments { snapshot, error in
        
        guard let snapshot = snapshot else { return }
        
        if !snapshot.isEmpty {
            
            memberIDsToCreateRecent = removeMemberWhoHasRecent(snapshot: snapshot, memberIDs: memberIDsToCreateRecent)
        }
        
        for userID in memberIDsToCreateRecent {
            
            let senderUser = userID == User.currentId ? User.currentUser! : getReceiverFrom(users: users)
            
            let receiverUser = userID == User.currentId ? getReceiverFrom(users: users) : User.currentUser!
            
            let recentObject = RecentChat(id: UUID().uuidString, chatRoomId: chatRoomID, senderId: senderUser.id, senderName: senderUser.username, receiverID: receiverUser.id, receiverName: receiverUser.username, date: Date(), memberIds: [senderUser.id, receiverUser.id], lastMessage: "", unreadCounter: 0, avatarLink: receiverUser.avatarLink)
            
            FirebaseRecentListener.shared.saveRecent(recentObject)
        }
        
    }
    
}

func removeMemberWhoHasRecent(snapshot: QuerySnapshot, memberIDs: [String]) -> [String] {
    
    var memberIDsToCreateRecent = memberIDs
    
    for recentData in snapshot.documents {
        
        let currentRecent = recentData.data() as Dictionary
        
        if let currentUserID = currentRecent[kSENDERID] {
            
            if memberIDsToCreateRecent.contains(currentUserID as! String) {
                
                memberIDsToCreateRecent.remove(at: memberIDsToCreateRecent.firstIndex(of: currentUserID as! String)!)
            }
        }
    }
    
    return memberIDsToCreateRecent
}


func chatRoomIDFrom(user1ID: String, user2ID: String) -> String {
    
    var chatRoomID = ""
    
    let value = user1ID.compare(user2ID).rawValue
    
    chatRoomID = value < 0 ? user1ID + user2ID : user2ID + user1ID
    
    return chatRoomID
    
}


func getReceiverFrom(users: [User]) -> User {
    
    var allUsers = users
    
    allUsers.remove(at: allUsers.firstIndex(of: User.currentUser!)!)
    
    return allUsers.first!
    
}
