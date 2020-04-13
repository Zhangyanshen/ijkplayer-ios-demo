//
//  YSPlayerController.h
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/13.
//  Copyright © 2020 张延深. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSPlayerControlDelegate.h"

@import IJKMediaFramework;

@class YSPlayerController;

NS_ASSUME_NONNULL_BEGIN

@protocol YSPlayerControllerDelegate <NSObject>

@optional
- (void)playerControllerDidClickDone:(YSPlayerController *)playerController;
- (void)playerControllerDidClickFullScreen:(YSPlayerController *)playerController;

@end

@interface YSPlayerController : NSObject

- (instancetype)initWithContentURL:(NSURL *)contentURL;

@property (weak, nonatomic) id<YSPlayerControllerDelegate> delegate;
@property (strong, nonatomic, readonly) UIView *view;
@property (strong, nonatomic, readonly) id<IJKMediaPlayback> player;
@property (assign, nonatomic, readonly, getter=isFullScreen) BOOL fullScreen;

@end

NS_ASSUME_NONNULL_END
