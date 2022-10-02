//
//  GlobalFunctions.swift
//  MyChat
//
//  Created by Афанасьев Александр Иванович on 20.08.2022.
//

import Foundation


func fileNameFrom(fileURL: String) -> String {
    
    return (fileURL.components(separatedBy: "_").last?.components(separatedBy: "?").first?.components(separatedBy: ".").first)!
    
}


func timeElapsed(_ date: Date) -> String {
    
    let seconds = Date().timeIntervalSince(date)
    
    if seconds < 60 {
        return "Just now"
    } else if seconds < 60 * 60 {
        
        let minutes = Int(seconds / 60)
        let minText = minutes > 1 ? "mins" : "min"
        return "\(minutes) \(minText)"
        
    } else if seconds < 24 * 60 * 60 {
        
        let hours = Int(seconds / 3600)
        let hourText = hours > 1 ? "hours" : "hour"
        return "\(hours) \(hourText)"
        
    } else {
        return date.longDate()
    }
    
}
