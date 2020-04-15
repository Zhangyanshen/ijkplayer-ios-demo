//
//  YSPlayerControlProtocol.h
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/13.
//  Copyright © 2020 张延深. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSPlayerControlDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol YSPlayerControlProtocol <NSObject>

/**
 代理
 */
@property (weak, nonatomic) id<YSPlayerControlDelegate> delegate;

/**
 是否正在播放
 */
@property (assign, nonatomic, getter=isPlaying) BOOL playing;

/**
 是否全屏
 */
@property (assign, nonatomic, getter=isFullScreen) BOOL fullScreen;

/**
 是否准备好播放
 */
@property (assign, nonatomic, getter=isPrepareToPlay) BOOL prepareToPlay;

/**
 设置播放时间和总时间
 */
- (void)setPlayTime:(NSTimeInterval)playTime totalTime:(NSTimeInterval)totalTime;

/**
 播放完成
 */
- (void)playbackComplete;

@end

NS_ASSUME_NONNULL_END
