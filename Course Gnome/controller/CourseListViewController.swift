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
    var selections = SelectionObject()
    
    //button collections
    @IBOutlet weak var openButton: UIButton!
    
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
        if (sender.titleColor(for: .normal) == UIColor.white) {
            turnOnButton(button: sender)
            selections.status.open = true
        } else {
            turnOffButton(button: sender)
            selections.status.open = false
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
            
            selections.days.either = true
            updateTable()
        }
    }
    
    @IBAction func selectOnly(_ sender: UIButton) {
        if (sender.backgroundColor == UIColor(named: "LighterBlue")) {
            // currently off, turn it on
            eitherDay = false
            anyButton.backgroundColor = UIColor(named: "Blue")
            eitherButton.backgroundColor = UIColor(named: "LighterBlue")
            
            selections.days.either = false
            updateTable()
        }
    }
    
    @IBAction func anyPressed(_ sender: UIButton) {
        if (sender.titleColor(for: .normal) == UIColor.white) {
            turnOnButton(button: sender)
        } else {
            turnOffButton(button: sender)
        }
        updateTable()
    }
    
    @IBAction func mondayPressed(_ sender: UIButton) {
        selections.days.monday = !selections.days.monday
    }
    
    @IBAction func tuesdayButton(_ sender: UIButton) {
        selections.days.tuesday = !selections.days.tuesday
    }
    
    @IBAction func wednesdayPressed(_ sender: UIButton) {
        selections.days.wednesday = !selections.days.wednesday
    }
    
    @IBAction func thursdayPressed(_ sender: UIButton) {
        selections.days.thursday = !selections.days.thursday
    }
    
    @IBAction func fridayPressed(_ sender: UIButton) {
        selections.days.friday = !selections.days.friday
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

        if (selectedCategory == "Department") {
            selections.department = selectedSearch
        } else if (selectedCategory == "CRN") {
            selections.crn = selectedSearch
        } else if (selectedCategory == "Instructor") {
            selections.instructor = selectedSearch
        } else if (selectedCategory == "Course Name") {
            selections.courseName = selectedSearch
        } else if (selectedCategory == "Subject Number") {
            selections.subjectNumber = selectedSearch
        } else if (selectedCategory == "Attribute") {
            selections.courseAttribute = selectedSearch
        }
        persistanceManager = PersistanceManager()
        updateTable()
    }
    
    func updateTable() {
        let results = persistanceManager.getCourses(selections: selections)
        courses = results.courses
        offerings = results.offerings
        title = "\(offerings.count) Results"
        tableView.reloadData()
        if (courses.count + offerings.count > 0) {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count + offerings.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var count = 0
        var course = 0
        
        while (true) {
            let currentCourse = courses[course]
            let offeringsForCourseCount = currentCourse.offerings.count
            if (indexPath.row == count) {
                return false
            } else if (indexPath.row <= offeringsForCourseCount + count) {
                return true
            }
            count += offeringsForCourseCount + 1
            course += 1
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal, title: "Add") { (action, indexpath) in
//            print(indexpath)
//            print(action)
        }
        deleteAction.backgroundColor = UIColor(named: "Red")
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var count = 0
        var course = 0
        
        let dateFormatterOut = DateFormatter()
        dateFormatterOut.dateFormat = "h:mm"

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
            let offeringsForCourse = currentCourse.offerings
            let offeringsForCourseCount = offeringsForCourse.count
            
            if (indexPath.row == count) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseCell
                var departmentLabel = ""
                if let department = currentCourse.department?.acronym {
                    departmentLabel = "\(department) \(currentCourse.subjectNumber!.string)"
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
                    if let startTime = day.startTime?.string {
                        if let endTime = day.endTime?.string {
                            timeLabel.text = startTime + " - " + endTime
                            timeLabel.textColor = colors[labelColor]
                            timeLabel.font = UIFont(name: "AvenirNext-Medium", size: 15)
                        }
                    }
                    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navViewController = segue.destination as? SearchNavigationController
        let filterViewController = navViewController?.viewControllers.first as! FilterViewController
        filterViewController.selections = selections
    }

    @IBAction func unwindToCourseList(segue: UIStoryboardSegue) {
    }
    
    @IBAction func unwindToCourseListAndSave(segue: UIStoryboardSegue) {
        filterScrollView.setContentOffset(CGPoint(x: 0,y:0), animated: true)
        // load button states
        if let origin = segue.source as? FilterViewController {
            selections = origin.selections
        }
        if (selections.status.open) {
            turnOnButton(button: openButton)
        } else {
            turnOffButton(button: openButton)
        }
        if (selections.days.either) {
            selectEither(eitherButton)
        } else {
            selectOnly(anyButton)
        }
        for i in 0...4 {
            turnOffButton(button: hiddenButtons[i])
        }
        daysActive = false
        if (selections.days.monday) {
            turnOnButton(button: hiddenButtons[0])
            daysActive = true
        }
        if (selections.days.tuesday) {
            turnOnButton(button: hiddenButtons[1])
            daysActive = true
        }
        if (selections.days.wednesday) {
            turnOnButton(button: hiddenButtons[2])
            daysActive = true
        }
        if (selections.days.thursday) {
            turnOnButton(button: hiddenButtons[3])
            daysActive = true
        }
        if (selections.days.friday) {
            turnOnButton(button: hiddenButtons[4])
            daysActive = true
        }
        if (daysActive) {
            if (daysCollapsed) { expandDays(dayButton) }
        } else {
            if (!daysCollapsed) { expandDays(dayButton) }
        }
        updateTable()
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
