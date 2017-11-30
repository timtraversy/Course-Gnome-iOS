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
                
                // loop over offerings
                for (_, course) in json {
                    print("Count \(x)/\(count)")
                    x += 1
                    let newCourse = Course()
                    
                    newCourse.courseName = course["courseName"].stringValue

                    newCourse.subjectNumber = course["subjectNumber"].stringValue

                    var found = false
                    for department in realm.objects(Department.self) {
                        if (department.acronym == course["subjectAcronym"].stringValue) {
                            newCourse.department = department
                            found = true
                            break
                        }
                    }
                    if (!found) {
                        let newDept = Department()
                        newDept.name = course["subjectName"].stringValue
                        newDept.acronym = course["subjectAcronym"].stringValue
                        realm.add(newDept)
                        newCourse.department = newDept
                    }
                    
                    for (_, offering) in course["offerings"] {
                        let newOffering = Offering()
                        newOffering.courseName = offering["courseName"].stringValue
                        newOffering.subjectNumber = offering["subjectNumber"].stringValue
                        
                        found = false
                        for status in realm.objects(Status.self) {
                            if (status.name == offering["status"].stringValue) {
                                newOffering.status = status
                                found = true
                                break
                            }
                        }
                        if (!found) {
                            let newStatus = Status()
                            newStatus.name = offering["status"].stringValue
                            realm.add(newStatus)
                            newOffering.status = newStatus
                        }
                                            
                        let newCrn = CRN()
                        newCrn.name = offering["CRN"].stringValue
                        realm.add(newCrn)
                        newOffering.crn = newCrn
                        
                        newOffering.bulletinLink = offering["bulletinLink"].stringValue
                        newOffering.sectionNumber = offering["sectionNumber"].stringValue
                        newOffering.credit = offering["credit"].stringValue
                        
                        // add instructors
                        for instructor in offering["instructor"] {
                            found = false
                            for savedInstructor in realm.objects(Instructor.self) {
                                if (savedInstructor.name == instructor.1.stringValue) {
                                    newOffering.instructors.append(savedInstructor)
                                    found = true
                                    break
                                }
                            }
                            if (!found) {
                                let newInstructor = Instructor()
                                newInstructor.name = instructor.1.stringValue
                                realm.add(newInstructor)
                                newOffering.instructors.append(newInstructor)
                            }
                        }
                        
                        //loop over days within course
                        for (_,day):(String, JSON ) in offering["classDays"] {
                            let newDay = ClassDay()
                            newDay.location = day["location"].stringValue
                            
                            // days entered as string (ex: TW) so check for each one and enter boolean if there/not there
                            let dayBools = day["days"].stringValue
                            newDay.days.append(dayBools.contains("U") ? true : false)
                            newDay.days.append(dayBools.contains("M") ? true : false)
                            newDay.days.append(dayBools.contains("T") ? true : false)
                            newDay.days.append(dayBools.contains("W") ? true : false)
                            newDay.days.append(dayBools.contains("R") ? true : false)
                            newDay.days.append(dayBools.contains("F") ? true : false)
                            newDay.days.append(dayBools.contains("S") ? true : false)
                            
                            newDay.startTime = day["startTime"].stringValue
                            newDay.endTime = day["endTime"].stringValue
                            
                            realm.add(newDay)
                            newOffering.classDays.append(newDay)
                        }
                        
                        newOffering.start = offering["start"].stringValue
                        newOffering.end = offering["end"].stringValue
                        newOffering.comment = offering["comment"].stringValue
                        newOffering.oldCourseNumber = offering["oldCourseNumber"].stringValue
                        newOffering.findBooksLink = offering["findBooksLink"].stringValue
                        
                        // add course attributes
                        for instructor in offering["instructor"] {
                            found = false
                            for savedInstructor in realm.objects(Instructor.self) {
                                if (savedInstructor.name == instructor.1.stringValue) {
                                    newOffering.instructors.append(savedInstructor)
                                    found = true
                                    break
                                }
                            }
                            if (!found) {
                                let newInstructor = Instructor()
                                newInstructor.name = instructor.1.stringValue
                                realm.add(newInstructor)
                                newOffering.instructors.append(newInstructor)
                            }
                        }
                        for attribute in offering["courseAttributes"] {
                            found = false
                            for savedAttribute in realm.objects(CourseAttribute.self) {
                                if (savedAttribute.name == attribute.1.stringValue) {
                                    newOffering.courseAttributes.append(savedAttribute)
                                    found = true
                                    break
                                }
                            }
                            if (!found) {
                                let newAttribute = CourseAttribute()
                                newAttribute.name = attribute.1.stringValue
                                realm.add(newAttribute)
                                newOffering.courseAttributes.append(newAttribute)
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
