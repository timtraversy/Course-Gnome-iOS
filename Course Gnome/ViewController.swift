//
//  ViewController.swift
//  Course Gnome
//
//  Created by Tim Traversy on 10/30/17.
//  Copyright © 2017 Tim Traversy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var noLoginSearchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noLoginSearchButton.layer.borderColor = #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 1)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

