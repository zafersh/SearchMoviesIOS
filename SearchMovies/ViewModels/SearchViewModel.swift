//
//  SearchViewModel.swift
//  SearchMovies
//
//  Created by Thafer Shahin on 8/21/18.
//  Copyright © 2018 Thafer Shahin. All rights reserved.
//

import Foundation
import Moya
import RxSwift

/// View model for search view.
final class SearchViewModel {
    
    /// Provider used to make API calls.
    private let provider : MoyaProvider<APIService>
    
    /// Current loaded page number. (0 = no pages loaded yet as API consider 1 as first page)
    private var pageNo = 0
    
    /// Number of total pages available for current search results.
    private var totalPages = 0
    
    /// Movies retrieved from search API.
    private(set) var movies = Variable<[Movie]>([])
    
    /// Default constructor for this view model
    ///
    /// - Parameter provider: Provider used to make API calls.
    init(provider : MoyaProvider<APIService>) {
        self.provider = provider
    }
    
    /// Call search API with specified keyword.
    /// Once response is received and parsed UI will be updated as UI table view is drived by this view model.
    ///
    /// - Parameter keyword: a string to search for.
    func searchFor(keyword : String) {
        // As this a search for a new key word, it will always starts with first page.
        provider.request(APIService.search(keyword: keyword)) { (result) in
            switch result {
            case .success(let response):
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Short)
                    let apiResponse = try decoder.decode(APIResponse.self, from: response.data)
                    
                    // Update current page and total pages for pagination.
                    self.pageNo = apiResponse.pageNo
                    self.totalPages = apiResponse.totalPages
                    self.movies.value = apiResponse.movies
                    
                    // As the query was success, add it to persistent suggestions.
                    CoreDataStack.insertSuggestion(keyword: keyword)
                    
                } catch (let error){
                    print("Error: \(error.localizedDescription)")
                }
                
            case .failure(let error):
                print("Error \(error)")
            }
        }
        
    }
    
    /// Load filtered persistent suggestions using specified keyword.
    ///
    /// - Parameter keyword: a string to be used to filter suggestions.
    func filterSuggestions(keyword : String) {
        print("filterSuggestions: \(keyword)")
    }
    
}
