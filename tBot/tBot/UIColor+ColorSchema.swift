import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    static let csDarkBackground = UIColor(red: 32, green: 35, blue: 40)
    static let csDarkView = UIColor(red: 41, green: 46, blue: 52)
    static let csDarkElement = UIColor(red: 48, green: 140, blue: 140)
    static let csDarkText = UIColor(red: 255, green: 255, blue: 255)
    
}
