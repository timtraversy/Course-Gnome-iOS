//
//  FilterViewController.swift
//  Course Gnome
//
//  Created by Tim Traversy on 12/21/17.
//  Copyright © 2017 Tim Traversy. All rights reserved.
//

import UIKit
import SearchTextField
import SwiftRangeSlider

class RedButton: UIButton {
    override open var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.25) {
                self.backgroundColor = self.isSelected ? UIColor(named: "Red") : UIColor.white
            }
        }
    }
}

class FilterViewController: UIViewController {
    
    var selectedSearches: [String:String]!
    
    @IBOutlet var buttonsToOutline: [UIButton]!
    
    @IBOutlet var allSwitches: [RedButton]!
    @IBOutlet var sortBySwitches: [RedButton]!
    @IBOutlet var timeSwitches: [RedButton]!
    @IBOutlet var creditSwitches: [RedButton]!
    
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var waitlistButton: UIButton!
    @IBOutlet weak var closedButton: UIButton!
    @IBOutlet var statusButtons: [RedButton]!
    
    @IBOutlet weak var fitSwitch: UISwitch!
    
    @IBOutlet var dayButton: [RedButton]!
    
    @IBOutlet weak var timeSlider: RangeSlider!
    
    @IBOutlet weak var departmentField: SearchTextField!
    @IBOutlet weak var instructorField: SearchTextField!
    @IBOutlet weak var attributeField: SearchTextField!
    
    @IBOutlet var autoCompleteFields: [SearchTextField]!
    
    @IBAction func buttonSwitched(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func sortSwitchSelected(_ sender: UIButton) {
        if (!sender.isSelected) {
            for sortSwitch in sortBySwitches {
                sortSwitch.isSelected = false
            }
            sender.isSelected = true
        }
    }
    
    @IBAction func timeSwitchSelected(_ sender: RedButton) {
        if (!sender.isSelected) {
            for timeSwitch in timeSwitches {
                timeSwitch.isSelected = false
            }
            sender.isSelected = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load current filters
        // load sort
//        for sortSwitch in sortBySwitches {
//            sortSwitch.isSelected = false
//        }
        if (selectedSearches["Sort By"] == "subjectNumber") {
            sortBySwitches[0].isSelected = true
        } else {
            sortBySwitches[1].isSelected = true
        }
        
        // load status
        if (selectedSearches["Status"]?.contains("Open")) ?? false {
            openButton.isSelected = true
        }
        if (selectedSearches["Status"]?.contains("Waitlist")) ?? false  {
            waitlistButton.isSelected = true
        }
        if (selectedSearches["Status"]?.contains("Closed")) ?? false {
            closedButton.isSelected = true
        }
        
        //load days
        let daysArray = selectedSearches["Days"]!.components(separatedBy: " ")
        for timeSwitch in timeSwitches {
            timeSwitch.isSelected = false
        }
        if (daysArray[0] == "O") {
            timeSwitches[1].isSelected = true
        } else {
            timeSwitches[0].isSelected = true
        }
        
        if (daysArray[1] == "true") {
            dayButton[0].isSelected = true
        }
        if (daysArray[2] == "true") {
            dayButton[1].isSelected = true
        }
        if (daysArray[3] == "true") {
            dayButton[2].isSelected = true
        }
        if (daysArray[4] == "true") {
            dayButton[3].isSelected = true
        }
        if (daysArray[5] == "true") {
            dayButton[4].isSelected = true
        }
        
        for button in buttonsToOutline {
            button.layer.borderColor = UIColor(named: "Red")?.cgColor
            button.layer.borderWidth = 1.0
            button.layer.cornerRadius = 3.0
        }
        
        for sortSwitch in allSwitches {
            sortSwitch.setTitleColor(UIColor(named: "Red"), for: UIControlState.normal)
            sortSwitch.setTitleColor(UIColor.white, for: UIControlState.selected)
        }
        
        fitSwitch.tintColor = UIColor.lightGray
        fitSwitch.layer.cornerRadius = 16
        fitSwitch.backgroundColor = UIColor.lightGray
                
        let deptStrings = PersistanceManager().getCategory(type: PersistanceManager.category.Department)
        departmentField.filterStrings(deptStrings)
        
        let instructorStrings = PersistanceManager().getCategory(type: PersistanceManager.category.Instructor)
        instructorField.filterStrings(instructorStrings)
        
        let attributeStrings = PersistanceManager().getCategory(type: PersistanceManager.category.CourseAttribute)
        attributeField.filterStrings(attributeStrings)
        
        for field in autoCompleteFields {
            field.theme.font = UIFont(name: "AvenirNext-Regular", size: 13.0)!
            field.highlightAttributes = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 13.0)!]
            field.theme.bgColor = UIColor.white
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "CancelSegue") { return }
        if (sortBySwitches[0].isSelected) {
            selectedSearches["Sort By"] = "subjectNumber"
        } else  {
            selectedSearches["Sort By"] = "department.name"
        }
        selectedSearches["Status"] = ""
        if (openButton.isSelected) {
            selectedSearches["Status"]?.append("Open ")
        }
        if (waitlistButton.isSelected) {
            selectedSearches["Status"]?.append("Waitlist ")
        }
        if (closedButton.isSelected) {
            selectedSearches["Status"]?.append("Closed ")
        }
        selectedSearches["Days"] = ""
        var dayBooleans = ""
        if (timeSwitches[0].isSelected) {
            dayBooleans.append("E ")
        } else {
            dayBooleans.append("O ")
        }
        for button in dayButton {
            if (button.isSelected) {
                dayBooleans.append("true ")
            } else {
                dayBooleans.append("false ")
            }
        }
        selectedSearches["Days"] = dayBooleans
        let timesArray = ["8:00 AM","8:15 AM","8:30 AM","8:45 AM","9:00 AM","9:15 AM","9:30 AM","9:45 AM","10:00 AM","10:15 AM","10:30 AM","10:45 AM","11:00 AM","11:15 AM","11:30 AM","11:45 AM","12:00 PM","12:15 PM","12:30 PM","12:45 PM","1:00 PM","1:15 PM","1:30 PM","1:45 PM","2:00 PM","2:15 PM","2:30 PM","2:45 PM","3:00 PM","3:15 PM","3:30 PM","3:45 PM","4:00 PM","4:15 PM","4:30 PM","4:45 PM","5:00 PM","5:15 PM","5:30 PM","5:45 PM","6:00 PM","6:15 PM","6:30 PM","6:45 PM","7:00 PM","7:15 PM","7:30 PM","7:45 PM","8:00 PM","8:15 PM","8:30 PM","8:45 PM","9:00 PM","9:15 PM","9:30 PM","9:45 PM","10:00 PM"]
//        let
    }

}
