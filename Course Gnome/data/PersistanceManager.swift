//
//  PersistanceManager.swift
//  Course Gnome
//
//  Created by Tim Traversy on 12/20/17.
//  Copyright © 2017 Tim Traversy. All rights reserved.
//

import Foundation
import RealmSwift

struct Days {
    var monday = false
    var tuesday = false
    var wednesday = false
    var thursday = false
    var friday = false
    var either = true
}

struct StatusList {
    var open = false
    var closed = false
    var waitlist = false
}

class SelectionObject {
    
    enum sortBy: String {
        case subjectNumber = "subjectNumber.string"
        case department = "department.name"
    }

    var sortBy = SelectionObject.sortBy.subjectNumber
    var department: String?
    var crn: String?
    var instructor: String?
    var status = StatusList()
    var courseAttribute: String?
    var courseName: String?
    var subjectNumber: String?
    var days = Days()
    var startTime = 480
    var endTime = 1320
    var lowerNumber = 0
    var upperNumber = 9000
    
}

class PersistanceManager {
    
    enum category {
        case Department
        case CRN
        case Instructor
        case Status
        case CourseAttribute
        case CourseName
        case SubjectNumber
        case Days
    }
    
    func getCourses (selections: SelectionObject) -> (courses: Results<Course>, offerings: Results<Offering>){
            
        let realm = try! Realm()
        var offerings = realm.objects(Offering.self)
        
        if let term = selections.department {
            offerings = offerings.filter("department.name = %@", term)
        }
        if let term = selections.crn { offerings = offerings.filter("crn = %@", term) }
        if let term = selections.instructor { offerings = offerings.filter("ANY instructors.name = %@", term) }
        
        let statuses = selections.status
        var first = true
        if (statuses.open) {
            offerings = offerings.filter("status.name = 'Open'")
            first = false
        }
        if (statuses.closed) {
            if (first) {
                offerings = offerings.filter("status.name = 'Closed'")
                first = false
            } else {
                offerings = offerings.filter("OR status.name = 'Closed'")
            }
        }
        if (statuses.waitlist) {
            if (first) {
                offerings = offerings.filter("status.name = 'Waitlist'")
            } else {
                offerings = offerings.filter("OR status.name = 'Waitlist'")
            }
        }
        
        if let term = selections.courseAttribute { offerings = offerings.filter("ANY courseAttributes.name = %@", term) }
        if let term = selections.courseName { offerings = offerings.filter("courseName = %@", term) }
        if let term = selections.subjectNumber { offerings = offerings.filter("subjectNumber = %@", term) }
        
        var predicateString = ""
        let days = selections.days
        var eitherAny = ""
        if (days.either) {
            eitherAny = "OR"
        } else {
            eitherAny = "AND"
        }
        if (days.monday) {
            predicateString = "ANY classDays.days contains 'M'"
        }
        if (days.tuesday) {
            if (predicateString.isEmpty) { predicateString += "ANY classDays.days contains 'T'" }
            else { predicateString += " \(eitherAny) ANY classDays.days contains 'T'" }
        }
        if (days.wednesday) {
            if (predicateString.isEmpty) { predicateString += "ANY classDays.days contains 'W'" }
            else { predicateString += " \(eitherAny) ANY classDays.days contains 'W'" }
        }
        if (days.thursday) {
            if (predicateString.isEmpty) { predicateString += "ANY classDays.days contains 'R'" }
            else { predicateString += " \(eitherAny) ANY classDays.days contains 'R'" }
        }
        if (days.friday) {
            if (predicateString.isEmpty) { predicateString += "ANY classDays.days contains 'F'" }
            else { predicateString += " \(eitherAny) ANY classDays.days contains 'F'" }
        }
        
        if (!predicateString.isEmpty) {
            offerings = offerings.filter(predicateString)
        }
        
        if selections.startTime > 480 {
            offerings = offerings.filter("NOT (ANY classDays.startTime.value < %@)", selections.startTime)
        }
        if selections.endTime < 1320 {
            offerings = offerings.filter("NOT (ANY classDays.endTime.value > %@)", selections.endTime)
        }
        
        if selections.lowerNumber > 0 {
            offerings = offerings.filter("subjectNumber.integer > %@", selections.lowerNumber)
        }
        if selections.upperNumber < 9000 {
            offerings = offerings.filter("subjectNumber.integer < %@", selections.upperNumber)
        }

        var courses = realm.objects(Course.self).filter("ANY offerings IN %@", offerings)
        
        courses = courses.sorted(byKeyPath: String(describing: selections.sortBy.rawValue))
        return (courses: courses, offerings: offerings)
    }
    
    func getCategory(type: PersistanceManager.category) -> [String] {
        let realm = try! Realm()
        var array = [String]()
        switch type {
        case .Department:
            let results = realm.objects(Department.self)
            for result in results { array.append(result.name) }
        case .Instructor:
            let results = realm.objects(Instructor.self)
            for result in results { array.append(result.name) }
        case .CourseAttribute:
            let results = realm.objects(CourseAttribute.self)
            for result in results { array.append(result.name) }
        default:
            print("Shouldn't get here: PersistanceManager:119")
        }
        return array
    }
}


