//
//  vm.swift
//  pbs-ios
//
//  Created by Jesper Dinger on 25/05/2025.
//

import Foundation

enum VMError: Error {
    case urlWrong
    case unknown(statusCode: Int?)
    case baseUrlNotFound
}

@Observable
class VM {
    
    enum Endpoint {
        case pbs, search
    }
    
    func urlString(for endpoint: Endpoint) -> String {
        #if targetEnvironment(simulator)
            let base = "http://localhost:8080"
        #else
            let base = Bundle.main.object(forInfoDictionaryKey: "API_ENDPOINT") as? String ?? ""
        #endif
        
        switch endpoint {
        case .pbs:
            return base + "/?athleteId="
        case .search:
            return base + "/search?name="
        }
    }
    
    func fetch(id: String) async throws -> Obj {
        var url: URL?
        #if targetEnvironment(simulator)
            url = URL(string: "http://localhost:8080/?athleteId=\(id)")
        #else
//        Get url from Secrets.xcconfig
            if let baseUrl = Bundle.main.object(forInfoDictionaryKey: "API_ENDPOINT") as? String {
                url = URL(string: "https://\(baseUrl)/?athleteId=\(id)")
            } else {
                throw VMError.baseUrlNotFound
            }
        #endif
        guard let url else { throw VMError.urlWrong }
        
        let request = URLRequest(url: url)
        let (data, res) = try await URLSession.shared.data(for: request)
        
        if let httpRes = res as? HTTPURLResponse {
            switch httpRes.statusCode {
                case 200:
                    let decoded = try JSONDecoder().decode(Obj.self, from: data)
                    return decoded
                case 400, 404:
                    let decoded = try JSONDecoder().decode(PBError.self, from: data)
                    throw decoded
                default:
                    throw VMError.unknown(statusCode: httpRes.statusCode)
            }
        }
        
        throw VMError.unknown(statusCode: nil)
    }
    
    func search(name: String) async throws -> [Athlete] {
        var url: URL?
        #if targetEnvironment(simulator)
            url = URL(string: "http://localhost:8080/search?name=\(name)")
        #else
//        Get url from Secrets.xcconfig
            if let baseUrl = Bundle.main.object(forInfoDictionaryKey: "API_ENDPOINT") as? String {
                url = URL(string: "https://\(baseUrl)/search?name=\(name)")
            } else {
                throw VMError.baseUrlNotFound
            }
        #endif
//        let url = URL(string: "http://145.126.5.190:8080/search?name=\(name)")
        guard let url else { throw VMError.urlWrong }
        
        let request = URLRequest(url: url)
        let (data, res) = try await URLSession.shared.data(for: request)
        
        if let httpRes = res as? HTTPURLResponse {
            switch httpRes.statusCode {
                case 200:
                    let decoded = try JSONDecoder().decode([Athlete].self, from: data)
                    return decoded
                case 400, 404:
                    let decoded = try JSONDecoder().decode(PBError.self, from: data)
                    throw decoded
                default:
                    throw VMError.unknown(statusCode: httpRes.statusCode)
            }
        }
        
        throw VMError.unknown(statusCode: nil)
    }
}

struct PBError: Codable, Error {
    var error: String
}

struct Obj: Codable {
    let info: Athlete
    let pbs: [PB]
}

struct PB: Codable, Hashable {
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
}
