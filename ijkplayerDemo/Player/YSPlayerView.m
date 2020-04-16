//
//  YSPlayerView.m
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/13.
//  Copyright © 2020 张延深. All rights reserved.
//

#import "YSPlayerView.h"
#import "Masonry.h"

@interface YSPlayerView ()

@property (strong, nonatomic) id<YSPlayerControlProtocol> playControl;

@end

@implementation YSPlayerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

#pragma mark - Private methods

- (void)setupUI {
    self.backgroundColor = [UIColor blackColor];
    self.playControl = [[NSBundle mainBundle] loadNibNamed:@"YSPlayerControl" owner:nil options:nil][0];
    [self addSubview:(UIView *)self.playControl];
    // 添加约束
    [(UIView *)self.playControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
}

#pragma mark - dealloc

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
