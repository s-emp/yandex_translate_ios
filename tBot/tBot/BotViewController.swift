//
//  BotViewController.swift
//  tBot
//
//  Created by Сергей Мельников on 21/06/2017.
//  Copyright © 2017 Сергей Мельников. All rights reserved.
//

import UIKit

class BotViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var fromLang: UIButton!
    @IBOutlet weak var toLang: UIButton!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var put: UIImageView!
    @IBOutlet weak var historyMessage: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        historyMessage.delegate = self
        historyMessage.dataSource = self
        historyMessage.rowHeight = UITableViewAutomaticDimension
        historyMessage.estimatedRowHeight = 36
    }
    
    //MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "message") as? MessageTableViewCell {
            cell.message = Message(typeMessage: .bot, text: "Привет, это тестовый прогон! Не волнуйся!")
            return cell
        }
        return UITableViewCell()
    }

}
