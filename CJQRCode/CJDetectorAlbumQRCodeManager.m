//
//  CJGenerateQRCodeManager.h
//  CommonProject
//
//  Created by zhuChaoJun的Mac on 2017/2/23.
//  Copyright © 2017年 zhucj. All rights reserved.
//

#import "CJDetectorAlbumQRCodeManager.h"
#import "CJPlaySoundTool.h"
#import "CJProgressHUD.h"

@interface CJDetectorAlbumQRCodeManager ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic, strong) UIViewController *controller;

@property(nonatomic, strong) NSMutableArray *resultMAry;

@end

@implementation CJDetectorAlbumQRCodeManager

+(instancetype)defaultManager {
    return [[CJDetectorAlbumQRCodeManager alloc] init];
}

-(instancetype)init {
    self = [super init];
    if (!self) return nil;
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    self.photoLibAuthorStatus    = status;
    switch (status) {
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
        {
            NSLog(@"无相册访问权限，请到设置->隐私->相册里面打开权限");
        }
            break;
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                self.photoLibAuthorStatus = status;
                if (status == PHAuthorizationStatusDenied) {
                    NSLog(@"不允许访问相册");
                }else if (status == PHAuthorizationStatusAuthorized) {
                    NSLog(@"允许访问相册");
                }
            }];
        }
            break;
            
        default:
            break;
    }
    
    
    return self;
}

-(void)presentDetectorAlbumQRCodeControllerFromController:(UIViewController *)controller delegate:(id<CJDetectorAlbumQRCodeManagerDelegate>)delegate{
    if (!controller) {
        @throw [NSException exceptionWithName:@"UIViewController" reason:@"FromController must be have" userInfo:nil];
    }
    
    if (self.photoLibAuthorStatus != PHAuthorizationStatusAuthorized) {
        NSLog(@"无访问相册权限");
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    imagePicker.delegate = self;
    imagePicker.modalPresentationStyle = UIModalPresentationCustom;
    [controller presentViewController:imagePicker animated:YES completion:nil];
    _controller   = controller;
    self.delegate = delegate;
}

#pragma mark --- UIImagePickerDelegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [_controller dismissViewControllerAnimated:YES completion:nil];
    if ([self.delegate respondsToSelector:@selector(detectorAlbumQRCodeImagePickDidCancel)]) {
        [self.delegate detectorAlbumQRCodeImagePickDidCancel];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
     [_controller dismissViewControllerAnimated:YES completion:^{}];
    
    [self.resultMAry removeAllObjects];
    // 选中的图片
    UIImage *selectImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [CJProgressHUD showNotice:@"识别中"];
    // 创建二维码识别对象
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    
    NSArray<CIFeature *> *featuresResult = [detector featuresInImage:[CIImage imageWithCGImage:selectImage.CGImage]];
    if (featuresResult.count == 0) {
        [CJProgressHUD hiddenNotice];
       
        [self showAlterViewSureActionClick:^{
            if ([self.delegate respondsToSelector:@selector(detectorAlbumQRCodeFailureAlertActionClick)]) {
                [self.delegate detectorAlbumQRCodeFailureAlertActionClick];
            }
        }];
        if ([self.delegate respondsToSelector:@selector(detectorAlbumQRCodeFailure)]) {
            [self.delegate detectorAlbumQRCodeFailure];
        }

        return;
    }else {
        
        for (int i = 0; i < featuresResult.count; i++) {
            CIQRCodeFeature *codeFeature = (CIQRCodeFeature *)featuresResult[i];
            NSString *resultString       = codeFeature.messageString;
            [self.resultMAry addObject:resultString];
        }
        [CJProgressHUD hiddenNotice];
        [CJPlaySoundTool playSystemSound];
        if ([self.delegate respondsToSelector:@selector(detectorAlbumQRCodeSuccess:)]) {
            [self.delegate detectorAlbumQRCodeSuccess:self.resultMAry];
        }
        return;
    }
    
    
}

#pragma mark --- private method
-(void)showAlterViewSureActionClick:(dispatch_block_t)sureActionBlock {
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"未识别到二维码" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action    = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alter dismissViewControllerAnimated:YES completion:nil];
        if (sureActionBlock) {
            sureActionBlock();
        }
    }];
    [alter addAction:action];
    [_controller presentViewController:alter animated:YES completion:nil];
}

#pragma mark --- lazy
-(NSMutableArray *)resultMAry {
    if (!_resultMAry) {
        _resultMAry = [NSMutableArray array];
    }
    return _resultMAry;
}
@end



