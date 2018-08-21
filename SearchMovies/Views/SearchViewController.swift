//
//  SearchViewController.swift
//  SearchMovies
//
//  Created by Thafer Shahin on 8/21/18.
//  Copyright © 2018 Thafer Shahin. All rights reserved.
//

import UIKit


/// UIViewController for search view which is the root view for this app.
class SearchViewController: UIViewController {
    
    // MARK: - SearchViewController
    
    /// IBOutlet to search bar.
    @IBOutlet weak var searchBar: UISearchBar!
    
    /// IBOutlet to table view used to show search suggestions and results.
    @IBOutlet weak var tableView: UITableView!
    
    /// Associated view model.
    let viewModel = SearchViewModel()
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

