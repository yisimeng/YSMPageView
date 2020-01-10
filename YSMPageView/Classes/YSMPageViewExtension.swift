//
//  YSMPageViewExtension.swift
//  YSMPageView
//
//  Created by duanzengguang on 2020/1/9.
//

import UIKit

private var childScrollViewKey  = "childScrollKey"
private var pageViewTitleKey = "pageViewTitleKey"

/// pageController delegate
public protocol YSMPageViewChildControllerDelegate: class {
    
    /// scrollView
    var childScrollView: UIScrollView? { get }
    
    /// 控制器标题
    var pageTitle: String { get }
}


extension YSMPageViewChildControllerDelegate where Self: UIViewController {
    
    private var _childScrollView: UIScrollView? {
        get {
            return objc_getAssociatedObject(self, &childScrollViewKey) as? UIScrollView
        }
        set {
            objc_setAssociatedObject(self, &childScrollViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var childScrollView: UIScrollView? {
        get {
            if let scrollView = _childScrollView {
                return scrollView
            }
            if self.view.isKind(of: UIScrollView.self) {
                _childScrollView = (self.view as! UIScrollView)
                return _childScrollView
            }
            for subView: UIView in view.subviews {
                if subView.isKind(of: UIScrollView.self), subView.frame.size.equalTo(view.frame.size) {
                    _childScrollView = (subView as! UIScrollView)
                    return _childScrollView
                }
            }
            return nil
        }
    }
    
    public var pageTitle: String {
        get {
            return objc_getAssociatedObject(self, &pageViewTitleKey) as? String ?? "标题"
        }
        set {
            objc_setAssociatedObject(self, &pageViewTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

// 给ViewController添加扩展
extension UIViewController: YSMPageViewChildControllerDelegate{}

// UIView extension
extension UIView {
    
    private struct associatedKey {
         static var parentVCkey = "parentVC"
    }
    
    private var _parentViewController: UIViewController?{
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &associatedKey.parentVCkey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            return objc_getAssociatedObject(self, &associatedKey.parentVCkey) as? UIViewController
        }
    }
    
    /// 父视图控制器
    var parentViewController: UIViewController? {
        get {
            if let parent = _parentViewController {
                return parent
            }else {
                var superView = self.superview
                while superView != nil {
                    let responder = superView!.next
                    if (responder?.isKind(of: UIViewController.self))! {
                        return responder as? UIViewController
                    }
                    superView = superView!.superview!
                }
                return nil
            }
        }
        set {
            _parentViewController = newValue
        }
    }
    
    /// 移除所有子视图
    func removeAllSubViews() {
        for subView in subviews {
            subView.removeFromSuperview()
        }
    }
    
}
