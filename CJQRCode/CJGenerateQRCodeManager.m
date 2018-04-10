//
//  CJGenerateQRCodeManager.h
//  CommonProject
//
//  Created by zhuChaoJun的Mac on 2017/2/23.
//  Copyright © 2017年 zhucj. All rights reserved.
//

#import "CJGenerateQRCodeManager.h"

@implementation CJGenerateQRCodeManager

+(UIImage *)generateDefaultQRCodeWithContent:(NSString *)content QRCodeSize:(CGFloat)codeWidth {
    // 初始化滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    // 二维码信息
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:contentData forKey:@"inputMessage"];
    
    // 输出
    CIImage *outputIamge = [filter outputImage];
    
    return [self creatNoneInterpolationUIImageFromCIImage:outputIamge imageWidth:codeWidth];
}

+(UIImage *)generateLogoQRCodeWithContent:(NSString *)content logoImage:(UIImage *)logoImage QRCodeSize:(CGFloat)codeWidth logoImageSize:(CGFloat)logoImageWidth{
    
    // 获取默认二维码图片
    UIImage *defaultImage = [self generateDefaultQRCodeWithContent:content QRCodeSize:codeWidth];
    
    // 开启图形上下文，添加Logo
    UIGraphicsBeginImageContextWithOptions(defaultImage.size, NO, [UIScreen mainScreen].scale);
    
    [defaultImage drawInRect:CGRectMake(0, 0, defaultImage.size.width, defaultImage.size.height)];
    
    CGFloat logoImage_x  = (codeWidth - logoImageWidth)*0.5;
    CGFloat logoImage_y  = (codeWidth - logoImageWidth)*0.5;
    [logoImage drawInRect:CGRectMake(logoImage_x, logoImage_y, logoImageWidth, logoImageWidth)];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭图形上下文
    UIGraphicsEndImageContext();
    
    return outputImage;
}

+(UIImage *)generateColorQRCodeWithContent:(NSString *)content backgroundColor:(CIColor *)backgoundColor filterColor:(CIColor *)filterColor QRCodeSize:(CGFloat)codeWidth{
    
    // 生成默认二维码
    UIImage *defautImage = [self generateDefaultQRCodeWithContent:content QRCodeSize:codeWidth];
    CIImage *defautCIImage = [CIImage imageWithCGImage:defautImage.CGImage];
    
    // 添加滤镜
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"];
    [colorFilter setDefaults];
    // 添加图片
    [colorFilter setValue:defautCIImage  forKey:@"inputImage"];
    // 添加颜色
    [colorFilter setValue:filterColor    forKey:@"inputColor0"];
    [colorFilter setValue:backgoundColor forKey:@"inputColor1"];
    // 添加滤镜后的图片
    CIImage *outputImage = [colorFilter outputImage];
    
    
    return [UIImage imageWithCIImage:outputImage];
  
    
}

#pragma mark -- private method
+(UIImage *)creatNoneInterpolationUIImageFromCIImage:(CIImage *)image imageWidth:(CGFloat)imageWidth {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(imageWidth/CGRectGetWidth(extent), imageWidth/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width  = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs     = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context     = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

@end
