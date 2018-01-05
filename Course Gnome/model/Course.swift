import Foundation
import RealmSwift

class Course: Object {
    @objc dynamic var courseID: Int = 0
    @objc dynamic var department: Department? = nil
    @objc dynamic var subjectNumber: String = ""
    @objc dynamic var courseName: String = ""
    @objc dynamic var credit: String = ""
    let offerings = List<Offering>()
}

class Offering: Course {
    @objc dynamic var status: Status? = nil
    @objc dynamic var crn: CRN? = nil
    @objc dynamic var bulletinLink: String = ""
    @objc dynamic var sectionNumber: String = ""
    let instructors = List<Instructor>()
    let classDays = List<ClassDay>()
    @objc dynamic var start: String = ""
    @objc dynamic var end: String = ""
    @objc dynamic var comment: String = ""
    @objc dynamic var oldCourseNumber: String = ""
    @objc dynamic var findBooksLink: String = ""
    let xList = List<Course>()
    let linked = List<Course>()
    let courseAttributes = List<CourseAttribute>()
    @objc dynamic var fee: String = ""
}

class Department: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var acronym: String = ""
}

class CRN: Object {
    @objc dynamic var name: String = ""
}

class Status: Object {
    @objc dynamic var name: String = ""
}

class Instructor: Object {
    @objc dynamic var name: String = ""
}

class CourseAttribute: Object {
    @objc dynamic var name: String = ""
}

class ClassDay: Object {
    @objc dynamic var days : String = ""
    @objc dynamic var location: String = ""
    @objc dynamic var startTime = Date()
    @objc dynamic var endTime = Date()
}

class LastRevised: Object {
    @objc dynamic var lastRevised: String = ""
}

class SavedSearch: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var search: String = ""
    @objc dynamic var searchCategory: String = ""
}

