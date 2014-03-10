//
//  LibraryAPI.h
//  BlueLibrary
//
//  Created by Admin on 30.01.14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Album;

@interface LibraryAPI : NSObject

-(NSArray *)getAlbums;
-(void)addAlbum:(Album *)album atIndex:(int)index;
-(void)deleteAlbumAtIndex:(int)index;

+(LibraryAPI *)sharedInstance;

-(void)saveAlbums;

@end
