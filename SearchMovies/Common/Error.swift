//
//  Error.swift
//  SearchMovies
//
//  Created by Thafer Shahin on 8/22/18.
//  Copyright © 2018 Thafer Shahin. All rights reserved.
//

import Foundation
import UIKit




/// This class will hold all expected errors to be handled.
///
/// - noInternet: <#noInternet description#>
/// - movieNotFound: <#movieNotFound description#>
/// - unknownError: <#unknownError description#>
enum Error  {
    case noInternet
    case movieNotFound
    case unknownError
    case invalidKeyword
    
    /// Provided localized description of the error.
    ///
    /// - Returns: <#return value description#>
    func localizedError() -> String {
        switch self {
        case .noInternet:
            return NSLocalizedString("Please make sure your phone is connected to the internet.", comment: "")
        case .movieNotFound:
            return NSLocalizedString("Unfortunately, we find nothing for you.", comment: "")
        case .unknownError:
            return NSLocalizedString("Oops... something wrong happened", comment: "")
        case .invalidKeyword:
            return NSLocalizedString("Please enter a valid keyword", comment: "")
        }
    }
}
