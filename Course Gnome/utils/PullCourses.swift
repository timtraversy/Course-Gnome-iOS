import Foundation
import RealmSwift
import SwiftyJSON
import Alamofire
import Alamofire_SwiftyJSON

class PullCourses {
    
    func checkForUpdate() {
        let realm = try! Realm()
        let results = realm.objects(LastRevised.self)
        
        let parameters: Parameters = ["timeOrString": "time"]
        Alamofire.request("http://coursegnome.com/php/forApp/getJson.php", parameters: parameters).responseString
            { response in
                let databaseUpdateTime = response.result.value
                
                // if courses never pulled, update them
                if (results.count == 0) {
                    self.fetchCourses(databaseUpdateTime: databaseUpdateTime!)
                    return
                }
                // if courses pulled before, but new update available, update them
                let localUpdateTime = results[0].lastRevised
                if (localUpdateTime != databaseUpdateTime) {
                    self.fetchCourses(databaseUpdateTime: databaseUpdateTime!)
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
        }
    }
}
