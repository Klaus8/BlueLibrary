//
//  Album+TableRepresentation.m
//  BlueLibrary
//
//  Created by Admin on 30.01.14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import "Album+TableRepresentation.h"

@implementation Album (TableRepresentation)

-(NSDictionary *)tr_tableRepresentation
{
    return @{@"titles": @[@"Исполнитель", @"Альбом", @"Жанр", @"Год"],
             @"values": @[self.artist, self.title, self.genre, self.year]};
}

@end
