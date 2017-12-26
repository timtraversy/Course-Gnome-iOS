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
    
    @IBOutlet var buttonsToOutline: [UIButton]!
    
    @IBOutlet var allSwitches: [RedButton]!
    @IBOutlet var sortBySwitches: [RedButton]!
    @IBOutlet var timeSwitches: [RedButton]!
    @IBOutlet var creditSwitches: [RedButton]!
    
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var waitlistButton: UIButton!
    @IBOutlet weak var closedButton: UIButton!
    
    @IBOutlet weak var fitSwitch: UISwitch!
    
    @IBOutlet weak var timeSlider: RangeSlider!
    
    @IBOutlet weak var departmentField: SearchTextField!
    @IBOutlet weak var instructorField: SearchTextField!
    @IBOutlet weak var attributeField: SearchTextField!
    
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
        departmentField.theme.font = UIFont(name: "AvenirNext-Regular", size: 13.0)!
        departmentField.highlightAttributes = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 13.0)!]
        departmentField.theme.bgColor = UIColor.white
        
        let instructorStrings = PersistanceManager().getCategory(type: PersistanceManager.category.Instructor)
        instructorField.filterStrings(instructorStrings)
        instructorField.theme.font = UIFont(name: "AvenirNext-Regular", size: 13.0)!
        instructorField.highlightAttributes = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 13.0)!]
        instructorField.theme.bgColor = UIColor.white
        
        let attributeStrings = PersistanceManager().getCategory(type: PersistanceManager.category.CourseAttribute)
        attributeField.filterStrings(attributeStrings)
        attributeField.theme.font = UIFont(name: "AvenirNext-Regular", size: 13.0)!
        attributeField.highlightAttributes = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 13.0)!]
        attributeField.theme.bgColor = UIColor.white

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
