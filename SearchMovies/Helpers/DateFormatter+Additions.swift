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
    
    /// DateFormat of yyyy-MM-dd
    static let iso8601Short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
}
