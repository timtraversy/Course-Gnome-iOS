import UIKit
import RealmSwift

class CourseCell: UITableViewCell {
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet var courseLabelsCollection: [UILabel]!
}

class OfferingCell: UITableViewCell {
    @IBOutlet weak var sectionNumberLabel: UILabel!
    @IBOutlet weak var mondayImage: UIImageView!
    @IBOutlet weak var tuesdayImage: UIImageView!
    @IBOutlet weak var wednesdayImage: UIImageView!
    @IBOutlet weak var thursdayImage: UIImageView!
    @IBOutlet weak var fridayImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var crnLabel: UILabel!
    @IBOutlet weak var instructorLabel: UILabel!
    @IBOutlet var offeringLabelsCollection: [UILabel]!
}

class CourseListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // get selection from search, matches one key from below
    var selectedSearch: String!
    var selectedCategory: String!
    
    //all filter buttons
    @IBOutlet var filterButtons: [UIButton]!
    @IBOutlet var dayButtons: [UIButton]!
    
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var fridayButton: UIButton!
    
    @IBOutlet weak var filterScrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    var courses = try! Realm().objects(Course.self)
    var offeringsCount = 0
    
    var persistanceManager: PersistanceManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        // set button styling
        for button in filterButtons {
            button.layer.cornerRadius = 4.0
            button.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 13.0)
        }
        for button in dayButtons {
            button.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 13.0)
        }
        
        //nav bar font
//        self.navigationItem.set
        
        dateButton.isEnabled = false
        dateButton.roundedLeft()
        fridayButton.roundedRight()
        
        persistanceManager = PersistanceManager()
        courses = persistanceManager.getCourses(selections: [selectedSearch:selectedCategory])
        for course in courses {
            offeringsCount += course.offerings.count
        }
        title = "\(offeringsCount) Results"
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count + offeringsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var count = 0
        var course = 0
        while (true) {
            
            let squareColor = course%9 + 1
            let labelColor = course%9
            let colors = [UIColor(red:0.10, green:0.74, blue:0.61, alpha:1.0),
                          UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0),
                          UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0),
                          UIColor(red:0.61, green:0.35, blue:0.71, alpha:1.0),
                          UIColor(red:0.20, green:0.29, blue:0.37, alpha:1.0),
                          UIColor(red:0.95, green:0.77, blue:0.06, alpha:1.0),
                          UIColor(red:0.90, green:0.49, blue:0.13, alpha:1.0),
                          UIColor(red:0.18, green:0.80, blue:0.44, alpha:1.0),
                          UIColor(red:0.58, green:0.65, blue:0.65, alpha:1.0)]
            
            if (indexPath.row == count) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseCell
                var departmentLabel = ""
                if let department = courses[course].department?.acronym {
                    departmentLabel = "\(department) \(courses[course].subjectNumber) - \(courses[course].credit) Credits"
                }
                cell.departmentLabel.text = departmentLabel
                cell.courseNameLabel.text = courses[course].courseName
                for label in cell.courseLabelsCollection {
                    label.textColor = colors[labelColor]
                }
                return cell
            } else if (indexPath.row <= courses[course].offerings.count + count) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "offeringCell", for: indexPath) as! OfferingCell
                let offering = courses[course].offerings[indexPath.row-count-1]
                cell.sectionNumberLabel.text = offering.sectionNumber
                cell.crnLabel.text = offering.crn?.name
                cell.instructorLabel.text = offering.instructors[0].name
                cell.timeLabel.text = "\(offering.classDays[0].startTime) - \(offering.classDays[0].endTime)"
                
                for label in cell.offeringLabelsCollection {
                    label.textColor = colors[labelColor]
                }
                
                if (offering.classDays[0].days[1]) {
                    cell.mondayImage.image = UIImage (named: "\(squareColor)Filled")
                } else {
                    cell.mondayImage.image = UIImage (named: "\(squareColor)Outline")
                }
                if (offering.classDays[0].days[2]) {
                    cell.tuesdayImage.image = UIImage (named: "\(squareColor)Filled")
                } else {
                    cell.tuesdayImage.image = UIImage (named: "\(squareColor)Outline")
                }
                if (offering.classDays[0].days[3]) {
                    cell.wednesdayImage.image = UIImage (named: "\(squareColor)Filled")
                } else {
                    cell.wednesdayImage.image = UIImage (named: "\(squareColor)Outline")
                }
                if (offering.classDays[0].days[4]) {
                    cell.thursdayImage.image = UIImage (named: "\(squareColor)Filled")
                } else {
                    cell.thursdayImage.image = UIImage (named: "\(squareColor)Outline")
                }
                if (offering.classDays[0].days[5]) {
                    cell.fridayImage.image = UIImage (named: "\(squareColor)Filled")
                } else {
                    cell.fridayImage.image = UIImage (named: "\(squareColor)Outline")
                }
                
                return cell
            }
            count += courses[course].offerings.count + 1
            course += 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "courseDetail", sender: self)
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

extension UIButton {
    func roundedLeft(){
        let maskPAth1 = UIBezierPath(roundedRect: self.bounds,
                                     byRoundingCorners: [.topLeft , .bottomLeft],
                                     cornerRadii:CGSize(width:5.0, height:5.0))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.bounds
        maskLayer1.path = maskPAth1.cgPath
        self.layer.mask = maskLayer1
    }
    func roundedRight(){
        let maskPAth1 = UIBezierPath(roundedRect: self.bounds,
                                     byRoundingCorners: [.topRight , .bottomRight],
                                     cornerRadii:CGSize(width:5.0, height:5.0))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.bounds
        maskLayer1.path = maskPAth1.cgPath
        self.layer.mask = maskLayer1
    }
}
