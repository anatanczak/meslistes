

//!!!DO IT IN Views LAYOUT SUBVIEWS

import UIKit

public enum UIButtonBorderSide {
    case Top, Bottom, Left, Right
}

extension UIButton {
    
    public func addBorder(side: UIButtonBorderSide, color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        
        switch side {
        case .Top:
            border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: width)
        case .Bottom:
            border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        case .Left:
            border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        case .Right:
            border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        
        }
        
        self.layer.addSublayer(border)
    }
    
}

//Border dlya main View

//extension UIView {
//
//public func addBorderMainView(side: UIButtonBorderSide, color: UIColor, width: CGFloat) {
//    let border = CALayer()
//    border.backgroundColor = color.cgColor
//
////    DARRRRK
//    border.cornerRadius = 0.0
//   border.borderColor = color.cgColor
//
//    switch side {
//    case .Top:
//        border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: width)
//    case .Bottom:
//        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
//    case .Left:
//        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
//    case .Right:
//        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
//    }
//
//    self.layer.addSublayer(border)
//}
//}
