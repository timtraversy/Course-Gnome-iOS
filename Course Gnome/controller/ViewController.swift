import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var noLoginSearchButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        noLoginSearchButton.layer.borderColor = #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 1)

        let pullCourses = PullCourses()
//        pullCourses.fetchNearbyGyms(latitude: 42.39, longitude: -71.12)
        pullCourses.checkForUpdate()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

