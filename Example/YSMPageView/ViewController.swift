//
//  ViewController.swift
//  YSMPageView
//
//  Created by yisimeng on 12/31/2019.
//  Copyright (c) 2019 yisimeng. All rights reserved.
//

import UIKit
import YSMPageView

//状态栏高度
let kStatusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
// 导航条
let kNavigationBarHeight: CGFloat = 44.0
//导航栏高度
let kNavigationHeight: CGFloat = (kStatusBarHeight + kNavigationBarHeight)

class ViewController: UIViewController {

    var viewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 200))
        headerView.backgroundColor = .cyan
        
        
        let pageView = YSMPageView(frame: CGRect(x: 0, y: kStatusBarHeight, width: view.bounds.width, height: view.bounds.height-kStatusBarHeight))
        pageView.headerHangingHeight = 64
        pageView.headerView = headerView
        pageView.dataSource = self
        view.addSubview(pageView)

        let viewController1 = FirstTableViewController(style: .plain)
        let viewController2 = SecondTableViewController(style: .plain)
        let viewController3 = ThirdTableViewController(style: .plain)
        let viewController4 = FourthTableViewController(style: .plain)
        pageView.viewControllerTitles = ["第一","第二", "第三","第四"]
        viewControllers.append(contentsOf: [viewController1,viewController2,viewController3,viewController4])
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: YSMPageViewDataSource {
    func numberOfChildViewController(in pageView: YSMPageView) -> Int {
        return viewControllers.count
    }
    
    func pageView(_ pageView: YSMPageView, childViewControllerAt index: Int) -> UIViewController {
        return viewControllers[index]
    }
    
    
}
