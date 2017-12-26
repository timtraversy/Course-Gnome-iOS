//
//  SearchViewController.swift
//  Course Gnome
//
//  Created by Tim Traversy on 11/20/17.
//  Copyright © 2017 Tim Traversy. All rights reserved.
//

import UIKit
import RealmSwift

// prototype cell definitions
class SearchResultCell: UITableViewCell {
    @IBOutlet weak var searchResultTitle: UILabel!
}

class CategoryCell: UITableViewCell {
    @IBOutlet weak var categoryTitle: UILabel!
}

class SavedSearchResultCell: UITableViewCell {
    @IBOutlet weak var searchResultTitle: UILabel!
    @IBOutlet weak var searchResultSubtitle: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
}

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // pull local savedSearches
    let savedSearches = try! Realm().objects(SavedSearch.self)
    
    // set up arrays to hold results for different categories
    var departments = [String]()
    var crns = [String]()
    var instructors = [String]()
    //var statuses = [String]()
    var attributes = [String]()
    var names = [String]()
    var numbers = [String]()
    var allArrays = [String:[String]]()
    
    // set up variables to pass to next controller
    var selectedSearch = ""
    var selectedCategory = ""
    
    // holds user text entry
    var text = ""
    
    // define width of cancel button to move text view
    let cancelButtonSize: CGFloat = 70.0
    var screenWidth: CGFloat =  0.0
    
    // outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBox: UITextField!
    @IBOutlet weak var topBar: UIView!
    
    // on load, determine screen size and set up delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        screenWidth = UIScreen.main.bounds.width
        tableView.dataSource = self
        tableView.delegate = self
        searchBox.delegate = self
    }
    
    // update results so freshly saved search will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateResults()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchResultSegue" {
            let destinationViewController = segue.destination as? CourseListViewController
            destinationViewController?.selectedSearch = selectedSearch
            destinationViewController?.selectedCategory = selectedCategory
        }
    }
    
    // when user cancels, clear any entered text, resign keyboard, update table
    @IBAction func cancelSearchButton(_ sender: Any) {
        searchBox.text = ""
        searchBox.resignFirstResponder()
        updateResults()
    }
    
    // deletes saved search. get id tag from button, use it to find object
    @IBAction func searchResultDeleteButton(_ sender: UIButton) {
        let realm = try! Realm()
        realm.beginWrite()
        let savedSearchID = sender.tag
        let toDelete = realm.objects(SavedSearch.self).filter("id = \(savedSearchID)")
        realm.delete(toDelete)
        try! realm.commitWrite()
        updateResults()
    }
    
    // clears all arrays
    func deleteAllResults() {
        departments.removeAll()
        crns.removeAll()
//        statuses.removeAll()
        instructors.removeAll()
        names.removeAll()
        numbers.removeAll()
        attributes.removeAll()
        return
    }
    
    // update search results
    func updateResults() {
        
        // delete old result, get entered text, return if empty
        deleteAllResults()
        text = searchBox.text?.lowercased().trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\\", with: "") ?? ""
        if (text.count == 0) {
            self.tableView.reloadData()
            return
        }
        
        // set up predicates to query for strings containing or beginning with text
        let predicates =  [NSPredicate(format: "name beginswith [c]'\(text)'"), NSPredicate(format: "name contains [c]'\(text)' and not name beginswith [c]'\(text)'")]
        let courseNamePredicates = [NSPredicate(format: "courseName beginswith [c]'\(text)'"), NSPredicate(format: "courseName contains [c]'\(text)' and not courseName beginswith [c]'\(text)'")]
//        let subjectNumberPredicate = NSPredicate(format: "subjectNumber beginswith [c]'\(text)'")

        // in background do realm query
        DispatchQueue.global(qos: .background).async {
            var totalCount = 0
            let maxResults = 10
            let realm = try! Realm()
            mainRun: while(true) {
                
                /* algorithm: for each returned object (department, crn, etc),
                add it to that array, and increase the total count. If the max
                number of results is reached, stop the search (main run).
                Don't add if already a saved search. */
                
                for predicate in predicates {
                    for result in realm.objects(Department.self).filter(predicate) {
                        if (!realm.objects(SavedSearch.self).filter("search = %@", result.name).isEmpty) {
                            continue
                        }
                        self.departments.append(result.name)
                        totalCount += 1
                        if (totalCount == maxResults) { break mainRun }
                    }
                    /*for result in realm.objects(Status.self).filter(predicate) {
                        if (!realm.objects(SavedSearch.self).filter("search = %@", result.name).isEmpty) {
                            continue
                        }
                        self.statuses.append(result.name)
                        totalCount += 1
                        if (totalCount == maxResults) { break mainRun }
                    }*/
                    for result in realm.objects(Instructor.self).filter(predicate) {
                        if (!realm.objects(SavedSearch.self).filter("search = %@", result.name).isEmpty) {
                            continue
                        }
                        self.instructors.append(result.name)
                        totalCount += 1
                        if (totalCount == maxResults) { break mainRun }
                    }
                    for result in realm.objects(CourseAttribute.self).filter(predicate) {
                        if (!realm.objects(SavedSearch.self).filter("search = %@", result.name).isEmpty) {
                            continue
                        }
                        self.attributes.append(result.name)
                        totalCount += 1
                        if (totalCount == maxResults) { break mainRun }
                    }
                }
                for predicate in courseNamePredicates {
                    for result in realm.objects(Course.self).filter(predicate) {
                        if (!realm.objects(SavedSearch.self).filter("search = %@", result.courseName).isEmpty) {
                            continue
                        }
                        self.names.append(result.courseName)
                        totalCount += 1
                        if (totalCount == maxResults) { break mainRun }
                    }
                }
                for result in realm.objects(Course.self).filter("subjectNumber beginswith '\(self.text)'") {
                    if (!realm.objects(SavedSearch.self).filter("search = %@", result.subjectNumber).isEmpty) {
                        continue
                    }
                    self.numbers.append(result.subjectNumber)
                    totalCount += 1
                    if (totalCount == maxResults) { break mainRun }
                }
                // missing CRNS too UGH
                for result in realm.objects(CRN.self).filter(predicates[1]) {
                    if (!realm.objects(SavedSearch.self).filter("search = %@", result.name).isEmpty) {
                        continue
                    }
                    self.crns.append(result.name)
                    totalCount += 1
                    if (totalCount == maxResults) { break mainRun }
                }
                break mainRun
            }
            
            // back on main, reload table with new result info
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func userEnteredText(_ sender: Any) {
        updateResults()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        /* need row for each saved search and result, as well as one row
        for each category title */
        
        var categoryTitlesCount = 0
        if (!departments.isEmpty) { categoryTitlesCount += 1 }
        if (!crns.isEmpty) { categoryTitlesCount += 1 }
        //if (!statuses.isEmpty) { categoryTitlesCount += 1 }
        if (!instructors.isEmpty) { categoryTitlesCount += 1 }
        if (!names.isEmpty) { categoryTitlesCount += 1 }
        if (!numbers.isEmpty) { categoryTitlesCount += 1 }
        if (!attributes.isEmpty) { categoryTitlesCount += 1 }
        return (categoryTitlesCount+savedSearches.count+departments.count+crns.count+attributes.count+instructors.count+names.count+numbers.count)
        // statuses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row < savedSearches.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "savedSearchResult") as! SavedSearchResultCell
            cell.searchResultTitle?.text = savedSearches[indexPath.row].search
            cell.searchResultSubtitle?.text = savedSearches[indexPath.row].searchCategory
            cell.deleteButton.tag = savedSearches[indexPath.row].id
            return cell
        }
        
        var currentCount = savedSearches.count
        
        if (!departments.isEmpty) {
            if (indexPath.row == currentCount) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryCell
                cell.categoryTitle?.text = "DEPARTMENT"
                return cell
            }
            if (indexPath.row <= (currentCount+departments.count)) {
                currentCount += 1
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult") as! SearchResultCell
                cell.searchResultTitle?.attributedText = attributedText(withString: departments[indexPath.row - currentCount], boldString: text)
                cell.tag = 0
                return cell
            }
            currentCount += departments.count + 1
        }
        if (!crns.isEmpty) {
            if (indexPath.row == currentCount) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryCell
                cell.categoryTitle?.text = "CRN"
                return cell
            }
            if (indexPath.row <= (currentCount+crns.count)) {
                currentCount += 1
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult") as! SearchResultCell
                cell.searchResultTitle?.attributedText = attributedText(withString: crns[indexPath.row - currentCount], boldString: text)
                cell.tag = 1
                return cell
            }
            currentCount += crns.count + 1
        }
        /*if (!statuses.isEmpty) {
            if (indexPath.row == currentCount) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryCell
                cell.categoryTitle?.text = "STATUS"
                return cell
            }
            if (indexPath.row <= (currentCount+statuses.count)) {
                currentCount += 1
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult") as! SearchResultCell
                cell.searchResultTitle?.attributedText = attributedText(withString: statuses[indexPath.row - currentCount], boldString: text)
                cell.tag = 2
                return cell
            }
            currentCount += statuses.count + 1
        }*/
        if (!instructors.isEmpty) {
            if (indexPath.row == currentCount) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryCell
                cell.categoryTitle?.text = "INSTRUCTOR"
                return cell
            }
            if (indexPath.row <= (currentCount+instructors.count)) {
                currentCount += 1
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult") as! SearchResultCell
                cell.searchResultTitle?.attributedText = attributedText(withString: instructors[indexPath.row - currentCount], boldString: text)
                cell.tag = 3
                return cell
            }
            currentCount += instructors.count + 1
        }
        if (!names.isEmpty) {
            if (indexPath.row == currentCount) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryCell
                cell.categoryTitle?.text = "COURSE NAME"
                return cell
            }
            if (indexPath.row <= (currentCount+names.count)) {
                currentCount += 1
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult") as! SearchResultCell
                cell.searchResultTitle?.attributedText = attributedText(withString: names[indexPath.row - currentCount], boldString: text)
                cell.tag = 4
                return cell
            }
            currentCount += names.count + 1
        }
        if (!numbers.isEmpty) {
            if (indexPath.row == currentCount) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryCell
                cell.categoryTitle?.text = "SUBJECT NUMBER"
                return cell
            }
            if (indexPath.row <= (currentCount+numbers.count)) {
                currentCount += 1
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult") as! SearchResultCell
                cell.searchResultTitle?.attributedText = attributedText(withString: numbers[indexPath.row - currentCount], boldString: text)
                cell.tag = 5
                return cell
            }
            currentCount += numbers.count + 1
        }
        if (!attributes.isEmpty) {
            if (indexPath.row == currentCount) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryCell
                cell.categoryTitle?.text = "COURSE ATTRIBUTE"
                return cell
            }
            if (indexPath.row <= (currentCount+attributes.count)) {
                currentCount += 1
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult") as! SearchResultCell
                cell.searchResultTitle?.attributedText = attributedText(withString: attributes[indexPath.row - currentCount], boldString: text)
                cell.tag = 6
                return cell
            }
            currentCount += attributes.count + 1
        }
        // this will never be reached
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryCell
        return cell
    }
    
    func attributedText(withString string: String, boldString: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 16.0)!])
        let boldFontAttribute: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 16.0)!]
        let range = (string.lowercased() as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row < savedSearches.count) {
            selectedSearch = savedSearches[indexPath.row].search
            selectedCategory = savedSearches[indexPath.row].searchCategory
            performSegue(withIdentifier: "SearchResultSegue", sender: self)
        } else {
            let cell = tableView.cellForRow(at: indexPath) as! SearchResultCell
            selectedSearch = cell.searchResultTitle.text!
            
            let titleArray = ["Department", "CRN", "Status", "Instructor", "Course Name", "Subject Number", "Attributes"]
            selectedCategory = titleArray[cell.tag]
            
            let newSavedSearch = SavedSearch()
            newSavedSearch.search = selectedSearch
            newSavedSearch.searchCategory = selectedCategory
            
            let realm = try! Realm()
            newSavedSearch.id = (realm.objects(SavedSearch.self).max(ofProperty: "id") as Int? ?? 0) + 1
            realm.beginWrite()
            realm.add(newSavedSearch)
            try! realm.commitWrite()

            performSegue(withIdentifier: "SearchResultSegue", sender: self)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        UIView.animate(withDuration: 0.25) {
            textField.frame.size.width -= self.cancelButtonSize
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  //delegate method
        textField.resignFirstResponder()
        UIView.animate(withDuration: 0.25) {
            textField.frame.size.width += self.cancelButtonSize
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
}
