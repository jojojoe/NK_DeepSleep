//
//  Flex.swift
//  GPFireable_Example
//
//  Created by Conver on 5/23/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

#if canImport(FlexLayout)
    import FlexLayout

    public extension Flex {
        var isDisplay: Bool {
            set {
                if view?.isHidden != !newValue {
                    isIncludedInLayout = newValue
                    view?.isHidden = !newValue
                }
            }
            get {
                return isIncludedInLayout && (view?.isHidden ?? false)
            }
        }
    }
#endif
