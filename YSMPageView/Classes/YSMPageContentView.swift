//
//  YSMPageContentView.swift
//  YSMPageView
//
//  Created by duanzengguang on 2020/1/6.
//

import UIKit

protocol YSMPageContentViewDelegate: class {
    func contentView(_ contentView: YSMPageContentView, didScrollToChildViewControllerAt index: Int)
    func contentView(_ contentView: YSMPageContentView, verticalScroll offsetY: CGFloat)
}

protocol YSMPageContentViewDataSource: class {
    func numberOfChildViewController(in contentView: YSMPageContentView) -> Int
    
    func contentView(_ contentView: YSMPageContentView, childViewControllerAt index: Int) -> UIViewController
}

class YSMPageContentView: UICollectionView {
    
    private(set) var viewControllers: [UIViewController] = []
    
    var headerViewHeight: CGFloat = 50
    
    weak var contentDataSource: YSMPageContentViewDataSource?
    weak var contentDelegate: YSMPageContentViewDelegate?
    
    init(frame: CGRect) {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = frame.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        super.init(frame: frame, collectionViewLayout: layout)
        
        delegate = self
        dataSource = self
        isPagingEnabled = true
        bounces = false
        backgroundColor = .white
        showsHorizontalScrollIndicator = false
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: YSMPageCollectionCellReuseID)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension YSMPageContentView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentDataSource?.numberOfChildViewController(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YSMPageCollectionCellReuseID, for: indexPath)
        
        guard let childViewController = contentDataSource?.contentView(self, childViewControllerAt: indexPath.row) else { return cell }
        
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
    
    func add(child viewController: UIViewController) {
        parentViewController?.addChildViewController(viewController)
        viewControllers.append(viewController)
    }
}

extension YSMPageContentView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let childViewController: UIViewController = viewControllers[indexPath.row]
        /*
        //FIXME: 控制将要显示的scrollView的偏移量
         */
        cell.contentView.addSubview(childViewController.view)
        if let scrollView = childViewController.childScrollView {
            scrollView.contentOffset = CGPoint(x: 0, y: -headerViewHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 结束显示，clean cell
        cell.contentView.removeAllSubViews()
    }
    
    /// 滑动停止
    /// - Parameter scrollView:
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex: Int = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        contentDelegate?.contentView(self, didScrollToChildViewControllerAt: currentIndex)
    }
    
    // 水平滑动时，将当前偏移置为原始值，以防header回弹
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let cell: UICollectionViewCell = visibleCells.first else {return}
        guard let indexPath: IndexPath = self.indexPath(for: cell) else {return}
        let childViewController: UIViewController = viewControllers[indexPath.row]
        guard let scrollView = childViewController.childScrollView else { return }
        scrollView.contentOffset = CGPoint(x: 0, y: -headerViewHeight)
    }
}

// KVO
extension YSMPageContentView {
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath != "contentOffset" {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        guard let contentOffset: CGPoint = change?[NSKeyValueChangeKey.newKey] as? CGPoint else { return }
        contentDelegate?.contentView(self, verticalScroll: contentOffset.y)
    }
}
