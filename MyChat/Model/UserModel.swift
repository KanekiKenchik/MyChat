//
//  UserModel.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 17.08.2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import UIKit


struct User: Codable, Equatable {
    
    var id = ""
    var username: String
    var email: String
    var pushId = ""
    var avatarLink = ""
    var status: String
    
    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }
    
    static var currentUser: User? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER) {
                
                let decoder = JSONDecoder()
                
                do {
                    let userObject = try decoder.decode(User.self, from: dictionary)
                    return userObject
                } catch {
                    print("Error decoding user from UserDefaults: ", error.localizedDescription)
                }
                
            }
        }
        
        return nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
}


func saveUserLocally(_ user: User) {
    
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: kCURRENTUSER)
    } catch {
        print("error saving user locally: ", error.localizedDescription)
    }
}


func createDummyUsers() {
    
    let names = ["Alexander Afanasev", "Anna Tsvetkova", "Andrew Nefedov", "Random Guy"]
    
    var imageIndex = 1
    var userIndex = 1
    
    for i in 0..<4 {
        
        let id = UUID().uuidString
        
        let fileDirectory = "Avatars/_\(id).jpg"
        
        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, path: fileDirectory) { avatarLink in
            
            let user = User(id: id, username: names[i], email: "user\(userIndex)@mail.ru", pushId: "", avatarLink: avatarLink ?? "", status: "Hey there!")
            
            userIndex += 1
            FirebaseUserListener.shared.saveUserToFirestore(user)
        }
        
        imageIndex += 1
        
        if imageIndex == 4 {
            imageIndex = 1
        }
    }
    
}
