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

/// 选择相片时候点击取消
-(void)detectorAlbumQRCodeImagePickDidCancel;

/// 将要识别二维码
-(void)willDetectorAlbumQRCode:(UIImage *)selectedImage;

/// 识别成功
-(void)detectorAlbumQRCodeSuccess:(NSArray<NSString *> *)resultArray;


/// 识别失败
-(void)detectorAlbumQRCodeFailure;

/// 识别失败，alertAction点击
-(void)detectorAlbumQRCodeFailureAlertActionClick;

@end

typedef NS_ENUM(NSUInteger, CJPhotoAuthorizationStatus) {
    CJPhotoAuthorizationStatusAuthorized,
    CJPhotoAuthorizationStatusDenied,
    CJPhotoAuthorizationStatusNotDetermined,
};

@interface CJDetectorAlbumQRCodeManager : NSObject

@property(nonatomic, weak) id<CJDetectorAlbumQRCodeManagerDelegate> delegate;

/**
 初始化

 @return 初始化对象
 */
+(instancetype)defaultManager;


/**
 获取相册授权状态

 @return 授权状态
 */
+(CJPhotoAuthorizationStatus)photoAuthorizationStatus;


/**
 配合上面使用，如果授权状态是CJPhotoAuthorizationStatusNotDetermined 那么调用改方法，调起系统授权弹窗

 @param completionHandle 授权完成回调
 */
+(void)requestPhotoAuthorizationStatus:(void(^)(CJPhotoAuthorizationStatus status))completionHandle;


/**
 跳转到选二维码图片控制器

 @param controller 由controller跳转
 */
-(void)presentDetectorAlbumQRCodeControllerFromController:(UIViewController *)controller
                                                 delegate:(id<CJDetectorAlbumQRCodeManagerDelegate>)delegate;
@end
