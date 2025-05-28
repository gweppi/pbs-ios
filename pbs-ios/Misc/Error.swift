//
//  Error.swift
//  pbs-ios
//
//  Created by Jesper Dinger on 28/05/2025.
//

import Foundation

typealias DecodableError = Decodable & Error

enum VMError: Error {
    case urlWrong
    case unknown(statusCode: Int?)
    case baseUrlNotFound
}

struct FetchError: DecodableError {
    var error: String
}
