enum ResponseCode {
    case unknows, success, forbidden, notCorrectKey, lockedKey, limitExceeded, canNotTranslate, notSupported, noConnect, errorJSON
    
    func info() -> String {
        switch self {
        case .unknows:
            return "Неизвестная ошибка"
        case .success:
            return "Операция успешно завершина"
        case .forbidden:
            return "Сервер не может обработать запрос"
        case .notCorrectKey:
            return "Некорректный API-ключ"
        case .lockedKey:
            return "API-ключ заблокирован"
        case .limitExceeded:
            return "Превышено суточное ограничение на объем переведенного текста"
        case .canNotTranslate:
            return "Текст не может быть переведен"
        case .notSupported:
            return "Заданное направление перевода не поддерживается"
        case .noConnect:
            return "Нету соединения с интернетом"
        case .errorJSON:
            return "Ошибка преобразования ответа в JSON"
        }
    }
    
    func code() -> Int {
        switch self {
        case .unknows:
            return 0
        case .noConnect:
            return 1
        case .errorJSON:
            return 2
        case .success:
            return 200
        case .forbidden:
            return 403
        case .notCorrectKey:
            return 401
        case .lockedKey:
            return 402
        case .limitExceeded:
            return 404
        case .canNotTranslate:
            return 422
        case .notSupported:
            return 501
        }
    }
}
