//
//  CJGenerateQRCodeManager.h
//  CommonProject
//
//  Created by zhuChaoJun的Mac on 2017/2/23.
//  Copyright © 2017年 zhucj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@protocol CJDetectorAlbumQRCodeManagerDelegate <NSObject>

/// 识别失败
-(void)detectorAlbumQRCodeFailure;

/// 识别失败，alertAction点击
-(void)detectorAlbumQRCodeFailureAlertActionClick;

/// 选择相片时候点击取消
-(void)detectorAlbumQRCodeImagePickDidCancel;

/// 识别成功
-(void)detectorAlbumQRCodeSuccess:(NSArray<NSString *> *)resultArray;

@end

@interface CJDetectorAlbumQRCodeManager : NSObject
@property(nonatomic, assign) PHAuthorizationStatus photoLibAuthorStatus;

@property(nonatomic, weak) id<CJDetectorAlbumQRCodeManagerDelegate> delegate;

/**
 初始化

 @return 初始化对象
 */
+(instancetype)defaultManager;


/**
 跳转到选二维码图片控制器

 @param controller 由controller跳转
 */
-(void)presentDetectorAlbumQRCodeControllerFromController:(UIViewController *)controller
                                                 delegate:(id<CJDetectorAlbumQRCodeManagerDelegate>)delegate;
@end
