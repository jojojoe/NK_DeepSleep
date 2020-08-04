//
//  SimplyExtension.swift
//  guru_iOS
//
//  Created by Di on 2018/12/6.
//  Copyright © 2018 gelonghui. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    @discardableResult
    func crop() -> Self {
        contentMode()
        clipsToBounds()
        return self
    }

    @discardableResult
    func alpha(_ value: CGFloat) -> Self {
        alpha = value
        return self
    }

    @discardableResult
    func hidden(_ value: Bool = true) -> Self {
        isHidden = value
        return self
    }
    
    @discardableResult
    func show(_ value: Bool = true) -> Self {
        isHidden = !value
        return self
    }

    @discardableResult
    func cornerRadius(_ value: CGFloat, masksToBounds: Bool = true) -> Self {
        layer.cornerRadius = value
        layer.masksToBounds = masksToBounds
        return self
    }

    @discardableResult
    func borderColor(_ value: UIColor, width: CGFloat = UIScreen.minLineWidth) -> Self {
        layer.borderColor = value.cgColor
        layer.borderWidth = width
        return self
    }

    @discardableResult
    func contentMode(_ value: UIView.ContentMode = .scaleAspectFill) -> Self {
        contentMode = value
        return self
    }

    @discardableResult
    func clipsToBounds(_ value: Bool = true) -> Self {
        clipsToBounds = value
        return self
    }

    @discardableResult
    func tag(_ value: Int) -> Self {
        tag = value
        return self
    }

    @discardableResult
    func tintColor(_ value: UIColor) -> Self {
        tintColor = value
        return self
    }

    @discardableResult
    func backgroundColor(_ value: UIColor) -> Self {
        backgroundColor = value
        return self
    }

    @discardableResult
    func isUserInteractionEnabled(_ value: Bool = true) -> Self {
        isUserInteractionEnabled = value
        return self
    }
}

public extension UIFont {
    enum FontNames: String {
        case AvenirNextCondensedDemiBold = "AvenirNextCondensed-DemiBold"
        case AvenirNextDemiBold = "AvenirNext-DemiBold "
        case AvenirNextBold = "AvenirNext-Bold"
        case AvenirHeavy = "Avenir-Heavy"
        case AvenirMedium = "Avenir-Medium"
        case GillSans
        case GillSansSemiBold = "GillSans-SemiBold"
        case GillSansSemiBoldItalic = "GillSans-SemiBoldItalic"
        case GillSansBold = "GillSans-Bold"
        case GillSansBoldItalic = "GillSans-BoldItalic"
        case MontserratMedium = "Montserrat-Medium"
        case MontserratSemiBold = "Montserrat-SemiBold"
        case Quicksand_Regular = "Quicksand-Regular"
        case Quicksand_Bold = "Quicksand-Bold"
        case Quicksand_Medium = "Quicksand-Medium"
        
    
    }

    static func custom(_ value: CGFloat, name: FontNames) -> UIFont {
        return UIFont(name: name.rawValue, size: value) ?? UIFont.systemFont(ofSize: value)
    }
}

public extension UILabel {
    @discardableResult
    func text(_ value: String?) -> Self {
        text = value
        return self
    }

    @discardableResult
    func color(_ value: UIColor) -> Self {
        textColor = value
        return self
    }

    @discardableResult
    func font(_ value: CGFloat, _ bold: Bool = false) -> Self {
        font = bold ? UIFont.boldSystemFont(ofSize: value) : UIFont.systemFont(ofSize: value)
        return self
    }

    @discardableResult
    func font(_ value: CGFloat, _ name: UIFont.FontNames) -> Self {
        font = UIFont(name: name.rawValue, size: value)
        return self
    }
    
    func fontName(_ value: CGFloat, _ name: String) -> Self {
        font = UIFont(name: name, size: value)
        return self
    }
    
    @discardableResult
    func numberOfLines(_ value: Int = 0) -> Self {
        numberOfLines = value
        return self
    }

    @discardableResult
    func textAlignment(_ value: NSTextAlignment) -> Self {
        textAlignment = value
        return self
    }

    @discardableResult
    func lineBreakMode(_ value: NSLineBreakMode = .byTruncatingTail) -> Self {
        lineBreakMode = value
        return self
    }
}

public extension UIButton {
    @discardableResult
    func title(_ value: String?, _ state: UIControl.State = .normal) -> Self {
        setTitle(value, for: state)
        return self
    }

    @discardableResult
    func titleColor(_ value: UIColor, _ state: UIControl.State = .normal) -> Self {
        setTitleColor(value, for: state)
        return self
    }

    @discardableResult
    func image(_ value: UIImage?, _ state: UIControl.State = .normal) -> Self {
        setImage(value, for: state)
        return self
    }

    @discardableResult
    func backgroundImage(_ value: UIImage?, _ state: UIControl.State = .normal) -> Self {
        setBackgroundImage(value, for: state)
        return self
    }

    @discardableResult
    func backgroundColor(_ value: UIColor, _ state: UIControl.State = .normal) -> Self {
        setBackgroundColor(value, for: state)
        return self
    }

    @discardableResult
    func font(_ value: CGFloat, _ bold: Bool = false) -> Self {
        titleLabel?.font(value, bold)
        return self
    }

    @discardableResult
    func font(_ value: CGFloat, _ name: UIFont.FontNames) -> Self {
        titleLabel?.font(value, name)
        return self
    }

    @discardableResult
    func lineBreakMode(_ value: NSLineBreakMode = .byTruncatingTail) -> Self {
        titleLabel?.lineBreakMode(value)
        return self
    }

    @discardableResult
    func isEnabled(_ value: Bool = false) -> Self {
        isEnabled = value
        return self
    }

    @discardableResult
    func showsTouch(_ value: Bool = true) -> Self {
        showsTouchWhenHighlighted = value
        return self
    }
}

public extension UIImageView {
    @discardableResult
    func image(_ value: String?, _: Bool = false) -> Self {
        guard let value = value else { return self }
        image = UIImage(named: value) ?? UIImage.named(value)
        return self
    }
}

extension Int {
    func secondsToTimeString(formatString: String) -> String {
        // "%lu天 %02lu:%02lu:%02lu"
        //天数计算
        let days = (self)/(24*3600);
        
        //小时计算
        let hours = (self)%(24*3600)/3600;
        
        //分钟计算
        let minutes = (self)%3600/60;
        
        //秒计算
        let second = (self)%60;
        
//        let timeString  = String(format: formatString, days, hours, minutes, second)
        let timeString  = String(format: formatString, minutes, second)
        return timeString
    }
}


