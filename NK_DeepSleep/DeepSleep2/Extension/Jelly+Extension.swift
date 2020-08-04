//
//  Jelly+Extension.swift
//  DeepSleep2
//
//  Created by JOJO on 2020/7/14.
//  Copyright © 2020 WhiteNoise. All rights reserved.
//


import Jelly

extension UIViewController {
    
    func presentOnBottom(_ controller: UIViewController,
                         inset: CGFloat = 8,
                         corner: CGFloat = 8) {
        var animator: Jelly.Animator?
         let interactionConfiguration = InteractionConfiguration(presentingViewController: self, completionThreshold: 0.5, dragMode: .canvas)
        let alignment = PresentationAlignment(vertical: .bottom, horizontal: .center)
        var uiConfig = PresentationUIConfiguration(cornerRadius: corner)
        uiConfig.isTapBackgroundToDismissEnabled = true
        let marginGuards = UIEdgeInsets(top: inset, left: inset,
                                        bottom: self.view.safeArea.bottom + inset, right: inset)
         
        
        let presentation = CoverPresentation.init(directionShow: .bottom, directionDismiss: .bottom, uiConfiguration: uiConfig, size: PresentationSize(width: .fullscreen, height: .fullscreen), alignment: alignment, marginGuards: marginGuards, interactionConfiguration: interactionConfiguration)
        
        animator = Animator(presentation:presentation)
        animator?.prepare(presentedViewController: controller)
        self.present(controller, animated: true, completion: nil)
        
    }
    
}
