//
//  SearchViewController.swift
//  Course Gnome
//
//  Created by Tim Traversy on 11/20/17.
//  Copyright © 2017 Tim Traversy. All rights reserved.
//

import UIKit
import RealmSwift

class SearchResult: UITableViewCell {
    @IBOutlet weak var searchResultTitle: UILabel!
    @IBOutlet weak var searchResultSubtitle: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
}

class SearchViewController: UIViewController, UITableViewDataSource {
    
    // open realm
    let realm = try! Realm()
    let results = try! Realm().objects(Course.self)
    var filteredResults = try! Realm().objects(Course.self)
    
    // define width of cancel button to move text view
    let cancelButtonSize: CGFloat = 70.0

    //outlets
    @IBOutlet weak var tableView: SearchResults!
    @IBOutlet weak var searchBox: UITextField!
    var screenWidth: CGFloat =  0.0
    @IBOutlet weak var topBar: UIView!
    
    //actions
    @IBAction func searchBoxTouched(_ sender: Any, forEvent event: UIEvent) {
        searchBox.frame.size.width -= cancelButtonSize
    }
    
    @IBAction func cancelSearchButton(_ sender: Any) {
        searchBox.frame.size.width += cancelButtonSize
        searchBox.text = ""
        searchBox.resignFirstResponder()
        updatedFilteredResults()
    }
    
    @IBAction func searchResultDeleteButton(_ sender: UIButton) {
        /*print (candies[sender.tag])
        let givenCandy = filteredCandies[sender.tag]
        for (index, candy) in candies.enumerated() {
            if (candy == givenCandy) {
                candies.remove(at: index)
                updateFilteredCandies()
                break
            }
        }*/
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenWidth = UIScreen.main.bounds.width
        tableView.dataSource = self
        self.tabBarController?.tabBar.isHidden = false;
    }
    
    @IBAction func unwindToMainMenu(segue: UIStoryboardSegue) {
        
    }
    
    func updatedFilteredResults() {
        if let text = searchBox.text?.lowercased() {
            if (text == "") {
                filteredResults = results
                self.tableView.reloadData()
                return
            }
            let predicate = NSPredicate(format: "courseName contains [c]'\(text)'")
            filteredResults = results.filter(predicate)
            self.tableView.reloadData()
        }
    }
    
    @IBAction func userEnteredText(_ sender: Any) {
        updatedFilteredResults()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult") as! SearchResult
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        
        let text = filteredResults[indexPath.row].courseName
        let text2 = filteredResults[indexPath.row].subjectNumber
        cell.searchResultTitle?.text = text
        cell.deleteButton.tag = indexPath.row
        cell.searchResultSubtitle?.text = text2
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
