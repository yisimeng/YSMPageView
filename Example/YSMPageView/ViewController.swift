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
        
        
        let pageView = YSMPageView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        pageView.pageHeaderView = headerView
        view.addSubview(pageView)

        let viewController1 = FirstTableViewController(style: .plain)
        viewController1.pageTitle = "第一个"
        let viewController2 = SecondTableViewController(style: .plain)
        viewController2.pageTitle = "第二个"
        let viewController3 = ThirdTableViewController(style: .plain)
        viewController3.pageTitle = "第ssan个"
        let viewController4 = FourthTableViewController(style: .plain)
        viewController4.pageTitle = "第si个"
        let viewController5 = FirstTableViewController(style: .plain)
        viewController5.pageTitle = "第wu个"
        let viewController6 = FirstTableViewController(style: .plain)
        viewController6.pageTitle = "第liu个"
        let viewController7 = FirstTableViewController(style: .plain)
        viewController7.pageTitle = "第qi个"
        pageView.viewControllers = [viewController1,viewController2,viewController3,viewController4,viewController5,viewController6,viewController7]
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

