import Foundation
import RealmSwift

class CourseDatabase {
    
    func getStuff() {

        let realm = try! Realm()
        
        let results = realm.objects(Course.self)
        
        let object = results[0]
        let days = object.courseName

        print ("Count: \(results.count)")
        print ("Days: \(days)")
        
    }
}
