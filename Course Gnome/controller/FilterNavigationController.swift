//
//  SearchNavigationController.swift
//  Course Gnome
//
//  Created by Tim Traversy on 11/21/17.
//  Copyright © 2017 Tim Traversy. All rights reserved.
//

import UIKit

class FilterNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor(named: "Blue")
        navigationBar.tintColor = UIColor.white
        
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white,
                                             NSAttributedStringKey.font: UIFont(name: "AvenirNext-Bold", size: 19)!]

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
