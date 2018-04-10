//
//  CJGenerateQRCodeManager.h
//  CommonProject
//
//  Created by zhuChaoJun的Mac on 2017/2/23.
//  Copyright © 2017年 zhucj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CJScanQRCodeView.h"

@class CJScanQRCodeManager;
@protocol CJScanQRCodeManagerDelegate <NSObject>

-(void)scanQRCodeManager:(CJScanQRCodeManager *)scanQRCodeManager didOutputMetadataObject:(AVMetadataMachineReadableCodeObject *)metadataMachineObject;

@end

@interface CJScanQRCodeManager : NSObject

@property(nonatomic, weak) id<CJScanQRCodeManagerDelegate> delegate;

@property(nonatomic, assign, readonly) AVAuthorizationStatus status;


@property(nonatomic, strong) CJScanQRCodeView *scanView;
/**
 初始化方法

 @return 实例对象
 */
+(instancetype)defaultManager;


/**
 设置扫描二维码工具

 @param sessionPreset AVCaptureSession.sessionPreset
 @param metadataObjectTypes AVCaptureMetadataOutput.metadataObjectTypes
 @param view show in View
 */
-(void)setupScanQRCodeManagerWithSessionPreset:(NSString *)sessionPreset
                           metadataObjectTypes:(NSArray *)metadataObjectTypes
                                   previewView:(UIView *)view
                                      scanView:(CJScanQRCodeView *)scanView
                                      delegate:(id<CJScanQRCodeManagerDelegate>)delegate;



/**
 开始扫描
 */
-(void)startScan;


/**
 停止扫描
 */
-(void)stopScan;


/**
 播放成功声音
 */
-(void)playerScanSucessSound;

/**
 播放成功声音，带振动
 */
-(void)playerScanSucessAlert;


/**
 设置焦距

 @param scale 焦距缩放系数
 */
-(void)setVideoZoomFactor:(CGFloat)scale;
@end
