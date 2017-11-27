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
                let json = JSON(response.result.value!)
                
                // open database connection
                let realm = try! Realm()
                
                // get ready to Realm, delete all course data
                realm.beginWrite()
                realm.deleteAll()
                
                //add updateTime
                let revisedTime = LastRevised()
                revisedTime.lastRevised = databaseUpdateTime
                realm.add(revisedTime)
                
                // loop over all courses
                for (_, subJson) in json {
                    let newCourse = Course()
                    newCourse.status = subJson["status"].stringValue
                    newCourse.crn = subJson["CRN"].stringValue
                    newCourse.subjectAcronym = subJson["subjectAcronym"].stringValue
                    newCourse.subjectName = subJson["subjectName"].stringValue
                    newCourse.subjectNumber = subJson["subjectNumber"].stringValue
                    newCourse.bulletinLink = subJson["bulletinLink"].stringValue
                    newCourse.sectionNumber = subJson["sectionNumber"].stringValue
                    newCourse.courseName = subJson["courseName"].stringValue
                    newCourse.credit = subJson["credit"].stringValue
                    
                    // add instructors
                    for instructor in subJson["instructor"] {
                        let newInstructor = Instructor()
                        newInstructor.name = instructor.1.stringValue
                        realm.add(newInstructor)
                        newCourse.instructors.append(newInstructor)
                    }
                    
                    //loop over days within course
                    for (_,day):(String, JSON ) in subJson["classDays"] {
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
                        newCourse.classDays.append(newDay)
                    }
                    
                    newCourse.start = subJson["start"].stringValue
                    newCourse.end = subJson["end"].stringValue
                    newCourse.comment = subJson["comment"].stringValue
                    newCourse.oldCourseNumber = subJson["oldCourseNumber"].stringValue
                    newCourse.findBooksLink = subJson["findBooksLink"].stringValue
                    newCourse.courseName = subJson["courseName"].stringValue
                    
                    // add course attriburtes
                    for attribute in subJson["courseAttributes"] {
                        let newAttribute = CourseAttribute()
                        newAttribute.attribute = attribute.1.stringValue
                        realm.add(newAttribute)
                        newCourse.courseAttributes.append(newAttribute)
                    }
                    
                    newCourse.fee = subJson["fee"].stringValue
                    realm.add(newCourse)
                    
                }
                try! realm.commitWrite()
                self.delegate?.coursesPulled(updateTime: databaseUpdateTime)
        }
    }
}
