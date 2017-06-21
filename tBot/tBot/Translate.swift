import SwiftyJSON

class Tranlsate {
    var code: Int
    var lang: String
    private var text: [String]
    var translate: String {
        return text.joined(separator: "\n")
    }
    
    init(code: Int, lang: String, text: [String]) {
        self.code = code
        self.lang = lang
        self.text = text
    }
    
    init?(json: JSON) {
        guard let code = json["code"].int,
            let lang = json["lang"].string,
            let text = json["text"].arrayObject as? [String] else {
                return nil
        }
        self.code = code
        self.lang = lang
        self.text = text
    }
}
