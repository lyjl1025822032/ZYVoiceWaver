//
//  ViewController.m
//  ZYSoundWaverView
//
//  Created by 王智垚 on 2017/9/19.
//  Copyright © 2017年 王智垚. All rights reserved.
//

#import "ViewController.h"
#import "CMAllMediaVoipWaverView.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
//获取麦克风声音
@property (nonatomic, strong) AVAudioRecorder *recorder;
//声音波形视图
@property (nonatomic, strong) CMAllMediaVoipWaverView *waverView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor blackColor];
    [self configureAVAudioSession];
}

//配置麦克风音频
- (void)configureAVAudioSession {
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    NSDictionary *settings = @{AVSampleRateKey:[NSNumber numberWithFloat: 44100.0],//采样率
                               AVFormatIDKey:[NSNumber numberWithInt: kAudioFormatAppleLossless],//录音格式
                               AVNumberOfChannelsKey:[NSNumber numberWithInt: 2],//录音通道数
                               AVEncoderAudioQualityKey:[NSNumber numberWithInt: AVAudioQualityMin]};//录音质量
    NSError *error;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if(error) {
        NSLog(@"Ups, could not create recorder %@", error);
        return;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    [self.recorder prepareToRecord];
    [self.recorder setMeteringEnabled:YES];
    [self.recorder record];
    
    [self.view addSubview:self.waverView];
    
    __block AVAudioRecorder *weakRecorder = self.recorder;
    
    _waverView.waverLevelBlock = ^(CMAllMediaVoipWaverView *waver) {
        [weakRecorder updateMeters];
        //averagePowerForChannel和peakPowerForChannel方法返回的是分贝数据，数值在-160 - 0之间（可能会返回大于0的值超出了极限
        CGFloat normalizedValue = pow (10, [weakRecorder averagePowerForChannel:0] / 40);
        
        waver.level = normalizedValue;
    };
}

//声音波形
- (CMAllMediaVoipWaverView *)waverView {
    if (!_waverView) {
        _waverView = [[CMAllMediaVoipWaverView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 350)];
        _waverView.center = self.view.center;
    }
    return _waverView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
