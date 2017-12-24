//
//  FilterViewController.swift
//  Course Gnome
//
//  Created by Tim Traversy on 12/21/17.
//  Copyright © 2017 Tim Traversy. All rights reserved.
//

import UIKit
import SwiftRangeSlider

class FilterViewController: UIViewController {
    
    @IBOutlet var buttonsToOutline: [UIButton]!
    
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var waitlistButton: UIButton!
    @IBOutlet weak var closedButton: UIButton!
    
    @IBOutlet weak var fitSwitch: UISwitch!
    
    @IBOutlet weak var rangeSlider: RangeSlider!
    @IBOutlet weak var lowerTimeLabel: UILabel!
    @IBOutlet weak var lowerTimeConstraint: NSLayoutConstraint!
    @IBOutlet weak var upperTimeLabel: UILabel!
    @IBOutlet weak var upperTimeConstraint: NSLayoutConstraint!
    var step: CGFloat!
    
    @IBAction func timeSliderChanged(_ sender: RangeSlider) {
        let lowerValue = CGFloat(rangeSlider.lowerValue)
        lowerTimeConstraint.constant = step * lowerValue + 10
        lowerTimeLabel.text = TimesArray().array[Int(lowerValue)]
        let upperValue = CGFloat(rangeSlider.upperValue)
        upperTimeConstraint.constant = (step * (57-upperValue) + 5)
        upperTimeLabel.text = TimesArray().array[Int(upperValue)]
    }
    
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
        
        step = rangeSlider.bounds.size.width/70

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
