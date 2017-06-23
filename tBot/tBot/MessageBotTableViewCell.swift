//
//  MessageTableViewCell.swift
//  tBot
//
//  Created by Сергей Мельников on 21/06/2017.
//  Copyright © 2017 Сергей Мельников. All rights reserved.
//

import UIKit

class MessageBotTableViewCell: UITableViewCell {
    var message: Message? {
        willSet {
            guard newValue != nil else { return }
            switch newValue!.typeMessage {
            case TypeMessage.bot.rawValue:
                messageBot.text = "\(newValue!.text)"
                messageBot.layer.backgroundColor = UIColor.csDarkElement.cgColor
                messageBot.textColor = UIColor.csDarkText
                messageBot.layer.cornerRadius = 8
                messageBot.clipsToBounds = true
            default:
                log.error("MessageCellBot передано сообщение не от бота")
                break
            }
            
        }
    }

    @IBOutlet weak var iconBot: UIImageView!
    @IBOutlet weak var messageBot: MessageLabel!

}
