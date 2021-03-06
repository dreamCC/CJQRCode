//
//  CJGenerateQRCodeManager.h
//  CommonProject
//
//  Created by zhuChaoJun的Mac on 2017/2/23.
//  Copyright © 2017年 zhucj. All rights reserved.
//

#import "CJScanQRCodeManager.h"
#import "CJPlaySoundTool.h"

@interface CJScanQRCodeManager ()<AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@property(nonatomic, strong) AVCaptureSession *session;

@property(nonatomic, strong) CJScanQRCodeView *scanView;

@end

@implementation CJScanQRCodeManager

+(instancetype)defaultManager {
   
    return [[CJScanQRCodeManager alloc] init];
}

-(instancetype)init {
    self = [super init];
    if (self) {
       
    }
    return self;
}

+(CJCameraAuthorizationStatus)cameraAuthorizeStatus {
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            return CJCameraAuthorizationStatusDenied;
        case AVAuthorizationStatusNotDetermined:
            return CJCameraAuthorizationStatusNotDetermined;
        case AVAuthorizationStatusAuthorized:
            return CJCameraAuthorizationStatusAuthorized;
        default:
            break;
    }
    return CJCameraAuthorizationStatusNotDetermined;
}

+(void)requestCameraAuthorizeStatus:(void (^)(CJCameraAuthorizationStatus))completionHandle {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        CJCameraAuthorizationStatus status = granted?CJCameraAuthorizationStatusAuthorized:CJCameraAuthorizationStatusDenied;
        completionHandle(status);
    }];
}

-(void)setupScanQRCodeManagerWithSessionPreset:(NSString *)sessionPreset
                           metadataObjectTypes:(NSArray *)metadataObjectTypes
                                   previewView:(UIView *)view
                                      scanView:(CJScanQRCodeView *)scanView
                                      delegate:(id<CJScanQRCodeManagerDelegate>)delegate {
    
    if (!view) {
        @throw [NSException exceptionWithName:@"show in view" reason:@"you must give a view to show" userInfo:nil];
    }
    
    _scanView     = scanView;
    
    self.delegate = delegate;
    
    sessionPreset       = sessionPreset ?:AVCaptureSessionPresetHigh;
    metadataObjectTypes = metadataObjectTypes ?:@[AVMetadataObjectTypeQRCode,
                                                  AVMetadataObjectTypeEAN13Code,
                                                  AVMetadataObjectTypeEAN8Code,
                                                  AVMetadataObjectTypeCode128Code];
    
    _session = [[AVCaptureSession alloc] init];
    if ([_session canSetSessionPreset:sessionPreset]) {
        [_session setSessionPreset:sessionPreset];
    }
    
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) {
        NSLog(@"AVCaptureDevice init failt");
        return;
    }
    
    NSError *inputError;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&inputError];
    if (inputError) {
        NSLog(@"AVCaptureDeviceInput init failt:%@",inputError);
        return;
    }
    
    if ([_session canAddInput:input]) {
        [_session addInput:input];
    }
    
    
    // 元数据输出流
    AVCaptureMetadataOutput *metaDataOutput = [[AVCaptureMetadataOutput alloc] init];
    if ([_session canAddOutput:metaDataOutput]) {
        [_session addOutput:metaDataOutput];
    }
    
    [metaDataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    metaDataOutput.metadataObjectTypes = metadataObjectTypes;
    
    // 摄像数据流
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    if ([_session canAddOutput:videoDataOutput]) {
        [_session addOutput:videoDataOutput];
    }
   
    
    AVCaptureVideoPreviewLayer *priviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    priviewLayer.frame        = view.bounds;
    priviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [view.layer insertSublayer:priviewLayer atIndex:0];
    [view addSubview:scanView];

   
    // 设置扫描范围
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect convertRect = [self.scanView convertRect:self.scanView.scanAreaRect toView:view];
        metaDataOutput.rectOfInterest = [priviewLayer metadataOutputRectOfInterestForRect:convertRect];
    });
  
}


-(void)startScan {
    if (!_session) {
        NSLog(@"AVCaptureSession is nil . you must first use method setupScanQRCodeManagerWithSessionPreset: metadataObjectTypes: showInView: to init session !");
        return;
    }
    if ([_session isRunning]) {
        return;
    }

    [_session startRunning];
    [_scanView continueAnimation];
}

-(void)stopScan {
    if (!_session) {
        NSLog(@"AVCaptureSession is nil . you must first use method setupScanQRCodeManagerWithSessionPreset: metadataObjectTypes: showInView: to init session !");
        return;
    }
    
    if ([_session isRunning]) {
        [_session stopRunning];
        [_scanView stopAnimation];
    }
}

-(void)playerScanSucessSound {
    [CJPlaySoundTool playSystemSound];
}

-(void)playerScanSucessAlert {
    [CJPlaySoundTool playSystemAlertSound];
}

-(void)setVideoZoomFactor:(CGFloat)scale {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    [device lockForConfiguration:&error];
    if (error) {
        return;
    }
    device.videoZoomFactor  = scale;
    [device unlockForConfiguration];
}
#pragma mark --- AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
   
    if ([self.delegate respondsToSelector:@selector(scanQRCodeManager:didOutputMetadataObject:)]) {
        AVMetadataMachineReadableCodeObject *metaMachineObj = metadataObjects.firstObject;
        [self.delegate scanQRCodeManager:self didOutputMetadataObject:metaMachineObj];
    }
    
}

#pragma mark --- AVCaptureVideoDataOutputSampleBufferDelegate
-(void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
  
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata   = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue  = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    if (brightnessValue < -1 && _scanView.torchButton.hidden) {
        [_scanView.torchButton setHidden:NO];
    }else if (brightnessValue >= -1 && !_scanView.torchButton.selected && !_scanView.torchButton.hidden) {
        [_scanView.torchButton setHidden:YES];
    }
    
}


-(void)dealloc {
    [self stopScan];
}


@end
