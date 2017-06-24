enum TypeMessage: Int {
    case bot = 0, user, info
    
    static func getTypeMessage(type: Int) -> TypeMessage? {
        switch type {
        case 0:
            return .bot
        case 1:
            return .user
        case 2:
            return .info
        default:
            return nil
        }
    }
}
