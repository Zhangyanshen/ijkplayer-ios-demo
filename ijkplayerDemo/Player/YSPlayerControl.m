//
//  YSPlayerControl.m
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/13.
//  Copyright © 2020 张延深. All rights reserved.
//

#import "YSPlayerControl.h"
#import <MediaPlayer/MediaPlayer.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#define NAV_BAR_HEIGHT 50
#define TOOL_BAR_HEIGHT 50

typedef NS_ENUM(NSUInteger, YSPanDirection) {
    YSPanDirectionUnknown, // 未知
    YSPanDirectionHorizontal, // 水平
    YSPanDirectionVertical // 垂直
};

@interface YSPlayerControl () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *navBar;
@property (weak, nonatomic) IBOutlet UIView *toolBar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarBottomConstraint;

/*
 status bar
 */
@property (weak, nonatomic) IBOutlet UIView *statusBar;
@property (weak, nonatomic) IBOutlet UILabel *carrierLbl; // 运营商
@property (weak, nonatomic) IBOutlet UILabel *timeLbl; // 时间
@property (weak, nonatomic) IBOutlet UILabel *batteryStateLbl; // 电池状态
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLbl; // 电量

/*
 自定义音量和亮度view
 */
@property (weak, nonatomic) IBOutlet UIView *volumeView;
@property (weak, nonatomic) IBOutlet UIProgressView *volumeProgressView;
@property (weak, nonatomic) IBOutlet UILabel *volumeTipLbl;

/*
 视频操作相关按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *playTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLbl;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (assign, nonatomic, getter=isHideBar) BOOL hideBar;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *timeTimer; // 时间计时器

@property (assign, nonatomic) YSPanDirection direction;
@property (nonatomic, assign) BOOL isVolume;/*!*是否在调节音量*/

@property (strong, nonatomic) UISlider *volumeSlider;
@property (strong, nonatomic) CTTelephonyNetworkInfo *networkInfo;

@end

@implementation YSPlayerControl

@synthesize delegate = _delegate;
@synthesize fullScreen = _fullScreen;
@synthesize playing = _playing;
@synthesize prepareToPlay = _prepareToPlay;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.direction = YSPanDirectionUnknown;
    self.hideBar = NO;
    self.clipsToBounds = YES;
    // 开启电池监测
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    // 音量、亮度view
    self.volumeView.layer.cornerRadius = 5;
    // 添加触摸手势
    [self addTapGesture];
    // 添加滑动手势
    [self addPanGesture];
    // 开启timer
    [self resetTimer];
    // 添加通知
    [self addNotifications];
    // 获取运营商
    [self loadCarrier];
    // 获取电池状态
    [self loadBatteryState];
    // 获取电池电量
    [self loadBatteryLevel];
    // 开启获取系统时间timer
    [self startTimeTimer];
    
    MPVolumeView *mpVolumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-30, -30, 0, 0)];
//    mpVolumeView.showsRouteButton = NO; // 是否显示AirPlay按钮
//    mpVolumeView.showsVolumeSlider = NO; // 是否显示音量条，如果设置为NO，则系统的音量条会显示
    [self addSubview:mpVolumeView];
    for (UIView *view in mpVolumeView.subviews) {
        if ([view isKindOfClass:UISlider.class]) {
            self.volumeSlider = (UISlider *)view;
            break;
        }
    }
    
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (CGRectContainsPoint(self.navBar.frame, point) || CGRectContainsPoint(self.toolBar.frame, point)) {
        return NO;
    }
    return YES;
}

#pragma mark - YSPlayerControlProtocol

- (void)setPlayTime:(NSTimeInterval)playTime totalTime:(NSTimeInterval)totalTime {
    self.playTimeLbl.text = [self formatTime:playTime];
    self.totalTimeLbl.text = [self formatTime:totalTime];
    self.progressSlider.value = playTime / totalTime;
}

- (void)playbackComplete {
    self.progressSlider.value = 0.0;
    self.playTimeLbl.text = @"00:00";
}

#pragma mark - Event response

- (void)handleSingleTapGesture:(UITapGestureRecognizer *)tap {
    [self toggleBar];
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(play)]) {
        [self.delegate play];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan {
    // 根据上次和本次移动的位置，算出一个速率的point
    //这个很关键,这个速率直接决定了平移手势的快慢
    CGPoint veloctyPoint = [pan velocityInView:pan.view];
    CGPoint translation = [pan translationInView:pan.view];

    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                self.direction = YSPanDirectionHorizontal;
                // 让timer失效
                [self invalidTimer];
                // 暂停播放
                if ([self.delegate respondsToSelector:@selector(progressChangeStart)]) {
                    [self.delegate progressChangeStart];
                }
            } else if (x < y) { // 垂直移动
                // 获取当前页面手指触摸的点
                CGPoint locationPoint = [pan locationInView:pan.view];
                // 音量和亮度
                self.direction = YSPanDirectionVertical;
                // 显示volumeView
                self.volumeView.hidden = NO;
                // 判断移动的点在屏幕的哪个位置
                if (locationPoint.x <= self.frame.size.width / 2.0) {//以屏幕的1/2位分界线
                    //亮度,调节亮度
                    self.isVolume = NO;
                    // 初始化屏幕亮度
                    [self initScreenBrightness];
                } else {
                    //音量.调节音量
                    self.isVolume = YES;
                    // 初始化系统音量
                    [self initSystemVolume];
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (self.direction){//通过手势变量来判断是什么操作
                case YSPanDirectionVertical: // 垂直
                {
                    CGFloat scale = translation.y / self.bounds.size.height;
                    if (self.isVolume) {
                        [self changeVolume:scale];
                    } else {
                        [self changeBrightness:scale];
                    }
                    break;
                }
                case YSPanDirectionHorizontal: // 水平
                {
                    CGFloat scale = translation.x / self.bounds.size.width;
                    self.progressSlider.value += scale;
                    if (self.progressSlider.value > 1.0) {
                        self.progressSlider.value = 1.0;
                    }
                    if (self.progressSlider.value < 0.0) {
                        self.progressSlider.value = 0.0;
                    }
                    if ([self.delegate respondsToSelector:@selector(didChangeProgress:)]) {
                        [self.delegate didChangeProgress:self.progressSlider.value];
                    }
                    break;
                }
                default:
                {
                    
                }
                    break;
            }
            break;

        }
        case UIGestureRecognizerStateEnded: { // 移动停止
            switch (self.direction) {
                case YSPanDirectionVertical: // 垂直
                {
                    self.isVolume = NO;
                    // 隐藏volumeView
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:0.5 animations:^{
                            self.volumeView.alpha = 0.0;
                        } completion:^(BOOL finished) {
                            self.volumeView.hidden = YES;
                            self.volumeView.alpha = 1.0;
                        }];
//                    });
                    break;
                }
                case YSPanDirectionHorizontal: //水平
                {
                    // 重新开启timer
                    [self resetTimer];
                    // 开始播放
                    if ([self.delegate respondsToSelector:@selector(progressChangeEnd)]) {
                        [self.delegate progressChangeEnd];
                    }
                    break;
                }
                default:
                {
                    
                }
                    break;
            }
        }
        default:
        {
            
        }
            break;
    }
    // 清空位移数据，避免拖拽事件的位移叠加
    [pan setTranslation:CGPointZero inView:pan.view];
}

- (IBAction)doneBtnClick:(UIButton *)sender {
    [self resetTimer];
    if ([self.delegate respondsToSelector:@selector(done)]) {
        [self.delegate done];
    }
}

- (IBAction)playSpeedChanged:(UIButton *)sender {
    [self resetTimer];
    static CGFloat rate = 1.0;
    if ([self.delegate respondsToSelector:@selector(setPlaybackRate:)]) {
        rate += 0.5;
        if (rate > 2.0) {
            rate = 0.5;
        }
        [sender setTitle:[NSString stringWithFormat:@"%.1lfx", rate] forState:UIControlStateNormal];
        [self.delegate setPlaybackRate:rate];
    }
}

- (IBAction)playOrPause:(UIButton *)sender {
    [self resetTimer];
    if ([self.delegate respondsToSelector:@selector(play)]) {
        [self.delegate play];
    }
}

- (IBAction)fullScreen:(UIButton *)sender {
    [self resetTimer];
    if ([self.delegate respondsToSelector:@selector(fullScreen)]) {
        [self.delegate fullScreen];
    }
}

- (IBAction)progressStartChange:(UISlider *)sender {
    [self invalidTimer];
    if ([self.delegate respondsToSelector:@selector(progressChangeStart)]) {
        [self.delegate progressChangeStart];
    }
}

- (IBAction)progressChanged:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(didChangeProgress:)]) {
        [self.delegate didChangeProgress:sender.value];
    }
}

- (IBAction)progressEndChange:(UISlider *)sender {
    [self resetTimer];
    if ([self.delegate respondsToSelector:@selector(progressChangeEnd)]) {
        [self.delegate progressChangeEnd];
    }
}

- (void)handleBatteryStateDidChangeNotification:(NSNotification *)notification {
    [self loadBatteryState];
}

- (void)handleBatteryLevelDidChangeNotification:(NSNotification *)notification {
    [self loadBatteryLevel];
}

#pragma mark - Setters/Getters

- (CTTelephonyNetworkInfo *)networkInfo {
    if (!_networkInfo) {
        _networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    }
    return _networkInfo;
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    NSString *img = playing ? @"player-pause" : @"player-start";
    [self.playBtn setImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
}

- (void)setFullScreen:(BOOL)fullScreen {
    _fullScreen = fullScreen;
    NSString *img = fullScreen ? @"player-small-screen" : @"player-full-screen";
    [self.fullScreenBtn setImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
    self.statusBar.hidden = fullScreen ? NO : YES;
}

- (void)setPrepareToPlay:(BOOL)prepareToPlay {
    _prepareToPlay = prepareToPlay;
    if (prepareToPlay) {
        [self.activityIndicatorView stopAnimating];
    } else {
        [self.activityIndicatorView startAnimating];
    }
}

#pragma mark - Private methods

// 添加通知
- (void)addNotifications {
    // 电池状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBatteryStateDidChangeNotification:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    // 电池电量
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBatteryLevelDidChangeNotification:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
}

// 移除通知
- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addTapGesture {
    // 单击手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    singleTap.delegate = self;
    [self addGestureRecognizer:singleTap];
    // 双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    // 解决双击手势和单击手势冲突
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)addPanGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
}

// 加载运营商信息
- (void)loadCarrier {
    NSDictionary *carrierDic = [self.networkInfo serviceSubscriberCellularProviders];
    [self updateCarrierInfo:carrierDic[self.networkInfo.dataServiceIdentifier]];
    __weak typeof(self) weakSelf = self;
    // 监听运营商变化
    self.networkInfo.serviceSubscriberCellularProvidersDidUpdateNotifier = ^(NSString * _Nonnull dataServiceIdentifier) {
        CTCarrier *carrier = carrierDic[dataServiceIdentifier];
        [weakSelf updateCarrierInfo:carrier];
    };
}

// 更新运营商信息
- (void)updateCarrierInfo:(CTCarrier *)carrier {
    NSString *carrierName;
    if (!carrier.isoCountryCode) {
        carrierName = @"无SIM卡";
    } else {
        carrierName = carrier.carrierName;
    }
    self.carrierLbl.text = carrierName;
}

// 初始化电量
- (void)loadBatteryLevel {
    float batteryLevel = [UIDevice currentDevice].batteryLevel;
    if (batteryLevel < 0.0) {
        self.batteryLevelLbl.text = @"0%";
    } else {
        self.batteryLevelLbl.text = [NSString stringWithFormat:@"%.0f%%", batteryLevel * 100];
    }
}

// 初始化电池状态
- (void)loadBatteryState {
    UIDeviceBatteryState batteryState = [UIDevice currentDevice].batteryState;
    switch (batteryState) {
        case UIDeviceBatteryStateCharging: // 正在充电(<100%)
        {
            self.batteryStateLbl.text = @"充电中";
        }
            break;
        case UIDeviceBatteryStateFull: // 正在充电(100%)
        {
            self.batteryStateLbl.text = @"已充满";
        }
            break;
        case UIDeviceBatteryStateUnplugged:
        {
            self.batteryStateLbl.text = @"未充电";
        }
            break;
        case UIDeviceBatteryStateUnknown:
        {
            self.batteryStateLbl.text = @"未知";
        }
            break;
        default:
            break;
    }
}

// 初始化屏幕亮度
- (void)initScreenBrightness {
    self.volumeTipLbl.text = @"亮度";
    self.volumeProgressView.progress = [UIScreen mainScreen].brightness;
}

// 初始化系统音量
- (void)initSystemVolume {
    self.volumeTipLbl.text = @"音量";
    self.volumeProgressView.progress = self.volumeSlider.value;
}

// 改变屏幕亮度
- (void)changeBrightness:(CGFloat)deltaY {
    CGFloat brightness = [UIScreen mainScreen].brightness;
    brightness -= deltaY;
    if (brightness > 1.0) {
        brightness = 1.0;
    }
    if (brightness < 0.0) {
        brightness = 0.0;
    }
    [UIScreen mainScreen].brightness = brightness;
    self.volumeProgressView.progress = brightness;
}

// 改变系统音量
- (void)changeVolume:(CGFloat)deltaY {
//    MPMusicPlayerController *playerController = [MPMusicPlayerController applicationMusicPlayer];
//    float volume = playerController.volume;
    float volume = self.volumeSlider.value;
    volume -= deltaY;
    if (volume > 1.0) {
        volume = 1.0;
    }
    if (volume < 0.0) {
        volume = 0.0;
    }
//    playerController.volume = volume;
    self.volumeSlider.value = volume;
    self.volumeProgressView.progress = volume;
}

// 隐藏或显示toolBar和navBar
- (void)toggleBar {
    self.hideBar = !self.isHideBar;
    self.navBarTopConstraint.constant = self.hideBar ? -NAV_BAR_HEIGHT : 0;
    self.toolBarBottomConstraint.constant = self.hideBar ? -TOOL_BAR_HEIGHT : 0;
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    if (self.isHideBar) {
        [self invalidTimer];
    } else {
        [self resetTimer];
    }
}

// 格式化时间
- (NSString *)formatTime:(NSInteger)time {
    NSInteger minutes = time / 60;
    NSInteger seconds = time % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds];
}

// 重置timer
- (void)resetTimer {
    [self invalidTimer];
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer timerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [weakSelf toggleBar];
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

// 让timer失效
- (void)invalidTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)startTimeTimer {
    __weak typeof(self) weakSelf = self;
    self.timeTimer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm";
        weakSelf.timeLbl.text = [formatter stringFromDate:date];
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.timeTimer forMode:NSRunLoopCommonModes];
}

- (void)invalidTimeTimer {
    if (self.timeTimer) {
        [self.timeTimer invalidate];
        self.timeTimer = nil;
    }
}

#pragma mark - dealloc

- (void)dealloc {
    [self removeNotifications];
    [self invalidTimer];
    [self invalidTimeTimer];
}

@end
