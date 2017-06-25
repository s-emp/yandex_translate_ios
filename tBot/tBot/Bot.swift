import Foundation

class Bot: OutputController {
    private var controller: InputController!
    private var networkAPI = ClientAPI()
    
    var history: [Message] = []
    var favorites: [Favorit] = []
    var langs: [Lang] = []
    
    var pickedFromLang = 0
    var pickedToLang = 0
    
    // MARK: Protocol
    func ask(_ text: String) {
        log.debug("Боту передано: \(text)")
        guard !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            return
        }
        let message = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if text.substring(to: text.index(text.startIndex, offsetBy: 1)) == "/" {
            log.debug("Это внутренняя команда")
            inside(message: message)
        } else {
            log.debug("Это обычный перевод")
            let messageSend = Message()
            messageSend.event = NSDate()
            messageSend.text = message
            messageSend.typeMessage = TypeMessage.user.rawValue
            networkAPI.translate(text: messageSend.text) { response in
                switch response.code {
                case .success:
                    let translate = Message()
                    translate.event = NSDate()
                    translate.typeMessage = TypeMessage.bot.rawValue
                    translate.text = response.translate!.translate
                    RealmHelper.add(messageSend)
                    RealmHelper.add(translate)
                    self.history.append(messageSend)
                    self.history.append(translate)
                    self.controller.updateUI()
                    log.debug("\(text) успешно переведен: \(response.translate!.translate)")
                default:
                    log.error("Ошибка работы с сетью")
                    self.addInfo(message: "Произошла ошибка сети. Проверьте ваше соединение.")
                }
            }
        }
    }
    
    func getListLangs() -> [Lang] {
        return langs
    }
    
    func getHistory() -> [Message] {
        return history
    }
    
    func getPickedFromLang() -> Int {
        return pickedFromLang
    }
    func getPickedToLang() -> Int {
        return pickedToLang
    }
    
    private func inside(message: String) {
        let command = parsing(message)
        log.debug("Разберем внутреннюю команду: команда - \(command.command) с параметрами: \(command.params)")
        switch KeyWord.getKey(command.command) {
        case .help:
            self.addInfo(message: help())
        case .author:
            self.addInfo(message: author())
        case .unknows:
            self.addInfo(message: "Некорректное сообщение. Для помощи напишите \"/help\"")
        case .favorites:
            if command.params.count > 0 {
                favorites(command.params[0])
            } else {
                self.addInfo(message: "Некорректное сообщение. Для помощи напишите \"/help\"")
            }
        case .clear:
            clear()
        case .fromLanguage:
            if command.params.count > 0 {
                changeFromLanguage(command.params[0])
            } else {
                self.addInfo(message: "Некорректное сообщение. Для помощи напишите \"/help\"")
            }
        case .toLanguage:
            if command.params.count > 0 {
                changeToLanguage(command.params[0])
            } else {
                self.addInfo(message: "Некорректное сообщение. Для помощи напишите \"/help\"")
            }
        case .switchLang:
            let fromLang = networkAPI.fromLang
            networkAPI.fromLang = networkAPI.toLang
            networkAPI.toLang = fromLang
        }
    }
    
    func parsing(_ message: String) -> (command: String, params: [String]) {
        var allParam = message.components(separatedBy: " ")
        if allParam.count > 0 {
            let comand = allParam[0]
            allParam.remove(at: 0)
            return (comand, allParam)
        } else {
            return ("",[])
        }
        
    }
    
    func help() -> String {
        return "Добро пожаловать! В данный момент работают следующие слежебные ключи:\n/help - справка\n/author - о авторе\n/favorites <n> - добавить в избранное сообщение под индексом <n>. Добавляется исходное сообщение и его перевод.\n/clr - очистить экран от справочной информации\n/from <code> - изменить язык с которого переводим - code = ru, en …\n/to <code> - изменить язык на который переводим - code = ru, en …\n/switchLang - поменять язык с которого переводим местами с языком на который переводим"
    }
    
    func author() -> String {
        return "Версия 1.2\nCopyright© 2017 Emp"
    }
    
    func favorites(_ index: String) {
        guard let indexMessage = Int(index) else {
            self.addInfo(message: "Некорректное сообщение. Для помощи напишите \"/help\"")
            return
        }
        if indexMessage >= 0 && indexMessage < history.count {
            let message = history[indexMessage]
            let typeMessage = TypeMessage.getTypeMessage(type: message.typeMessage)
            switch typeMessage! {
            case .bot:
                if indexMessage - 1 >= 0 {
                    let userMessage = history[indexMessage - 1]
                    let fav = Favorit()
                    fav.source = userMessage
                    fav.translate = message
                    RealmHelper.add(fav)
                    self.addInfo(message: "Фраза успешно добавлена в избранное!")
                } else {
                    self.addInfo(message: "Внутренняя ошибка, сожалею :(")
                }
            case .user:
                if indexMessage + 1 < history.count {
                    let botMessage = history[indexMessage + 1]
                    let fav = Favorit()
                    fav.source = botMessage
                    fav.translate = message
                    RealmHelper.add(fav)
                    self.addInfo(message: "Фраза успешно добавлена в избранное!")
                } else {
                    self.addInfo(message: "Внутренняя ошибка, сожалею :(")
                }
            case .info:
                self.addInfo(message: "Нельзя информационные сообщения добавлять в избранное :)")
            }
        } else {
            self.addInfo(message: "Передан не корректный параметр в /favorite. Смотрите /help")
        }
    }
    
    func clear() {
        history = history.filter() {
            return $0.typeMessage == TypeMessage.info.rawValue ? false: true
        }
        controller.updateUI()
    }
    
    func changeFromLanguage(_ lang: String) {
        log.debug("Изменяем язык с которого переводим. Был: \(networkAPI.fromLang) стал: \(lang)")
        networkAPI.fromLang = lang
    }
    
    func changeToLanguage(_ lang: String) {
        log.debug("Изменяем язык на который переводим. Был: \(networkAPI.toLang) стал: \(lang)")
        networkAPI.toLang = lang
    }
    
    func getLangs() {
        if langs.isEmpty {
            networkAPI.getListLang() { response in
                switch response.code {
                case .success:
                    self.langs = response.list!.sorted() { return $0.name < $1.name ? true : false }
                    for (index, lang) in self.langs.enumerated() {
                        if lang.name == "Русский" {
                            self.pickedFromLang = index
                        }
                        if lang.name == "Английский" {
                            self.pickedToLang = index
                        }
                    }
                default:
                    log.error("Не реализованная ветка событий")
                }
            }
        } else {
            
        }
    }
    
    func addInfo(message: String) {
        let info = Message()
        info.typeMessage = TypeMessage.info.rawValue
        info.text = message
        self.history.append(info)
        self.controller.updateUI()
    }
    
    // MARK: Init
    init(_ controller: InputController) {
        self.controller = controller
        getLangs()
        let realmHistory = RealmHelper.loadHistory()
        for hist in realmHistory {
            history.append(hist)
        }
    }
}
