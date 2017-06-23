import SwiftyBeaver
import SwiftHTTP
import SwiftyJSON

class ClientAPI {
    typealias ResponseTranslate = (code: ResponseCode, translate: Tranlsate?)
    typealias ResponseGetListLang = (code: ResponseCode, list: [Lang]?)
    
    private let APIKey = "trnsl.1.1.20170411T084541Z.7d7dcebbee0cae59.2dfcbbe761fa05823160d774ccc226a3b2b68fd0"
    private let baseURL = "https://translate.yandex.net/"
    private let translateURL = "api/v1.5/tr.json/translate"
    private let getListLangURL = "/api/v1.5/tr.json/getLangs"
    
    var fromLang = "ru"
    var toLang = "en"
    
    func translate(text: String, callback: @escaping (ResponseTranslate) -> ()) {
        let params = ["key": APIKey, "text": text, "lang": "\(fromLang)-\(toLang)"]
        do {
            try HTTP.POST(baseURL + translateURL, parameters: params).start() { response in
                guard let code = response.statusCode else {
                    log.error("Response code is nil: \(response.description)")
                    callback(ResponseTranslate(ResponseCode.noConnect, nil))
                    return
                }
                switch code {
                case 200:
                    log.debug("Translate success: \(response.text!)")
                    let translate = Tranlsate(json: JSON(data: response.data))
                    guard translate != nil else {
                        callback(ResponseTranslate(ResponseCode.errorJSON, nil))
                        return
                    }
                    switch translate!.code {
                    case 200:
                        callback(ResponseTranslate(ResponseCode.success, translate))
                    case 401:
                        callback(ResponseTranslate(ResponseCode.notCorrectKey, nil))
                    case 402:
                        callback(ResponseTranslate(ResponseCode.lockedKey, nil))
                    case 404:
                        callback(ResponseTranslate(ResponseCode.limitExceeded, nil))
                    case 422:
                        callback(ResponseTranslate(ResponseCode.canNotTranslate, nil))
                    case 501:
                        callback(ResponseTranslate(ResponseCode.success, nil))
                    default:
                        callback(ResponseTranslate(ResponseCode.unknows, nil))
                    }
                default:
                    log.error("Error other code: \(code)")
                    callback(ResponseTranslate(ResponseCode.unknows, nil))
                }
            }
        } catch let error {
            log.error(error.localizedDescription)
            callback(ResponseTranslate(ResponseCode.noConnect, nil))
        }
    }
    
    func getListLang(_ ui: String = "ru", callback: @escaping (ResponseGetListLang) -> ()) {
        let params = ["ui": ui, "key": APIKey]
        do {
            try HTTP.POST(baseURL + getListLangURL, parameters: params).start() { response in
                guard let code = response.statusCode else {
                    log.error("Response code is nil: \(response.description)")
                    callback(ResponseGetListLang(ResponseCode.noConnect, nil))
                    return
                }
                switch code {
                case 200:
                    guard let langs = JSON(data: response.data)["langs"].dictionary else {
                        callback(ResponseGetListLang(ResponseCode.errorJSON, nil))
                        return
                    }
                    var resultLangs: [Lang] = []
                    for (code, lang) in langs {
                        resultLangs.append(Lang(code, name: lang.string!))
                    }
                    guard !resultLangs.isEmpty else {
                        callback(ResponseGetListLang(ResponseCode.errorJSON, nil))
                        return
                    }
                    callback(ResponseGetListLang(ResponseCode.success, resultLangs))
                default:
                    log.error("Error other code: \(code)")
                    callback(ResponseGetListLang(ResponseCode.unknows, nil))
                }
            }
        } catch let error {
            log.error(error.localizedDescription)
            callback(ResponseGetListLang(ResponseCode.noConnect, nil))
        }
    }
}
