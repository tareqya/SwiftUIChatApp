//
//  ChatUser.swift
//  ChatAppFirebase
//
//  Created by Tareq Yassin on 12/07/2023.
//

import Foundation

struct ChatUser: Identifiable {
    let uid, email, profileImageUrl: String
    var id: String { uid }
    
    init(data:[String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        let username = data["email"] as? String ?? ""
        self.email = String(username.split(separator: "@").first ?? "")
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }
}
