//
//  JYPhotoBrowserViewController.h
//  Demo
//
//  Created by weijingyun on 16/6/22.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JYPhotoBrowserViewController : UIViewController

//imageItem的类型可能是UIImage、NSString (url), NSURL
@property (nonatomic, strong) NSArray* images;
// 当前页码
@property (nonatomic, assign) NSInteger currentIndex;

@end
