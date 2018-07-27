//
//  CJGenerateQRCodeManager.h
//  CommonProject
//
//  Created by zhuChaoJun的Mac on 2017/2/23.
//  Copyright © 2017年 zhucj. All rights reserved.
//

#import "CJDetectorAlbumQRCodeManager.h"
#import "CJPlaySoundTool.h"

@interface CJDetectorAlbumQRCodeManager ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic, strong) UIViewController *controller;

@property(nonatomic, strong) NSMutableArray *resultMAry;

@end

@implementation CJDetectorAlbumQRCodeManager

+(instancetype)defaultManager {
    return [[CJDetectorAlbumQRCodeManager alloc] init];
}


+(CJPhotoAuthorizationStatus)photoAuthorizationStatus {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
            return CJPhotoAuthorizationStatusDenied;
        case PHAuthorizationStatusNotDetermined:
            return CJPhotoAuthorizationStatusNotDetermined;
        case PHAuthorizationStatusAuthorized:
            return CJPhotoAuthorizationStatusAuthorized;
        default:
            break;
    }
    return CJPhotoAuthorizationStatusNotDetermined;
}

+(void)requestPhotoAuthorizationStatus:(void (^)(CJPhotoAuthorizationStatus))completionHandle {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        CJPhotoAuthorizationStatus photoStatus = CJPhotoAuthorizationStatusNotDetermined;
        if (status == PHAuthorizationStatusAuthorized) {
            photoStatus = CJPhotoAuthorizationStatusAuthorized;
        }else if (status == PHAuthorizationStatusDenied) {
            photoStatus = CJPhotoAuthorizationStatusDenied;
        }
        completionHandle(photoStatus);
    }];
}

-(void)presentDetectorAlbumQRCodeControllerFromController:(UIViewController *)controller delegate:(id<CJDetectorAlbumQRCodeManagerDelegate>)delegate{
    if (!controller) {
        @throw [NSException exceptionWithName:@"UIViewController" reason:@"FromController must be have" userInfo:nil];
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
    
    // 创建二维码识别对象
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willDetectorAlbumQRCode:)]) {
        [self.delegate willDetectorAlbumQRCode:selectImage];
    }
    
    NSArray<CIFeature *> *featuresResult = [detector featuresInImage:[CIImage imageWithCGImage:selectImage.CGImage]];
    if (featuresResult.count == 0) {
      
        [self showAlterViewSureActionClick:^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(detectorAlbumQRCodeFailureAlertActionClick)]) {
                [self.delegate detectorAlbumQRCodeFailureAlertActionClick];
            }
        }];
        if (self.delegate && [self.delegate respondsToSelector:@selector(detectorAlbumQRCodeFailure)]) {
            [self.delegate detectorAlbumQRCodeFailure];
        }
        return;
    }else {
        
        for (int i = 0; i < featuresResult.count; i++) {
            CIQRCodeFeature *codeFeature = (CIQRCodeFeature *)featuresResult[i];
            NSString *resultString       = codeFeature.messageString;
            [self.resultMAry addObject:resultString];
        }
      
        [CJPlaySoundTool playSystemSound];
        if (self.delegate && [self.delegate respondsToSelector:@selector(detectorAlbumQRCodeSuccess:)]) {
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



