//
//  XZBLayout.swift
//  XZBScrollViewController
//
//  Created by 🍎上的豌豆 on 2018/10/19.
//  Copyright © 2018年 xiao. All rights reserved.
//

import UIKit


let NORMAL_BASE_COLOR: UIColor = UIColor(r: 0, g: 0, b: 0)
let SELECT_BASE_COLOR: UIColor = UIColor(r: 255, g: 0, b: 0)
let xzb_sliderDefaultWidth: CGFloat = 40.010101010
public class XZBLayout: NSObject {
    /* pageView背景颜色 */
    @objc public var titleViewBgColor: UIColor? = UIColor(r: 255, g: 239, b: 213)
    
    /* 标题颜色，请使用RGB赋值 */
    @objc public var titleColor: UIColor? = NORMAL_BASE_COLOR
    
    /* 标题选中颜色，请使用RGB赋值 */
    @objc public var titleSelectColor: UIColor? = SELECT_BASE_COLOR
    
    /* 标题字号 */
    @objc public var titleFont: UIFont? = UIFont.systemFont(ofSize: 16)
    
    /* 滑块底部线的颜色 - UIColor.blue */
    @objc public var bottomLineColor: UIColor? = UIColor.black
    
    /* 整个滑块的高，pageTitleView的高 */
    @objc public var sliderHeight: CGFloat = 44.0
    
    /* 单个滑块的宽度, 一旦设置，将不再自动计算宽度，而是固定为你传递的值 */
    @objc public var sliderWidth: CGFloat = xzb_sliderDefaultWidth
    
    /*
     * 如果刚开始的布局不希望从最左边开始， 只想平均分配在整个宽度中，设置它为true
     * 注意：此时最左边 lrMargin 以及 titleMargin 仍然有效，如果不需要可以手动设置为0
     */
    @objc public var isAverage: Bool = false
    
    /* 滑块底部线的高 */
    @objc public var bottomLineHeight: CGFloat = 2.0
    
    /* 滑块底部线圆角 */
    @objc public var bottomLineCornerRadius: CGFloat = 0.0
    
    /* 是否隐藏滑块、底部线*/
    @objc public var isHiddenSlider: Bool = false
    
    /* 标题直接的间隔（标题距离下一个标题的间隔）*/
    @objc public var titleMargin: CGFloat = 30.0
    
    /* 距离最左边和最右边的距离 */
    @objc public var lrMargin: CGFloat = 10.0
    
    /* 滑动过程中是否放大标题 */
    @objc public var isNeedScale: Bool = true
    
    /* 放大标题的倍率 */
    @objc public var scale: CGFloat = 1.2
    
    /* 是否开启颜色渐变 */
    @objc public var isColorAnimation: Bool = true
    
    /* 是否隐藏底部线 */
    @objc public var isHiddenPageBottomLine: Bool = false
    
    /* pageView底部线的高度 */
    @objc public var pageBottomLineHeight: CGFloat = 0.5
    
    /* pageView底部线的颜色 */
    @objc public var pageBottomLineColor: UIColor? = UIColor(r: 230, g: 230, b: 230)
    
    /* pageView的内容ScrollView是否开启左右弹性效果 */
    @objc public var isShowBounces: Bool = false
    
    /* pageView的内容ScrollView是否开启左右滚动 */
    @objc public var isScrollEnabled: Bool = true
    
    /* pageView的内容ScrollView是否显示HorizontalScrollIndicator */
    @objc public var showsHorizontalScrollIndicator: Bool = true
    
    /* 是否悬停 默认为true开启悬停 此属性仅对LTSimpleManager有效 关闭时记得修改viewControll的frame*/
    @objc public var isHovered: Bool = true
    
    /* 内部使用 - 外界不需要调用 */
    internal var isSinglePageView: Bool = false
}
