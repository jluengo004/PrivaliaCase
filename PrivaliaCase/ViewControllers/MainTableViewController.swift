//
//  MainTableViewController.swift
//  PrivaliaCase
//
//  Created by Marisa on 23/3/19.
//  Copyright © 2019 Jon. All rights reserved.
//

import UIKit

class MainTableViewController: UIViewController, MainTableViewModelDelegate {
    private var viewModel: MainTableViewModel!
    
    private var shouldShowLoadingCell = false
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Privalia Movie"
        tableView.prefetchDataSource = self
        
//        indicatorView.color = ColorPalette.RWGreen
//        indicatorView.startAnimating()
        
        tableView.isHidden = true
        tableView.dataSource = self
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        viewModel = MainTableViewModel.init(delegate: self)
        viewModel.fetchMovies(requestType: RequestType.DISCOVER, searchQuery: nil)
    }

    // MARK: - Table view data source
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= viewModel.currentCount
    }
    
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
//            indicatorView.stopAnimating()
            tableView.isHidden = false
            tableView.reloadData()
            return
        }
        tableView.reloadRows(at: newIndexPathsToReload, with: .automatic)
    }
    
    func onFetchFailed(with reason: String) {
//        indicatorView.stopAnimating()
        
        let title = "Warning"
        let action = UIAlertAction(title: "OK", style: .default)
        createAlert(with: title , message: reason, actions: [action])
    }
    
    func createAlert(with title: String, message: String, actions: [UIAlertAction]? = nil) {
        guard presentedViewController == nil else {
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions?.forEach { action in
            alertController.addAction(action)
        }
        present(alertController, animated: true)
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
    func tableView(tableView: UITableView,
                   heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 400
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
            viewModel.fetchMovies(requestType: requestType, searchQuery: query)
        }
    }
}

extension MainTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.viewModel.fetchMovies(requestType: RequestType.DISCOVER, searchQuery: nil)
    }
}

extension MainTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let requestType = requestVarsByType().0
        let query = requestVarsByType().1
        if query != nil{
            self.viewModel.fetchMovies(requestType: requestType, searchQuery: query)
        }
    }
}
