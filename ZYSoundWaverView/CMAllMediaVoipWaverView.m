//
//  CMAllMediaVoipWaverView.m
//  CmosAllMedia
//
//  Created by 王智垚 on 2017/9/11.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import "CMAllMediaVoipWaverView.h"

@interface CMAllMediaVoipWaverView ()
//波浪个数
@property (nonatomic, assign) NSInteger wavesCount;
//波浪颜色
@property (nonatomic, strong) UIColor * waveColor;
//主波浪宽度
@property (nonatomic, assign) CGFloat mainWaveWidth;
//副波浪宽度
@property (nonatomic, assign) CGFloat decorativeWavesWidth;
//限制振幅
@property (nonatomic, assign) CGFloat idleAmplitude;
//频率
@property (nonatomic, assign) CGFloat frequency;
//振幅
@property (nonatomic, assign) CGFloat amplitude;
//密度
@property (nonatomic, assign) CGFloat density;
//移相
@property (nonatomic, assign) CGFloat phaseShift;
//阶段
@property (nonatomic, assign) CGFloat phase;

@property (nonatomic, strong) NSMutableArray *waveArray;
@property (nonatomic, assign) CGFloat waveHeight;
@property (nonatomic, assign) CGFloat waveWidth;
@property (nonatomic, assign) CGFloat waveMid;
@property (nonatomic, assign) CGFloat maxAmplitude;
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation CMAllMediaVoipWaverView
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.waveArray = [NSMutableArray new];
    
    self.frequency = 1.2f;
    
    self.amplitude = 1.0f;
    self.idleAmplitude = 0.01f;
    
    self.wavesCount = 3;
    self.phaseShift = -0.25f;
    self.density = 1.f;
    
    self.waveColor = [UIColor whiteColor];
    self.mainWaveWidth = 2.0f;
    self.decorativeWavesWidth = 1.0f;
    
    self.waveHeight = CGRectGetHeight(self.bounds);
    self.waveWidth  = CGRectGetWidth(self.bounds);
    self.waveMid    = self.waveWidth / 2.0f;
    self.maxAmplitude = self.waveHeight / 2.0f;
}

- (void)setWaverLevelBlock:(void (^)(CMAllMediaVoipWaverView *))waverLevelBlock {
    _waverLevelBlock = waverLevelBlock;
    
    [self.displayLink invalidate];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(invokeWaveCallback)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    for(int i=0; i < self.wavesCount; i++) {
        CAShapeLayer *waveline = [CAShapeLayer layer];
        waveline.lineCap       = kCALineCapButt;
        waveline.lineJoin      = kCALineJoinRound;
        waveline.strokeColor   = [[UIColor clearColor] CGColor];
        waveline.fillColor     = [[UIColor clearColor] CGColor];
        [waveline setLineWidth:(i==0 ? self.mainWaveWidth : self.decorativeWavesWidth)];
        CGFloat progress = 1.0f - (CGFloat)i / self.wavesCount;
        CGFloat multiplier = MIN(1.0, (progress / 3.0f * 2.0f) + (1.0f / 3.0f));
        UIColor *color = [self.waveColor colorWithAlphaComponent:(i == 0 ? 1.0 : 1.0 * multiplier)];
        waveline.strokeColor = color.CGColor;
        [self.layer addSublayer:waveline];
        [self.waveArray addObject:waveline];
    }
}

- (void)invokeWaveCallback {
    self.waverLevelBlock(self);
}

- (void)setLevel:(CGFloat)level {
    _level = level;
    
    self.phase += self.phaseShift; // Move the wave
    self.amplitude = fmax( level, self.idleAmplitude);
    [self updateMeters];
}

- (void)updateMeters {
    UIGraphicsBeginImageContext(self.frame.size);
    
    for(int i=0; i < self.wavesCount; i++) {
        
        UIBezierPath *wavelinePath = [UIBezierPath bezierPath];
        
        // Progress is a value between 1.0 and -0.5, determined by the current wave idx, which is used to alter the wave's amplitude.
        CGFloat progress = 1.0f - (CGFloat)i / self.wavesCount;
        CGFloat normedAmplitude = (1.5f * progress - (2.0f / self.wavesCount)) * self.amplitude;
        
        
        for(CGFloat x = 0; x<self.waveWidth + self.density; x += self.density) {
            
            //Thanks to https://github.com/stefanceriu/SCSiriWaveformView
            // We use a parable to scale the sinus wave, that has its peak in the middle of the view.
            CGFloat scaling = -pow(x / self.waveMid  - 1, 2) + 1; // make center bigger
            
            CGFloat y = scaling * self.maxAmplitude * normedAmplitude * sinf(2 * M_PI *(x / self.waveWidth) * self.frequency + self.phase) + (self.waveHeight * 0.5);
            
            if (x==0) {
                [wavelinePath moveToPoint:CGPointMake(x, y)];
            }
            else {
                [wavelinePath addLineToPoint:CGPointMake(x, y)];
            }
        }
        
        CAShapeLayer *waveline = [self.waveArray objectAtIndex:i];
        waveline.path = [wavelinePath CGPath];
    }
    
    UIGraphicsEndImageContext();
}

- (void)dealloc {
    [_displayLink invalidate];
}
@end
