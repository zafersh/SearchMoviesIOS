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
        
        // Enable table view automatic row height estimation.
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        
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
            self.viewModel.searchFor(keyword: keyword.trimmingCharacters(in: .whitespacesAndNewlines), pageNo: 1, clearCurrent: true)
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
        
        // Load next results page when scroll to bottom.
        self.tableView.rx.contentOffset.asObservable().subscribe(onNext: { (point) in
            // If scroll bottom enought near edge of content, load next page.
            if point.y + self.tableView.frame.size.height + 30 > self.tableView.contentSize.height {
                self.viewModel.loadNextPageIfAvailable()
            }
        }).disposed(by: disposeBag)
        
        // Handle tapping table's row.
        self.tableView.rx.itemSelected.map { indexPath in
            return self.dataSource[indexPath]
            }.subscribe(onNext: { model in
                if let _ = model as? Movie {
                    // So far, nothing required to do yet.
                    
                } else if let suggestion = model as? Suggestion {
                    self.viewModel.searchFor(keyword: suggestion.keyword, pageNo: 1, clearCurrent: true)
                    self.searchBar.text = suggestion.keyword
                    self.view.endEditing(true)
                }
        }).disposed(by: disposeBag)
        
        // Show an alert when an error occurs.
        self.viewModel.error.asDriver().drive(onNext: { (error) in
            guard error != nil else {return}
            let alertView = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error?.localizedError(), preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
            })
            self.present(alertView, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

