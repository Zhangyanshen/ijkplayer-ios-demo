//
//  YSAVViewController.m
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/11.
//  Copyright © 2020 张延深. All rights reserved.
//

#import "YSAVViewController.h"
#import "YSPlayerController.h"
#import "AppDelegate.h"

@interface YSAVViewController () <YSPlayerControllerDelegate>

@property (strong, nonatomic) YSPlayerController *playerController;

@end

@implementation YSAVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.playerController = [[YSPlayerController alloc] initWithContentURL:self.fileURL];
    self.playerController.view.frame = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16.0);
    self.playerController.delegate = self;
    [self.view addSubview:self.playerController.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.playerController.player prepareToPlay];
}

#pragma mark - YSPlayerControllerDelegate

- (void)playerControllerDidClickDone:(YSPlayerController *)playerController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)playerControllerDidClickFullScreen:(YSPlayerController *)playerController {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.fullScreen = self.playerController.isFullScreen;
    [self changeOritention];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (self.playerController.isFullScreen) {
        self.playerController.view.frame = self.view.bounds;
    } else {
        self.playerController.view.frame = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16.0);
    }
}

#pragma mark - Private methods

- (void)changeOritention {
    UIInterfaceOrientation orientation = self.playerController.fullScreen ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait;
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:orientation] forKey:@"orientation"];
}

#pragma mark - dealloc

- (void)dealloc {
    [self.playerController.player shutdown];
    NSLog(@"%s", __func__);
}

@end
