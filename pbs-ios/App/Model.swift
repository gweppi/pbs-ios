//
//  Model.swift
//  pbs-ios
//
//  Created by Jesper Dinger on 28/05/2025.
//

import Foundation

struct PBS: Codable {
    let info: Athlete
    let pbs: [PersonalBest]
}

struct PersonalBest: Codable, Hashable {
    let event: String
    let course: String
    let time: String
    let pts: String
    let date: String
    let city: String
    let name: String
}

struct Athlete: Codable, Hashable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let dobYear: String
    let country: String?
    let club: String?
    
    var fullName: String {
        "\(lastName) \(firstName)"
    }
}
