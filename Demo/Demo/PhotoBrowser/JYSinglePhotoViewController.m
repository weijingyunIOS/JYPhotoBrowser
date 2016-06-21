//
//  JYSinglePhotoViewController.m
//  Demo
//
//  Created by weijingyun on 16/6/22.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import "JYSinglePhotoViewController.h"
#import "JYImageScrollView.h"
@interface JYSinglePhotoViewController ()

@property (nonatomic, strong) JYImageScrollView* imgView;

@end

@implementation JYSinglePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self constructUI];
}

- (void)constructUI
{
    if ([self.imageItem isKindOfClass:[UIImage class]]) {
        [self.imgView setImage:self.imageItem];
        
    }else if ([self.imageItem isKindOfClass:[NSString class]]){
        [self.imgView setImageWithURL:[NSURL URLWithString:self.imageItem]];
        
    }else if ([self.imageItem isKindOfClass:[NSURL class]]){
        [self.imgView setImageWithURL:self.imageItem];
    }else{
        NSLog(@"类型不对");
    }
    self.imgView.backgroundColor = [UIColor redColor];
}

#pragma mark - 懒加载
- (JYImageScrollView *)imgView{
    
    if (!_imgView) {
        _imgView = [[JYImageScrollView alloc] initWithFrame:CGRectMake(0., 0., self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:_imgView];
    }
    return _imgView;
}

@end
