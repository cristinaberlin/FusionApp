//
//  MockUsers.swift
//  FusionTests
//
//  Created by Cristina Berlinschi on 24/03/2024.
//

import Foundation
@testable import Fusion

class MockUsers{
    static let users: [User] = [
        User(id: UUID().uuidString, fullname: "Pink Panther", email: "panther32@gmail.com", businessField: .hospitality, company: "Hilton", experience: "3 years", bio: "I love cheese", avatar: "https://firebasestorage.googleapis.com/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2Fbae61406_1d3e_40ee_b419_8a077f10f911.jpeg?alt=media&token=4a4f93e2-9404-4733-9291-0620552440ab", l: [53.61516818024476, -6.197533607482911]),
        User(id: UUID().uuidString, fullname: "Ana Banana", email: "ana123@icloud.com", businessField: .fashion, bio: "Interested in starting a business", avatar: "https://firebasestorage.googleapis.com/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2Fbae61406_1d3e_40ee_b419_8a077f10f911.jpeg?alt=media&token=4a4f93e2-9404-4733-9291-0620552440ab", l: [53.61292784933422, -6.189894676208496]),
        User(id: UUID().uuidString, fullname: "Tony B", email: "tony98@icloud.com", businessField: .automotive, bio: "Interested in starting a business", avatar: "https://firebasestorage.googleapis.com/v0/b/fusion-eea9a.appspot.com/o/images%2F9xyjsqzPgBQiK0wd76E6zplxYM12%2Fbae61406_1d3e_40ee_b419_8a077f10f911.jpeg?alt=media&token=4a4f93e2-9404-4733-9291-0620552440ab", l: [53.61292784933486, -6.184659004211427])
    ]
}
