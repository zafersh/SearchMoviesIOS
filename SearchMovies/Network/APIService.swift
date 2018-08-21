//
//  APIService.swift
//  SearchMovies
//
//  Created by Thafer Shahin on 8/21/18.
//  Copyright © 2018 Thafer Shahin. All rights reserved.
//

import Foundation
import Moya

// Used APIServices
enum APIService {
    
    static private let apiKey = "2696829a81b1b5827d515ff121700838"
    static let imagesBaseUrl = "http://image.tmdb.org/t/p/"
    
    case search(keyword : String)
}

// Search movies API configurations.
extension APIService : TargetType {
    var baseURL: URL {
        switch self {
        case .search(_):
            return URL(string: "http://api.themoviedb.org/3/search")!
        }
    }
    
    var path: String {
        switch self {
        case .search:
            return "/movie"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .search:
            return .get
        }
    }
    
    var sampleData: Data {
        return "No sample data so far".data(using: .utf8)!
    }
    
    public var task: Task {
        switch self {
        case .search(let keyword):
            return .requestParameters(
                parameters: [
                    "api_key": APIService.apiKey,
                    "page": 1,
                    "query": keyword],
                encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }
    
    
}
