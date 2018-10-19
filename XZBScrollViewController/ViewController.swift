//
//  ViewController.swift
//  XZBScrollViewController
//
//  Created by 🍎上的豌豆 on 2018/10/19.
//  Copyright © 2018年 xiao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        self.title  = "XZBScrollViewController"
        let avatarBackground:UIImageView = UIImageView.init(image: UIImage.init(named: "苹果"))
        avatarBackground.frame = self.view.bounds
        avatarBackground.clipsToBounds = true
        avatarBackground.isUserInteractionEnabled = true
        avatarBackground.contentMode = .scaleAspectFill
        self.view.addSubview(avatarBackground)
        avatarBackground.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onTapAction(sender:))))
        
        avatarBackground.addSubview(TitleLabel)
    }
    lazy var TitleLabel:UILabel = {
        let nameLab = UILabel.init()
        nameLab.textAlignment = NSTextAlignment.left
        nameLab.font = UIFont.boldSystemFont(ofSize: 28)
        nameLab.textColor = .white
        nameLab.text = "Touch Me"
        
        nameLab.frame = .init(x: 150, y: 150, width: 200, height: 80)
        return nameLab
    }()
    @objc func onTapAction(sender: UITapGestureRecognizer) {
        self.navigationController?.pushViewController(DeTailViewController(), animated: true)
    }
}
