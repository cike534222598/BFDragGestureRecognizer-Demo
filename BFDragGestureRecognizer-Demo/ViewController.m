//
//  ViewController.m
//  BFDragGestureRecognizer-Demo
//
//  Created by Jame on 15/5/21.
//  Copyright (c) 2015年 SSIC. All rights reserved.
//

#import "ViewController.h"
#import "BFDragGestureRecognizer.h"

@interface ViewController () <UIScrollViewDelegate,UIBarPositioningDelegate>

@end

@implementation ViewController
{
    UIScrollView *_scrollView;
    UIView *_contentView;
    CGPoint _startCenter;
}

#pragma mark - 加载视图
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self showUI];
}

- (void)showUI
{
    CGFloat scrollViewHeight = 1000;
    CGFloat scrollViewWidth = 1000;
    CGSize scrollViewSize = CGSizeMake(scrollViewWidth, scrollViewHeight);
    
    CGRect rect = (CGRect){CGPointZero,scrollViewSize};
    CGRect labelFrame = CGRectMake(0, 0, 284, 62);

    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.contentSize = scrollViewSize;
    _scrollView.contentInset = UIEdgeInsetsMake(64, 0, 44, 0);
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = 3;
    _scrollView.delegate = self;
    UIEdgeInsets indicatorInsets = _scrollView.scrollIndicatorInsets;
    indicatorInsets.bottom = _scrollView.contentInset.bottom;
    _scrollView.scrollIndicatorInsets = indicatorInsets;
    [self.view insertSubview:_scrollView atIndex:0];
    
    
    _contentView = [[UIView alloc] initWithFrame:rect];
    [_scrollView addSubview:_contentView];
    
    NSString *text = @"长按彩色图形，开始拖拽。"
    "移动彩色图形到滚动视图任意地方。";
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.numberOfLines = 0;
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.center = CGPointMake(scrollViewWidth / 2, scrollViewHeight / 2);
    [_contentView addSubview:label];
    
    _scrollView.contentOffset = CGPointMake(label.center.x - _scrollView.bounds.size.width / 2, label.center.y - _scrollView.bounds.size.height / 2);
    
    
    int count = 100;
    for (int i = 0; i < count; i++) {
        
        // Use a fixed seed to always have the same color views.
        srandom(314159265);
        
        // Find a random position for the color view, that doesn't intersect other views.
        CGRect randomRect = CGRectZero;
        BOOL canPlace = NO;
        while (!canPlace) {
            CGPoint randomPoint = CGPointMake(100 + random() % (int)(scrollViewWidth - 200),
                                              100 + random() % (int)(scrollViewHeight - 200));
            randomRect = (CGRect){randomPoint, CGSizeMake(50, 50)};
            
            canPlace = YES;
            for (UIView *subview in _contentView.subviews) {
                if (CGRectIntersectsRect(randomRect, subview.frame)) {
                    canPlace = NO;
                    break;
                }
            }
        }
        
        UIView *view = [[UIView alloc] initWithFrame:randomRect];
        
        // Assign a random background color.
        CGFloat hue = (CGFloat)(random() % 256 / 256.0);  //  0.0 to 1.0
        CGFloat saturation = (CGFloat)((random() % 128 / 256.0) + 0.5);  //  0.5 to 1.0, away from white
        CGFloat brightness = (CGFloat)((random() % 128 / 256.0) + 0.5);  //  0.5 to 1.0, away from black
        UIColor *randomColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        view.backgroundColor = randomColor;
        [_contentView addSubview:view];
        
        // Add the drag gesture recognizer with default values.
        BFDragGestureRecognizer *holdDragRecognizer = [[BFDragGestureRecognizer alloc] init];
        [holdDragRecognizer addTarget:self action:@selector(dragRecognized:)];
        [view addGestureRecognizer:holdDragRecognizer];
    }
}

- (void)dragRecognized:(BFDragGestureRecognizer *)recognizer {
    UIView *view = recognizer.view;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // When the gesture starts, remember the current position, and animate the it.
        _startCenter = view.center;
        [view.superview bringSubviewToFront:view];
        [UIView animateWithDuration:0.2 animations:^{
            view.transform = CGAffineTransformMakeScale(1.2, 1.2);
            view.alpha = 0.7;
        }];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // During the gesture, we just add the gesture's translation to the saved original position.
        // The translation will account for the changes in contentOffset caused by auto-scrolling.
        CGPoint translation = [recognizer translationInView:_contentView];
        CGPoint center = CGPointMake(_startCenter.x + translation.x, _startCenter.y + translation.y);
        view.center = center;
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        [UIView animateWithDuration:0.2 animations:^{
            view.transform = CGAffineTransformIdentity;
            view.alpha = 1.0;
        }];
    } else if (recognizer.state == UIGestureRecognizerStateFailed) {
        
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView1 {
    return _contentView;
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark - 接收内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
