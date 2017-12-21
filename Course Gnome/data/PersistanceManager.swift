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
    func getCourses (selections: [String:String]) -> Results<Course>{
        let realm = try! Realm()
        var courses = realm.objects(Course.self)
        
        for (term, category) in selections {
            print(term)
            switch category {
            case "Department" :
                courses = courses.filter("department.name = %@", term)
            case "CRN" :
                courses = courses.filter("ANY offerings.crn.name = %@", term)
            case "Instructor" :
                let instructors = realm.objects(Offering.self).filter("ANY instructors.name = %@", term)
                courses = courses.filter("ANY offerings IN %@", instructors)
            case "Status" :
                courses = courses.filter("ANY offerings.status.name = %@", term)
            case "Attributes" :
                let attributes = realm.objects(Offering.self).filter("ANY courseAttributes.name = %@", term)
                courses = courses.filter("ANY offerings IN %@", attributes)
            case "Course Name" :
                courses = courses.filter("courseName = %@", term)
            case "Subject Number" :
                courses = courses.filter("subjectNumber = %@", term)
            default :
                print ("No category found!")
            }
        }
        
        return courses.sorted(byKeyPath: "subjectNumber")
        
    }
}
