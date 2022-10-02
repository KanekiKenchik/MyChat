//
//  FileStorage.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 20.08.2022.
//

import Foundation
import FirebaseStorage
import ProgressHUD
import UIKit

let storage = Storage.storage()

class FileStorage {
    
    class func uploadImage(_ image: UIImage, path: String, completion: @escaping (_ documentLink: String?) -> Void) {
        
        let storageReference = storage.reference(forURL: kFILEREFERENCE).child(path)
        
        let imageData = image.jpegData(compressionQuality: 0.8)
        
        var task: StorageUploadTask!
        task = storageReference.putData(imageData!, metadata: nil, completion: { metadata, error in
            
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil {
                print("Error uploading image: ", error?.localizedDescription)
                return
            }
            
            storageReference.downloadURL { url, error in
                
                guard let downloadURL = url else {
                    completion(nil)
                    return
                }
                
                completion(downloadURL.absoluteString)
                
            }
            
        })
        
        task.observe(.progress) { snapshot in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
        
    }
    
    class func downloadImage(imageURL: String, completion: @escaping (_ image: UIImage?) -> Void) {
        
        let imageFileName = fileNameFrom(fileURL: imageURL)
        if fileExistsAtPath(path: imageFileName) {
            //get it locally
            print("We have local image")
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
                
                completion(contentsOfFile)
            } else {
                
                print("Couldnt convert local image")
                completion(UIImage(named: "avatar"))
            }
        } else {
            //download from Firebase
            print("Lets get from Firebase")
            
            if imageURL != "" {
                
                let documentURL = URL(string: imageURL)
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                
                downloadQueue.async {
                    
                    let data = NSData(contentsOf: documentURL!)
                    
                    if data != nil {
                        
                        //Save locally
                        FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)
                        DispatchQueue.main.async {
                            completion(UIImage(data: data! as Data))
                        }
                        
                    } else {
                        print("no document in database")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: - Save locally
    class func saveFileLocally(fileData: NSData, fileName: String) {
        
        let docURL = getDocumentsUrl().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: docURL, atomically: true)
        
    }
    
}


//MARK: - Helpers
func fileInDocumentsDirectory(fileName: String) -> String {
    
    return getDocumentsUrl().appendingPathComponent(fileName).path
    
}

func getDocumentsUrl() -> URL {
    
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    
}

func fileExistsAtPath(path: String) -> Bool {
    
    return FileManager.default.fileExists(atPath: fileInDocumentsDirectory(fileName: path))
    
}
