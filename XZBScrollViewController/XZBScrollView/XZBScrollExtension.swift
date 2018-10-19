//
//  XZBScrollExtension.swift
//  XZBScrollViewController
//
//  Created by 🍎上的豌豆 on 2018/10/19.
//  Copyright © 2018年 xiao. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    public typealias XZBScrollHandle = (UIScrollView) -> Void
    
    private struct XZBHandleKey {
        static var key = "xzb_handle"
        static var tKey = "xzb_isTableViewPlain"
    }
    
    public var scrollHandle: XZBScrollHandle? {
        get { return objc_getAssociatedObject(self, &XZBHandleKey.key) as? XZBScrollHandle }
        set { objc_setAssociatedObject(self, &XZBHandleKey.key, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
    
    @objc public var isTableViewPlain: Bool {
        get { return (objc_getAssociatedObject(self, &XZBHandleKey.tKey) as? Bool) ?? false}
        set { objc_setAssociatedObject(self, &XZBHandleKey.tKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
}
extension UIScrollView {
    
    public class func initializeOnce() {
        
        DispatchQueue.once(token: UIDevice.current.identifierForVendor?.uuidString ?? "XZBScrollView") {
            let originSelector = Selector(("_notifyDidScroll"))
            let swizzleSelector = #selector(xzb_scrollViewDidScroll)
            xzb_swizzleMethod(self, originSelector, swizzleSelector)
        }
    }
    
    @objc dynamic func xzb_scrollViewDidScroll() {
        self.xzb_scrollViewDidScroll()
        guard let scrollHandle = scrollHandle else { return }
        scrollHandle(self)
    }
}
extension UIViewController {
    
    private struct XZBVCKey {
        static var sKey = "xzb_scrollViewKey"
        static var oKey = "xzb_upOffsetKey"
    }
    
    @objc public var xzb_scrollView: UIScrollView? {
        get { return objc_getAssociatedObject(self, &XZBVCKey.sKey) as? UIScrollView }
        set { objc_setAssociatedObject(self, &XZBVCKey.sKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public var xzb_upOffset: String? {
        get { return objc_getAssociatedObject(self, &XZBVCKey.oKey) as? String }
        set { objc_setAssociatedObject(self, &XZBVCKey.oKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
extension NSObject {
    
    static func xzb_swizzleMethod(_ cls: AnyClass?, _ originSelector: Selector, _ swizzleSelector: Selector)  {
        let originMethod = class_getInstanceMethod(cls, originSelector)
        let swizzleMethod = class_getInstanceMethod(cls, swizzleSelector)
        guard let swMethod = swizzleMethod, let oMethod = originMethod else { return }
        let didAddSuccess: Bool = class_addMethod(cls, originSelector, method_getImplementation(swMethod), method_getTypeEncoding(swMethod))
        if didAddSuccess {
            class_replaceMethod(cls, swizzleSelector, method_getImplementation(oMethod), method_getTypeEncoding(oMethod))
        } else {
            method_exchangeImplementations(oMethod, swMethod)
        }
    }
}

extension UIColor {
    
    public convenience init(r : CGFloat, g : CGFloat, b : CGFloat) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
    }
}

extension DispatchQueue {
    private static var _onceTracker = [String]()
    public class func once(token: String, block: () -> ()) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
    
    func async(block: @escaping ()->()) {
        self.async(execute: block)
    }
    
    func after(time: DispatchTime, block: @escaping ()->()) {
        self.asyncAfter(deadline: time, execute: block)
    }
}

extension DispatchQueue {
    func after(_ delay: TimeInterval, execute: @escaping () -> Void) {
        asyncAfter(deadline: .now() + delay, execute: execute)
    }
}
