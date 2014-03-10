//
//  Album+TableRepresentation.h
//  BlueLibrary
//
//  Created by Admin on 30.01.14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import "Album.h"

@interface Album (TableRepresentation)

-(NSDictionary *)tr_tableRepresentation;

@end
