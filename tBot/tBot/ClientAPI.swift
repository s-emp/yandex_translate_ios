import SwiftyBeaver
import SwiftHTTP
import SwiftyJSON

class ClientAPI {
    typealias ResponseAPI = (ResponseCode, Tranlsate?)
    
    private let APIKey = "trnsl.1.1.20170411T084541Z.7d7dcebbee0cae59.2dfcbbe761fa05823160d774ccc226a3b2b68fd0"
    private let baseURL = "https://translate.yandex.net/"
    private let translateURL = "api/v1.5/tr.json/translate"
    
    var fromLang = "ru"
    var toLang = "en"
    
    func translate(text: String, callback: @escaping (ResponseAPI) -> ()) {
        let params = ["key": APIKey, "text": text, "lang": "\(fromLang)-\(toLang)"]
        do {
            try HTTP.POST(baseURL + translateURL, parameters: params).start() { response in
                guard let code = response.statusCode else {
                    log.error("Response code is nil: \(response.description)")
                    callback(ResponseAPI(ResponseCode.noConnect, nil))
                    return
                }
                switch code {
                case 200:
                    log.debug("Translate success: \(response.text!)")
                    let translate = Tranlsate(json: JSON(data: response.data))
                    guard translate != nil else {
                        callback(ResponseAPI(ResponseCode.errorJSON, nil))
                        return
                    }
                    switch translate!.code {
                    case 200:
                        callback(ResponseAPI(ResponseCode.success, translate))
                    case 401:
                        callback(ResponseAPI(ResponseCode.notCorrectKey, nil))
                    case 402:
                        callback(ResponseAPI(ResponseCode.lockedKey, nil))
                    case 404:
                        callback(ResponseAPI(ResponseCode.limitExceeded, nil))
                    case 422:
                        callback(ResponseAPI(ResponseCode.canNotTranslate, nil))
                    case 501:
                        callback(ResponseAPI(ResponseCode.success, nil))
                    default:
                        callback(ResponseAPI(ResponseCode.unknows, nil))
                    }
                default:
                    log.error("Error other code: \(code)")
                    callback(ResponseAPI(ResponseCode.unknows, nil))
                }
            }
        } catch let error {
            log.error(error.localizedDescription)
            callback(ResponseAPI(ResponseCode.noConnect, nil))
        }
    }
}
