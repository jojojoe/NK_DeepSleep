//
//  UIKit.swift
//  TagPost
//
//  Created by Di on 2019/3/19.
//  Copyright © 2019 Di. All rights reserved.
//

import CoreImage
import SwifterSwift
import UIKit

protocol UIViewLoading {}

/// Extend UIView to declare that it includes nib loading functionality
extension UIView: UIViewLoading {}

/// Protocol implementation
extension UIViewLoading where Self: UIView {
    static func loadFromNib(nibNameOrNil: String? = nil) -> Self {
        let nibName = nibNameOrNil ?? className
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! Self
    }
}

extension UIApplication {
    public static var rootController: UIViewController? {
        return shared.keyWindow?.rootViewController
    }
}

public extension UIImage {
    static func named(_ value: String?) -> UIImage? {
        guard let value = value else { return nil }
        return UIImage(named: value)
//            ?? UIImage(namedInBundle: value)
    }

//    convenience init?(namedInBundle name: String) {
//        let path = Bundle(for: FireUserManager.self).path(forResource: "GPFireable", ofType: "bundle") ?? ""
//        self.init(named: name, in: Bundle(path: path), compatibleWith: nil)
//    }
    
    convenience init?(namedInBundle name: String) {
        let path = Bundle.main.path(forResource: "BachCore", ofType: "bundle") ?? ""
        self.init(named: name, in: Bundle(path: path), compatibleWith: nil)
    }
    
    func original() -> UIImage {
        return self.original
    }
    
}

public extension Color {
    static func hexString(_ value: String) -> Color {
        return Color(hexString: value) ?? .white
    }
}

public extension UIView {
    func setAnchorPoint(anchorPoint: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * anchorPoint.x, y: bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position: CGPoint = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = anchorPoint
    }
}

public extension UIView {
    var safeArea: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return safeAreaInsets
        } else {
            return .zero
        }
    }

    @discardableResult
    func gradientBackground(_ colorOne: UIColor, _ colorTwo: UIColor,
                            startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0),
                            endPoint: CGPoint = CGPoint(x: 0.0, y: 1.0)) -> CAGradientLayer {
        
        let gradient = layer.sublayers?.filter { $0 is CAGradientLayer }.first as? CAGradientLayer
        
        if let gradient = gradient {
            gradient.frame = bounds
            return gradient
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        layer.insertSublayer(gradientLayer, at: 0)
        //        layer.addSublayer(gradientLayer)
        return gradientLayer
    }
}

public extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
}

public extension UIImage {
    func toCIImage() -> CIImage? {
        return ciImage ?? CIImage(cgImage: cgImage!)
    }

    func scaled(length: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: length, height: length), false, 0)
        draw(in: CGRect(x: 0, y: 0, width: length, height: length))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    var averageColor: UIColor? {
        guard let inputImage = self.ciImage ?? CIImage(image: self) else { return nil }
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: CIVector(cgRect: inputImage.extent)])
        else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [CIContextOption.workingColorSpace: kCFNull])
        let outputImageRect = CGRect(x: 0, y: 0, width: 1, height: 1)

        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: outputImageRect, format: CIFormat.RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}

public extension CIImage {
    func toUIImage() -> UIImage {
        /* If need to reduce the process time, than use next code. But ot produce a bug with wrong filling in the simulator.
         return UIImage(ciImage: self)
         */
        let context: CIContext = CIContext(options: nil)
        let cgImage: CGImage = context.createCGImage(self, from: extent)!
        let image: UIImage = UIImage(cgImage: cgImage)
        return image
    }

    func toCGImage() -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(self, from: self.extent) {
            return cgImage
        }
        return nil
    }
}

public extension UIScreen {
    static var width: CGFloat {
        return UIScreen.main.bounds.width
    }

    static var height: CGFloat {
        return UIScreen.main.bounds.height
    }
}

public extension UIScreen {
    static var isWidthLessThen4_7inch: Bool {
        return UIScreen.main.bounds.width < 375
    }

    static var isHeightLessThen4_7inch: Bool {
        return UIScreen.main.bounds.height < 667
    }

    static var isLessThen4_7inch: Bool {
        return isWidthLessThen4_7inch || isHeightLessThen4_7inch
    }

    static var minLineWidth: CGFloat {
        return 1 / UIScreen.main.scale
    }
}

public extension UIImage {
    static func with(
        color: UIColor,
        size: CGSize = CGSize(sideLength: 1),
        opaque: Bool = false,
        scale: CGFloat = 0
    ) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)

        UIGraphicsBeginImageContextWithOptions(rect.size, opaque, scale)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.setFillColor(color.cgColor)
        context.fill(rect)

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func tinted(with color: UIColor, opaque: Bool = false) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, opaque, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        guard
            let context = UIGraphicsGetCurrentContext(),
            let cgImage = self.cgImage
        else { return nil }

        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)

        let rect = CGRect(origin: .zero, size: size)

        context.setBlendMode(.normal)
        context.draw(cgImage, in: rect)

        context.setBlendMode(.sourceIn)
        context.setFillColor(color.cgColor)
        context.fill(rect)

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

public extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        setBackgroundImage(UIImage.with(color: color), for: state)
    }
}

public extension CGSize {
    init(sideLength: Int) {
        self.init(width: sideLength, height: sideLength)
    }

    init(sideLength: Double) {
        self.init(width: sideLength, height: sideLength)
    }

    init(sideLength: CGFloat) {
        self.init(width: sideLength, height: sideLength)
    }

    var longSide: CGFloat {
        return max(width, height)
    }

    var shortSide: CGFloat {
        return min(width, height)
    }
}

public typealias ButtonActionBlock = (UIButton) -> Void

var ActionBlockKey: UInt8 = 02

private class ActionBlockWrapper: NSObject {
    let block: ButtonActionBlock

    init(block: @escaping ButtonActionBlock) {
        self.block = block
    }
}
