//
//  MainTableViewController.swift
//  PrivaliaCase
//
//  Created by Marisa on 23/3/19.
//  Copyright © 2019 Jon. All rights reserved.
//

import UIKit

class MainTableViewController: UIViewController, MainTableViewModelDelegate, AlertDisplayer {
    public var viewModel: MainTableViewModel!
    
    private var previousSearch = ""
    private var shouldShowLoadingCell = false
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Privalia Movies"
        
        tableView.prefetchDataSource = self
        tableView.dataSource = self
        tableView.estimatedSectionHeaderHeight = 30
        tableView.keyboardDismissMode = .onDrag
        tableView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.5)
        
        searchControllerSetUp()
        
        viewModel.delegate = self
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    func searchControllerSetUp(){
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        searchController.searchBar.backgroundColor = UIColor.black
        searchController.searchBar.tintColor = UIColor.white
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    // MARK: - Table view data source
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= viewModel.currentCount
    }
    
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            tableView.isHidden = false
            if viewModel.isNewSearch{
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
            tableView.reloadData()
            return
        }
        
        tableView.reloadRows(at: newIndexPathsToReload, with: .automatic)
    }
    
    func onFetchFailed(with reason: String) {
        let title = "Warning"
        let action = UIAlertAction(title: "OK", style: .default)
        displayAlert(with: title , message: reason, actions: [action])
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isSearching() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func requestVarsByType() -> (RequestType , String?){
        var requestType = RequestType.DISCOVER
        var query: String?
        if isSearching(){
            requestType = RequestType.SEARCH
            query = searchController.searchBar.text!
        }
        return (requestType, query)
    }
}

extension MainTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.searchBar.text != "" {
            return ("Movies containing: " + searchController.searchBar.text!)
        }else{
            return "Most popular movies"
        }
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalCount
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell",
                                                 for: indexPath) as! MainTableViewCell
        
        if isLoadingCell(for: indexPath) {
            cell.configure(with: .none)
        } else {
            cell.configure(with: viewModel.movie(at: indexPath.row))
        }
        return cell
    }
}

extension MainTableViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            let requestType = requestVarsByType().0
            let query = requestVarsByType().1
            DispatchQueue.global().async() {
                self.viewModel.fetchMovies(requestType: requestType, searchQuery: query)
            }
        }
    }
}

extension MainTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if previousSearch != "" {
            previousSearch = ""
            DispatchQueue.global().async() {
                self.viewModel.fetchMovies(requestType: RequestType.DISCOVER, searchQuery: nil)
            }
        }
    }
}

extension MainTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let requestType = requestVarsByType().0
        let query = requestVarsByType().1
        if query != nil{
            previousSearch = query!
            DispatchQueue.global().async() {
                self.viewModel.fetchMovies(requestType: requestType, searchQuery: query)
            }
        }else if previousSearch != "" {
            previousSearch = ""
            DispatchQueue.global().async() {
                self.viewModel.fetchMovies(requestType: RequestType.DISCOVER, searchQuery: nil)
            }
        }
    }
}
