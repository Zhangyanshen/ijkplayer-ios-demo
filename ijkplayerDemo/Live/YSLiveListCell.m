//
//  YSLiveListCell.m
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/12.
//  Copyright © 2020 张延深. All rights reserved.
//

#import "YSLiveListCell.h"

@implementation YSLiveListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatorImageView.layer.cornerRadius = 30;
}

@end
