//
//  YSPlayerControl.m
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/13.
//  Copyright © 2020 张延深. All rights reserved.
//

#import "YSPlayerControl.h"
#import <MediaPlayer/MediaPlayer.h>

#define NAV_BAR_HEIGHT 50
#define TOOL_BAR_HEIGHT 50

typedef NS_ENUM(NSUInteger, YSPanDirection) {
    YSPanDirectionUnknow = 0,
    YSPanDirectionHorizontal,
    YSPanDirectionVertical
};

typedef NS_ENUM(NSUInteger, YSPlaybackRate) {
    YSPlaybackRateHalf = 0,
    YSPlaybackRateNormal,
    YSPlaybackRateOneAndHalf,
    YSPlaybackRateTwo
};

@interface YSPlayerControl () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *navBar;
@property (weak, nonatomic) IBOutlet UIView *toolBar;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *playTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLbl;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarBottomConstraint;

@property (assign, nonatomic, getter=isHideBar) BOOL hideBar;
@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) YSPanDirection direction;
@property (assign, nonatomic) YSPlaybackRate playbackRate;

@end

@implementation YSPlayerControl

@synthesize delegate = _delegate;
@synthesize fullScreen = _fullScreen;
@synthesize playing = _playing;
@synthesize prepareToPlay = _prepareToPlay;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.playbackRate = YSPlaybackRateNormal;
    self.hideBar = NO;
    self.clipsToBounds = YES;
    // 添加触摸手势
    [self addTapGesture];
    // 添加滑动手势
    [self addPanGesture];
    // 开启timer
    [self resetTimer];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (CGRectContainsPoint(self.navBar.frame, point) || CGRectContainsPoint(self.toolBar.frame, point)) {
        return NO;
    }
    return YES;
}

#pragma mark - Event response

- (void)handleSingleTapGesture:(UITapGestureRecognizer *)tap {
    [self toggleBar];
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)tap {
    [self resetTimer];
    if ([self.delegate respondsToSelector:@selector(play)]) {
        [self.delegate play];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan {
    
    CGFloat startX = [pan locationInView:pan.view].x;
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.direction = YSPanDirectionUnknow;
            NSLog(@"深哥：start：%@", NSStringFromCGPoint([pan locationInView:pan.view]));
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            NSLog(@"深哥：changed：%@", NSStringFromCGPoint([pan locationInView:pan.view]));
            CGPoint translation = [pan translationInView:pan.view];
            CGFloat absX = fabs(translation.x);
            CGFloat absY = fabs(translation.y);
            if (MAX(absX, absY) < 10) {
                return;
            }
            if (absX > absY) { // 水平
                self.direction = YSPanDirectionHorizontal;
                CGFloat deltaX = [pan velocityInView:pan.view].x;
                BOOL forward = YES;
                if (translation.x < 0) { // 后退
                    forward = NO;
                }
                if ([self.delegate respondsToSelector:@selector(seekToProgress:forward:)]) {
                    [self.delegate seekToProgress:fabs(deltaX / self.bounds.size.width / 100.0) forward:forward];
                }
            } else if (absY > absX) { // 垂直
                self.direction = YSPanDirectionVertical;
                CGPoint velocity = [pan velocityInView:pan.view];
                if (startX <= self.bounds.size.width * 0.5) {
                    [self changeBrightness:velocity.y];
                } else {
                    [self changeVolume:velocity.y];
                }
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"深哥：end：%@", NSStringFromCGPoint([pan locationInView:pan.view]));
        }
            break;
        default:
            break;
    }
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

#pragma mark - Setters/Getters

- (void)setPlayTime:(NSTimeInterval)playTime totalTime:(NSTimeInterval)totalTime {
    self.playTimeLbl.text = [self formatTime:playTime];
    self.totalTimeLbl.text = [self formatTime:totalTime];
    self.progressSlider.value = playTime / totalTime;
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

// 改变屏幕亮度
- (void)changeBrightness:(CGFloat)deltaY {
    CGFloat brightness = [UIScreen mainScreen].brightness;
    brightness -= deltaY / 10000.0;
    if (brightness > 1.0) {
        brightness = 1.0;
    }
    if (brightness < 0.0) {
        brightness = 0.0;
    }
    [UIScreen mainScreen].brightness = brightness;
}

// 改变系统音量
- (void)changeVolume:(CGFloat)deltaY {
    MPMusicPlayerController *playerController = [MPMusicPlayerController applicationMusicPlayer];
    float volume = playerController.volume;
    volume -= deltaY / 10000.0;
    if (volume > 1.0) {
        volume = 1.0;
    }
    if (volume < 0.0) {
        volume = 0.0;
    }
    playerController.volume = volume;
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

@end
