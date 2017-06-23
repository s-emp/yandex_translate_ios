import UIKit

class MessageUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageUI: MessageLabel!
    
    var message: Message? {
        willSet {
            guard newValue != nil else { return }
            switch newValue!.typeMessage {
            case TypeMessage.user.rawValue:
                messageUI.text = "\(newValue!.text)"
                messageUI.layer.backgroundColor = UIColor.csDarkView.cgColor
                messageUI.textColor = UIColor.csDarkText
                messageUI.layer.cornerRadius = 8
                messageUI.clipsToBounds = true
            default:
                log.error("MessageCellUser передано сообщение не от пользователя")
                break
            }
            
        }
    }

}
