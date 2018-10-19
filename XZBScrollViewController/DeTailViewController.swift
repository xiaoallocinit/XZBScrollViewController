//
//  DeTailViewController.swift
//  XZBScrollViewController
//
//  Created by 🍎上的豌豆 on 2018/10/19.
//  Copyright © 2018年 xiao. All rights reserved.
//

import UIKit
let xzb_iphoneX = (UIScreen.main.bounds.height == 812.0)
class DeTailViewController: UIViewController {
    private let headerHeight: CGFloat = 250.0
    //防止侧滑的时候透明度变化
    private var currentProgress: CGFloat = 0.0
    private let navHeight: CGFloat = UIApplication.shared.statusBarFrame.height + 44
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.alpha = currentProgress
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18.0)]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.alpha = 1.0
    }
    private lazy var titles: [String] = {
        return ["热门", "精彩推荐", "科技控", "游戏", "汽车", "财经", "搞笑", "图片"]
    }()
    private lazy var viewControllers: [UIViewController] = {
        var vcs = [UIViewController]()
        for _ in titles {
            vcs.append(FirstViewController())
        }
        return vcs
    }()
    private lazy var headerView: UIView = {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: headerHeight))
        return headerView
    }()
    
    private lazy var headerImageView: UIImageView = {
        let headerImageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: headerView.bounds.height))
        headerImageView.image = UIImage(named: "苹果")
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        headerImageView.isUserInteractionEnabled = true
        headerImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(_:))))
        return headerImageView
    }()
    private lazy var layout: XZBLayout = {
        let layout = XZBLayout()
        
        layout.titleColor = UIColor(r: 238, g: 238, b: 238)
        layout.titleSelectColor = UIColor(r: 0, g: 0, b: 0)
        layout.titleViewBgColor = UIColor(r: 255, g: 255, b: 255)
        
        return layout
    }()
    private lazy var simpleManager: XZBScrollManager = {
        let Y: CGFloat = 0.0
        let H: CGFloat = xzb_iphoneX ? (view.bounds.height - 34) : view.bounds.height
        let simpleManager = XZBScrollManager(frame: CGRect(x: 0, y: Y, width: view.bounds.width, height: H), viewControllers: viewControllers, titles: titles, currentViewController: self, layout: layout)
        
        /* 设置代理 监听滚动 */
        simpleManager.delegate = self
        
        /* 设置悬停位置 */
        simpleManager.hoverY = navHeight
        
        return simpleManager
    }()
    var statusBarStyle: UIStatusBarStyle = .lightContent
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        automaticallyAdjustsScrollViewInsets = false
//        if #available(iOS 11.0, *) {
//            
//            //xzb_scrollView?.contentInsetAdjustmentBehavior = .never
//        }else {
//            automaticallyAdjustsScrollViewInsets = false
//        }
        view.addSubview(simpleManager)
        simpleManagerConfig()
    }
    
    deinit {
        print(" < --> deinit")
    }
}

extension DeTailViewController {
    
    //MARK: 具体使用请参考以下
    private func simpleManagerConfig() {
        
        //MARK: headerView设置
        simpleManager.configHeaderView {[weak self] in
            guard let strongSelf = self else { return nil }
            strongSelf.headerView.addSubview(strongSelf.headerImageView)
            return strongSelf.headerView
        }
        
        //MARK: pageView点击事件
        simpleManager.didSelectIndexHandle { (index) in
            print("点击了 \(index) 😆")
        }
        
    }
    
    @objc private func tapLabel(_ gesture: UITapGestureRecognizer)  {
        print("tapLabel")
    }
}
extension DeTailViewController: XZBScrollManagerDelegate {
    
    //MARK: 滚动代理方法
    func xzb_scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        var headerImageViewY: CGFloat = offsetY
        var headerImageViewH: CGFloat = headerHeight - offsetY
        if offsetY <= 0.0 {
            navigationController?.navigationBar.alpha = 0
            currentProgress = 0.0
        }else {
            
            headerImageViewY = 0
            headerImageViewH = headerHeight
            
            let adjustHeight: CGFloat = headerHeight - navHeight
            let progress = 1 - (offsetY / adjustHeight)
            //设置状态栏
            navigationController?.navigationBar.barStyle = progress > 0.5 ? .black : .default
            
            //设置导航栏透明度
            navigationController?.navigationBar.alpha = 1 - progress
            currentProgress = 1 - progress
            
        }
        headerImageView.frame.origin.y = headerImageViewY
        headerImageView.frame.size.height = headerImageViewH
    }
    
    //MARK: 控制器刷新事件代理方法
    func xzb_refreshScrollView(_ scrollView: UIScrollView, _ index: Int) {
        
    }
}

