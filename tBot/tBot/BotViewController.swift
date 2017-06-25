import UIKit
import RealmSwift

class BotViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, InputController {
    
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
    
    var alert: UIAlertController!
    
    var bot: OutputController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("Первоначальная настройка")
        
        bot = Bot(self)
        
        effectViewLang.layer.cornerRadius = 25
        viewLang.layer.cornerRadius = 25
        effectViewLang.clipsToBounds = true
        
        listLangs.delegate = self
        listLangs.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        indicatorLoading.color = UIColor.csDarkElement
        indicatorLoading.isHidden = false
        log.debug("Realm path: \(Realm.Configuration.defaultConfiguration.fileURL!)")
        message.delegate = self
        historyMessage.delegate = self
        historyMessage.dataSource = self
        historyMessage.rowHeight = UITableViewAutomaticDimension
        historyMessage.estimatedRowHeight = 36
        log.debug("Первоначальная настройка завершена")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollToBottom()
        indicatorLoading.isHidden = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bot.getHistory().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch bot.getHistory()[indexPath.row].typeMessage {
        case TypeMessage.bot.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "messageBot") as? MessageBotTableViewCell {
                cell.message = bot.getHistory()[indexPath.row]
                return cell
            }
        case TypeMessage.user.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "messageUser") as? MessageUserTableViewCell {
                cell.message = bot.getHistory()[indexPath.row]
                return cell
            }
        case TypeMessage.info.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "messageInfo") as? MessageInfoTableViewCell {
                cell.message = bot.getHistory()[indexPath.row]
                return cell
            }
        default:
            log.error("Получино необрабатываемое значение ячейки")
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let favorit = UITableViewRowAction(style: .default, title: "Изб.") { action, index in
            self.bot.ask("\(KeyWord.favorites.rawValue) \(index.row)")
        }
        favorit.backgroundColor = UIColor.csDarkElement
        return [favorit]
    }
    
    //MARK: Update UI
    func scrollToBottom(){
        if (bot.getHistory().count-1 >= 0) {
            let indexPath = IndexPath(row: self.bot.getHistory().count-1, section: 0)
            self.historyMessage.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    // MARK: Action
    @IBAction func touchSendMessage(_ sender: UIButton) {
        guard message.text != nil && !message.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            return
        }
        indicatorLoading.isHidden = false
        message.isEnabled = false
        bot.ask(message.text!)
        message.text = ""
    }
    
    @IBAction func touchSwitchMessage(_ sender: UIButton) {
        let lang = fromLang.title(for: .normal)
        fromLang.setTitle(toLang.title(for: .normal), for: .normal)
        toLang.setTitle(lang, for: .normal)
        bot.ask(KeyWord.switchLang.rawValue)
    }
    
    @IBAction func touchLang(_ sender: UIButton) {
        guard effectViewLang.isHidden else {
            return
        }
        effectViewLang.isHidden = false
        listLangs.reloadAllComponents()
        if sender.tag == 1 {
            listLangs.selectRow(bot.getPickedFromLang(), inComponent: 0, animated: false)
            listLangs.tag = 1
            changingLang.text = "Выберите язык с которого переводим"
        } else {
            listLangs.selectRow(bot.getPickedToLang(), inComponent: 0, animated: false)
            listLangs.tag = 2
            changingLang.text = "Выберите язык на который переводим"
        }
    }
    
    @IBAction func touchChangeLang(_ sender: UIButton) {
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
        return bot.getListLangs()[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bot.getListLangs().count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        log.debug("Picked: \(bot.getListLangs()[row].name)")
        if pickerView.tag == 1 {
            bot.ask("\(KeyWord.fromLanguage.rawValue) \(bot.getListLangs()[row].name)")
        } else if pickerView.tag == 2 {
            bot.ask("\(KeyWord.toLanguage.rawValue) \(bot.getListLangs()[row].name)")
        } else {
            log.error("Ошибка tag у pickedView: \(pickerView.tag)")
        }
    }
    
    //MARK: Protocol InputController
    func updateUI() {
        DispatchQueue.main.async {
            self.historyMessage.setEditing(false, animated: true)
            self.historyMessage.reloadData()
            self.scrollToBottom()
            self.message.isEnabled = true
            self.indicatorLoading.isHidden = true
        }
    }
}
