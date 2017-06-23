import UIKit
import RealmSwift

class BotViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var fromLang: UIButton!
    @IBOutlet weak var toLang: UIButton!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var historyMessage: UITableView!
    @IBOutlet weak var indicatorLoading: UIActivityIndicatorView!
    
    
    var alert: UIAlertController!
    var realmHistory: Results<Message>!
    var yandex: ClientAPI!
    var history: [Message] = []
    var listLang: [Lang] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicatorLoading.color = UIColor.csDarkElement
        indicatorLoading.isHidden = false
        yandex = ClientAPI()
        yandex.getListLang() { response in
            switch response.code {
            case .success:
                self.listLang = response.list!
            default:
                log.error("Не реализованная ветка событий")
            }
        }
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let favorit = UITableViewRowAction(style: .default, title: "Изб.") { action, index in
            let result = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            if let cell = tableView.cellForRow(at: indexPath) as? MessageBotTableViewCell {
                let fav = Favorit()
                fav.source = self.history[indexPath.row - 1]
                fav.translate = cell.message!
                result.title = "Избранное"
                result.message = "Успешно добавлено!"
                RealmHelper.add(fav)
            } else if let cell = tableView.cellForRow(at: indexPath) as? MessageUserTableViewCell {
                let fav = Favorit()
                fav.source = cell.message!
                fav.translate = self.history[indexPath.row + 1]
                result.title = "Избранное"
                result.message = "Успешно добавлено!"
                RealmHelper.add(fav)
            } else {
                result.title = "Ошибка"
                result.message = "В избранное можно добавлять только перевод!"
            }
            self.present(result, animated: true)
            
            let when = DispatchTime.now() + 1.5
            DispatchQueue.main.asyncAfter(deadline: when){
                // your code with delay
                result.dismiss(animated: true, completion: nil)
            }
        }
        favorit.backgroundColor = UIColor.csDarkElement
        return [favorit]
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
            self.indicatorLoading.isHidden = true
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
        indicatorLoading.isHidden = false
        let messageSend = Message()
        messageSend.event = NSDate()
        messageSend.text = message.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        messageSend.typeMessage = TypeMessage.user.rawValue
        message.text = ""
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
                RealmHelper.add(messageSend)
                RealmHelper.add(translate)
            default:
                break
            }
        }
        
    }
    
    @IBAction func touchSwitchMessage(_ sender: UIButton) {
        
    }
    
    @IBAction func touchLang(_ sender: UIButton) {
        self.present(alert, animated: true)
    }
    
    
    // MARK: TextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        touchSendMessage(fromLang)
        return true
    }
}
