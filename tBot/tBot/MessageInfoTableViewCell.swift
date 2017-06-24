import UIKit

class MessageInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var messageUI: MessageLabel!
    
    var message: Message? {
        willSet {
            guard newValue != nil else { return }
            switch newValue!.typeMessage {
            case TypeMessage.info.rawValue:
                messageUI.text = "\(newValue!.text)"
                messageUI.layer.backgroundColor = UIColor.csDarkElement.cgColor
                messageUI.textColor = UIColor.csDarkText
                messageUI.layer.cornerRadius = 8
                messageUI.clipsToBounds = true
            default:
                log.error("MessageCellInfo передано сообщение не info")
                break
            }
            
        }
    }
}
