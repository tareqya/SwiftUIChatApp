//
//  RecentMessage.swift
//  ChatAppFirebase
//
//  Created by Tareq Yassin on 14/07/2023.
//

import Foundation
import Firebase

struct RecentMessage: Identifiable {
    var id: String {documentId}
    
    let documentId: String
    let text, fromId, toId: String
    let email, profileImageUrl: String
    let timestamp: Firebase.Timestamp
    
    init(document: String, data: [String: Any]) {
        self.documentId = document
        self.text = data["text"] as? String ?? ""
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }

    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        
        let date = self.timestamp.dateValue() // Convert Timestamp to Date
        return formatter.localizedString(for: date, relativeTo: Date())
    }

}
