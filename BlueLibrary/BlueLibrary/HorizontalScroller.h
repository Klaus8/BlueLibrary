//
//  HorizontalScroller.h
//  BlueLibrary
//
//  Created by Admin on 30.01.14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HorizontalScrollerDelegate;


@interface HorizontalScroller : UIView

@property (weak) id<HorizontalScrollerDelegate> delegate;

-(void)reload;

@end


@protocol HorizontalScrollerDelegate <NSObject>

-(NSUInteger)numberOfViewsForHorizontalScroller:(HorizontalScroller *)scroller;
-(UIView *)horizontalScroller:(HorizontalScroller *)scroller viewAtIndex:(int)index;
-(void)horizontalScroller:(HorizontalScroller *)scroller clickedViewAtIndex:(int)index;

@optional
-(NSInteger)initialViewIndexForHorizontalScroller:(HorizontalScroller *)scroller;

@end