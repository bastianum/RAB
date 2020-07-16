//
//  GitTableViewController.swift
//  RAB
//
//  Created by Bastian Fischer on 16.07.20.
//  Copyright © 2020 com.bastianfischer. All rights reserved.
//

import UIKit

// Class for custom UITableViewCell
class GitTableViewCell: UITableViewCell {
    
    // Cell labels
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var privateLabel: UILabel!
    
}

// Class for main UITableViewController
class GitTableViewController: UITableViewController, UISearchBarDelegate {
    
    // Empty data object based on RAB model
    var dataObject: Git = []
    // Git user name, initialized with default value
    var gitUser: String = "rockabyte"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Intial setup
        tableView.rowHeight = 88
        self.clearsSelectionOnViewWillAppear = true
        
        self.setupSearchBar()
        self.setupRefreshControl()
        
        //Fetches default user data from API
        fetchData(endpoint: "https://api.github.com/users/" + gitUser + "/repos")
        
    }
    
    // MARK: - Network communication
    
    // Fetches JSON data from API and decodes into usable object
    func fetchData(endpoint: String){
        if let url = URL(string: endpoint) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else {
                    debugPrint("Error loading data", error ?? "Unknown error")
                    return
                }
                // Decodes data into Git object (based on model9
                do {
                    self.dataObject = try JSONDecoder().decode(Git.self, from: data)
                } catch {
                    print("User not found")
                }
                
                // Updates table view and ends refreshing (if active)
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                    self.refreshControl!.endRefreshing()
                }
            }.resume()
        }
    }
    
    
    // MARK: - Table view
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataObject.count
    }
    
    // Inititalizes custom cell and sets correct data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GitCell", for: indexPath) as! GitTableViewCell
        
        cell.fullNameLabel.text = dataObject[indexPath.row].fullName
        cell.urlLabel.text = dataObject[indexPath.row].url
        cell.updatedAtLabel.text = dataObject[indexPath.row].updatedAt
        
        if dataObject[indexPath.row].rabPrivate! {
            cell.privateLabel.text = "private"
        } else {
            cell.privateLabel.text = "public"
        }
        
        cell.languageLabel.text = dataObject[indexPath.row].language
        
        return cell
    }
    
    // Inititalizes and presents WebViewController when cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let webViewController = storyBoard.instantiateViewController(withIdentifier: "webViewController") as! WebViewController
        
        webViewController.url = dataObject[indexPath.row].url!
        
        self.present(webViewController, animated: true, completion: nil)
        
        // Deselects row
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    
    // MARK: - Search bar
    
    // Initializes searchController
    private var searchController = UISearchController(searchResultsController: nil)
    
    func setupSearchBar() {
        self.navigationItem.searchController = searchController
        searchController.searchBar.placeholder = "Search for git user"
        searchController.searchBar.delegate = self
    }
    
    // Triggers when seachButton is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        gitUser = searchBar.text!
        fetchData(endpoint: "https://api.github.com/users/" + gitUser + "/repos")
        searchController.isActive = false
    }
    
    //MARK: - Refresh control
    
    // Initializes pull to refresh functionality
    func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    // Triggers when refreshing
    @objc func refresh(_ sender: AnyObject) {
        fetchData(endpoint: "https://api.github.com/users/" + gitUser + "/repos")
    }
}
