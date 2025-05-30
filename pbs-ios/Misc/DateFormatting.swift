//
//  DateFormatting.swift
//  pbs-ios
//
//  Created by Jesper Dinger on 30/05/2025.
//

import Foundation

extension Date {
    init(string: String, format: String = "dd MMMM yyyy") throws {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        let date = formatter.date(from: string)
        if let date {
            self.init(timeIntervalSince1970: date.timeIntervalSince1970)
        } else {
            throw DateError.failedToParseDate
        }

    }
}

enum DateError: Error {
    case failedToParseDate
}
