//
//  AlbumView.m
//  BlueLibrary
//
//  Created by Admin on 30.01.14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import "AlbumView.h"

@implementation AlbumView {
    UIImageView *coverImage;
    UIActivityIndicatorView *indicator;
}



-(id)initWithFrame:(CGRect)frame albumCover:(NSString *)albumCover
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        coverImage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, frame.size.width-10, frame.size.height-10)];
//        coverImage.backgroundColor = [UIColor greenColor];
        [self addSubview:coverImage];
        
        indicator = [[UIActivityIndicatorView alloc]init];
        indicator.center = self.center;
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [indicator startAnimating];
        [self addSubview:indicator];
        
        [coverImage addObserver:self forKeyPath:@"image" options:0 context:nil];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"BLDownloadImageNotification"
                                                           object:self
                                                         userInfo:@{@"coverUrl":albumCover,
                                                                    @"imageView":coverImage}];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if ([keyPath isEqualToString:@"image"]) {
        [indicator stopAnimating];
    }
}


-(void)dealloc
{
    [coverImage removeObserver:self
                    forKeyPath:@"image"];
}

@end
