//
//  JYImageScrollView.h
//  Demo
//
//  Created by weijingyun on 16/6/2.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JYImageScrollView : UIScrollView

- (void)setImage:(UIImage *)aImage;
- (void)setImageWithURL:(NSURL *)url;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

@end
