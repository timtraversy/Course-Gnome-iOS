//
//  SearchViewController.swift
//  Course Gnome
//
//  Created by Tim Traversy on 11/20/17.
//  Copyright © 2017 Tim Traversy. All rights reserved.
//

import UIKit
import RealmSwift

class SearchResultCell: UITableViewCell {
    @IBOutlet weak var searchResultTitle: UILabel!
    @IBOutlet weak var searchResultSubtitle: UILabel!
}

class SavedSearchResultCell: UITableViewCell {
    @IBOutlet weak var searchResultTitle: UILabel!
    @IBOutlet weak var searchResultSubtitle: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
}

// store search result data
struct SearchResult {
    let searchResultTitle: String
    let searchResultSubtitle: String
}

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    // open realm
    let realm = try! Realm()
    
    //return all courses, empty filtered result object, and saved searches
    let results = try! Realm().objects(Course.self)
    let savedSearches = try! Realm().objects(SavedSearch.self)
    var filteredResults = try! Realm().objects(Course.self).filter("status contains 'x'")
    var searchResults = [SearchResult]()
    let searchTermsOne = ["instructors.name": "Instructor", "courseAttributes.attribute": "Course Attribute"]
    let searchTermsTwo = ["subjectName": "Department", "status": "Status", "crn": "CRN", "subjectNumber": "Subject Number", "courseName": "Course Name"]
    
    // define width of cancel button to move text view
    let cancelButtonSize: CGFloat = 70.0
    var searchFocused = false
    
    // outlets
    @IBOutlet weak var tableView: SearchResults!
    @IBOutlet weak var searchBox: UITextField!
    var screenWidth: CGFloat =  0.0
    @IBOutlet weak var topBar: UIView!
    
    // load
    override func viewDidLoad() {
        super.viewDidLoad()
        screenWidth = UIScreen.main.bounds.width
        tableView.dataSource = self
        tableView.delegate = self
        tabBarController?.tabBar.isHidden = false;
        searchBox.becomeFirstResponder()
    }
    
    //actions
    @IBAction func searchBoxTouched(_ sender: Any, forEvent event: UIEvent) {
        // shrink box unless user already focused on it
        if (!searchFocused) {
            searchBox.frame.size.width -= cancelButtonSize
            searchFocused = true
        }
    }
    
    @IBAction func cancelSearchButton(_ sender: Any) {
        searchBox.frame.size.width += cancelButtonSize
        searchBox.text = ""
        searchBox.resignFirstResponder()
        searchFocused = true
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
    
    @IBAction func unwindToMainMenu(segue: UIStoryboardSegue) {
        
    }
    
    func updatedFilteredResults() {
        guard let text = searchBox.text?.lowercased().trimmingCharacters(in: .whitespaces) else {
            return
        }
        
        searchResults.removeAll()
        if (text.count < 2) {
            filteredResults = results.filter("status contains 'x'")
            self.tableView.reloadData()
            return
        }
        var tempResultTitles = [String]()
        
        for (term,termTitle) in searchTermsTwo {
            let subjectNamePredicate = NSPredicate(format: "\(term) beginswith [c]'\(text)'")
            filteredResults = results.filter(subjectNamePredicate)
            resultLoop: for result in filteredResults {
                for title in tempResultTitles {
                    if (result[term] as! String == title) {
                        continue resultLoop
                    }
                }
                tempResultTitles.append(result[term] as! String)
            }
            for title in tempResultTitles {
                searchResults.append(SearchResult(searchResultTitle: title, searchResultSubtitle: termTitle))
            }
            tempResultTitles.removeAll()
        }
        
        for (term,termTitle) in searchTermsTwo {
            let subjectNamePredicate = NSPredicate(format: "\(term) contains [c]'\(text)' and not \(term) beginswith [c]'\(text)'")
            filteredResults = results.filter(subjectNamePredicate)
            resultLoop: for result in filteredResults {
                for title in tempResultTitles {
                    if (result[term] as! String == title) {
                        continue resultLoop
                    }
                }
                tempResultTitles.append(result[term] as! String)
            }
            for title in tempResultTitles {
                searchResults.append(SearchResult(searchResultTitle: title, searchResultSubtitle: termTitle))
            }
            tempResultTitles.removeAll()
        }
        
        for (term,termTitle) in searchTermsOne {
            let subjectNamePredicate = NSPredicate(format: "ANY \(term) beginswith [c]'\(text)'")
            filteredResults = results.filter(subjectNamePredicate)
            resultLoop: for result in filteredResults {
                if (termTitle == "Instructor") {
                    for instructor in result.instructors {
                        if (!instructor.name.lowercased().hasPrefix(text)) {
                            continue
                        }
                        for title in tempResultTitles {
                            if (instructor.name == title) {
                                continue resultLoop
                            }
                        }
                        tempResultTitles.append(instructor.name)
                    }
                }
                else {
                    for attribute in result.courseAttributes {
                        if (!attribute.attribute.lowercased().hasPrefix(text)) {
                            continue
                        }
                        for title in tempResultTitles {
                            if (attribute.attribute == title) {
                                continue resultLoop
                            }
                        }
                        tempResultTitles.append(attribute.attribute)
                    }
                }
            }
            for title in tempResultTitles {
                searchResults.append(SearchResult(searchResultTitle: title, searchResultSubtitle: termTitle))
            }
            tempResultTitles.removeAll()
        }
        self.tableView.reloadData()
    }
    
    @IBAction func userEnteredText(_ sender: Any) {
        updatedFilteredResults()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let x = searchResults.count+savedSearches.count
        return (searchResults.count+savedSearches.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row < savedSearches.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "savedSearchResult") as! SavedSearchResultCell
            cell.searchResultTitle?.text = savedSearches[indexPath.row].search
            cell.searchResultSubtitle?.text = savedSearches[indexPath.row].searchCategory
            cell.deleteButton.tag = indexPath.row
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult") as! SearchResultCell
            let newRow = indexPath.row - savedSearches.count
            cell.searchResultTitle?.text = searchResults[newRow].searchResultTitle
            cell.searchResultSubtitle?.text = searchResults[newRow].searchResultSubtitle
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row < savedSearches.count) {
        } else {
            let realm = try! Realm()
            realm.beginWrite()
            let newSavedSearch = SavedSearch()
            let newRow = indexPath.row - savedSearches.count
            newSavedSearch.search = searchResults[newRow].searchResultTitle
            newSavedSearch.searchCategory = searchResults[newRow].searchResultSubtitle
            realm.add(newSavedSearch)
            try! realm.commitWrite()
            tableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
