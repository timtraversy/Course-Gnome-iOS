//
//  PersistanceManager.swift
//  Course Gnome
//
//  Created by Tim Traversy on 12/20/17.
//  Copyright © 2017 Tim Traversy. All rights reserved.
//

import Foundation
import RealmSwift

class PersistanceManager {
    func getCourses (selections: [String:String]) -> (courses: Results<Course>, offerings: Results<Offering>){
        
        let realm = try! Realm()
        var offerings = realm.objects(Offering.self)
        
        for (category, term) in selections {
            switch category {
            case "Department" :
                offerings = offerings.filter("department.name = %@", term)
            case "CRN" :
                offerings = offerings.filter("crn.name = %@", term)
            case "Instructor" :
                offerings = offerings.filter("ANY instructors.name = %@", term)
            case "Status" :
                offerings = offerings.filter("status.name = %@", term)
            case "Attributes" :
                offerings = offerings.filter("ANY courseAttributes.name = %@", term)
            case "Course Name" :
                offerings = offerings.filter("courseName = %@", term)
            case "Subject Number" :
                offerings = offerings.filter("subjectNumber = %@", term)
            case "Days" :
                //term = E/O-M-T-W-R-F
                let daysArray = term.components(separatedBy: " ")
                var eitherOnly = ""
                if (daysArray[0] == "O") {
                    eitherOnly = "AND"
                } else {
                    eitherOnly = "OR"
                }
                var predicateString = ""
                
                if (daysArray[1] == "true") {
                    predicateString = "ANY classDays.days contains 'M'"
                }
                if (daysArray[2] == "true") {
                    if (predicateString.isEmpty) {
                        predicateString = "ANY classDays.days contains 'T'"
                    } else {
                        predicateString += " \(eitherOnly) ANY classDays.days contains 'T'"
                    }
                }
                if (daysArray[3] == "true") {
                    if (predicateString.isEmpty) {
                        predicateString = "ANY classDays.days contains 'W'"
                    } else {
                        predicateString += " \(eitherOnly) ANY classDays.days contains 'W'"
                    }
                }
                if (daysArray[4] == "true") {
                    if (predicateString.isEmpty) {
                        predicateString = "ANY classDays.days contains 'R'"
                    } else {
                        predicateString += " \(eitherOnly) ANY classDays.days contains 'R'"
                    }
                }
                if (daysArray[5] == "true") {
                    if (predicateString.isEmpty) {
                        predicateString = "ANY classDays.days contains 'F'"
                    } else {
                        predicateString += " \(eitherOnly) ANY classDays.days contains 'F'"
                    }
                }
                
                if (!predicateString.isEmpty) {
                    offerings = offerings.filter(predicateString)
                }
                
            default :
                print ("No category found!")
            }
        }
        
        var courses = realm.objects(Course.self).filter("ANY offerings IN %@", offerings)
        courses = courses.sorted(byKeyPath: "subjectNumber")

        return (courses: courses, offerings: offerings)
        
    }
}


