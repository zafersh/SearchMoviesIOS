//
//  APIResponse.swift
//  SearchMovies
//
//  Created by Thafer Shahin on 8/21/18.
//  Copyright © 2018 Thafer Shahin. All rights reserved.
//

import Foundation

/// Model for movies API response.
struct APIResponse : Codable {
    
    /// Current page number. First page number is 1
    var pageNo  = 1
    
    /// Total pages available at the server.
    var totalPages = 1
    
    /// The actual movies.
    var movies : [Movie]
    
    /// Coding keys used to match model properties with API response attributes.
    private enum CodingKeys: String, CodingKey {
        case pageNo = "page"
        case totalPages = "total_pages"
        case movies = "results"
    }
    
}
