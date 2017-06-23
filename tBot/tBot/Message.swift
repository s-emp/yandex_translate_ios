import Foundation
import RealmSwift

class Message: Object {
    
    dynamic var event = NSDate()
    dynamic var text = ""
    dynamic var typeMessage = 0
    
}
