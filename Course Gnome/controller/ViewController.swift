import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var noLoginSearchButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        noLoginSearchButton.layer.borderColor = #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 1)

//        let pullCourses = PullCourses()
//        pullCourses.fetchCourses()
//        let courseDB = CourseDatabase()
//        courseDB.getStuff()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

