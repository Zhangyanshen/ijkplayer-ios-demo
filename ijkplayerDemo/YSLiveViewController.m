//
//  YSLiveViewController.m
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/12.
//  Copyright © 2020 张延深. All rights reserved.
//

#import "YSLiveViewController.h"
#import "UIImageView+WebCache.h"

@import IJKMediaFramework;

@interface YSLiveViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) id<IJKMediaPlayback> player;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@end

@implementation YSLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.activityIndicatorView startAnimating];
    [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:self.coverUrlStr] placeholderImage:nil];
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    // 解决音视频不同步的问题
    [options setPlayerOptionIntValue:1 forKey:@"framedrop"];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURLString:self.liveUrlStr withOptions:options];
    self.player.view.frame = self.view.bounds;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    [self.view insertSubview:self.player.view belowSubview:self.closeBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self addNotifications];
    [self.player prepareToPlay];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self removeNotifications];
    [self.player shutdown];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.player.view.frame = self.view.bounds;
}

#pragma mark - Event response

- (IBAction)close:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleLoadStateDidChangeNotification:(NSNotification *)notification {
    IJKMPMovieLoadState loadState = self.player.loadState;
    if (loadState == IJKMPMovieLoadStatePlaythroughOK) {
        self.bgImageView.hidden = YES;
        [self.activityIndicatorView stopAnimating];
    }
}

#pragma mark - Private methods

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadStateDidChangeNotification:) name:IJKMPMoviePlayerLoadStateDidChangeNotification object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - dealloc

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
