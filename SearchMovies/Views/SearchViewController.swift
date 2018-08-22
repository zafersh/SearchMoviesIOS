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
import RxDataSources
import Kingfisher

/// UIViewController for search view which is the root view for this app.
class SearchViewController: UIViewController {
    
    // MARK: - SearchViewController
    
    /// IBOutlet to search bar.
    @IBOutlet weak var searchBar: UISearchBar!
    
    /// IBOutlet to table view used to show search suggestions and results.
    @IBOutlet weak var tableView: UITableView!
    
    /// Associated view model.
    let viewModel = SearchViewModel(provider: MoyaProvider())
    
    /// Dispose bag for all used observables subscriptions.
    private let disposeBag = DisposeBag()
    
    /// Table view data source to provide Movie or Suggestion cell.
    let dataSource = RxTableViewSectionedReloadDataSource<SearchSectionModel>(
        configureCell: { (_, tv, indexPath, model) in
            
            // Populate UI table cell.
            var cell = tv.dequeueReusableCell(withIdentifier: String(describing: SuggestionTableViewCell.self))!
            if let movie = model as? Movie {
                let movieCell = tv.dequeueReusableCell(withIdentifier: String(describing: MovieTableViewCell.self))! as! MovieTableViewCell
                movieCell.nameLabel.text = movie.name
                movieCell.dateLabel.text = movie.releaseDate != nil ? DateFormatter.formattedMedium(date: movie.releaseDate!) : NSLocalizedString("Not available", comment: "Not available")
                movieCell.overviewLabel.text = movie.overview
                movieCell.movieImageView.kf.setImage(with: movie.posterUrlFor(size: .width92))
                cell = movieCell
            } else if let suggestion = model as? Suggestion {
                let suggestionCell = tv.dequeueReusableCell(withIdentifier: String(describing: SuggestionTableViewCell.self))!
                suggestionCell.textLabel?.text = suggestion.keyword
                cell = suggestionCell
            }
            return cell
            
    }
    )
    
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
            self.viewModel.showSuggestions(keyword: self.searchBar.text!)
        }).disposed(by: disposeBag)
        
        // Subscribe to changes in search keyword to filter suggestions.
        self.searchBar.rx.text.orEmpty
            .subscribe(onNext: { (keyword) in
            self.viewModel.filterSuggestions(keyword: keyword)
        }).disposed(by: disposeBag)
        
        // Bind table view to table view model.
        self.viewModel.tableRows.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        // Handle tapping table's row.
        self.tableView.rx.itemSelected.map { indexPath in
            return self.dataSource[indexPath]
            }.subscribe(onNext: { model in
                if let _ = model as? Movie {
                    // So far, nothing required to do yet.
                    
                } else if let suggestion = model as? Suggestion {
                    self.viewModel.searchFor(keyword: suggestion.keyword)
                    self.searchBar.text = suggestion.keyword
                    self.view.endEditing(true)
                }
        }).disposed(by: disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

