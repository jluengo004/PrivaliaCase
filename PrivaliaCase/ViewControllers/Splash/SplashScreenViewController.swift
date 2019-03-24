//
//  SplashScreenViewController.swift
//  PrivaliaCase
//
//  Created by Marisa on 24/3/19.
//  Copyright © 2019 Jon. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController, MainTableViewModelDelegate, AlertDisplayer {
    
    
    
    private var viewModel: MainTableViewModel!
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.startAnimating()
        
        viewModel = MainTableViewModel.init(delegate: self)
        viewModel.fetchMovies(requestType: RequestType.DISCOVER, searchQuery: nil)
    }
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        self.performSegue(withIdentifier: "toMainTable", sender: nil)
    }
    
    func onFetchFailed(with reason: String) {
        let title = "Warning"
        let action = UIAlertAction(title: "OK", style: .default)
        displayAlert(with: title , message: reason, actions: [action])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextNavigationController = segue.destination as? UINavigationController{
            if let nextViewController = nextNavigationController.viewControllers.first as? MainTableViewController{
                nextViewController.viewModel = viewModel
            }
        }
    }

}
