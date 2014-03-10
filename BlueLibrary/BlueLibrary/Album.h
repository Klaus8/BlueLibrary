//
//  Album.h
//  BlueLibrary
//
//  Created by Admin on 30.01.14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Album : NSObject <NSCoding>

@property (nonatomic, copy, readonly) NSString *title, *artist, *genre, *coverUrl, *year;

-(id)initWithTitle:(NSString *)title
            artist:(NSString *)artist
          coverUrl:(NSString *)coverUrl
              year:(NSString *)year;


@end
