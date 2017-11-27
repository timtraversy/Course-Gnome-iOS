import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var noLoginSearchButton: UIButton!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        noLoginSearchButton.layer.borderColor = #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 1)

        // check to see if most recent course data pulled, pull if not
        let pullCourses = PullCourses()
        pullCourses.delegate = self
        pullCourses.checkForUpdate()
        
    }
    
}

extension ViewController: PullCoursesDelegate {
    func coursesPulled(updateTime: String) {
        lastUpdateLabel.text = "Courses last updated: \(updateTime)"
    }
    
    func coursesNotPulled(newUser: Bool) {
        lastUpdateLabel.text = "Unable to pull courses. Check connection"
    }
    
    
}

