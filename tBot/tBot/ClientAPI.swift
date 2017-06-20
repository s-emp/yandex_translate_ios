import SwiftyBeaver
import SwiftHTTP
import SwiftyJSON

class ClientAPI {
    typealias ResponseAPI = (Int, String)
    
    var fromLang = "ru"
    var toLang = "en"
    
    func translate(text: String, callback: @escaping (ResponseAPI) -> ()) {
        
    }
}
