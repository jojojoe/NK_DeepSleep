//
//  HUDExtension.swift
//  EasyTrack
//
//  Created by Conver on 14/8/2019.
//  Copyright © 2019 Conver. All rights reserved.
//

import Alertift
import Foundation
import ZKProgressHUD

public struct HUD {
    public static func show() {
        guard !ZKProgressHUD.isShowing else { return }
        ZKProgressHUD.show()
    }

    public static func hide() {
        ZKProgressHUD.dismiss()
    }

    
    public static func error(_ value: String? = nil) {
        hide()
        ZKProgressHUD.showError(value, autoDismissDelay: 2.0)
    }

    public static func success(_ value: String? = nil) {
        hide()
        ZKProgressHUD.showSuccess(value, autoDismissDelay: 2.0)
    }
    
    public static func progress(_ value: CGFloat?) {
        ZKProgressHUD.showProgress(value)
    }
    
    public static func progress(_ value: CGFloat?, status: String? = nil) {
        ZKProgressHUD.showProgress(value, status: status, onlyOnceFont: UIFont.systemFont(ofSize: 14, weight: .semibold))
    }
    
}

public struct Alert {
    public static func error(_ value: String?, title: String? = "Error", success: (() -> Void)? = nil) {
        
        HUD.hide()
        Alertift
            .alert(title: title, message: value)
            .action(.cancel("OK"), handler: { _, _, _ in
                success?()
            })
            .show(on: UIApplication.rootController?.visibleVC, completion: nil)
    }

    public static func message(_ value: String?, success: (() -> Void)? = nil) {
        
        HUD.hide()
        Alertift
            .alert(message: value)
            .action(.cancel("OK"), handler: { _, _, _ in
                success?()
            })
            .show(on: UIApplication.rootController?.visibleVC, completion: nil)
    }
}

@objc
public class HUDClass: NSObject {
    @objc
    public static func show() {
        guard !ZKProgressHUD.isShowing else { return }
        ZKProgressHUD.show()
    }

    @objc
    public static func hide() {
        ZKProgressHUD.dismiss()
    }
}
