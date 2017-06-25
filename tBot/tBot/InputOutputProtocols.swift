protocol InputController {
    func updateUI()
}

protocol OutputController {
    
    func ask(_ text: String)
    func getListLangs() -> [Lang]
    func getHistory() -> [Message]
    func getPickedFromLang() -> Int
    func getPickedToLang() -> Int
}
