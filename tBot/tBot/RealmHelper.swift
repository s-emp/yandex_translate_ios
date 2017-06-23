import RealmSwift
import Foundation

class RealmHelper {
    static let dbUI = try! Realm()
    
    static func loadHistory() -> Results<Message> {
        return dbUI.objects(Message.self)
    }
    
    static func add(_ obj: Object) {
        DispatchQueue.main.async {
            try! dbUI.write() {
                dbUI.add(obj)
            }
        }
    }
}
