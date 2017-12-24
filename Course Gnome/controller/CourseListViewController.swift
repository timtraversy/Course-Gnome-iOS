import UIKit
import RealmSwift

class CourseCell: UITableViewCell {
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet var courseLabelsCollection: [UILabel]!
}

class OfferingCell: UITableViewCell {
    @IBOutlet weak var sectionNumberLabel: UILabel!
    @IBOutlet weak var crnLabel: UILabel!
    @IBOutlet weak var instructorLabel: UILabel!
    @IBOutlet var offeringLabelsCollection: [UILabel]!
    @IBOutlet weak var classDaysStack: UIStackView!
}

class CourseListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // get selection from search, matches one key from below
    var selectedSearch: String!
    var selectedCategory: String!
    var selectedSearches = [String:String]()
    
    //button collections
    @IBOutlet var allButtons: [UIButton]!
    @IBOutlet var hiddenButtons: [UIButton]!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var daysStackView: UIStackView!
    var daysActive = false
    var daysCollapsed = true
    
    @IBOutlet weak var eitherButton: UIButton!
    @IBOutlet weak var anyButton: UIButton!
    var eitherDay = true
    
    //button actions
    @IBAction func expandDays(_ sender: UIButton) {
        daysCollapsed = !daysCollapsed
        UIView.animate(withDuration: 0.25) {
            for i in 2...14 {
              let view = self.daysStackView.arrangedSubviews[i]
                view.isHidden = self.daysCollapsed
            }
        }
        if (daysCollapsed) {
            if (daysActive) {
                turnOnButton(button: dayButton)
            }
        } else {
            turnOffButton(button: dayButton)
        }
    }
    
    @IBAction func pushedOpenButton(_ sender: UIButton) {
        if (selectedSearches["Status"] == "Open") {
            selectedSearches.removeValue(forKey: "Status")
        } else {
            selectedSearches["Status"] = "Open"
        }
        updateTable()
    }
    
    func turnOffButton(button: UIButton) {
        UIView.animate(withDuration: 0.25) {
            button.backgroundColor = UIColor(named: "LightestRed")
            button.setTitleColor(.white, for: .normal)
        }
    }
    func turnOnButton(button: UIButton) {
        UIView.animate(withDuration: 0.25) {
            button.backgroundColor = UIColor.white
            button.setTitleColor(UIColor(named: "Red"), for: .normal)
        }
    }
    
    @IBAction func selectEither(_ sender: UIButton) {
        if (sender.backgroundColor == UIColor(named: "LighterBlue")) {
            // currently off, turn it on
            eitherDay = true
            eitherButton.backgroundColor = UIColor(named: "Blue")
            anyButton.backgroundColor = UIColor(named: "LighterBlue")
            
            dayBooleans.removeFirst(1)
            dayBooleans = "E" + dayBooleans
            selectedSearches["Days"] = dayBooleans
            updateTable()
        }
    }
    
    @IBAction func selectOnly(_ sender: UIButton) {
        if (sender.backgroundColor == UIColor(named: "LighterBlue")) {
            // currently off, turn it on
            eitherDay = false
            anyButton.backgroundColor = UIColor(named: "Blue")
            eitherButton.backgroundColor = UIColor(named: "LighterBlue")
            
            dayBooleans.removeFirst(1)
            dayBooleans = "O" + dayBooleans
            selectedSearches["Days"] = dayBooleans
            updateTable()
        }
    }
    
    var dayBooleans = ""
    
    @IBAction func anyPressed(_ sender: UIButton) {
        if (sender.titleColor(for: .normal) == UIColor.white) {
            turnOnButton(button: sender)
        } else {
            turnOffButton(button: sender)
        }
    }
    
     @IBAction func dayPressed(_ sender: UIButton) {
        daysActive = false
        dayBooleans = ""
        if (eitherDay) {
            dayBooleans.append("E ")
        } else {
            dayBooleans.append("O ")
        }
        for i in 0...5 {
            if (hiddenButtons[i].backgroundColor == UIColor.white) {
                daysActive = true
                dayBooleans.append("true ")
            } else {
                dayBooleans.append("false ")
            }
        }
        selectedSearches["Days"] = dayBooleans
        updateTable()
    }
    
    @IBOutlet weak var filterScrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    var courses = try! Realm().objects(Course.self)
    var offerings = try! Realm().objects(Offering.self)
    
    var persistanceManager: PersistanceManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        for button in hiddenButtons {
            button.isHidden = true
        }

        selectedSearches[selectedCategory] = selectedSearch
        persistanceManager = PersistanceManager()
        updateTable()
    }
    
    func updateTable() {
        let results = persistanceManager.getCourses(selections: selectedSearches)

        courses = results.courses
        offerings = results.offerings

        title = "\(offerings.count) Results"
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count + offerings.count
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
            
            // this is where we calculate the offerings for this course
            let currentCourse = courses[course]
            let offeringsForCourse = offerings.filter("courseID = %@", currentCourse.courseID)
            let offeringsForCourseCount = offeringsForCourse.count
            
            if (indexPath.row == count) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseCell
                var departmentLabel = ""
                if let department = currentCourse.department?.acronym {
                    departmentLabel = "\(department) \(currentCourse.subjectNumber)"
                }
                cell.departmentLabel.text = departmentLabel
                cell.courseNameLabel.text = currentCourse.courseName
                for label in cell.courseLabelsCollection {
                    label.textColor = colors[labelColor]
                }
                return cell
            } else if (indexPath.row <= offeringsForCourseCount + count) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "offeringCell", for: indexPath) as! OfferingCell
                let offering = offeringsForCourse[indexPath.row-count-1]
                
                for view in cell.classDaysStack.arrangedSubviews {
                    view.removeFromSuperview()
                }
                
                // loop over each class day and add it to stack
                for day in offering.classDays {
                    let imageViewOne = UIImageView()
                    // add special aspect ratio constraint to make them all squares
                    let aspectConstraint = NSLayoutConstraint(item: imageViewOne,
                                                              attribute: NSLayoutAttribute.height,
                                                              relatedBy: NSLayoutRelation.equal,
                                                              toItem: imageViewOne,
                                                              attribute: NSLayoutAttribute.width,
                                                              multiplier: 1,
                                                              constant: 0)
                    NSLayoutConstraint.activate([aspectConstraint])

                    if (day.days.contains("M")) {
                        imageViewOne.image = UIImage(named: "\(squareColor)Filled")
                    } else {
                        imageViewOne.image = UIImage (named: "\(squareColor)Outline")
                    }
                    
                    let imageViewTwo = UIImageView()
                    if (day.days.contains("T")) {
                        imageViewTwo.image = UIImage (named: "\(squareColor)Filled")
                    } else {
                        imageViewTwo.image = UIImage (named: "\(squareColor)Outline")
                    }
                    
                    let imageViewThree = UIImageView()
                    if (day.days.contains("W")) {
                        imageViewThree.image = UIImage (named: "\(squareColor)Filled")
                    } else {
                        imageViewThree.image = UIImage (named: "\(squareColor)Outline")
                    }
                    
                    let imageViewFour = UIImageView()
                    if (day.days.contains("R")) {
                        imageViewFour.image = UIImage (named: "\(squareColor)Filled")
                    } else {
                        imageViewFour.image = UIImage (named: "\(squareColor)Outline")
                    }
                    
                    let imageViewFive = UIImageView()
                    if (day.days.contains("F")) {
                        imageViewFive.image = UIImage (named: "\(squareColor)Filled")
                    } else {
                        imageViewFive.image = UIImage (named: "\(squareColor)Outline")
                    }
                    
                    let subStackView = UIStackView()
                    subStackView.axis = UILayoutConstraintAxis.horizontal
                    subStackView.distribution = UIStackViewDistribution.fillEqually
                    subStackView.alignment = UIStackViewAlignment.fill
                    subStackView.spacing = 3.0
                    let heightConstraint = NSLayoutConstraint(item: subStackView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 13)
                    NSLayoutConstraint.activate([heightConstraint])
                    
                    subStackView.addArrangedSubview(imageViewOne)
                    subStackView.addArrangedSubview(imageViewTwo)
                    subStackView.addArrangedSubview(imageViewThree)
                    subStackView.addArrangedSubview(imageViewFour)
                    subStackView.addArrangedSubview(imageViewFive)
                    
                    let timeLabel = UILabel()
                    timeLabel.text = day.startTime + " - " + day.endTime
                    timeLabel.textColor = colors[labelColor]
                    timeLabel.font = UIFont(name: "AvenirNext-Medium", size: 15)
                    
                    let stackView = UIStackView()
                    stackView.axis = UILayoutConstraintAxis.horizontal
                    stackView.distribution = UIStackViewDistribution.fill
                    stackView.alignment = UIStackViewAlignment.fill
                    stackView.spacing = 10.0
                    
                    stackView.addArrangedSubview(subStackView)
                    stackView.addArrangedSubview(timeLabel)
                    
                    cell.classDaysStack.addArrangedSubview(stackView)

                }
                
                cell.sectionNumberLabel.text = offering.sectionNumber
                cell.crnLabel.text = offering.crn?.name
                var instructorText = ""
                for instructor in offering.instructors {
                    instructorText += "\(instructor.name); "
                }
                instructorText.removeLast(2)
                cell.instructorLabel.text = instructorText
                
                for label in cell.offeringLabelsCollection {
                    label.textColor = colors[labelColor]
                }

                return cell
            }
            count += offeringsForCourseCount + 1
            course += 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    @IBAction func unwindToCourseList(segue: UIStoryboardSegue) {
    }
    
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
