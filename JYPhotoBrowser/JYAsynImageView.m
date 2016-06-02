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
    if (self.image == nil) {
        return;
    }
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
    __block CGRect rect = CGRectZero;
    __weak typeof(self) weakSelf = self;
    task.willDisplay = ^(CALayer *layer) {
        
        rect = [weakSelf frameForImageSize:image.size frameSize:weakSelf.frame.size];
        layer.bounds = rect;
        layer.position = weakSelf.center;
        CGFloat scale = [weakSelf scaleForImageSize:image.size frameSize:layer.frame.size];
        if (scale > 1.0) {
            layer.contentsScale = weakSelf.fuzzy ? scale : 0.2;
        }else{
            weakSelf.fuzzy = YES;
        }
        layer.backgroundColor = weakSelf.backgroundColor.CGColor;
    };
    
    task.display = ^(CGContextRef context, CGSize size, BOOL(^isCancelled)(void)) {
        if (isCancelled()) return;
        CGContextTranslateCTM(context, 0, size.height);
        if (isCancelled()) return;
        CGContextScaleCTM(context, 1.0, -1.0);
        if (isCancelled()) return;
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), image.CGImage);
        if (isCancelled()) return;
    };
    
    task.didDisplay = ^(CALayer *layer, BOOL finished) {

        if (finished) {
            // finished
            if (!weakSelf.fuzzy) {
                weakSelf.fuzzy = YES;
                [[YYTransaction transactionWithTarget:weakSelf selector:@selector(contentsNeedUpdated)] commit];
            }
            if (layer.contentsScale > 1) {
                weakSelf.fuzzy = YES;
            }
        } else {
            // cancelled
            weakSelf.fuzzy = NO;
            NSLog(@"cancelled display");
        }
    };
    
    return task;
}

- (CGFloat)scaleForImageSize:(CGSize)imageSize frameSize:(CGSize)frameSize{
    
    CGFloat height = imageSize.height / imageSize.width * frameSize.width;
    if (height <= frameSize.height) {
        
        CGFloat scale = imageSize.width / frameSize.width;
        CGFloat kscale = [self limitLenght] / frameSize.width / frameSize.height / scale / scale;
        if (kscale < 1.0) {
            scale = scale * kscale;
        }
        return scale;
    }
    
    CGFloat width = imageSize.width / imageSize.height * frameSize.height;
    if (width <= frameSize.width) {
         CGFloat scale = imageSize.height / frameSize.height;
        CGFloat kscale = [self limitLenght] / frameSize.width / frameSize.height / scale / scale;
        if (kscale < 1.0) {
            scale = scale * kscale;
        }
        return scale;
    }

    return 1.0;
}

- (double)limitLenght{
    return 2048 * 2048 * 1.5;
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
