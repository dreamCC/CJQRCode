//
//  CJGenerateQRCodeManager.h
//  CommonProject
//
//  Created by zhuChaoJun的Mac on 2017/2/23.
//  Copyright © 2017年 zhucj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CJGenerateQRCodeManager : NSObject


/**
 生成一张普通二维码

 @param content 二维码内容
 @param codeWidth 二维码宽度（默认是正方形）
 @return 二维码图片
 */
+(UIImage *)generateDefaultQRCodeWithContent:(NSString *)content
                                  QRCodeSize:(CGFloat)codeWidth;


/**
 生成一张带logo的二维码

 @param content 内容
 @param logoImage logo图片
 @param codeWidth 二维码宽度（默认正方形）
 @return 二维码图片
 */
+(UIImage *)generateLogoQRCodeWithContent:(NSString *)content
                                logoImage:(UIImage *)logoImage
                               QRCodeSize:(CGFloat)codeWidth
                            logoImageSize:(CGFloat)logoImageWidth;



/**
 生成一张带颜色的二维码

 @param content 二维码内容
 @param backgoundColor 背景颜色
 @param filterColor 二维码颜色
 @return 二维码图片
 */
+(UIImage *)generateColorQRCodeWithContent:(NSString *)content
                           backgroundColor:(CIColor *)backgoundColor
                               filterColor:(CIColor *)filterColor
                                 QRCodeSize:(CGFloat)codeWidth;

@end
