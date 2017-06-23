import UIKit
import RealmSwift

class BotViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var fromLang: UIButton!
    @IBOutlet weak var toLang: UIButton!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var historyMessage: UITableView!
    
    var realmHistory: Results<Message>!
    var yandex: ClientAPI!
    var history: [Message] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yandex = ClientAPI()
        log.debug("Realm path: \(Realm.Configuration.defaultConfiguration.fileURL!)")
        message.delegate = self
        historyMessage.delegate = self
        historyMessage.dataSource = self
        historyMessage.rowHeight = UITableViewAutomaticDimension
        historyMessage.estimatedRowHeight = 36
        readHistoryAndUpdateUI()
    }
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        log.debug("Cell count: \(history.count)")
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch history[indexPath.row].typeMessage {
        case TypeMessage.bot.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "messageBot") as? MessageBotTableViewCell {
                cell.message = history[indexPath.row]
                return cell
            }
        case TypeMessage.user.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "messageUser") as? MessageUserTableViewCell {
                cell.message = history[indexPath.row]
                return cell
            }
        case TypeMessage.info.rawValue:
            fatalError("Не реализован switch на тип info cell")
        default:
            log.error("Получино необрабатываемое значение ячейки")
        }
        return UITableViewCell()
    }
    
    //MARK: Update UI
    func readHistoryAndUpdateUI() {
        readHistory()
        updateUI()
    }
    
    func readHistory() {
        realmHistory = RealmHelper.loadHistory()
        history = []
        for hist in realmHistory {
            history.append(hist)
        }
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.historyMessage.setEditing(false, animated: true)
            self.historyMessage.reloadData()
            self.scrollToBottom()
        }
    }
    
    func scrollToBottom(){
        if (history.count-1 >= 0) {
            let indexPath = IndexPath(row: self.history.count-1, section: 0)
            self.historyMessage.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    // MARK: Action
    @IBAction func touchSendMessage(_ sender: UIButton) {
        guard message.text != nil && !message.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            return
        }
        let messageSend = Message()
        messageSend.event = NSDate()
        messageSend.text = message.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        messageSend.typeMessage = TypeMessage.user.rawValue
        yandex.translate(text: messageSend.text) { response in
            switch response.code {
            case .success:
                let translate = Message()
                translate.event = NSDate()
                translate.typeMessage = TypeMessage.bot.rawValue
                translate.text = response.translate!.translate
                self.history.append(messageSend)
                self.history.append(translate)
                self.updateUI()
                RealmHelper.add(messageSend) { result in }
                RealmHelper.add(translate) { result in }
            default:
                break
            }
        }
        
    }
    
    @IBAction func touchSwitchMessage(_ sender: UIButton) {
        
    }
    
    // MARK: TextField
    
}
