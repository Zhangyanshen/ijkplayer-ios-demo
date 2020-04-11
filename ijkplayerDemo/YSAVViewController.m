//
//  YSAVViewController.m
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/11.
//  Copyright © 2020 张延深. All rights reserved.
//

#import "YSAVViewController.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
//@import IJKMediaFramework;

@interface YSAVViewController ()

@property (strong, nonatomic) id<IJKMediaPlayback> player;

@end

@implementation YSAVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    // 解决音视频不同步的问题
    [options setPlayerOptionIntValue:1 forKey:@"framedrop"];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.fileURL withOptions:options];
    self.player.view.frame = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16.0);
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    [self.view addSubview:self.player.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.player prepareToPlay];
}

#pragma mark - dealloc

- (void)dealloc {
    if (self.player) {
        [self.player shutdown];
        self.player = nil;
    }
    NSLog(@"%s", __func__);
}

@end
