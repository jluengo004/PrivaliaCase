//
//  MainTableViewModel.swift
//  PrivaliaCase
//
//  Created by Marisa on 23/3/19.
//  Copyright © 2019 Jon. All rights reserved.
//

import Foundation

protocol MainTableViewModelDelegate: class {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
    func onFetchFailed(with reason: String)
}

final class MainTableViewModel {
    private weak var delegate: MainTableViewModelDelegate?
    
    private var movies: [Movie] = []
    private var currentPage = 1
    private var total = 0
    private var isFetchInProgress = false
    
    init(delegate: MainTableViewModelDelegate) {
        self.delegate = delegate
    }
    
    let client = ServerCall()
    
    var totalCount: Int {
        return total
    }
    
    var currentCount: Int {
        return movies.count
    }
    
    func movie(at index: Int) -> Movie {
        return movies[index]
    }

    func fetchMovies(requestType: RequestType, searchQuery: String?) {

        guard !isFetchInProgress else {
            return
        }
        isFetchInProgress = true
        
        client.fetchMovies(requestType: requestType, searchQuery: searchQuery) { result in
            switch result {
            
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isFetchInProgress = false
                    self.delegate?.onFetchFailed(with: error.reason)
                }
            
            case .success(let response):
                DispatchQueue.main.async {
                    self.currentPage += 1
                    self.isFetchInProgress = false
                    
                    self.total = response.total_results
//                    if response.page == 1{
//                        self.movies.removeAll()
//                    }
                    
                    self.movies.append(contentsOf: response.movies)
                    

                    if response.page > 1 {
                        let indexPathsToReload = self.calculateIndexPathsToReload(from: response.movies)
                        self.delegate?.onFetchCompleted(with: indexPathsToReload)
                    } else {
                        self.delegate?.onFetchCompleted(with: .none)
                    }
                }
                
            }
        }
    }
    
    private func calculateIndexPathsToReload(from newMovies: [Movie]) -> [IndexPath] {
        let startIndex = movies.count - newMovies.count
        let endIndex = startIndex + newMovies.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}
