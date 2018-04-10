//
//  CJGenerateQRCodeManager.h
//  CommonProject
//
//  Created by zhuChaoJun的Mac on 2017/2/23.
//  Copyright © 2017年 zhucj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CJScanQRCodeViewCornerPosition) {
    CJScanQRCodeViewCornerPositionOutside,
    CJScanQRCodeViewCornerPositionInside,
    CJScanQRCodeViewCornerPositionOverlap //默认重合
};

typedef NS_ENUM(NSUInteger, CJScanQRCodeViewScanStyle) {
    CJScanQRCodeViewStyleScanLine, // 线
    CJScanQRCodeViewStyleScanGrid  // 网格
};

@interface CJScanQRCodeView : UIView

/// 扫描范围
@property(nonatomic, assign, readonly) CGRect scanAreaRect;

/// 手电筒
@property(nonatomic, strong, readonly) UIButton *torchButton;


/// 扫描区域宽度(高度和宽度一样), 默认(self.frame.size.width - 50 * 2),表示左右边界各为50.
@property(nonatomic, assign) CGFloat scanAreaWidth;

/// 扫描区域边界颜色，默认whiteColor
@property(nonatomic, strong) UIColor *scanAreaBorderColor;

/// 扫描区域边界宽度，默认0.5f
@property(nonatomic, assign) CGFloat scanAreaBorderWidth;

/// 扫描区域四个角的颜色，默认和扫描风格匹配
@property(nonatomic, strong) UIColor *scanAreaCornerColor;

/// 四个角线宽度，默认4.f.
@property(nonatomic, assign) CGFloat scanAreaCornerBorderWidth;

/// 扫描区域四个角宽度，默认15.f
@property(nonatomic, assign) CGFloat scanAreaCornerWidth;

/// 扫描区域四个角度所在位置，默认CJScanQRCodeViewCornerPositionInside
@property(nonatomic, assign) CJScanQRCodeViewCornerPosition cornerPosition;

/// 扫描风格，默认是CJScanQRCodeViewScanStyleLine
@property(nonatomic, assign) CJScanQRCodeViewScanStyle scanStyle;


/**
 停止动画
 */
-(void)stopAnimation;

/**
 继续动画
 */
-(void)continueAnimation;
@end
