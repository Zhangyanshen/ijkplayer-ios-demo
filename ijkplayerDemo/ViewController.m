//
//  ViewController.m
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/11.
//  Copyright © 2020 张延深. All rights reserved.
//

#import "ViewController.h"
#import "YSAVViewController.h"
#import "YSLiveListViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ijkplayer";
    self.dataArray = @[
        @{@"title": @"播放本地视频", @"url": @""},
        @{@"title": @"播放远程视频", @"url": @""},
        @{@"title": @"直播", @"url": @""}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSDictionary *dic = self.dataArray[indexPath.row];
    cell.textLabel.text = dic[@"title"];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSURL *url = nil;
    switch (indexPath.row) {
        case 0:
        {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"hubblecast" ofType:@"m4v"];
            url = [NSURL fileURLWithPath:filePath];
        }
            break;
        case 1:
        {
            url = [NSURL URLWithString:@"https://output.newbanker.cn/mp4MultibitrateIn30/ed77288065a511eaa2e7d9eff256d7b2.mp4"];
        }
            break;
        case 2:
        {
            YSLiveListViewController *liveListVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"YSLiveListViewController"];
            [self.navigationController pushViewController:liveListVC animated:YES];
            return;
        }
            break;
        default:
            break;
    }
    YSAVViewController *avVC = [[YSAVViewController alloc] init];
    avVC.modalPresentationStyle = UIModalPresentationFullScreen;
    avVC.fileURL = url;
    [self presentViewController:avVC animated:YES completion:^{
        
    }];
}

@end
