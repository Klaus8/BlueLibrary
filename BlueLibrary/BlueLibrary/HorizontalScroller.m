//
//  HorizontalScroller.m
//  BlueLibrary
//
//  Created by Admin on 30.01.14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import "HorizontalScroller.h"

#define VIEW_PADDING 10
#define VIEW_DIMENSIONS 100
#define VIEWS_OFFSET 100

@interface HorizontalScroller () <UIScrollViewDelegate>

@end


@implementation HorizontalScroller
{
    UIScrollView *scroller;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        scroller = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scroller.delegate = self;
        [self addSubview:scroller];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                       action:@selector(scrollerTapped:)];
        [scroller addGestureRecognizer:tapRecognizer];
    }
    return self;
}

-(void)scrollerTapped:(UITapGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:gesture.view];
    
    for (int index = 0; index < [self.delegate numberOfViewsForHorizontalScroller:self]; index ++) {
        UIView *view = scroller.subviews[index];
        if (CGRectContainsPoint(view.frame, location)) {
            [self.delegate horizontalScroller:self clickedViewAtIndex:index];
            CGPoint offset = CGPointMake(view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, 0);
//            NSLog(@"%f   %f    %f     = %f", view.frame.origin.x, self.frame.size.width/2,  view.frame.size.width/2, offset.x);
            [scroller setContentOffset:offset animated:YES];
            break;
        }
    }
}

-(void)didMoveToSuperview
{
    [self reload];
}

-(void)reload
{
    if (self.delegate == nil) return;
    
    [scroller.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    CGFloat xValue = VIEWS_OFFSET;
    for (int i = 0; i < [self.delegate numberOfViewsForHorizontalScroller:self]; i++) {
        xValue += VIEW_PADDING;
        UIView *view = [self.delegate horizontalScroller:self viewAtIndex:i];
        view.frame = CGRectMake(xValue, VIEW_PADDING, VIEW_DIMENSIONS, VIEW_DIMENSIONS);
        [scroller addSubview:view];
        xValue += VIEW_DIMENSIONS + VIEW_PADDING;
    }
    
    scroller.contentSize = CGSizeMake(xValue + VIEWS_OFFSET, VIEW_PADDING);

    if ([self.delegate respondsToSelector:@selector(initialViewIndexForHorizontalScroller:)]) {
        int initialView = [self.delegate initialViewIndexForHorizontalScroller:self];
        CGPoint offset = CGPointMake(initialView * (VIEW_DIMENSIONS + (2 * VIEW_PADDING)), 0);
        [scroller setContentOffset:offset animated:YES];
    }
}


//расстояние текущего представления от центра, на основании текущего смещения прокрутки
-(void)centerCurrentView
{
    int xFinal = scroller.contentOffset.x + (VIEWS_OFFSET / 2) + VIEW_PADDING;
    int viewIndex = xFinal / (VIEW_DIMENSIONS + (2 * VIEW_PADDING));
//    NSLog(@"contentOffset = %f", scroller.contentOffset.x);
//    NSLog(@"xFinal = %d,    viewIndex = %d", xFinal, viewIndex);
    
    xFinal = viewIndex * (VIEW_DIMENSIONS + (2 * VIEW_PADDING));
//    NSLog(@"%d", xFinal);
    
    [scroller setContentOffset:CGPointMake(xFinal, 0) animated:YES];
    [self.delegate horizontalScroller:self clickedViewAtIndex:viewIndex];
}


-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self centerCurrentView];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self centerCurrentView];
}

@end
