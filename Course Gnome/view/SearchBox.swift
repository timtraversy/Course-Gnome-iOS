//
//  SearchBox.swift
//  Course Gnome
//
//  Created by Tim Traversy on 11/28/17.
//  Copyright © 2017 Tim Traversy. All rights reserved.
//

import UIKit

class SearchBox: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 20);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

}
