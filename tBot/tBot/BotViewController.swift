import UIKit
import RealmSwift

class BotViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var botMainView: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var fromLang: UIButton!
    @IBOutlet weak var toLang: UIButton!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var historyMessage: UITableView!
    @IBOutlet weak var indicatorLoading: UIActivityIndicatorView!
    
    // Elemen change lang
    @IBOutlet weak var effectViewLang: UIVisualEffectView!
    @IBOutlet weak var viewLang: UIView!
    @IBOutlet weak var changingLang: UILabel!
    @IBOutlet weak var listLangs: UIPickerView!
    
    var pickedFromLang = 0
    var pickedToLang = 0
    
    var alert: UIAlertController!
    var realmHistory: Results<Message>!
    var yandex: ClientAPI!
    var history: [Message] = []
    var listLang: [Lang] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        effectViewLang.layer.cornerRadius = 25
        viewLang.layer.cornerRadius = 25
        effectViewLang.clipsToBounds = true
        
        listLangs.delegate = self
        listLangs.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        indicatorLoading.color = UIColor.csDarkElement
        indicatorLoading.isHidden = false
        yandex = ClientAPI()
        yandex.getListLang() { response in
            switch response.code {
            case .success:
                self.listLang = response.list!.sorted() { return $0.name < $1.name ? true : false }
                for (index, lang) in self.listLang.enumerated() {
                    if lang.name == self.fromLang.title(for: .normal) {
                        self.pickedFromLang = index
                    }
                    if lang.name == self.toLang.title(for: .normal) {
                        self.pickedToLang = index
                    }
                }
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
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
            self.historyMessage.scrollToRow(at: indexPath, at: .bottom, animated: false)
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
        let lang = fromLang.title(for: .normal)
        fromLang.setTitle(toLang.title(for: .normal), for: .normal)
        toLang.setTitle(lang, for: .normal)
        yandex.switchLang()
    }
    
    @IBAction func touchLang(_ sender: UIButton) {
        guard effectViewLang.isHidden else {
            return
        }
        effectViewLang.isHidden = false
        listLangs.reloadAllComponents()
        if sender.tag == 1 {
            listLangs.selectRow(pickedFromLang, inComponent: 0, animated: false)
            listLangs.tag = 1
            changingLang.text = "Выберите язык с которого переводим"
        } else {
            listLangs.selectRow(pickedToLang, inComponent: 0, animated: false)
            listLangs.tag = 2
            changingLang.text = "Выберите язык на который переводим"
        }
    }
    
    @IBAction func touchChangeLang(_ sender: UIButton) {
        yandex.fromLang = listLang[pickedFromLang].code
        yandex.toLang = listLang[pickedToLang].code
        fromLang.setTitle(listLang[pickedFromLang].name, for: .normal)
        toLang.setTitle(listLang[pickedToLang].name, for: .normal)
        effectViewLang.isHidden = true
    }
    
    
    
    // MARK: TextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        touchSendMessage(fromLang)
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Keyboard
    // Событие обработки появления клавиатуры
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.botMainView.constant = keyboardSize.height
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                self.scrollToBottom()
            }
        }
    }
    
    // Событие обработки скрытия клавиатуры
    func keyboardWillHide(notification: NSNotification) {
        self.botMainView.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Pick
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return listLang[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listLang.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        log.debug("Picked: \(listLang[row].name)")
        if pickerView.tag == 1 {
            pickedFromLang = row
        } else if pickerView.tag == 2 {
            pickedToLang = row
        } else {
            log.error("Ошибка tag у pickedView: \(pickerView.tag)")
        }
    }
    
}
