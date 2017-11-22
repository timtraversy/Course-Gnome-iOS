import Foundation
import RealmSwift

class Course: Object {
    @objc dynamic var status: String = ""
    @objc dynamic var crn: String = ""
    @objc dynamic var subjectAcronym: String = ""
    @objc dynamic var subjectName: String = ""
    @objc dynamic var subjectNumber: String = ""
    @objc dynamic var bulletinLink: String = ""
    @objc dynamic var sectionNumber: String = ""
    @objc dynamic var courseName: String = ""
    @objc dynamic var credit: String = ""
    let instructor = List<String>()
    let classDays = List<ClassDay>()
    @objc dynamic var start: String = ""
    @objc dynamic var end: String = ""
    @objc dynamic var comment: String = ""
    @objc dynamic var oldCourseNumber: String = ""
    @objc dynamic var findBooksLink: String = ""
    let xList = List<Course>()
    let linked = List<Course>()
    let courseAttributes = List<String>()
    @objc dynamic var fee: String = ""
}

class ClassDay: Object {
    let days = List<Bool>()
    @objc dynamic var location: String = ""
    @objc dynamic var startTime: String = ""
    @objc dynamic var endTime: String = ""
}
