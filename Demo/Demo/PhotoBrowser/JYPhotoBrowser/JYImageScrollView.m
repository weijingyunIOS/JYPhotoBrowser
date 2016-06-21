//
//  JYImageScrollView.m
//  Demo
//
//  Created by weijingyun on 16/6/2.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import "JYImageScrollView.h"
#import "JYIndicatorView.h"
#import <YYWebImage/YYWebImage.h>

#define kAPPSize [UIScreen mainScreen].bounds.size

@interface JYImageScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *zoomView;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) CGPoint pointToCenterAfterResize;
@property (nonatomic, assign) CGFloat scaleToRestoreAfterResize;

// 关于指示器
@property (nonatomic, strong) JYIndicatorView *indicatorView;

@end

@implementation JYImageScrollView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    if (sizeChanging) {
        [self prepareToResize];
    }
    
    [super setFrame:frame];
    
    if (sizeChanging) {
        [self recoverFromResizing];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.zoomView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.zoomView.frame = frameToCenter;
}

#pragma mark - 显示图片
- (void)setImageWithURL:(NSURL *)url{
    UIImage *image = [UIImage imageNamed:@"JYImageScrollView_placeholder"];
    [self setImageWithURL:url placeholderImage:image];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder{
    
    __weak typeof(self)weakSelf = self;
    [self.zoomView yy_setImageWithURL:url placeholder:placeholder options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
        weakSelf.indicatorView.progress = receivedSize / (expectedSize * 1.0f);
        
    } transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        
        if (stage != YYWebImageStageFinished) { // 未完成
            return;
        }
        [weakSelf.indicatorView removeFromSuperview];
        weakSelf.indicatorView = nil;
        
        if (!error) {
            
        }
        
    }];
}

- (void)setImage:(UIImage *)aImage{
    [self displayImage:aImage];
}

- (void)displayImage:(UIImage *)image{
    
    // clear the previous image
    [self.zoomView removeFromSuperview];
    self.zoomView = nil;
    
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
    // make a new UIImageView for the new image
    self.zoomView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:self.zoomView];
    [self configureForImageSize:image.size];
}

#pragma mark - 缩放 大小计算设置
- (void)configureForImageSize:(CGSize)imageSize
{
    self.imageSize = imageSize;
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    
    CGSize boundsSize = self.bounds.size;
    
    // 计算 min/max zoomscale
    CGFloat xScale = boundsSize.width  / self.imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / self.imageSize.height;   // the scale needed to perfectly fit the image height-wise
    
    // 填补宽高
    BOOL imagePortrait = self.imageSize.height > self.imageSize.width;
    BOOL phonePortrait = boundsSize.height > boundsSize.width;
    CGFloat minScale = imagePortrait == phonePortrait ? xScale : MIN(xScale, yScale);
    
    // maximum zoom scale to 0.5. 考虑高分辨率屏幕
    CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
    
    // 不要让minScale超过maxScale。(如果图像比屏幕小,我们不想放大。)
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale * 0.99;
}

#pragma mark - frame改变后的调整 如 旋转
- (void)prepareToResize {
    
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.pointToCenterAfterResize = [self convertPoint:boundsCenter toView:self.zoomView];
    
    self.scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (self.scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON){
        self.scaleToRestoreAfterResize = 0;
    }
}

- (void)recoverFromResizing {
    
    [self setMaxMinZoomScalesForCurrentBounds];
    
    //第一步:恢复缩放尺度,首先确保在允许的范围内。
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, self.scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
    
    //第二步:恢复中心点,首先确保在允许的范围内。
    
    // 2a: 把我们所需的中心指向自己的坐标空间
    CGPoint boundsCenter = [self convertPoint:self.pointToCenterAfterResize fromView:self.zoomView];
    
    // 2b: 计算内容中心点的偏移量
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: 恢复抵消,在允许的范围内调整
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset {
    
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset {
    
    return CGPointZero;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return self.zoomView;
}

#pragma mark - 懒加载
- (JYIndicatorView *)indicatorView{
    if (!_indicatorView) {
    
        _indicatorView = [[JYIndicatorView alloc] init];
        _indicatorView.style = JYIndicatorStyleLoopDiagram;
        _indicatorView.center = CGPointMake(kAPPSize.width * 0.5, kAPPSize.height * 0.5);
        [self addSubview:_indicatorView];
    }
    return _indicatorView;
}

@end
