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
    
    var selections: SelectionObject!
    
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
    
    @IBOutlet weak var subjectNumberSlider: RangeSlider!
    
    @IBOutlet var autoCompleteFields: [SearchTextField]!
    
    @IBAction func buttonSwitched(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func sortByNumberPressed(_ sender: UIButton) {
        if (!sender.isSelected) {
            sortBySwitches[0].isSelected = true
            sortBySwitches[1].isSelected = false
            selections.sortBy = SelectionObject.sortBy.subjectNumber
        }
    }
    
    @IBAction func sortByDepartmentPressed(_ sender: UIButton) {
        if (!sender.isSelected) {
            sortBySwitches[1].isSelected = true
            sortBySwitches[0].isSelected = false
            selections.sortBy = SelectionObject.sortBy.department
        }
    }
    
    @IBAction func openStatusPressed(_ sender: RedButton) {
        selections.status.open = !selections.status.open
    }
    
    @IBAction func waitlistStatusPressed(_ sender: RedButton) {
        selections.status.waitlist = !selections.status.waitlist
    }
    
    @IBAction func closedStatusPressed(_ sender: RedButton) {
        selections.status.closed = !selections.status.closed
    }
    
    @IBAction func dayButtonPressed(_ sender: RedButton) {
        if (sender.titleLabel?.text == "M") {
            selections.days.monday = !selections.days.monday
        } else if (sender.titleLabel?.text == "T") {
            selections.days.tuesday = !selections.days.tuesday
        } else if (sender.titleLabel?.text == "W") {
            selections.days.wednesday = !selections.days.wednesday
        } else if (sender.titleLabel?.text == "R") {
            selections.days.thursday = !selections.days.thursday
        } else if (sender.titleLabel?.text == "F") {
            selections.days.friday = !selections.days.friday
        }
    }
    
    @IBAction func timeSwitchSelected(_ sender: RedButton) {
        if (!sender.isSelected) {
            for timeSwitch in timeSwitches {
                timeSwitch.isSelected = false
            }
            sender.isSelected = true
            selections.days.either = !selections.days.either
        }
    }
    
    @IBAction func timeChanged(_ sender: RangeSlider) {
        selections.startTime = DateManager().getTimeValue(value: sender.lowerValue)
        selections.endTime = DateManager().getTimeValue(value: sender.upperValue)
    }
    
    @IBAction func subjectNumberChanged(_ sender: RangeSlider) {
        selections.lowerNumber = Int(sender.lowerValue)
        selections.upperNumber = Int(sender.upperValue)
    }
    
    @IBAction func creditChanged(_ sender: RedButton) {
        selections.credit.removeAll()
        for credit in creditSwitches {
            if credit.isSelected {
                if (credit.tag == 5) {
                    selections.credit.append(5)
                    selections.credit.append(6)
                    selections.credit.append(7)
                    selections.credit.append(8)
                    selections.credit.append(9)
                } else {
                    selections.credit.append(credit.tag)
                }
            }
        }
    }
    
    @IBAction func departmentChanged(_ sender: SearchTextField) {
//        print(sender.text)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load current filters //////////
        
        if (selections.sortBy == SelectionObject.sortBy.subjectNumber) {
            sortBySwitches[0].isSelected = true
        } else {
            sortBySwitches[1].isSelected = true
        }
        
        // load status
        if (selections.status.open) {
            openButton.isSelected = true
        }
        if (selections.status.waitlist) {
            waitlistButton.isSelected = true
        }
        if (selections.status.closed) {
            closedButton.isSelected = true
        }
        
        //load days
        for timeSwitch in timeSwitches {
            timeSwitch.isSelected = false
        }
        if (selections.days.either) {
            timeSwitches[0].isSelected = true
        } else {
            timeSwitches[1].isSelected = true
        }
        
        if (selections.days.monday) {
            dayButton[0].isSelected = true
        }
        if (selections.days.tuesday) {
            dayButton[1].isSelected = true
        }
        if (selections.days.wednesday) {
            dayButton[2].isSelected = true
        }
        if (selections.days.thursday) {
            dayButton[3].isSelected = true
        }
        if (selections.days.friday) {
            dayButton[4].isSelected = true
        }
        
        //load times
        timeSlider.lowerValue = DateManager().getSliderIncrement(value: selections.startTime)
        timeSlider.upperValue = DateManager().getSliderIncrement(value: selections.endTime)
        
        //load departmentb
        departmentField.text = selections.department
        
        //load instructor
        instructorField.text = selections.instructor
        
        //load attribute
        attributeField.text = selections.courseAttribute
        
        // load subjectNumber
        subjectNumberSlider.lowerValue = Double(selections.lowerNumber)
        subjectNumberSlider.upperValue = Double(selections.upperNumber)
        
        // load credit
        if (selections.credit.contains(0)) { creditSwitches[0].isSelected = true }
        if (selections.credit.contains(1)) { creditSwitches[1].isSelected = true }
        if (selections.credit.contains(2)) { creditSwitches[2].isSelected = true }
        if (selections.credit.contains(3)) { creditSwitches[3].isSelected = true }
        if (selections.credit.contains(4)) { creditSwitches[4].isSelected = true }
        if (selections.credit.contains(5)) { creditSwitches[5].isSelected = true }
        
        //// done loading filters ////////
        
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
        
        refreshAutocompletes()
        
        for field in autoCompleteFields {
            field.theme.font = UIFont(name: "AvenirNext-Regular", size: 13.0)!
            field.highlightAttributes = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 13.0)!]
            field.theme.bgColor = UIColor.white
        }
    }
    
    func refreshAutocompletes() {
        let deptStrings = PersistanceManager().getCategory(type: PersistanceManager.category.Department)
        departmentField.filterStrings(deptStrings)
        
        let instructorStrings = PersistanceManager().getCategory(type: PersistanceManager.category.Instructor)
        instructorField.filterStrings(instructorStrings)
        
        let attributeStrings = PersistanceManager().getCategory(type: PersistanceManager.category.CourseAttribute)
        attributeField.filterStrings(attributeStrings)
    }
    
    // fix rangeslider layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        timeSlider.layoutIfNeeded()
        timeSlider.updateLayerFramesAndPositions()
        
        subjectNumberSlider.layoutIfNeeded()
        subjectNumberSlider.updateLayerFramesAndPositions()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if cancel, do nothing
        if (segue.identifier == "CancelSegue") { return }
        if let department = departmentField.text {
            if (department.isEmpty) {
                selections.department = nil
            } else {
                selections.department = department
            }
        }
        if let instructor = instructorField.text {
            if (instructor.isEmpty) {
                selections.instructor = nil
            } else {
                selections.instructor = instructor
            }
        }
        if let attribute = attributeField.text {
            if (attribute.isEmpty) {
                selections.courseAttribute = nil
            } else {
                selections.courseAttribute = attribute
            }
        }
        //otherwise, courseList will just take the selection object
    }

}
