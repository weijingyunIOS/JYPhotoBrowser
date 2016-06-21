//
//  ViewController.m
//  Demo
//
//  Created by weijingyun on 16/5/29.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import "ViewController.h"
#import "JYPhotoBrowserViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    JYPhotoBrowserViewController *vc = [[JYPhotoBrowserViewController alloc] init];
    vc.images = @[
                  @"http://ww2.sinaimg.cn/bmiddle/98719e4agw1e5j49zmf21j20c80c8mxi.jpg",
                  @"http://ww2.sinaimg.cn/bmiddle/642beb18gw1ep3629gfm0g206o050b2a.gif",
                  @"http://ww2.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg",
                  @"http://ww2.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr39ht9j20gy0o6q74.jpg",
                  @"http://ww3.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr3xvtlj20gy0obadv.jpg",
                  @"http://ww4.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg",
                  @"http://ww3.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg",
                  @"http://ww2.sinaimg.cn/bmiddle/677febf5gw1erma104rhyj20k03dz16y.jpg",
                  @"http://ww4.sinaimg.cn/bmiddle/677febf5gw1erma1g5xd0j20k0esa7wj.jpg"
                  ];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
