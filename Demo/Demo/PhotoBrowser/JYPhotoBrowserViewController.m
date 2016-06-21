//
//  JYPhotoBrowserViewController.m
//  Demo
//
//  Created by weijingyun on 16/6/22.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import "JYPhotoBrowserViewController.h"
#import "JYSinglePhotoViewController.h"

@interface JYPhotoBrowserViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController *pageViewController;

@end

@implementation JYPhotoBrowserViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    CGRect rect = [UIScreen mainScreen].bounds;
    self.pageViewController.view.frame = CGRectMake(0, 0, rect.size.width + 20, rect.size.height);
    JYSinglePhotoViewController *initialViewController = [self viewControllerAtIndex:self.currentIndex];
    NSArray *viewControllers = nil;
    if (initialViewController) {
        viewControllers = [NSArray arrayWithObject:initialViewController];
    } else {
        viewControllers = [NSArray array];
    }
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
}

#pragma mark - 控制器创建
- (NSUInteger)getCount{
    
    return self.images.count;
}

- (id)contentAtIndex:(NSUInteger) index{
    
    return self.images[index];
}

- (NSUInteger)indexOfObject:(id) obj{
    
    return [self.images indexOfObject:obj];
}

- (JYSinglePhotoViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([self getCount] == 0) || (index >= [self getCount])) {
        return nil;
    }
    JYSinglePhotoViewController *dataViewController = [[JYSinglePhotoViewController alloc] init];
    dataViewController.imageItem = [self contentAtIndex: index];
    dataViewController.view.backgroundColor = [UIColor clearColor] ;
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(JYSinglePhotoViewController *)viewController {
    return [self indexOfObject:viewController.imageItem];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:(JYSinglePhotoViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    UIViewController * vc = [self viewControllerAtIndex:index];
    vc.view.backgroundColor = [UIColor clearColor];
    return vc;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:(JYSinglePhotoViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == [self getCount]) {
        return nil;
    }
    UIViewController *vc = [self viewControllerAtIndex:index];
    vc.view.backgroundColor = [UIColor clearColor] ;
    return vc ;
}

#pragma mark -UIPageViewControllerDelegate
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        self.currentIndex = [self indexOfViewController:(JYSinglePhotoViewController *)[self.pageViewController.viewControllers objectAtIndex:0]];
//        self.pageLabel.text = [NSString stringWithFormat:@"%@ / %@", @(self.currentIndex + 1), @([self getCount])];
    }
}

#pragma mark - 懒加载
- (UIPageViewController *)pageViewController{
    if (!_pageViewController) {
        
        NSDictionary *options =[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin] forKey: UIPageViewControllerOptionSpineLocationKey];
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options: options];
        _pageViewController.dataSource = self;
        _pageViewController.delegate = self;
        [self addChildViewController:_pageViewController];
        [self.view addSubview:[_pageViewController view]];
    }
    return _pageViewController;
}

@end
