//
//  SearchViewController.swift
//  SearchMovies
//
//  Created by Thafer Shahin on 8/21/18.
//  Copyright © 2018 Thafer Shahin. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa

/// UIViewController for search view which is the root view for this app.
class SearchViewController: UIViewController {
    
    // MARK: - SearchViewController
    
    /// IBOutlet to search bar.
    @IBOutlet weak var searchBar: UISearchBar!
    
    /// IBOutlet to table view used to show search suggestions and results.
    @IBOutlet weak var tableView: UITableView!
    
    /// Associated view model.
    let viewModel = SearchViewModel(provider: MoyaProvider())
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Subscribe to search button clicked signal to do search API call.
        self.searchBar.rx.searchButtonClicked.subscribe(onNext: { () in
            // Make sure thay keyword is not empy.
            let keyword = self.searchBar.text ?? ""
            guard keyword.count > 0 else {
                // TODO: Show error alert.
                return
            }
            // Hide keyboard.
            self.view.endEditing(true)
            self.viewModel.searchFor(keyword: keyword)
        }).disposed(by: disposeBag)
        
        // Subscribe to search bar begin editing to show persistent suggestions.
        self.searchBar.rx.textDidBeginEditing.subscribe(onNext: { () in
            // TODO: Show suggestions.
            print("+++ Show suggestions")
        }).disposed(by: disposeBag)
        
        // Subscribe to search bar end editting to hide persistent suggestions.
        self.searchBar.rx.textDidEndEditing.subscribe(onNext: { () in
            // TODO: Hide suggestions.
            print("--- Hide suggestions")
        }).disposed(by: disposeBag)
        
        // Subscribe to changes in search keyword to filter suggestions.
        self.searchBar.rx.text.orEmpty
            .subscribe(onNext: { (keyword) in
            self.viewModel.filterSuggestions(keyword: keyword)
        }).disposed(by: disposeBag)
        
        self.viewModel.movies.asObservable().bind(to: tableView.rx.items(cellIdentifier: String(describing: MovieTableViewCell.self), cellType: MovieTableViewCell.self)) { row, movie, cell in
            cell.nameLabel.text = movie.name
            cell.dateLabel.text = DateFormatter.formattedMedium(date: movie.releaseDate)
            cell.overviewLabel.text = movie.overview
        }.disposed(by: disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

