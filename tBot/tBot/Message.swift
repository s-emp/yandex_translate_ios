class Message {
    var typeMessage: TypeMessage
    var text: String
    
    init(typeMessage: TypeMessage = .user, text: String) {
        self.typeMessage = typeMessage
        self.text = text
    }
}
