//
//  YSLiveListCell.h
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/12.
//  Copyright © 2020 张延深. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSLiveListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *areaLbl;
@property (weak, nonatomic) IBOutlet UILabel *visitCountLbl;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@end

NS_ASSUME_NONNULL_END
