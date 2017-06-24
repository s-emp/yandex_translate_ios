enum KeyWord: String {
    case help = "/help", author = "/author", unknows, favorites = "/favorites"
    
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
        default:
            return .unknows
        }
    }
}
