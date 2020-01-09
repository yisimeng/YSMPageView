//
//  YSMPageView.swift
//  YSMPageView
//
//  Created by duanzengguang on 2019/12/31.
//

import UIKit
import SnapKit

let kStatusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height

let YSMPageCollectionCellReuseID = "YSMPageCollectionCellReuseID"

public protocol YSMPageViewDelegate: class {
    func pageView(_ pageView: YSMPageView, didScrollToChildViewControllerAt index: Int)
}

public protocol YSMPageViewChildControllerDelegate: class {
    var childScrollView: UIScrollView? { get }
}

private var childScrollViewKey  = "childScrollKey"

extension YSMPageViewChildControllerDelegate where Self: UIViewController {
    
    private var _childScrollView: UIScrollView? {
        get {
            objc_getAssociatedObject(self, &childScrollViewKey) as? UIScrollView
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
}
extension UIViewController: YSMPageViewChildControllerDelegate{}

public class YSMPageView: UIView {

    public var viewControllers: [UIViewController] = []
    
    public weak var delegate: YSMPageViewDelegate?
    
    public var viewControllerTitles: [String] = []{
        didSet{
            headerView.titleArray = viewControllerTitles
        }
    }
    
    // 悬停高度
    public var headerHangingHeight: CGFloat = 0
    
    public var pageHeaderView: UIView?{
        didSet{
            headerViewHeight = headerViewHeight+(pageHeaderView?.frame.height ?? 0)
            headerView.frame = CGRect(x: headerView.frame.minX, y: headerView.frame.minY, width: headerView.frame.width, height: headerViewHeight)
            headerView.headerView = pageHeaderView
        }
    }
    
    var headerViewHeight: CGFloat = 50{
        didSet {
            collectionView.headerViewHeight = headerViewHeight
        }
    }
    
    private lazy var headerView: YSMPageHeaderView = {
        let titleView = YSMPageHeaderView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: headerViewHeight))
        titleView.delegate = self
        return titleView
    }()
    
    private lazy var collectionView: YSMPageContentView = {
        let collectionView = YSMPageContentView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        collectionView.contentDataSource = self
        collectionView.contentDelegate = self
        return collectionView
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        addSubview(headerView)
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension YSMPageView {
    // 添加子视图控制器
    func add(child viewController: UIViewController) {
        parentViewController?.addChildViewController(viewController)
        viewControllers.append(viewController)
    }
}

extension YSMPageView: YSMPageContentViewDataSource{
    
    func numberOfChildViewController(in contentView: YSMPageContentView) -> Int {
        return viewControllers.count
    }
    
    func contentView(_ contentView: YSMPageContentView, childViewControllerAt index: Int) -> UIViewController {
        let childViewController: UIViewController = viewControllers[index]
        return childViewController
    }
}
extension YSMPageView: YSMPageContentViewDelegate {
    func contentView(_ contentView: YSMPageContentView, verticalScroll offsetY: CGFloat) {
        var headerFrame = headerView.frame        
        // 初始静止状态offsetY=-250
        if offsetY < -headerViewHeight + kStatusBarHeight {
            // 初始位置继续下拉
            headerFrame.origin.y = 0
            let height = (-headerViewHeight+kStatusBarHeight) - offsetY
            headerFrame.size.height = height + headerViewHeight
        }else if offsetY < -headerHangingHeight {
            // 初始位置与悬停之间
            headerFrame.origin.y = -(headerViewHeight - kStatusBarHeight + offsetY)
            headerFrame.size.height = headerViewHeight
        }
        headerView.frame = headerFrame
    }
    
    func contentView(_ contentView: YSMPageContentView, didScrollToChildViewControllerAt index: Int) {
        headerView.didSelectTitle(at: index)
    }
}


extension YSMPageView: YSMPageTitleViewDelegate{
    func titleView(_ titleView: YSMPageHeaderView, didSelect index: Int) {
        let targetIndexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: targetIndexPath, at: .left, animated: true)
    }
}





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
    
    func removeAllSubViews() {
        for subView in subviews {
            subView.removeFromSuperview()
        }
    }
    
}
