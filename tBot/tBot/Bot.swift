import Foundation

class Bot: OutputController {
    private var controller: InputController!
    private var networkAPI = ClientAPI()
    
    func ask(_ text: String) {
        log.debug(text)
        guard !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            return
        }
        let message = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if text.substring(to: text.index(text.startIndex, offsetBy: 1)) == "/" {
            inside(message: message)
        } else {
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
                    self.controller.add(messages: [messageSend, translate])
                default:
                    break
                }
            }
        }
    }
    
    private func inside(message: String) {
        
        switch KeyWord.getKey(message) {
        case .help:
            controller.ask(help())
        case .author:
            controller.ask(author())
        case .unknows:
            controller.ask("Некорректное сообщение. Для помощи напишите \"/help\"")
        case .favorites:
            favorites(message: message)
        }
    }
    
    func help() -> String {
        return "Добро пожаловать! В данный момент работают следующие слежебные ключи:\n/help - отображение списка всех ключей. "
    }
    
    func author() -> String {
        return "Версия 1.1\nCopyright© 2017 Emp"
    }
    
    func favorites(message: String) {
        guard let index = message.range(of: " "),
            let indexMessage = Int(message.substring(from: index.lowerBound).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)),
            let message = controller.getMessage(index: indexMessage),
            let typeMessage = TypeMessage.getTypeMessage(type: message.typeMessage) else {
            controller.ask("Передан не корректный параметр в /favorite. Смотрите /help")
            return
        }
        
        switch typeMessage {
        case .bot:
            guard let userMessage = controller.getMessage(index: indexMessage - 1) else {
                controller.ask("Внутренняя ошибка, сожалею :(")
                return
            }
            let fav = Favorit()
            fav.source = userMessage
            fav.translate = message
            RealmHelper.add(fav)
            controller.ask("Фраза успешно добавлена в избранное!")
        case .user:
            guard let botMessage = controller.getMessage(index: indexMessage + 1) else {
                controller.ask("Внутренняя ошибка, сожалею :(")
                return
            }
            let fav = Favorit()
            fav.source = botMessage
            fav.translate = message
            RealmHelper.add(fav)
            controller.ask("Фраза успешно добавлена в избранное!")
        case .info:
            controller.ask("Нельзя информационные сообщения добавлять в избранное :)")
        }
    }
    
    init(_ controller: InputController) {
        self.controller = controller
    }
}
