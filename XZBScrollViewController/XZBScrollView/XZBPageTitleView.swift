//
//  XZBPageTitleView.swift
//  XZBScrollViewController
//
//  Created by 🍎上的豌豆 on 2018/10/19.
//  Copyright © 2018年 xiao. All rights reserved.
//

import UIKit
typealias scrollIndexHandle = () -> Int
public typealias XZBCreateViewControllerHandle = (Int) -> Void
public typealias XZBDidSelectTitleViewHandle = (Int) -> Void
public class XZBPageTitleView: UIView {

    /*    --------------- 自定义titleView选择性重写以下方法 -------------- */
    
    /**
     * layout中属性 isCustomTitleView 必须需要设置为 true
     * layout中属性 isCustomTitleViewAndCreateSubController 根据实际情况是否需要设置为true
     */
    @objc public var mainScrollView: UIScrollView?
    @objc public func xzb_contentScrollViewDidScroll(_ scrollView: UIScrollView) { }
    @objc public func xzb_contentScrollViewWillBeginDragging(_ scrollView: UIScrollView) {}
    @objc public func xzb_contentScrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {}
    @objc public func xzb_contentScrollViewDidEndDecelerating(_ scrollView: UIScrollView) {}
    @objc public func xzb_contentScrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {}
    @objc public func xzb_contentScrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {}
    
    /*    --------------- 自定义titleView选择性重写以上方法 -------------- */
    
    private var titles: [String] = [String]()
    private var layout: XZBLayout = XZBLayout()
    private var xzb_textWidths: [CGFloat] = []
    private var xzb_lineWidths: [CGFloat] = []
    private var xzb_buttons: [UIButton] = []
    private var xzb_currentIndex: Int = 0
    private var isClick: Bool = false
    private var xzb_startOffsetX: CGFloat = 0.0
    private var xzb_isClickScrollAnimation = false
    var isClickScrollAnimation = false
    private var isFirstLoad: Bool = true
    var scrollIndexHandle: scrollIndexHandle?
    var xzb_createViewControllerHandle: XZBCreateViewControllerHandle?
    var xzb_didSelectTitleViewHandle: XZBDidSelectTitleViewHandle?
    var isCustomTitleView: Bool = false {
        didSet {
            if isCustomTitleView == false {
                setupSubViews()
            }
        }
    }
    weak var delegate: XZBPageViewDelegate?

   
    
    private lazy var xzb_titleRGBlColor: (r : CGFloat, g : CGFloat, b : CGFloat) = getRGBWithColor(layout.titleColor ?? NORMAL_BASE_COLOR)
    private lazy var xzb_selectTitleRGBlColor: (r : CGFloat, g : CGFloat, b : CGFloat) = getRGBWithColor(layout.titleSelectColor ?? SELECT_BASE_COLOR)
    
    private lazy var sliderScrollView: UIScrollView = {
        let sliderScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        sliderScrollView.showsHorizontalScrollIndicator = false
        sliderScrollView.bounces = false
        return sliderScrollView
    }()
    
    private lazy var pageBottomLineView: UIView = {
        let pageBottomLineView = UIView(frame: CGRect(x: 0, y: bounds.height - layout.pageBottomLineHeight, width: bounds.width, height: layout.pageBottomLineHeight))
        pageBottomLineView.backgroundColor = layout.pageBottomLineColor
        return pageBottomLineView
    }()
    
    private lazy var sliderLineView: UIView = {
        let sliderLineView = UIView(frame: CGRect(x: layout.lrMargin, y: bounds.height - layout.bottomLineHeight - layout.pageBottomLineHeight, width: 0, height: layout.bottomLineHeight))
        sliderLineView.backgroundColor = layout.bottomLineColor
        return sliderLineView
    }()
    
    @objc public init(frame: CGRect, titles: [String], layout: XZBLayout) {
        self.titles = titles
        self.layout = layout
        super.init(frame: frame)
        if #available(iOS 11.0, *) {
            sliderScrollView.contentInsetAdjustmentBehavior = .never
        }
        backgroundColor = layout.titleViewBgColor
    }
    
    /* 滚动到某个位置 */
    @objc public func scrollToIndex(index: Int)  {
        var index = index
        xzb_setupScrollToIndex(&index)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension XZBPageTitleView {
    func setupSubViews() {
        addSubview(sliderScrollView)
        sliderScrollView.addSubview(sliderLineView)
        addSubview(pageBottomLineView)
        setupButtonsLayout()
    }
}
//MARK: 滑动TitleView的ButtonsLayout
extension XZBPageTitleView {
    
    private func setupButtonsLayout() {
        
        if titles.count == 0 { return }
        
        // 将所有的宽度计算出来放入数组
        for (_, text) in titles.enumerated() {
            if layout.isAverage {
                let textAverageW = (bounds.width - layout.lrMargin * 2.0 - layout.titleMargin * CGFloat(titles.count - 1)) / CGFloat(titles.count)
                xzb_textWidths.append(textAverageW)
                xzb_lineWidths.append(textAverageW)
            }else {
                if text.count == 0 {
                    xzb_textWidths.append(60)
                    xzb_lineWidths.append(60)
                    continue
                }
                let textW = text.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 8), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : layout.titleFont ?? UIFont.systemFont(ofSize: 16)], context: nil).size.width
                xzb_textWidths.append(textW)
                xzb_lineWidths.append(textW)
            }
        }
        
        
        
        // 将所有的宽度计算出来放入数组
        for text in titles {
            if layout.isAverage {
                let textAverageW = (bounds.width - layout.lrMargin * 2.0 - layout.titleMargin * CGFloat(titles.count - 1)) / CGFloat(titles.count)
                xzb_textWidths.append(textAverageW)
            }else {
                if text.count == 0 {
                    xzb_textWidths.append(60)
                    xzb_lineWidths.append(60)
                    continue
                }
            }
            let textW = text.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 8), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : layout.titleFont ?? UIFont.systemFont(ofSize: 16)], context: nil).size.width
            if !layout.isAverage {
                xzb_textWidths.append(textW)
            }
            xzb_lineWidths.append(textW)
        }
        
        
        // 按钮布局
        var upX: CGFloat = layout.lrMargin
        let subH = bounds.height - layout.bottomLineHeight
        for index in 0..<titles.count {
            let subW = xzb_textWidths[index]
            let buttonReact = CGRect(x: upX, y: 0, width: subW, height: subH)
            let button = subButton(frame: buttonReact, flag: index, title: titles[index], parentView: sliderScrollView)
            let color = (index == 0 ? layout.titleSelectColor : layout.titleColor)
            button.setTitleColor(color, for: .normal)
            upX = button.frame.origin.x + subW + layout.titleMargin
            xzb_buttons.append(button)
        }
        
        let firstButton = xzb_buttons[0]
        let firstLineWidth = xzb_lineWidths[0]
        let firstTextWidth = xzb_textWidths[0]
        
        if layout.isNeedScale {
            firstButton.transform = CGAffineTransform(scaleX: layout.scale , y: layout.scale)
        }
        
        // lineView的宽度为第一个的宽度
        if layout.sliderWidth == xzb_sliderDefaultWidth {
            if layout.isAverage {
                sliderLineView.frame.size.width = firstLineWidth
                sliderLineView.frame.origin.x = (firstTextWidth - firstLineWidth) * 0.5 + layout.lrMargin
            }else {
                sliderLineView.frame.size.width = firstButton.frame.size.width
                sliderLineView.frame.origin.x = firstButton.frame.origin.x
            }
        }else {
            sliderLineView.frame.size.width = layout.sliderWidth
            sliderLineView.frame.origin.x = ((firstTextWidth + layout.lrMargin * 2) - layout.sliderWidth) * 0.5
        }
        
        if layout.bottomLineCornerRadius != 0.0 {
            sliderLineView.layer.cornerRadius = layout.bottomLineCornerRadius
            sliderLineView.layer.masksToBounds = true
            sliderLineView.clipsToBounds = true
        }
        
        if layout.isAverage {
            sliderScrollView.contentSize = CGSize(width: bounds.width, height: 0)
            return
        }
        
        // 计算sliderScrollView的contentSize
        let sliderContenSizeW = upX - layout.titleMargin + layout.lrMargin
        
        if sliderContenSizeW < bounds.width {
            sliderScrollView.frame.size.width = sliderContenSizeW
        }
        
        //最后多加了一个 layout.titleMargin， 这里要减去
        sliderScrollView.contentSize = CGSize(width: sliderContenSizeW, height: 0)
        
    }
    @objc private func titleSelectIndex(_ btn: UIButton)  {
        
        setupTitleSelectIndex(btn.tag)
        
    }
    
    private func setupTitleSelectIndex(_ btnSelectIndex: Int) {
        guard let scrollView = mainScrollView else { return }
        if xzb_currentIndex == btnSelectIndex || scrollView.isDragging || scrollView.isDecelerating {
            return
        }
        let totalW = bounds.width
        isClick = true
        xzb_isClickScrollAnimation = true
        scrollView.setContentOffset(CGPoint(x: totalW * CGFloat(btnSelectIndex), y: 0), animated: isClickScrollAnimation)
        if isClickScrollAnimation {
            return
        }
        let nextButton = xzb_buttons[btnSelectIndex]
        if layout.sliderWidth == xzb_sliderDefaultWidth {
            if layout.isAverage {
                let adjustX = (nextButton.frame.size.width - xzb_lineWidths[btnSelectIndex]) * 0.5
                sliderLineView.frame.origin.x = nextButton.frame.origin.x + adjustX
                sliderLineView.frame.size.width = xzb_lineWidths[btnSelectIndex]
            }else {
                sliderLineView.frame.origin.x = nextButton.frame.origin.x
                sliderLineView.frame.size.width = nextButton.frame.width
            }
        }else {
            setupSliderLineViewWidth(currentButton: nextButton)
        }
        xzb_currentIndex = btnSelectIndex
    }
    
}
//MARK: 处理刚进入滚动到第几个位置
extension XZBPageTitleView {
    
    private func xzb_setupScrollToIndex(_ index:inout Int) {
        if index >= titles.count {
            print("超过最大数量限制, 请正确设置值, 默认这里取第一个")
            index = 0
        }
        
        if isClickScrollAnimation {
            
            let nextButton = xzb_buttons[index]
            
            if layout.sliderWidth == xzb_sliderDefaultWidth {
                
                if layout.isAverage {
                    let adjustX = (nextButton.frame.size.width - xzb_lineWidths[index]) * 0.5
                    sliderLineView.frame.origin.x = nextButton.frame.origin.x + adjustX
                    sliderLineView.frame.size.width = xzb_lineWidths[index]
                }else {
                    sliderLineView.frame.origin.x = nextButton.frame.origin.x
                    sliderLineView.frame.size.width = nextButton.frame.width
                }
                
            }else {
                if isFirstLoad {
                    setupSliderLineViewWidth(currentButton: xzb_buttons[index])
                    isFirstLoad = false
                }
            }
        }
        
        setupTitleSelectIndex(index)
    }
    
}




//MARK: 滑动pageView的Delegate
extension XZBPageTitleView: XZBPageViewDelegate {
    
    private func scrollViewDidScrollOffsetX(_ offsetX: CGFloat)  {
        
        _ = setupLineViewX(offsetX: offsetX)
        
        let index = currentIndex()
        
        if xzb_currentIndex != index {
            
            //如果开启滚动动画
            if isClickScrollAnimation {
                //如果不是点击事件继续在这个地方设置偏移
                if !xzb_isClickScrollAnimation {
                    setupSlierScrollToCenter(offsetX: offsetX, index: index)
                }
            }else {
                //设置滚动的位置
                setupSlierScrollToCenter(offsetX: offsetX, index: index)
            }
            
            // 如果是点击的话
            if isClick {
                
                let upButton = xzb_buttons[xzb_currentIndex]
                
                let currentButton = xzb_buttons[index]
                
                if layout.isNeedScale {
                    UIView.animate(withDuration: 0.2, animations: {
                        currentButton.transform = CGAffineTransform(scaleX: self.layout.scale , y: self.layout.scale)
                        upButton.transform = CGAffineTransform(scaleX: 1.0 , y: 1.0 )
                    })
                }
                
                setupButtonStatusAnimation(upButton: upButton, currentButton: currentButton)
                
            }
            
            if layout.isColorAnimation == false {
                let upButton = xzb_buttons[xzb_currentIndex]
                let currentButton = xzb_buttons[index]
                setupButtonStatusAnimation(upButton: upButton, currentButton: currentButton)
            }
            
            //如果开启滚动动画
            if isClickScrollAnimation {
                //如果不是点击事件继续在这个地方设置偏移
                if !xzb_isClickScrollAnimation {
                    xzb_createViewControllerHandle?(index)
                    xzb_didSelectTitleViewHandle?(index)
                }
            }else {
                //默认的设置
                xzb_createViewControllerHandle?(index)
                xzb_didSelectTitleViewHandle?(index)
            }
            xzb_currentIndex = index
        }
        isClick = false
        
    }
    
    //MARK: 让title的ScrollView滚动到中心点位置
    private func setupSlierScrollToCenter(offsetX: CGFloat, index: Int)  {
        let currentButton = xzb_buttons[index]
        let btnCenterX = currentButton.center.x
        var scrollX = btnCenterX - sliderScrollView.bounds.width * 0.5
        if scrollX < 0 {
            scrollX = 0
        }
        if scrollX > sliderScrollView.contentSize.width - sliderScrollView.bounds.width {
            scrollX = sliderScrollView.contentSize.width - sliderScrollView.bounds.width
        }
        sliderScrollView.setContentOffset(CGPoint(x: scrollX, y: 0), animated: true)
    }
    
    private func setupButtonStatusAnimation(upButton: UIButton, currentButton: UIButton)  {
        upButton.setTitleColor(layout.titleColor, for: .normal)
        currentButton.setTitleColor(layout.titleSelectColor, for: .normal)
    }
    
    private func currentIndex() -> Int {
        return scrollIndexHandle?() ?? 0
    }
    
    
    
    private func setupIsClickScrollAnimation(index: Int) {
        if !isClickScrollAnimation {
            return
        }
        for button in xzb_buttons {
            if button.tag == index {
                if layout.isNeedScale {
                    button.transform = CGAffineTransform(scaleX: layout.scale , y: layout.scale)
                }
                button.setTitleColor(self.layout.titleSelectColor, for: .normal)
            }else {
                if layout.isNeedScale {
                    button.transform = CGAffineTransform(scaleX: 1.0 , y: 1.0)
                }
                button.setTitleColor(self.layout.titleColor, for: .normal)
            }
        }
        xzb_isClickScrollAnimation = false
    }
}

//MARK: 滑动TitleView的setupLine线的移动
extension XZBPageTitleView {
    
    //MARK: 设置线的移动
    private func setupLineViewX(offsetX: CGFloat) -> Bool {
        if isClick {
            return false
        }
        //目的是改变它的值，让制滑动第一个和最后一个的时候（-0.5），导致数组下标越界
        var offsetX = offsetX
        let scrollW = bounds.width
        let scrollContenSizeW: CGFloat = bounds.width * CGFloat(titles.count)
        // 目的是滑动到最后一个的时候 不让其再往后滑动
        if offsetX + scrollW >= scrollContenSizeW {
            if layout.sliderWidth == xzb_sliderDefaultWidth {
                let adjustX = (xzb_textWidths.last! - xzb_lineWidths.last!) * 0.5
                sliderLineView.frame.origin.x = layout.lrMargin + adjustX
            }else {
                setupSliderLineViewWidth(currentButton: xzb_buttons.last!)
            }
            offsetX = scrollContenSizeW - scrollW - 0.5
        }
        // 目的是滑动到第一个的时候 不让其再往前滑动
        if offsetX <= 0 {
            if layout.sliderWidth == xzb_sliderDefaultWidth {
                let adjustX = (xzb_textWidths[0] - xzb_lineWidths[0]) * 0.5
                sliderLineView.frame.origin.x = layout.lrMargin + adjustX
            }else {
                sliderLineView.frame.origin.x = ((xzb_textWidths[0] + layout.lrMargin * 2) - layout.sliderWidth) * 0.5
            }
            offsetX = 0.5
        }
        var nextIndex = Int(offsetX / scrollW)
        var sourceIndex = Int(offsetX / scrollW)
        //向下取整 目的是减去整数位，只保留小数部分
        var progress = (offsetX / scrollW) - floor(offsetX / scrollW)
        if offsetX > xzb_startOffsetX { // 向左滑动
            //向左滑动 下个位置比源位置下标 多1
            nextIndex = nextIndex + 1
        }else { // 向右滑动
            //向右滑动 由于源向下取整的缘故 必须补1 nextIndex则恰巧是原始位置
            sourceIndex = sourceIndex + 1
            progress = 1 - progress
        }
        let nextButton = xzb_buttons[nextIndex]
        let currentButton = xzb_buttons[sourceIndex]
        if layout.isColorAnimation {
            let colorDelta = (xzb_selectTitleRGBlColor.0 - xzb_titleRGBlColor.0, xzb_selectTitleRGBlColor.1 - xzb_titleRGBlColor.1, xzb_selectTitleRGBlColor.2 - xzb_titleRGBlColor.2)
            let nextColor = UIColor(r: xzb_titleRGBlColor.0 + colorDelta.0 * progress, g: xzb_titleRGBlColor.1 + colorDelta.1 * progress, b: xzb_titleRGBlColor.2 + colorDelta.2 * progress)
            let currentColor = UIColor(r: xzb_selectTitleRGBlColor.0 - colorDelta.0 * progress, g: xzb_selectTitleRGBlColor.1 - colorDelta.1 * progress, b: xzb_selectTitleRGBlColor.2 - colorDelta.2 * progress)
            currentButton.setTitleColor(currentColor, for: .normal)
            nextButton.setTitleColor(nextColor, for: .normal)
        }
        if layout.isNeedScale {
            let scaleDelta = (layout.scale - 1.0) * progress
            currentButton.transform = CGAffineTransform(scaleX: layout.scale - scaleDelta, y: layout.scale - scaleDelta)
            nextButton.transform = CGAffineTransform(scaleX: 1.0 + scaleDelta, y: 1.0 + scaleDelta)
        }
        // 判断是否是自定义Slider的宽度（这里指没有自定义）
        if layout.sliderWidth == xzb_sliderDefaultWidth {
            
            if layout.isAverage {
                /*
                 * 原理：（按钮的宽度 - 线的宽度）/ 2 = 线的X便宜量
                 * 如果是不是平均分配 按钮的宽度 = 线的宽度
                 */
                // 计算宽度的该变量
                let moveW = xzb_lineWidths[nextIndex] - xzb_lineWidths[sourceIndex]
                
                // （按钮的宽度 - 线的宽度）/ 2
                let nextButtonAdjustX = (nextButton.frame.size.width - xzb_lineWidths[nextIndex]) * 0.5
                
                // （按钮的宽度 - 线的宽度）/ 2
                let currentButtonAdjustX = (currentButton.frame.size.width - xzb_lineWidths[sourceIndex]) * 0.5
                
                // x的该变量
                let moveX = (nextButton.frame.origin.x + nextButtonAdjustX) - (currentButton.frame.origin.x + currentButtonAdjustX)
                
                self.sliderLineView.frame.size.width = xzb_lineWidths[sourceIndex] + moveW * progress
                
                self.sliderLineView.frame.origin.x = currentButton.frame.origin.x + moveX * progress + currentButtonAdjustX
                
            }else {
                // 计算宽度的该变量
                let moveW = nextButton.frame.width - currentButton.frame.width
                
                // 计算X的该变量
                let moveX = nextButton.frame.origin.x - currentButton.frame.origin.x
                
                self.sliderLineView.frame.size.width = currentButton.frame.width + moveW * progress
                self.sliderLineView.frame.origin.x = currentButton.frame.origin.x + moveX * progress - 0.25
            }
            
        }else {
            
            
            /*
             * 原理：按钮的最左边X（因为有lrMargin，这里必须减掉） 以及 按钮的相对右边X（注意不是最右边，因为每个按钮的X都有一个lrMargin， 所以相对右边则有两个才能保证按钮的位置，这个和titleMargin无关）
             */
            let maxNextLeft = nextButton.frame.origin.x - layout.lrMargin
            let maxNextRight = maxNextLeft + layout.lrMargin * 2.0 + nextButton.frame.size.width
            let originNextX = (maxNextRight - maxNextLeft - layout.sliderWidth) * 0.5 + maxNextLeft
            
            let maxLeft = currentButton.frame.origin.x - layout.lrMargin
            let maxRight = maxLeft + layout.lrMargin * 2.0 + currentButton.frame.size.width
            let originX = (maxRight - maxLeft - layout.sliderWidth) * 0.5 + maxLeft
            
            let moveX = originNextX - originX
            
            self.sliderLineView.frame.origin.x = originX + moveX * progress
            
            sliderLineView.frame.size.width = layout.sliderWidth
        }
        
        return false
    }
    
    // currentButton将要滚动到的按钮
    private func setupSliderLineViewWidth(currentButton: UIButton)  {
        let maxLeft = currentButton.frame.origin.x - layout.lrMargin
        let maxRight = maxLeft + layout.lrMargin * 2 + currentButton.frame.size.width
        let originX = (maxRight - maxLeft - layout.sliderWidth) * 0.5  + maxLeft
        sliderLineView.frame.origin.x = originX
        sliderLineView.frame.size.width = layout.sliderWidth
    }
}
extension XZBPageTitleView {
    
    public func xzb_scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isCustomTitleView {
            xzb_contentScrollViewDidScroll(scrollView)
            return
        }
        scrollViewDidScrollOffsetX(scrollView.contentOffset.x)
    }
    
    public func xzb_scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.xzb_scrollViewWillBeginDragging?(scrollView)
        if isCustomTitleView {
            xzb_contentScrollViewWillBeginDragging(scrollView)
            return
        }
        xzb_startOffsetX = scrollView.contentOffset.x
    }
    
    public func  xzb_scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if isCustomTitleView {
            xzb_contentScrollViewWillBeginDecelerating(scrollView)
            return
        }
    }
    
    public func xzb_scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isCustomTitleView {
            xzb_contentScrollViewDidEndDecelerating(scrollView)
            return
        }
    }
    
    public func glt_scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.xzb_scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        if isCustomTitleView {
            xzb_contentScrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
            return
        }
    }
    
    public func xzb_scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if isCustomTitleView {
            xzb_contentScrollViewDidEndScrollingAnimation(scrollView)
            return
        }
        if xzb_isClickScrollAnimation {
            let index = currentIndex()
            xzb_createViewControllerHandle?(index)
            setupSlierScrollToCenter(offsetX: scrollView.contentOffset.x, index: index)
            setupIsClickScrollAnimation(index: index)
            xzb_didSelectTitleViewHandle?(index)
        }
    }
}

extension XZBPageTitleView {
    
    private func getRGBWithColor(_ color : UIColor) -> (CGFloat, CGFloat, CGFloat) {
        guard let components = color.cgColor.components else {
            fatalError("请使用RGB方式给标题颜色赋值")
        }
        return (components[0] * 255, components[1] * 255, components[2] * 255)
    }
}
extension XZBPageTitleView {
    
    @discardableResult
    private func subButton(frame: CGRect, flag: Int, title: String?, parentView: UIView) -> UIButton {
        let button = UIButton(type: .custom)
        button.frame = frame
        button.tag = flag
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(titleSelectIndex(_:)), for: .touchUpInside)
        button.titleLabel?.font = layout.titleFont
        parentView.addSubview(button)
        return button
    }
    
}
