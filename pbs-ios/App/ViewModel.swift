//
//  vm.swift
//  pbs-ios
//
//  Created by Jesper Dinger on 25/05/2025.
//

import Foundation

@Observable
class ViewModel {
    
    private enum Endpoint {
        case pbs, search
    }
    
    private func urlString(for endpoint: Endpoint) -> String {
        #if targetEnvironment(simulator)
            let base = "http://localhost:8080"
        #else
            let base = "https://" + (Bundle.main.object(forInfoDictionaryKey: "API_ENDPOINT") as? String ?? "")
        #endif
        
        switch endpoint {
        case .pbs:
            return base + "/?athleteId="
        case .search:
            return base + "/search?name="
        }
    }
    
    private func decode<T: Decodable>(_ data: Data, from response: URLResponse, successType: T.Type, failureType: DecodableError.Type = FetchError.self) throws -> T {
        if let httpRes = response as? HTTPURLResponse {
            switch httpRes.statusCode {
                case 200:
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    return decoded
                case 400, 404:
                    let decoded = try JSONDecoder().decode(failureType, from: data)
                    throw decoded
                default:
                    throw VMError.unknown(statusCode: httpRes.statusCode)
            }
        }
        
        throw VMError.unknown(statusCode: nil)
    }
    
    func fetch(id: String) async throws -> PBS {
        let url = URL(string: urlString(for: .pbs) + id)
        guard let url else { throw VMError.urlWrong }
        
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let decoded = try decode(data, from: response, successType: PBS.self)
        return decoded
    }
    
    func search(name: String) async throws -> [Athlete] {
        let url = URL(string: urlString(for: .search) + name)
        guard let url else { throw VMError.urlWrong }
        
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let decoded = try decode(data, from: response, successType: [Athlete].self)
        return decoded
    }
}
