//
//  Movie.swift
//  SearchMovies
//
//  Created by Thafer Shahin on 8/21/18.
//  Copyright © 2018 Thafer Shahin. All rights reserved.
//

import Foundation

/// Model for Movie.
struct Movie : Codable {
    
    let poster : String?
    let name : String
    let releaseDate : Date
    let overview : String?
    
    // Coding keys used to match model properties with API response attributes.
    private enum CodingKeys: String, CodingKey {
        case poster = "poster_path"
        case name = "title"
        case releaseDate = "release_date"
        case overview
    }
    
}
