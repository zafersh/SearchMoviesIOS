//
//  DateFormatter+Additions.swift
//  SearchMovies
//
//  Created by Thafer Shahin on 8/21/18.
//  Copyright © 2018 Thafer Shahin. All rights reserved.
//

import Foundation

// MARK: - DateFormatter+Additions

/// This extension is created to hold all used date formates.
extension DateFormatter {
    
    /// DateFormatter used for medium date style.
    private static var dateFormatterMedium : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    /// DateFormat of yyyy-MM-dd
    static let iso8601Short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    /// Format provided date as a medium style.
    ///
    /// - Parameter date: a date to be formatted
    static func formattedMedium(date : Date) -> String {
        return DateFormatter.dateFormatterMedium.string(from:date)
    }
    
}
