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

class FilterViewController: UIViewController {
    
    @IBOutlet var buttonsToOutline: [UIButton]!
    
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var waitlistButton: UIButton!
    @IBOutlet weak var closedButton: UIButton!
    
    @IBOutlet weak var fitSwitch: UISwitch!
    
    @IBOutlet weak var timeSlider: RangeSlider!
    
    @IBOutlet weak var departmentField: SearchTextField!
    @IBOutlet weak var instructorField: SearchTextField!
    @IBOutlet weak var attributeField: SearchTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for button in buttonsToOutline {
            button.layer.borderColor = UIColor(named: "Red")?.cgColor
            button.layer.borderWidth = 1.0
            button.layer.cornerRadius = 3.0
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
