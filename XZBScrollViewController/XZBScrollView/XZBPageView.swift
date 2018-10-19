//
//  XZBPageView.swift
//  XZBScrollViewController
//
//  Created by 🍎上的豌豆 on 2018/10/19.
//  Copyright © 2018年 xiao. All rights reserved.
//

import UIKit
public typealias PageViewDidSelectIndexBlock = (XZBPageView, Int) -> Void
public typealias AddChildViewControllerBlock = (Int, UIViewController) -> Void

@objc public protocol XZBPageViewDelegate: class {
    @objc optional func xzb_scrollViewDidScroll(_ scrollView: UIScrollView)
    @objc optional func xzb_scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    @objc optional func xzb_scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
    @objc optional func xzb_scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    @objc optional func xzb_scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    @objc optional func xzb_scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
}

public class XZBPageView: UIView {

    private weak var currentViewController: UIViewController?
    private var viewControllers: [UIViewController] = []
    private var titles: [String] = []
    private var layout: XZBLayout = XZBLayout()
    private var xzb_currentIndex: Int = 0;
    
    @objc public var didSelectIndexBlock: PageViewDidSelectIndexBlock?
    @objc public var addChildVcBlock: AddChildViewControllerBlock?
    
    /* 点击切换滚动过程动画  */
    @objc public var isClickScrollAnimation = false
    
    /* pageView的scrollView左右滑动监听 */
    @objc public weak var delegate: XZBPageViewDelegate?
    
    var isCustomTitleView: Bool = false
    
    var pageTitleView: XZBPageTitleView!
    
    @objc public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        scrollView.contentSize = CGSize(width: self.bounds.width * CGFloat(self.titles.count), height: 0)
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.bounces = layout.isShowBounces
        scrollView.isScrollEnabled = layout.isScrollEnabled
        scrollView.showsHorizontalScrollIndicator = layout.showsHorizontalScrollIndicator
        return scrollView
    }()
    
    @objc public init(frame: CGRect, currentViewController: UIViewController, viewControllers:[UIViewController], titles: [String], layout: XZBLayout, titleView: XZBPageTitleView? = nil) {
        self.currentViewController = currentViewController
        self.viewControllers = viewControllers
        self.titles = titles
        self.layout = layout
        guard viewControllers.count == titles.count else {
            fatalError("控制器数量和标题数量不一致")
        }
        super.init(frame: frame)
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        if titleView != nil {
            isCustomTitleView = true
            self.pageTitleView = titleView!
        }else {
            self.pageTitleView = setupTitleView()
        }
        self.pageTitleView.isCustomTitleView = isCustomTitleView
        setupSubViews()
    }
    
    /* 滚动到某个位置 */
    @objc public func scrollToIndex(index: Int)  {
        pageTitleView.scrollToIndex(index: index)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: addSubview
extension XZBPageView {
    
    private func setupSubViews()  {
        addSubview(scrollView)
        if layout.isSinglePageView == false {
            addSubview(pageTitleView)
            xzb_createViewController(0)
            setupGetPageViewScrollView(self, pageTitleView)
        }
    }
    
}
//MARK: 创建XZBPageTitleView
extension XZBPageView {
    private func setupTitleView() -> XZBPageTitleView {
        let pageTitleView = XZBPageTitleView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.layout.sliderHeight), titles: titles, layout: layout)
        pageTitleView.backgroundColor = self.layout.titleViewBgColor
        return pageTitleView
    }
}

extension XZBPageView {
    internal func setupGetPageViewScrollView(_ pageView:XZBPageView, _ titleView: XZBPageTitleView) {
        pageView.delegate = titleView
        titleView.mainScrollView = pageView.scrollView
        titleView.scrollIndexHandle = pageView.currentIndex
        titleView.xzb_createViewControllerHandle = {[weak pageView] index in
            pageView?.xzb_createViewController(index)
        }
        titleView.xzb_didSelectTitleViewHandle = {[weak pageView] index in
            pageView?.didSelectIndexBlock?((pageView)!, index)
        }
    }
}
//MARK: 创建Controller
extension XZBPageView {
    
    public func xzb_createViewController(_ index: Int)  {
        let VC = viewControllers[index]
        guard let currentViewController = currentViewController else { return }
        if currentViewController.children.contains(VC) {
            return
        }
        var viewControllerY: CGFloat = 0.0
        layout.isSinglePageView ? viewControllerY = 0.0 : (viewControllerY = layout.sliderHeight)
        VC.view.frame = CGRect(x: scrollView.bounds.width * CGFloat(index), y: viewControllerY, width: scrollView.bounds.width, height: scrollView.bounds.height)
        scrollView.addSubview(VC.view)
        currentViewController.addChild(VC)
//        if #available(iOS 11.0, *) {
//            //VC.xzb_scrollView?.contentInsetAdjustmentBehavior = .never
//        }else {
//           VC.automaticallyAdjustsScrollViewInsets = false
//        }
        VC.automaticallyAdjustsScrollViewInsets = false
        addChildVcBlock?(index, VC)
        if let xzb_scrollView = VC.xzb_scrollView {
            if #available(iOS 11.0, *) {
                xzb_scrollView.contentInsetAdjustmentBehavior = .never
            }
            xzb_scrollView.frame.size.height = xzb_scrollView.frame.size.height - viewControllerY
        }
    }
    
    public func currentIndex() -> Int {
        if scrollView.bounds.width == 0 || scrollView.bounds.height == 0 {
            return 0
        }
        let index = Int((scrollView.contentOffset.x + scrollView.bounds.width * 0.5) / scrollView.bounds.width)
        return max(0, index)
    }
    
}
//MARK: UIScrollViewDelegate
extension XZBPageView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.xzb_scrollViewDidScroll?(scrollView)
        if isCustomTitleView {
            let index = currentIndex()
            if xzb_currentIndex != index {
                xzb_createViewController(index)
                didSelectIndexBlock?(self, index)
                xzb_currentIndex = index
            }
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.xzb_scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegate?.xzb_scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.xzb_scrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.xzb_scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.xzb_scrollViewDidEndScrollingAnimation?(scrollView)
        
    }
}

