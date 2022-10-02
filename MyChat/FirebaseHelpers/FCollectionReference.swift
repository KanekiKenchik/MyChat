//
//  FCollectionReference.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 17.08.2022.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Recent
    case Messages
    case Typing
}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
