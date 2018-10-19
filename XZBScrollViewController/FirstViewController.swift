//
//  FirstViewController.swift
//  XZBScrollViewController
//
//  Created by 🍎上的豌豆 on 2018/10/19.
//  Copyright © 2018年 xiao. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController ,XZBScrollTableViewProtocal{
    private lazy var tableView: UITableView = {
        let statusBarH = UIApplication.shared.statusBarFrame.size.height
        //这个44为导航高度
        let Y: CGFloat = statusBarH + 44
        //这个44为切换条的高度
        let H: CGFloat = xzb_iphoneX ? (view.bounds.height - Y - 44 - 34) : view.bounds.height - Y - 44
        let tableView = tableViewConfig(CGRect(x: 0, y: 44, width: view.bounds.width, height: H), self, self, nil)
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        xzb_scrollView = tableView
       
        if #available(iOS 11.0, *) {
            xzb_scrollView?.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    

}
extension FirstViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cellWithTableView(tableView)
        let num = arc4random() % 10
        cell.textLabel?.text = "苹果🍎上的第 \(num) 个豌豆💰"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("点击了第\(indexPath.row + 1)行")
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}

