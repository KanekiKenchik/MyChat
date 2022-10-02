//
//  IncomingMessage.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 30.08.2022.
//

import Foundation
import MessageKit
import CoreLocation

class IncomingMessage {
    
    var messageCollectionView: MessagesViewController
    
    init(_collectionView: MessagesViewController) {
        messageCollectionView = _collectionView
    }
    
    
    //MARK: - CreateMessage
    
    func createMessage(localMessage: LocalMessage) -> MKMessage? {
        
        let mkMessage = MKMessage(message: localMessage)
        
        //multimedia messages
        
        return mkMessage
        
    }
    
}
