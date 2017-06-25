enum KeyWord: String {
    case help = "/help", author = "/author", unknows, favorites = "/favorites", clear = "/clr",
    fromLanguage = "/from", toLanguage = "/to", switchLang = "/switchLang"
    
    static func getKey(_ message: String) -> KeyWord {
        let index = message.range(of: " ")
        var key: String
        if index != nil {
            key = message.substring(to: index!.lowerBound)
        } else {
            key = message
        }
        switch key {
        case "/help":
            return .help
        case "/author":
            return .author
        case "/favorites":
            return .favorites
        case "/clr":
            return.clear
        case "/from":
            return .fromLanguage
        case "/to":
            return .toLanguage
        case "/switchLang":
            return .switchLang
        default:
            return .unknows
        }
    }
}
