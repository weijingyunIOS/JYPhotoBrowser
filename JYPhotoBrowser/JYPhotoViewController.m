//
//  JYPhotoViewController.m
//  Demo
//
//  Created by weijingyun on 16/6/3.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import "JYPhotoViewController.h"
#import "JYImageScrollView.h"

@interface JYPhotoViewController()

@property (nonatomic, strong) JYImageScrollView *scrollView;

@end

@implementation JYPhotoViewController

- (void)loadView{
    
    self.scrollView = [[JYImageScrollView alloc] init];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = self.scrollView ;
}

@end
