//
//  CJGenerateQRCodeManager.h
//  CommonProject
//
//  Created by zhuChaoJun的Mac on 2017/2/23.
//  Copyright © 2017年 zhucj. All rights reserved.
//

#import "CJPlaySoundTool.h"
#import <AVFoundation/AVFoundation.h>

@implementation CJPlaySoundTool


+(void)playSystemSound {
    SystemSoundID outSystemSoundID = [self getSucessSystemSoundID];
    AudioServicesPlaySystemSound(outSystemSoundID);
}

+(void)playSystemAlertSound {
    SystemSoundID outSystemSoundID = [self getSucessSystemSoundID];
    AudioServicesPlayAlertSound(outSystemSoundID);
}

#pragma mark --- private method
+(SystemSoundID)getSucessSystemSoundID {
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"CJQRCode.bundle/sound.caf" ofType:nil];
    NSURL *soundUrl     = [NSURL fileURLWithPath:soundPath];
    
    SystemSoundID outSystemSoundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundUrl, &outSystemSoundID);
    
    return outSystemSoundID;
}
@end
