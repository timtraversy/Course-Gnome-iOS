//
//  CourseDetailViewController.swift
//  Course Gnome
//
//  Created by Tim Traversy on 1/12/18.
//  Copyright © 2018 Tim Traversy. All rights reserved.
//

import UIKit

class BlueButton: UIButton {
    override open var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.25) {
                self.backgroundColor = self.isSelected ? UIColor(named: "Red") : UIColor.white
            }
        }
    }
}

class CourseDetailViewController: UIViewController {
    
    var offeringCRN: String!
    var offering: Offering!
    
    @IBOutlet weak var departmentSectionLabel: UILabel!
    @IBOutlet weak var addButton: BlueButton!
    @IBOutlet weak var courseNameLabel: UILabel!
    
    @IBOutlet weak var friendsBox: UIView!
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    
    
    @IBOutlet weak var crnCreditInstBox: UIView!
    
    @IBOutlet weak var crnLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var instructorLabel: UILabel!
    @IBOutlet weak var meetsBox: UIView!
    @IBOutlet weak var classDaysStackView: UIStackView!
    @IBOutlet weak var courseAttributesBox: UIView!
    @IBOutlet weak var courseAttributesLabel: UILabel!
    @IBOutlet weak var commentBox: UIView!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FORMAT
        
        // LOAD
        
        offering = PersistanceManager().getOffering(crn: offeringCRN)
        
        // load deptSection label
        var deptSectionText = ""
        if let department = offering.department?.acronym {
            deptSectionText += department
        }
        if let number = offering.subjectNumber?.string {
           deptSectionText += number
        }
        if let sectionNumber = offering.sectionNumber {
            deptSectionText += " - Section " + sectionNumber
        }
        if (deptSectionText.isEmpty) {
            departmentSectionLabel.isHidden = true
        } else {
            departmentSectionLabel.text = deptSectionText
        }
        
        // load coursename label
        let attrString = NSMutableAttributedString(string: offering.courseName)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 1.0
        style.lineHeightMultiple = 0.75
        attrString.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSAttributedStringKey.baselineOffset, value: -3, range: NSMakeRange(0, attrString.length))
        courseNameLabel.clipsToBounds = false
        courseNameLabel.attributedText = attrString
        
        // load friends
        friendsBox.isHidden = true
//        crnCreditInstBox.isHidden = true
        meetsBox.isHidden = true
        
        // load crn, credit, instructor labels
        if let crn = offering.crn?.name {
            crnLabel.text = crn
        } else {
            // should always have crn
        }
        if let credit = offering.credit.value {
            creditLabel.text = String(credit)
        } else {
            creditLabel.text = "Unknown"
        }
        
        if (!offering.instructors.isEmpty) {
            var first = true
            for instructor in offering.instructors {
                if (first) {
                    instructorLabel.text = instructor.name
                    first = false
                } else {
                    instructorLabel.text! += "\n\(instructor.name)"
                }
            }
        } else {
            instructorLabel.text = "None listed"
        }
        
        // load meets
        
        // load course attributes
        if (!offering.courseAttributes.isEmpty) {
            courseAttributesLabel.text = ""
            for attribute in offering.courseAttributes {
                courseAttributesLabel.text! += attribute.name + " "
            }
        } else {
            courseAttributesBox.isHidden = true
        }
        
        if let comment = offering.comment {
            commentLabel.text = comment
        } else {
            commentBox.isHidden = true
        }

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
