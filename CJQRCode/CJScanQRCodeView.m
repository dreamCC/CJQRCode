//
//  CJGenerateQRCodeManager.h
//  CommonProject
//
//  Created by zhuChaoJun的Mac on 2017/2/23.
//  Copyright © 2017年 zhucj. All rights reserved.
//

#import "CJScanQRCodeView.h"
#import "CALayer+CJAnimation.h"
#import "UIView+CJCategory.h"
#import "UIButton+CJCategory.h"
#import <AVFoundation/AVFoundation.h>

@interface CJScanQRCodeView ()

@property (nonatomic, weak) CALayer *scanImageLayer;
@property(nonatomic, strong, readwrite) UIButton *torchButton;
@property(nonatomic, assign, readwrite) CGRect scanAreaRect;


@end

@implementation CJScanQRCodeView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    [self setupScanQRCodeView];

    return self;
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
   
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    CGFloat scanArea_x = (CGRectGetWidth(self.frame) - _scanAreaWidth) * 0.5;
    CGFloat scanArea_y = (CGRectGetHeight(self.frame) - _scanAreaWidth -  100) * 0.5;
    _scanAreaRect      = CGRectMake(scanArea_x, scanArea_y, _scanAreaWidth, _scanAreaWidth);
    
    CAShapeLayer *scanAreaLayer = [CAShapeLayer layer];
    [self.layer addSublayer:scanAreaLayer];
    
    
    UIBezierPath *selfPath     = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *scanAreaPath = [UIBezierPath bezierPathWithRect:_scanAreaRect];
    [selfPath appendPath:scanAreaPath];
    [scanAreaLayer setPath:selfPath.CGPath];
    [scanAreaLayer setFillRule:kCAFillRuleEvenOdd];
    [scanAreaLayer setFillColor:self.backgroundColor.CGColor];
    
    // 设置扫描区域边界样式
    [scanAreaPath setLineWidth:_scanAreaBorderWidth];
    [_scanAreaBorderColor set];
    [scanAreaPath stroke];
    
    // 左上角
    CGPoint cornerPoint, firstPoint, lastPoint;
    UIBezierPath *left_top_path = [UIBezierPath bezierPath];
    switch (_cornerPosition) {
        case CJScanQRCodeViewCornerPositionOverlap:
        {
            cornerPoint = CGPointMake(scanArea_x, scanArea_y);
            firstPoint  = CGPointMake(scanArea_x, scanArea_y + _scanAreaCornerWidth);
            lastPoint   = CGPointMake(scanArea_x + _scanAreaCornerWidth, scanArea_y);
        }
            break;
        case CJScanQRCodeViewCornerPositionOutside:
        {
            cornerPoint = CGPointMake(scanArea_x - _scanAreaCornerBorderWidth * 0.5 + _scanAreaBorderWidth *0.5, scanArea_y - _scanAreaCornerBorderWidth * 0.5 + _scanAreaBorderWidth *0.5);
            firstPoint  = CGPointMake(cornerPoint.x, cornerPoint.y + _scanAreaCornerWidth);
            lastPoint   = CGPointMake(cornerPoint.x + _scanAreaCornerWidth, cornerPoint.y);
        }
            break;
        case CJScanQRCodeViewCornerPositionInside:
        {
            cornerPoint = CGPointMake(scanArea_x + _scanAreaCornerBorderWidth * 0.5 - _scanAreaBorderWidth*0.5, scanArea_y + _scanAreaCornerBorderWidth * 0.5 - _scanAreaBorderWidth*0.5);
            firstPoint  = CGPointMake(cornerPoint.x, cornerPoint.y + _scanAreaCornerWidth);
            lastPoint   = CGPointMake(cornerPoint.x + _scanAreaCornerWidth, cornerPoint.y);
        }
            break;
        default:
            break;
    }
    [left_top_path moveToPoint:firstPoint];
    [left_top_path addLineToPoint:cornerPoint];
    [left_top_path addLineToPoint:lastPoint];
   
    
    // 左下角
    UIBezierPath *left_bottom_path = [UIBezierPath bezierPath];
    switch (_cornerPosition) {
        case CJScanQRCodeViewCornerPositionOverlap:
        {
            cornerPoint = CGPointMake(scanArea_x, scanArea_y + _scanAreaWidth);
            firstPoint  = CGPointMake(cornerPoint.x, cornerPoint.y - _scanAreaCornerWidth);
            lastPoint   = CGPointMake(scanArea_x + _scanAreaCornerWidth, cornerPoint.y);
        }
            break;
        case CJScanQRCodeViewCornerPositionOutside:
        {
            cornerPoint = CGPointMake(scanArea_x - _scanAreaCornerBorderWidth * 0.5 + _scanAreaBorderWidth *0.5, scanArea_y + _scanAreaCornerBorderWidth * 0.5 - _scanAreaBorderWidth *0.5 + _scanAreaWidth);
            firstPoint  = CGPointMake(cornerPoint.x, cornerPoint.y - _scanAreaCornerWidth);
            lastPoint   = CGPointMake(cornerPoint.x + _scanAreaCornerWidth, cornerPoint.y);
        }
            break;
        case CJScanQRCodeViewCornerPositionInside:
        {
            cornerPoint = CGPointMake(scanArea_x + _scanAreaCornerBorderWidth * 0.5 - _scanAreaBorderWidth*0.5, scanArea_y - _scanAreaCornerBorderWidth * 0.5 + _scanAreaBorderWidth*0.5 + _scanAreaWidth);
            firstPoint  = CGPointMake(cornerPoint.x, cornerPoint.y - _scanAreaCornerWidth);
            lastPoint   = CGPointMake(cornerPoint.x + _scanAreaCornerWidth, cornerPoint.y);
        }
            break;
        default:
            break;
    }
    [left_bottom_path moveToPoint:firstPoint];
    [left_bottom_path addLineToPoint:cornerPoint];
    [left_bottom_path addLineToPoint:lastPoint];
    [left_top_path appendPath:left_bottom_path];
    
    // 右上角
    UIBezierPath *right_top_path = [UIBezierPath bezierPath];
    switch (_cornerPosition) {
        case CJScanQRCodeViewCornerPositionOverlap:
        {
            cornerPoint = CGPointMake(scanArea_x + _scanAreaWidth, scanArea_y);
            firstPoint  = CGPointMake(cornerPoint.x - _scanAreaCornerWidth, cornerPoint.y);
            lastPoint   = CGPointMake(cornerPoint.x, cornerPoint.y + _scanAreaCornerWidth);
        }
            break;
        case CJScanQRCodeViewCornerPositionOutside:
        {
            cornerPoint = CGPointMake(scanArea_x + _scanAreaCornerBorderWidth * 0.5 - _scanAreaBorderWidth *0.5 + _scanAreaWidth, scanArea_y - _scanAreaCornerBorderWidth * 0.5 + _scanAreaBorderWidth *0.5);
            firstPoint  = CGPointMake(cornerPoint.x - _scanAreaCornerWidth, cornerPoint.y);
            lastPoint   = CGPointMake(cornerPoint.x, cornerPoint.y + _scanAreaCornerWidth);
        }
            break;
        case CJScanQRCodeViewCornerPositionInside:
        {
            cornerPoint = CGPointMake(scanArea_x - _scanAreaCornerBorderWidth * 0.5 + _scanAreaBorderWidth*0.5 + _scanAreaWidth, scanArea_y + _scanAreaCornerBorderWidth * 0.5 - _scanAreaBorderWidth*0.5);
            firstPoint  = CGPointMake(cornerPoint.x - _scanAreaCornerWidth, cornerPoint.y);
            lastPoint   = CGPointMake(cornerPoint.x, cornerPoint.y + _scanAreaCornerWidth);
        }
            break;
        default:
            break;
    }
    [right_top_path moveToPoint:firstPoint];
    [right_top_path addLineToPoint:cornerPoint];
    [right_top_path addLineToPoint:lastPoint];
    [left_top_path appendPath:right_top_path];
    
    // 右下角
    UIBezierPath *right_bottom_path = [UIBezierPath bezierPath];
    switch (_cornerPosition) {
        case CJScanQRCodeViewCornerPositionOverlap:
        {
            cornerPoint = CGPointMake(scanArea_x + _scanAreaWidth, scanArea_y + _scanAreaWidth);
            firstPoint  = CGPointMake(cornerPoint.x - _scanAreaCornerWidth, cornerPoint.y);
            lastPoint   = CGPointMake(cornerPoint.x, cornerPoint.y - _scanAreaCornerWidth);
        }
            break;
        case CJScanQRCodeViewCornerPositionOutside:
        {
            cornerPoint = CGPointMake(scanArea_x + _scanAreaCornerBorderWidth * 0.5 - _scanAreaBorderWidth *0.5 + _scanAreaWidth, scanArea_y + _scanAreaCornerBorderWidth * 0.5 - _scanAreaBorderWidth *0.5 + _scanAreaWidth);
            firstPoint  = CGPointMake(cornerPoint.x - _scanAreaCornerWidth, cornerPoint.y);
            lastPoint   = CGPointMake(cornerPoint.x, cornerPoint.y - _scanAreaCornerWidth);
        }
            break;
        case CJScanQRCodeViewCornerPositionInside:
        {
            cornerPoint = CGPointMake(scanArea_x - _scanAreaCornerBorderWidth * 0.5 + _scanAreaBorderWidth*0.5 + _scanAreaWidth, scanArea_y - _scanAreaCornerBorderWidth * 0.5 + _scanAreaBorderWidth*0.5 + _scanAreaWidth);
            firstPoint  = CGPointMake(cornerPoint.x - _scanAreaCornerWidth, cornerPoint.y);
            lastPoint   = CGPointMake(cornerPoint.x, cornerPoint.y - _scanAreaCornerWidth);
        }
            break;
        default:
            break;
    }
    
    [right_bottom_path moveToPoint:firstPoint];
    [right_bottom_path addLineToPoint:cornerPoint];
    [right_bottom_path addLineToPoint:lastPoint];
    [left_top_path appendPath:right_bottom_path];
    
    // 四个角统一设置样式
    [_scanAreaCornerColor set];
    [left_top_path setLineCapStyle:kCGLineCapRound];
    [left_top_path setLineWidth:_scanAreaCornerBorderWidth];
    [left_top_path stroke];
    
    
    // 扫描线
    CALayer *imageContentLayer = [CALayer layer];
    imageContentLayer.frame    = CGRectMake(scanArea_x, scanArea_y, _scanAreaWidth, _scanAreaWidth);
    imageContentLayer.backgroundColor = [UIColor clearColor].CGColor;
    imageContentLayer.masksToBounds   = YES;
    [self.layer addSublayer:imageContentLayer];
    
    NSString *scanImagePath;
    if (_scanStyle == CJScanQRCodeViewStyleScanLine) {
        scanImagePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"CJQRCode.bundle/QRCodeScanningLine.png"];
    }else if (_scanStyle == CJScanQRCodeViewStyleScanGrid) {
        scanImagePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"CJQRCode.bundle/QRCodeScanningLineGrid.png"];
    }
    UIImage *scanImage  = [UIImage imageWithContentsOfFile:scanImagePath];
    
    CALayer *scanImageLayer = [CALayer layer];
    scanImageLayer.frame    = CGRectMake(0, - _scanAreaWidth, _scanAreaWidth, _scanAreaWidth);
    scanImageLayer.contents = (__bridge id _Nullable)(scanImage.CGImage);
    scanImageLayer.contentsGravity =  kCAGravityResizeAspect;
    [imageContentLayer addSublayer:scanImageLayer];
    _scanImageLayer    = scanImageLayer;
    
    // 扫描线动画
    CABasicAnimation *scanAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    scanAnimation.toValue  = @(_scanAreaWidth);
    scanAnimation.duration = 3.0f;
    scanAnimation.repeatCount    = HUGE;
    scanAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [scanImageLayer addAnimation:scanAnimation forKey:@"com.scanAnimation.cn"];
    
    // 手电筒
    [self addSubview:self.torchButton];

  
}

-(void)stopAnimation {
    [_scanImageLayer cj_pauseAnimation];
}

-(void)continueAnimation {
    [_scanImageLayer cj_continueAnimation];
}

#pragma mark ---  private method
-(void)setupScanQRCodeView {
    
    self.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.2];
    _scanAreaWidth       = CGRectGetWidth(self.frame) - 50 *2;
    _scanAreaBorderColor = [UIColor whiteColor];
    _scanAreaBorderWidth = 0.5f;
    _scanAreaCornerColor = [UIColor colorWithRed:85/255.0f green:183/255.0 blue:55/255.0 alpha:1.0];
    _scanAreaCornerWidth = 20.f;
    _cornerPosition      = CJScanQRCodeViewCornerPositionInside;
    _scanStyle           = CJScanQRCodeViewStyleScanLine;
    _scanAreaCornerBorderWidth = 4.f;
}

-(void)torchButtonClick:(UIButton *)torchButton {
    torchButton.selected = !torchButton.selected;
    
    if (torchButton.selected) {
        [self opeonCameraTorch];
    }else {
        [self closeCameraTorch];
    }
}

-(void)opeonCameraTorch {
    [self deviceLockForConfig:^(AVCaptureDevice *device) {
        device.torchMode = AVCaptureTorchModeOn;
    }];
}

-(void)closeCameraTorch {
    [self deviceLockForConfig:^(AVCaptureDevice *device) {
        device.torchMode = AVCaptureTorchModeOff;
    }];
}

-(void)deviceLockForConfig:(void(^)(AVCaptureDevice *device))lockConfig {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![device hasTorch]) {
        NSLog(@"手电筒不可用");
        return;
    }
    NSError *error;
    BOOL isLock = [device lockForConfiguration:&error];
    if (isLock) {
        lockConfig(device);
        [device unlockForConfiguration];
    }
}

#pragma mark --- setter
-(void)setScanStyle:(CJScanQRCodeViewScanStyle)scanStyle {
    _scanStyle = scanStyle;
    
    switch (scanStyle) {
        case CJScanQRCodeViewStyleScanLine:
            _scanAreaCornerColor = [UIColor colorWithRed:85/255.0f green:183/255.0 blue:55/255.0 alpha:1.0];
            break;
        case CJScanQRCodeViewStyleScanGrid:
            _scanAreaCornerColor = [UIColor orangeColor];
            break;
        default:
            break;
    }
    [self setNeedsDisplay];
}

-(void)setScanAreaWidth:(CGFloat)scanAreaWidth {
    _scanAreaWidth = scanAreaWidth;
    [self setNeedsDisplay];
}

-(UIButton *)torchButton {
    if (!_torchButton) {
        CGFloat scanArea_y = (CGRectGetHeight(self.frame) - _scanAreaWidth -  100) * 0.5;
        NSString *torchOpenPath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"CJQRCode.bundle/SGQRCodeFlashlightOpenImage.png"];
        NSString *torchClosePath= [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"CJQRCode.bundle/SGQRCodeFlashlightCloseImage.png"];
        
        UIButton *torchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [torchButton setTitle:@"轻触打开" forState:UIControlStateNormal];
        [torchButton setTitle:@"轻触关闭" forState:UIControlStateSelected];
        [torchButton setImage:[UIImage imageWithContentsOfFile:torchOpenPath] forState:UIControlStateNormal];
        [torchButton setImage:[UIImage imageWithContentsOfFile:torchClosePath] forState:UIControlStateSelected];
        [torchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        torchButton.titleLabel.font = [UIFont systemFontOfSize:12];
        torchButton.frame      = CGRectMake((self.frame.size.width - 60)*0.5, scanArea_y + _scanAreaWidth - 70, 60, 70);
        torchButton.selected   = NO;
        [torchButton cj_changeImagePosition:CJImagePositionTop];
        [torchButton addTarget:self action:@selector(torchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [torchButton setHidden:YES];
        _torchButton = torchButton;
    }
    return _torchButton;
}

@end