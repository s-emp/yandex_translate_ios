//
//  MessageTableViewCell.swift
//  tBot
//
//  Created by Сергей Мельников on 21/06/2017.
//  Copyright © 2017 Сергей Мельников. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    var message: Message? {
        willSet {
            guard newValue != nil else { return }
            switch newValue!.typeMessage {
            case .bot:
                messageBot.text = "\(newValue!.text)"
                messageBot.layer.backgroundColor = UIColor.csDarkElement.cgColor
                messageBot.textColor = UIColor.csDarkText
                messageBot.clipsToBounds = true
            default:
                log.error("В ячейку с сообщением бота, передано сообщение не бота!")
            }
        }
    }

    @IBOutlet weak var iconBot: UIImageView!
    @IBOutlet weak var messageBot: MessageLabel!

}
