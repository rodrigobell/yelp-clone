//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate {
    
    let userDefaults = UserDefaults.standard
    
    var businesses: [Business]!
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchBar = UISearchBar()
    
    var isMoreDataLoading = false
    var loadMoreOffset = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
                
        // Embed search bar in navigation controller
        searchBar.sizeToFit()
        searchBar.placeholder = "Search"
        self.navigationItem.titleView = self.searchBar
        let textFieldAppearance = UITextField.appearance()
        textFieldAppearance.keyboardAppearance = .light //.default//.light//.alert
        
        if let prevQuery = self.userDefaults.string(forKey: "searchQuery") {
            searchForBusinesses(query: prevQuery)
        }
        
    }
    
    func searchForBusinesses(query: String) {
        Business.searchWithTerm(term: query, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.tableView.reloadData()
            
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "business-cell", for: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchForBusinesses(query: searchBar.text!)
        
        searchBar.resignFirstResponder()
        
        userDefaults.set(searchBar.text!, forKey: "searchQuery")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: ProgressIndicator.defaultHeight)
                
                self.loadMoreOffset += 20
                loadMoreData()
            }
        }
    }
    
    func loadMoreData() {
        let prevQuery = self.userDefaults.string(forKey: "searchQuery")
        
        Business.searchWithTerm(term: prevQuery!, offset: loadMoreOffset, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.loadMoreOffset += 20
            
            self.businesses.append(contentsOf: businesses!)
            
            self.tableView.reloadData()
            
        })
        
        self.isMoreDataLoading = false
        
        self.tableView.reloadData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let business = businesses[indexPath!.row]
        
        let vc = segue.destination as! DetailsViewController
        vc.business = business
    }
    
}
