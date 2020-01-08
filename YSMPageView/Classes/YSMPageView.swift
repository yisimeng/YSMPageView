//
//  YSMPageView.swift
//  YSMPageView
//
//  Created by duanzengguang on 2019/12/31.
//

import UIKit

let YSMPageCollectionCellReuseID = "YSMPageCollectionCellReuseID"

public protocol YSMPageViewDataSource: class {
    func numberOfChildViewController(in pageView: YSMPageView) -> Int
    
    func pageView(_ pageView: YSMPageView, childViewControllerAt index: Int) -> UIViewController
}

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

    public private(set) var viewControllers: [UIViewController] = []
    
    public weak var dataSource: YSMPageViewDataSource!
    public weak var delegate: YSMPageViewDelegate?
    
    public var viewControllerTitles: [String] = []{
        didSet{
            titleView.titleArray = viewControllerTitles
            if titleView.superview == nil {
                addSubview(titleView)
            }
        }
    }
    
    var headerViewHeight: CGFloat = 0
    public var headerView: UIView? {
        didSet{
            headerViewHeight = headerView?.frame.height ?? 0
            if let headerView = headerView {
                addSubview(headerView)
                titleView.frame = CGRect(x: 0, y: headerViewHeight, width: self.bounds.width, height: 50)
            }
        }
    }
    // 悬停高度
    public var headerHangingHeight: CGFloat = 0
    
    private lazy var titleView: YSMPageTitleView = {
        let titleView = YSMPageTitleView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 50))
        titleView.delegate = self
        return titleView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = self.frame.size
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 50, width: self.bounds.width, height: self.bounds.height-50), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: YSMPageCollectionCellReuseID)
        return collectionView
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
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

extension YSMPageView: UICollectionViewDelegate{
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let childViewController = dataSource?.pageView(self, childViewControllerAt: indexPath.row) else { return }
        // FIXME: - 将要显示回调
        cell.contentView.addSubview(childViewController.view)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 结束显示，clean cell
        cell.contentView.removeAllSubViews()
    }
    
    /// 滑动停止
    /// - Parameter scrollView: <#scrollView description#>
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex: Int = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        delegate?.pageView(self, didScrollToChildViewControllerAt: currentIndex)
        titleView.didSelectTitle(at: currentIndex)
    }
    
}

extension YSMPageView: UICollectionViewDataSource{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfChildViewController(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YSMPageCollectionCellReuseID, for: indexPath)
        
        guard let childViewController = dataSource?.pageView(self, childViewControllerAt: indexPath.row) else { return cell }
        if !viewControllers.contains(childViewController) {
            add(child: childViewController)
            if let scrollView = childViewController.childScrollView {
                if #available(iOS 11.0, *) {
                    childViewController.childScrollView?.contentInsetAdjustmentBehavior = .never
                }else {
                    childViewController.automaticallyAdjustsScrollViewInsets = false
                }
                let contentInset = UIEdgeInsets(top: headerViewHeight, left: 0, bottom: 0, right: 0)
                scrollView.contentInset = contentInset
                scrollView.scrollIndicatorInsets = contentInset
                scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            }
            
        }
        return cell
    }
}

// KVO
extension YSMPageView {
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath != "contentOffset" {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        guard let headerView = headerView else { return }
        guard let contentOffset: CGPoint = change?[NSKeyValueChangeKey.newKey] as? CGPoint else { return }
        
        var headerFrame: CGRect = headerView.frame
        if contentOffset.y < -headerViewHeight {
            // header 完全显示后，继续下拉
            headerFrame.origin.y = 0
            let height = (-headerViewHeight) - contentOffset.y
            headerFrame.size.height = height + headerViewHeight
        }else if contentOffset.y <= -headerHangingHeight{
            // header初始位置到悬停位置之间
            headerFrame.origin.y = -(headerViewHeight + contentOffset.y)
            headerFrame.size.height = headerViewHeight
        }else {
            headerFrame.origin.y = headerHangingHeight - headerViewHeight
        }
        headerView.frame = headerFrame
        
//        let offset: CGPoint = CGPoint(x: contentOffset.x, y: contentOffset.y + headerViewHeight)
//        delegate?.pageView(self, didScrollContentOffset: offset)
    }
}

extension YSMPageView: YSMPageTitleViewDelegate{
    func titleView(_ titleView: YSMPageTitleView, didSelect index: Int) {
        let targetIndexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: targetIndexPath, at: .left, animated: false)
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
                while var superView: UIView = self.superview {
                    let responder = superView.next
                    if (responder?.isKind(of: UIViewController.self))! {
                        return responder as? UIViewController
                    }
                    superView = superView.superview!
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
