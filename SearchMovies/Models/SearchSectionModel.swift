//
//  SearchSectionModel.swift
//  SearchMovies
//
//  Created by Thafer Shahin on 8/22/18.
//  Copyright © 2018 Thafer Shahin. All rights reserved.
//

import Foundation
import RxDataSources

/// Section model for search table used for Movies and Suggestions sections.
struct SearchSectionModel : SectionModelType {
    var items: [CellModel]
    
    init(items : [CellModel]) {
        self.items = items
    }
    
    init(original: SearchSectionModel, items: [CellModel]) {
        self = original
        self.items = items
    }
    
}


