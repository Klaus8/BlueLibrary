//
//  PersistencyManager.h
//  BlueLibrary
//
//  Created by Admin on 30.01.14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Album;

@interface PersistencyManager : NSObject

-(NSArray *)getAlbums;
-(void)addAlbum:(Album *)album atIndex:(NSUInteger)index;
-(void)deleteAlbumAtIndex:(NSUInteger)index;

-(void)saveImage:(UIImage *)image filename:(NSString *)filename;
-(UIImage *)getImage:(NSString *)filename;

-(void)saveAlbums;

@end
