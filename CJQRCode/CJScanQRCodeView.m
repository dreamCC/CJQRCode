//
//  CJGenerateQRCodeManager.h
//  CommonProject
//
//  Created by zhuChaoJun的Mac on 2017/2/23.
//  Copyright © 2017年 zhucj. All rights reserved.
//

#import "CJScanQRCodeView.h"
#import <AVFoundation/AVFoundation.h>

@interface CJScanQRCodeView ()

@property (nonatomic, weak) CALayer *scanImageLayer;
@property(nonatomic, strong, readwrite) UIButton *torchButton;
@property(nonatomic, assign, readwrite) CGRect scanAreaRect;

// 扫描整体显示
@property(nonatomic, weak) CAShapeLayer *scanAreaLayer;
// 四个拐角
@property(nonatomic, weak) CAShapeLayer *cornerShapeLayer;
// 扫描线
@property(nonatomic, weak) CALayer *imageContentLayer;
// 扫面动画
@property(nonatomic, weak) CABasicAnimation *scanAnimation;


@end

@implementation CJScanQRCodeView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    [self setupScanQRCodeView];
    
    [self setupContentView];
    return self;
}


-(void)stopAnimation {
    [self stopAnimationWithLayer:_scanImageLayer];
}

-(void)continueAnimation {
    [self continueAnimationWithLayer:_scanImageLayer];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateContentViewPosition];
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

-(void)setupContentView {

    CAShapeLayer *scanAreaLayer = [CAShapeLayer layer];
    [scanAreaLayer setFillRule:kCAFillRuleEvenOdd];
    [self.layer addSublayer:scanAreaLayer];
    _scanAreaLayer = scanAreaLayer;
    

    
    // 设置扫描区域边界样式
    [scanAreaLayer setStrokeColor:_scanAreaBorderColor.CGColor];
    [scanAreaLayer setLineWidth:_scanAreaBorderWidth];
    
    // 四个拐角
    CAShapeLayer *cornerShapeLayer = [CAShapeLayer layer];
    cornerShapeLayer.lineCap     = kCALineCapRound;
    cornerShapeLayer.fillColor   = [UIColor clearColor].CGColor;
    [self.layer addSublayer:cornerShapeLayer];
    _cornerShapeLayer = cornerShapeLayer;
    
    
    // 扫描线
    CALayer *imageContentLayer = [CALayer layer];
    imageContentLayer.backgroundColor = [UIColor clearColor].CGColor;
    imageContentLayer.masksToBounds   = YES;
    [self.layer addSublayer:imageContentLayer];
    _imageContentLayer = imageContentLayer;

    

    CALayer *scanImageLayer = [CALayer layer];
    scanImageLayer.contentsGravity =  kCAGravityResizeAspect;
    [imageContentLayer addSublayer:scanImageLayer];
    _scanImageLayer    = scanImageLayer;
    
    // 手电筒
    [self addSubview:self.torchButton];

}


-(void)updateContentViewPosition {
    
    CGFloat scanArea_x = (CGRectGetWidth(self.frame) - _scanAreaWidth) * 0.5;
    CGFloat scanArea_y = (CGRectGetHeight(self.frame) - _scanAreaWidth -  100) * 0.5;
    _scanAreaRect      = CGRectMake(scanArea_x, scanArea_y, _scanAreaWidth, _scanAreaWidth);
    
    UIBezierPath *selfPath     = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *scanAreaPath = [UIBezierPath bezierPathWithRect:_scanAreaRect];
    [selfPath appendPath:scanAreaPath];
    [self.scanAreaLayer setPath:selfPath.CGPath];
    [self.scanAreaLayer setFillColor:self.backgroundColor.CGColor];
    [self.scanAreaLayer setStrokeColor:_scanAreaBorderColor.CGColor];
    [self.scanAreaLayer setLineWidth:_scanAreaBorderWidth];
    
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
    self.cornerShapeLayer.path = left_top_path.CGPath;
    self.cornerShapeLayer.lineWidth   = _scanAreaCornerBorderWidth;
    self.cornerShapeLayer.strokeColor = _scanAreaCornerColor.CGColor;
    
    self.imageContentLayer.frame = CGRectMake(scanArea_x, scanArea_y, _scanAreaWidth, _scanAreaWidth);
    
    NSString *scanImagePath;
    if (_scanStyle == CJScanQRCodeViewStyleScanLine) {
        scanImagePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"CJQRCode.bundle/QRCodeScanningLine.png"];
    }else if (_scanStyle == CJScanQRCodeViewStyleScanGrid) {
        scanImagePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"CJQRCode.bundle/QRCodeScanningLineGrid.png"];
    }
    UIImage *scanImage  = [UIImage imageWithContentsOfFile:scanImagePath];
    self.scanImageLayer.contents = (__bridge id _Nullable)(scanImage.CGImage);
    self.scanImageLayer.frame    = CGRectMake(0, - _scanAreaWidth, _scanAreaWidth, _scanAreaWidth);

    // 扫描线动画
    CABasicAnimation *scanAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    scanAnimation.toValue  = @(_scanAreaWidth);
    scanAnimation.duration = 3.0f;
    scanAnimation.repeatCount    = HUGE;
    scanAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.scanImageLayer addAnimation:scanAnimation forKey:@"com.scanAnimation.cn"];
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

-(void)stopAnimationWithLayer:(CALayer *)layer {
    if (layer.speed == 0) {
        return;
    }
    CFTimeInterval pauseTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed      = 0.f;
    layer.timeOffset = pauseTime;
}

-(void)continueAnimationWithLayer:(CALayer *)layer {
    if (layer.speed != 0) return;
    CFTimeInterval  pauseTime = layer.timeOffset;
    
    layer.speed      = 1.0f;
    layer.timeOffset = 0.f;
    layer.beginTime  = 0.f; //表示持续时间内的，开始时间
    
    CFTimeInterval sinceTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pauseTime;
    layer.beginTime  = sinceTime;
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
}

-(void)setScanAreaWidth:(CGFloat)scanAreaWidth {
    _scanAreaWidth = scanAreaWidth;
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
        [torchButton setImageEdgeInsets:UIEdgeInsetsMake(-torchButton.titleLabel.intrinsicContentSize.height, 0, 0, -torchButton.titleLabel.intrinsicContentSize.width)];
        [torchButton setTitleEdgeInsets:UIEdgeInsetsMake(torchButton.currentImage.size.height, -torchButton.currentImage.size.width, 0, 0)];
        [torchButton addTarget:self action:@selector(torchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [torchButton setHidden:YES];
        _torchButton = torchButton;
    }
    return _torchButton;
}

@end
