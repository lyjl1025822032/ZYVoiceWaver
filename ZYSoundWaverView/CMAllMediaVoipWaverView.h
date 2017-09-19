//
//  CMAllMediaVoipWaverView.h
//  CmosAllMedia
//
//  Created by 王智垚 on 2017/9/11.
//  Copyright © 2017年 liangscofield. All rights reserved.
//  声音波浪

#import <UIKit/UIKit.h>

@interface CMAllMediaVoipWaverView : UIView
@property (nonatomic, copy)void(^waverLevelBlock)(CMAllMediaVoipWaverView *waver);
//分贝数值
@property (nonatomic, assign) CGFloat level;
@end
