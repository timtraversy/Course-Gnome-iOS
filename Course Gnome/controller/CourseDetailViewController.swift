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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
