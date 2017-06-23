import RealmSwift
import Foundation

class RealmHelper {
    static let dbUI = try! Realm()
    
    static func loadHistory() -> Results<Message> {
        return dbUI.objects(Message.self)
    }
    
    static func add(_ obj: Object, callback: @escaping (Bool)->()) {
        DispatchQueue.main.async {
            do {
                try dbUI.write() {
                    dbUI.add(obj)
                }
                callback(true)
            } catch let error {
                log.error(error.localizedDescription)
                callback(false)
            }
        }
    }
}
