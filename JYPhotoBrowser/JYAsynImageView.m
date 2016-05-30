//
//  JYAsynImageView.m
//  JYImageView
//
//  Created by weijingyun on 16/4/29.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import "JYAsynImageView.h"
#import "YYAsyncLayer.h"
@interface JYAsynImageView()

@property (nonatomic, assign) BOOL fuzzy;

@end

@implementation JYAsynImageView

- (void)setImage:(UIImage *)image{
    _image = image;
    [self redraw];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self transaction];
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self transaction];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    [self transaction];
}

- (void)transaction{
    if (self.fuzzy) {
        return;
    }
    [self redraw];
}

- (void)redraw{
    self.fuzzy = NO;
    [[YYTransaction transactionWithTarget:self selector:@selector(contentsNeedUpdated)] commit];
}

- (void)contentsNeedUpdated {
    // do update
    [self layoutIfNeeded];
    [self.layer setNeedsDisplay];
}

#pragma mark - YYAsyncLayer
+ (Class)layerClass {
    return YYAsyncLayer.class;
}

- (YYAsyncLayerDisplayTask *)newAsyncDisplayTask {
    // capture current state to display task
    UIImage *image = self.image;
    YYAsyncLayerDisplayTask *task = [YYAsyncLayerDisplayTask new];
    task.willDisplay = ^(CALayer *layer) {
        CGFloat scale = [self scaleForImageSize:image.size frameSize:layer.bounds.size];
        if (scale > 1.0) {
            layer.contentsScale = self.fuzzy ? scale : 0.5;
        }else{
            self.fuzzy = YES;
        }
        layer.backgroundColor = self.backgroundColor.CGColor;
    };
    
    task.display = ^(CGContextRef context, CGSize size, BOOL(^isCancelled)(void)) {
        if (isCancelled()) return;
        CGContextTranslateCTM(context, 0, size.height);
        if (isCancelled()) return;
        CGContextScaleCTM(context, 1.0, -1.0);
        if (isCancelled()) return;
        CGRect rect = [self frameForImageSize:image.size frameSize:size];
        if (isCancelled()) return;
        CGContextDrawImage(context, rect, image.CGImage);
        if (isCancelled()) return;
    };
    
    task.didDisplay = ^(CALayer *layer, BOOL finished) {
        if (finished) {
            // finished
            if (!self.fuzzy) {
                self.fuzzy = YES;
                [[YYTransaction transactionWithTarget:self selector:@selector(contentsNeedUpdated)] commit];
            }
            if (layer.contentsScale > 1) {
                self.fuzzy = YES;
            }
        } else {
            // cancelled
            self.fuzzy = NO;
            NSLog(@"cancelled");
        }
    };
    
    return task;
}

- (CGFloat)scaleForImageSize:(CGSize)imageSize frameSize:(CGSize)frameSize{
    CGFloat height = imageSize.height / imageSize.width * frameSize.width;
    if (height <= frameSize.height) {
        CGFloat scale = imageSize.width / frameSize.width;
        if (scale > [self maxScale]) {
            scale = [self maxScale];
        }
        return scale;
    }
    
    CGFloat width = imageSize.width / imageSize.height * frameSize.height;
    if (width <= frameSize.width) {
         CGFloat scale = imageSize.height / frameSize.height;
        if (scale > [self maxScale]) {
            scale = [self maxScale];
        }
        return scale;
    }
    
    return 1.0;
}

- (CGFloat)maxScale{
    return 10;
}

- (CGRect)frameForImageSize:(CGSize)imageSize frameSize:(CGSize)frameSize{
    CGFloat height = imageSize.height / imageSize.width * frameSize.width;
    if (height <= frameSize.height) {
        CGRect frame = CGRectMake(0, (frameSize.height - height) * 0.5, frameSize.width, height);
        return frame;
    }
    
    CGFloat width = imageSize.width / imageSize.height * frameSize.height;
    if (width <= frameSize.width) {
        CGRect frame = CGRectMake((frameSize.width - width) * 0.5,0, width, frameSize.height);
        return frame;
    }
    return CGRectMake(0, 0, imageSize.width,imageSize.height);
}

@end
