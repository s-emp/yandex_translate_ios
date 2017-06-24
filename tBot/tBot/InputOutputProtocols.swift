protocol InputController {
    func add(messages: [Message])
    func ask(_ text: String)
    func getMessage(index: Int) -> Message?
}

protocol OutputController {
    
    func ask(_ text: String)
}
