//
//  YSMPageTitleView.swift
//  YSMPageView
//
//  Created by duanzengguang on 2019/12/31.
//

import UIKit

var titleViewHeight: CGFloat = 50

protocol YSMPageTitleViewDelegate: class {
    func titleView(_ titleView: YSMPageHeaderView, didSelect index: Int)
}

class YSMPageHeaderView: UIView {

    var scrollView: UIScrollView = UIScrollView()
    
    var titleArray: [String] = []{
        didSet{
            setupSubViews()
        }
    }
    private var titleLabels : [UILabel] = []
    private var currentIndex: Int = 0
    
    weak var delegate: YSMPageTitleViewDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(titleViewHeight)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension YSMPageHeaderView {
    
    fileprivate func setupTitleLabels() {
        for (index,title) in titleArray.enumerated() {
            let label = UILabel()
            label.text = title
            label.font = UIFont.systemFont(ofSize: 16)
            label.textAlignment = .center
            label.tag = index
            scrollView.addSubview(label)
            titleLabels.append(label)
            
            //添加触摸手势
            let tap = UITapGestureRecognizer(target: self, action: #selector(titleLabelDidClick(_:)))
            label.addGestureRecognizer(tap)
            label.isUserInteractionEnabled = true
            
            if index == currentIndex {
                label.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }
        }
    }
    
    fileprivate func setupSubViews() {
        setupTitleLabels()
        
        var maxX: CGFloat = 20 * 0.5
        for (index, label) in titleLabels.enumerated() {
            //获取title宽度
            let w:CGFloat = (titleArray[index] as NSString).boundingRect(with: CGSize(width:CGFloat(MAXFLOAT), height: 0), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 16)], context: nil).width+20
            label.frame = CGRect(x: maxX, y: 0, width: w, height: titleViewHeight)
            maxX = label.frame.maxX+20
        }
        scrollView.contentSize = CGSize(width: maxX, height: titleViewHeight)
    }
    
    private var titlesTotalWidth: CGFloat {
        let titles: String = titleArray.joined()
        return NSString(string: titles).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: titleViewHeight), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 68)], context: nil).width
    }
    
    @objc func titleLabelDidClick(_ tap: UITapGestureRecognizer) {
        guard let selectIndex = tap.view?.tag else { return }
        delegate?.titleView(self, didSelect: selectIndex)
        didSelectTitle(at: selectIndex)
    }
    
    func didSelectTitle(at index: Int) {
        let currentLabel = self.titleLabels[currentIndex]
        currentLabel.transform = .identity
        
        let selectLabel = self.titleLabels[index]
        selectLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        currentIndex = index
    }
    
}

