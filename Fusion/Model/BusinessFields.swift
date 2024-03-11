//
//  BusinessFields.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 19/02/2024.
//  Add in scrolling feature to view all business fields

import Foundation

enum BusinessFields: Int, CaseIterable, Identifiable, Codable { //int gives each business field a number
    case accounting, agriculture, automotive, consultant, education, energy, environmental, fashion, finance, food, healthcare, hospitality, it, law, logistics, manufacturing, marketing, media, music, realestate, retail, sports, technology, transportation //all the businessfields
    
    var id: Self {
        self
    }
    
    var title: String {
        switch self {
        case .accounting:
            return "Accounting"
        case .agriculture:
            return "Agriculture"
        case .automotive:
            return "Automotive"
        case .consultant:
            return "Consultant"
        case .education:
            return "Education"
        case .energy:
            return "Energy"
        case .environmental:
            return "Environmental"
        case .fashion:
            return "Fashion"
        case .finance:
            return "Finance"
        case .food:
            return "Food"
        case .healthcare:
            return "Healthcare"
        case .hospitality:
            return "Hospitality"
        case .it:
            return "IT"
        case .law:
            return "Law"
        case .logistics:
            return "Logistics"
        case .manufacturing:
            return "Manufacturing"
        case .marketing:
            return "Marketing"
        case .media:
            return "Media"
        case .music:
            return "Music"
        case .realestate:
            return "Real Estate"
        case .retail:
            return "Retail"
        case .sports:
            return "Sports"
        case .technology:
            return "Technology"
        case .transportation:
            return "Transportation"
        }
    }
}
