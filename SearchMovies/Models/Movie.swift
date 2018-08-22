//
//  Movie.swift
//  SearchMovies
//
//  Created by Thafer Shahin on 8/21/18.
//  Copyright © 2018 Thafer Shahin. All rights reserved.
//

import Foundation

/// Model for Movie.
struct Movie : Codable, CellModel {
    
    /// Relative URL string to movie's poster.
    let poster : String?
    
    /// Movie's name.
    let name : String
    
    /// Movie's release date.
    let releaseDate : Date?
    
    /// Movie's overview.
    let overview : String?
    
    /// Coding keys used to match model properties with API response attributes.
    private enum CodingKeys: String, CodingKey {
        case poster = "poster_path"
        case name = "title"
        case releaseDate = "release_date"
        case overview
    }
    
    /// This constructor is required to handle cases when some attributes are not available.
    ///
    /// - Parameter decoder: <#decoder description#>
    /// - Throws: <#throws value description#>
    public init(from decoder : Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            name = try container.decode(String.self, forKey: .name)
        } catch {
            name = ""
        }
        do {
            poster = try container.decode(String.self, forKey: .poster)
        } catch {
            poster = ""
        }
        do {
        overview = try container.decode(String.self, forKey: .overview)
        } catch {
            overview = ""
        }
        do {
            releaseDate = try container.decode(Date.self, forKey: .releaseDate)
        } catch {
            // In case release date is not available.
            releaseDate = nil
        }
    }
    
}

// MARK: - Poster Size

/// Enum for possible images sized at the server.
///
/// - w92: <#w92 description#>
/// - w185: <#w185 description#>
/// - w500: <#w500 description#>
/// - w780: <#w780 description#>
enum ImageSize : String {
    case width92 = "w92"
    case width185 = "w185"
    case width500 = "w500"
    case width780 = "w780"
}

extension Movie {
    
    /// Creates URL for this movie poster according to specified size.
    ///
    /// - Parameter size: <#size description#>
    /// - Returns: <#return value description#>
    func posterUrlFor(size : ImageSize) -> URL? {
        guard let poster = self.poster else {return nil}
        let urlString = "\(APIService.imagesBaseUrl)\(size.rawValue)\(poster)"
        return URL(string: urlString)
    }
    
}
