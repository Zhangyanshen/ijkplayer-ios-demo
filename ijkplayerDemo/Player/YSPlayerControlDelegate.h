//
//  YSPlayerControlProtocol.h
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/13.
//  Copyright © 2020 张延深. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YSPlayerControlDelegate <NSObject>

/**
 done按钮点击
 */
- (void)done;

/**
 倍速播放
 */
- (void)setPlaybackRate:(CGFloat)playbackRate;

/**
 播放按钮点击
 */
- (void)play;

/**
 开始滑动
 */
- (void)progressChangeStart;

/**
 滑动中
 */
- (void)didChangeProgress:(CGFloat)progress;

/**
 滑动结束
 */
- (void)progressChangeEnd;

/**
 全屏按钮点击
 */
- (void)fullScreen;

@end

NS_ASSUME_NONNULL_END
