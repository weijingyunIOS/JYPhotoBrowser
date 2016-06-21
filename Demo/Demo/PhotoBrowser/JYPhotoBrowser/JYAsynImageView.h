//
//  JYAsynImageView.h
//  JYImageView
//
//  Created by weijingyun on 16/4/29.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JYAsynImageView : UIView

@property (nonatomic, strong) UIImage *image;
- (void)redraw;

@end
