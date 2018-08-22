//
//  Suggestion.swift
//  SearchMovies
//
//  Created by Thafer Shahin on 8/22/18.
//  Copyright © 2018 Thafer Shahin. All rights reserved.
//

import Foundation

/// Structure for suggestion table view model.
struct Suggestion : CellModel {
    var keyword : String
    
    init(keyword : String) {
        self.keyword = keyword
    }
}
