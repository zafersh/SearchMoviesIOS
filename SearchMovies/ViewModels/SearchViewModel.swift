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
import RxCocoa
import RxDataSources

/// View model for search view.
final class SearchViewModel {
    
    /// Provider used to make API calls.
    private let provider : MoyaProvider<APIService>
    
    /// Current loaded page number. (0 = no pages loaded yet as API consider 1 as first page)
    private var pageNo = 0
    
    /// Number of total pages available for current search results.
    private var totalPages = 0
    
    /// Movies retrieved from search API.
    private var movies = [Movie]()
    
    /// Suggestions retrieved from persistent store.
    private var suggestions = [Suggestion]()
    
    /// Models to be displayed at table view.
    private(set) var tableRows = BehaviorRelay<[SearchSectionModel]>(value: [SearchSectionModel]())
    
    /// Reference to last occured error.
    /// Search view controller will show an alert when error occurs.
    private(set) var error = BehaviorRelay<Error?>(value: nil)
    
    /// Boolean value indicates if next page is being loaded.
    private var isLoading = false
    
    /// Last search keyword. Used to load more pages.
    private var lastKeyword : String?
    
    /// Default constructor for this view model
    ///
    /// - Parameter provider: Provider used to make API calls.
    init(provider : MoyaProvider<APIService>) {
        self.provider = provider
    }
    
    /// Call search API with specified keyword.
    /// Once response is received and parsed UI will be updated as UI table view is drived by this view model.
    ///
    /// - Parameters:
    ///   - keyword: <#keyword description#>
    ///   - pageNo: <#pageNo description#>
    ///   - clearCurrent: <#clearCurrent description#>
    func searchFor(keyword : String, pageNo : Int, clearCurrent : Bool) {
        
        lastKeyword = keyword
        provider.request(APIService.search(keyword: keyword, pageNo: pageNo)) { (result) in
            switch result {
            case .success(let response):
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Short)
                    let apiResponse = try decoder.decode(APIResponse.self, from: response.data)
                    
                    // Update current page and total pages for pagination.
                    self.pageNo = apiResponse.pageNo
                    self.totalPages = apiResponse.totalPages
                    self.tableRows.accept([SearchSectionModel(items: (clearCurrent ? apiResponse.movies : self.tableRows.value[0].items + apiResponse.movies))])
                    
                    if apiResponse.movies.count > 0 {
                        // As the query was success, add it to persistent suggestions.
                        CoreDataStack.insertSuggestion(keyword: keyword)
                    } else {
                        // Inform the user that no movie is found.
                        self.error.accept(Error.movieNotFound)
                    }
                    
                } catch (let error){
                    print("Error: \(error.localizedDescription)")
                    // Inform the user of unknown error.
                    // It is not nice to tell the user that error occured while decoding JSON response or ....
                    // So a message of unknown error is better.
                    self.error.accept(Error.unknownError)
                }
                self.isLoading = false
                
            case .failure(let error):
                
                self.isLoading = false
                switch error {
                case .underlying(_, _):
                    self.error.accept(Error.noInternet)
                default:
                    // We can provide specific message or handling for different type of errors here if required.
                    self.error.accept(Error.unknownError)
                }
                
            }
        }
        
    }
    
    /// Load next page of search results if last page is not loaded yet and there is not active request for the same.
    func loadNextPageIfAvailable() {
        if pageNo < totalPages && isLoading == false && lastKeyword != nil {
            isLoading = true
            searchFor(keyword: lastKeyword!, pageNo: pageNo + 1, clearCurrent: false)
        }
    }
    
    /// Hide movies if they are listed, and show persistent suggestions.
    func showSuggestions(keyword : String) {
        // Persistent store is accessed only when search bar get focus.
        // Retrieved array are filtered while typing.
        self.suggestions = CoreDataStack.getSuggestion(filter: "", filterType: .contains)
        filterSuggestions(keyword: keyword)
    }
    
    /// Load filtered persistent suggestions using specified keyword.
    ///
    /// - Parameter keyword: a string to be used to filter suggestions.
    func filterSuggestions(keyword : String) {
        let filtered = keyword.isEmpty ? self.suggestions : self.suggestions.filter( { $0.keyword.contains(keyword) })
        self.tableRows.accept([SearchSectionModel(items: filtered)])
    }
    
}
