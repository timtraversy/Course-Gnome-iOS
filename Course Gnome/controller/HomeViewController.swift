//
//  HomeViewController.swift
//  Course Gnome
//
//  Created by Tim Traversy on 1/13/18.
//  Copyright © 2018 Tim Traversy. All rights reserved.
//

import UIKit
import PureLayout
import NVActivityIndicatorView

class HomeViewController: UIViewController {
    
    var loaderView: NVActivityIndicatorView!
    var alertWhiteSquareView: UIView!
    var currentType = 1
    
    @IBAction func changeAnimationType(_ sender: UIButton) {
        currentType += 1
        if (currentType == 33) {
            currentType = 1
        }
        
        loaderView.removeFromSuperview()
        let frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        loaderView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType(rawValue: currentType), color: UIColor(named: "Red"))
        
        alertWhiteSquareView.addSubview(loaderView)
        loaderView.startAnimating()
        loaderView.autoCenterInSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let grayOutView = UIView()
        alertWhiteSquareView = UIView()
        alertWhiteSquareView.backgroundColor=UIColor.white
        alertWhiteSquareView.layer.cornerRadius=15
        self.view.addSubview(alertWhiteSquareView)
        alertWhiteSquareView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.init(top: 180.0, left: 50.0, bottom: 250.0, right: 50.0))
        
        let frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        loaderView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType(rawValue: 1), color: UIColor(named: "Red"))
        
        alertWhiteSquareView.addSubview(loaderView)
        loaderView.startAnimating()
//        loaderView.autoPinEdge(edge: ALEdge.top, to: ALEdge.top, of: loaderView.superview)

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
