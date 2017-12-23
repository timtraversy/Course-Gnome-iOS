import Foundation
import RealmSwift
import SwiftyJSON
import Alamofire
import Alamofire_SwiftyJSON

protocol PullCoursesDelegate {
    func coursesPulled(updateTime: String)
    func coursesNotPulled(newUser: Bool)
}

class PullCourses {
    
    // delegate reports status of pulliing
    var delegate: PullCoursesDelegate?
    
    // first check if update is needed
    func checkForUpdate() {
        
        // open realm, read time courses were last revised
        let realm = try! Realm()
        let results = realm.objects(LastRevised.self)
        
        // make HTTP request to get JSON containing time of last course update
        let parameters: Parameters = ["timeOrString": "time"]
        Alamofire.request("http://coursegnome.com/php/forApp/getJson.php", parameters: parameters).responseString
            { response in
                
                // if request fails, tell delegate, and say if user is new
                if (response.result.isFailure) {
                    self.delegate?.coursesNotPulled(newUser: results.count == 0)
                    return
                }
                
                let databaseUpdateTime = response.result.value
                
                // if no data ever pulled, user is new
                // get time update string from database and call fetch courses
                if (results.count == 0) {
                    self.fetchCourses(databaseUpdateTime: databaseUpdateTime!)
                    return
                } else {
                    // else, user is not new
                    // get locally stored update time and see if it matches fresh one
                    // if they don't match, pull new course data
                    let localUpdateTime = results[0].lastRevised
                    if (localUpdateTime != databaseUpdateTime) {
                        self.fetchCourses(databaseUpdateTime: databaseUpdateTime!)
                    } else {
                        self.delegate?.coursesPulled(updateTime: localUpdateTime)
                    }
                }
        }
    }
    
    func fetchCourses(databaseUpdateTime: String) {
        Alamofire.request("http://coursegnome.com/php/forApp/getJson.php").responseJSON
            { response in
                
                // open database connection
                let realm = try! Realm()
                
                // get ready to Realm, delete all course data
                realm.beginWrite()
                realm.deleteAll()
                
                //add updateTime
                let revisedTime = LastRevised()
                revisedTime.lastRevised = databaseUpdateTime
                realm.add(revisedTime)
                
                let json = JSON(response.result.value!)
                
                var x = 0
                let count = json.count
                
                // add statuses
                let open = Status()
                open.name = "Open"
                realm.add(open)
                let waitlist = Status()
                waitlist.name = "Waitlist"
                realm.add(waitlist)
                let closed = Status()
                closed.name = "Closed"
                realm.add(closed)
                
                // loop over offerings
                for (_, course) in json {
                    print("Count \(x)/\(count)")
                    let newCourse = Course()
                    newCourse.courseID = x
                    x += 1
                    
                    newCourse.courseName = course["courseName"].stringValue
                    newCourse.subjectNumber = course["subjectNumber"].stringValue
                    newCourse.credit = course["credit"].stringValue
                    
                    // get department
                    let found = realm.objects(Department.self).filter("acronym = %@", course["subjectAcronym"].stringValue)
                    if (found.count == 0) {
                        let newDepartment = Department()
                        newDepartment.name = course["subjectName"].stringValue
                        newDepartment.acronym = course["subjectAcronym"].stringValue
                        realm.add(newDepartment)
                        newCourse.department = newDepartment
                    } else {
                        newCourse.department = found[0]
                    }
                    
                    for (_, offering) in course["offerings"] {
                        let newOffering = Offering()
                        
                        // copy parent values
                        newOffering.courseID = newCourse.courseID
                        newOffering.department = newCourse.department
                        newOffering.subjectNumber = newCourse.subjectNumber
                        newOffering.courseName = newCourse.courseName
                        newOffering.credit = newCourse.credit
                        
                        newOffering.courseName = offering["courseName"].stringValue
                        newOffering.subjectNumber = offering["subjectNumber"].stringValue
                        
                        let status = realm.objects(Status.self).filter("name = %@", offering["status"].stringValue)
                        newOffering.status = status[0]
                                            
                        let newCrn = CRN()
                        newCrn.name = offering["CRN"].stringValue
                        realm.add(newCrn)
                        newOffering.crn = newCrn
                        
                        newOffering.bulletinLink = offering["bulletinLink"].stringValue
                        newOffering.sectionNumber = offering["sectionNumber"].stringValue

                        
                        //loop over days within course
                        for (_,day):(String, JSON ) in offering["classDays"] {
                            let newDay = ClassDay()
                            newDay.location = day["location"].stringValue
                            
                            // days entered as string (ex: TW) so check for each one and enter boolean if there/not there
                            newDay.days = day["days"].stringValue
                            
                            let dateFormatterIn = DateFormatter()
                            dateFormatterIn.dateFormat = "HH:mm"
                            let dateFormatterOut = DateFormatter()
                            dateFormatterOut.dateFormat = "h:mm"
                            let startString = day["startTime"].stringValue
                            guard let startDateIn = dateFormatterIn.date(from: startString) else {
                                // can't parse date, date probably empty
                                continue
                            }
                            newDay.startTime = dateFormatterOut.string(from: startDateIn)
                            let endString = day["endTime"].stringValue
                            guard let endDateIn = dateFormatterIn.date(from: endString) else {
                                // can't parse date, date probably empty
                                continue
                            }
                            newDay.endTime = dateFormatterOut.string(from: endDateIn)
                            
                            realm.add(newDay)
                            newOffering.classDays.append(newDay)
                        }
                        
                        newOffering.start = offering["start"].stringValue
                        newOffering.end = offering["end"].stringValue
                        newOffering.comment = offering["comment"].stringValue
                        newOffering.oldCourseNumber = offering["oldCourseNumber"].stringValue
                        newOffering.findBooksLink = offering["findBooksLink"].stringValue
                        
                        // add instrucotrs
                        for instructor in offering["instructor"] {
                            let found = realm.objects(Instructor.self).filter("name = %@", instructor.1.stringValue)
                            if (found.count == 0) {
                                let newInstructor = Instructor()
                                newInstructor.name = instructor.1.stringValue
                                realm.add(newInstructor)
                                newOffering.instructors.append(newInstructor)
                            } else {
                                newOffering.instructors.append(found[0])
                            }
                        }
                        
                        // add attributes
                        for attribute in offering["courseAttributes"] {
                            let found = realm.objects(CourseAttribute.self).filter("name = %@", attribute.1.stringValue)
                            if (found.count == 0) {
                                let newAttribute = CourseAttribute()
                                newAttribute.name = attribute.1.stringValue
                                realm.add(newAttribute)
                                newOffering.courseAttributes.append(newAttribute)
                            } else {
                                newOffering.courseAttributes.append(found[0])
                            }
                        }
                        
                        newOffering.fee = offering["fee"].stringValue
                        realm.add(newOffering)
                        newCourse.offerings.append(newOffering)
                    }
                    realm.add(newCourse)
                }
                try! realm.commitWrite()
                self.delegate?.coursesPulled(updateTime: databaseUpdateTime)
        }
    }
}
