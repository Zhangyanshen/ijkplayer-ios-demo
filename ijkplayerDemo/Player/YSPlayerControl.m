//
//  YSPlayerControl.m
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/13.
//  Copyright © 2020 张延深. All rights reserved.
//

#import "YSPlayerControl.h"

#define NAV_BAR_HEIGHT 50
#define TOOL_BAR_HEIGHT 50

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

@end

@implementation YSPlayerControl

@synthesize delegate = _delegate;
@synthesize fullScreen = _fullScreen;
@synthesize playing = _playing;
@synthesize prepareToPlay = _prepareToPlay;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.hideBar = NO;
    self.clipsToBounds = YES;
    // 添加触摸手势
    [self addTapGesture];
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

- (void)handleTapGesture:(UITapGestureRecognizer *)tap {
    [self toggleBar];
}

- (IBAction)doneBtnClick:(UIButton *)sender {
    [self resetTimer];
    if ([self.delegate respondsToSelector:@selector(done)]) {
        [self.delegate done];
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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

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

- (NSString *)formatTime:(NSInteger)time {
    NSInteger minutes = time / 60;
    NSInteger seconds = time % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds];
}

- (void)resetTimer {
    [self invalidTimer];
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer timerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [weakSelf toggleBar];
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)invalidTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
