import UIKit
import RealmSwift

class CourseCell: UITableViewCell {
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
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
}

class CourseListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // get selection from search, matches one key from below
    var selectedSearch: String!
    var selectedCategory: String!
    
    @IBOutlet weak var tableView: UITableView!
    
    var courses = try! Realm().objects(Course.self)
    var offeringsCount = 0
    
    var persistanceManager: PersistanceManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
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
            if (indexPath.row == count) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseCell
                var departmentLabel = ""
                if let department = courses[course].department?.acronym {
                    departmentLabel = "\(department) \(courses[course].subjectNumber) - \(courses[course].credit) Credits"
                }
                cell.departmentLabel.text = departmentLabel
                cell.courseNameLabel.text = courses[course].courseName
                return cell
            } else if (indexPath.row <= courses[course].offerings.count + count) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "offeringCell", for: indexPath) as! OfferingCell
                let offering = courses[course].offerings[indexPath.row-count-1]
                cell.sectionNumberLabel.text = offering.sectionNumber
                cell.crnLabel.text = offering.crn?.name
                cell.instructorLabel.text = offering.instructors[0].name
                cell.timeLabel.text = "\(offering.classDays[0].startTime) - \(offering.classDays[0].endTime)"
                
                if (offering.classDays[0].days[1]) {
                    cell.mondayImage.image = UIImage (named: "GreenFilled")
                } else {
                    cell.mondayImage.image = UIImage (named: "GreenOutline")
                }
                if (offering.classDays[0].days[2]) {
                    cell.tuesdayImage.image = UIImage (named: "GreenFilled")
                } else {
                    cell.tuesdayImage.image = UIImage (named: "GreenOutline")
                }
                if (offering.classDays[0].days[3]) {
                    cell.wednesdayImage.image = UIImage (named: "GreenFilled")
                } else {
                    cell.wednesdayImage.image = UIImage (named: "GreenOutline")
                }
                if (offering.classDays[0].days[4]) {
                    cell.thursdayImage.image = UIImage (named: "GreenFilled")
                } else {
                    cell.thursdayImage.image = UIImage (named: "GreenOutline")
                }
                if (offering.classDays[0].days[5]) {
                    cell.fridayImage.image = UIImage (named: "GreenFilled")
                } else {
                    cell.fridayImage.image = UIImage (named: "GreenOutline")
                }
                
                return cell
            }
            count += courses[course].offerings.count + 1
            course += 1
        }
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
