//
//  LibraryAPI.m
//  BlueLibrary
//
//  Created by Admin on 30.01.14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import "LibraryAPI.h"
#import "HTTPClient.h"
#import "PersistencyManager.h"
#import "Album.h"

@interface LibraryAPI()
{
    PersistencyManager *persistencyManager;
    HTTPClient *httpClient;
    BOOL isOnline; //должны ли изменения , связанные с альбомами, поступать на сервер
}
@end


@implementation LibraryAPI


-(id)init
{
    self = [super init];
    if (self) {
        persistencyManager = [[PersistencyManager alloc]init];
        httpClient = [[HTTPClient alloc]init];
        isOnline = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                selector:@selector(downloadImage:)
                                                    name:@"BLDownloadImageNotification"
                                                  object:nil];
    }
    return self;
}

-(void)downloadImage:(NSNotification *)notification
{
    NSString *coverUrl = notification.userInfo[@"coverUrl"];
    UIImageView *imageView = notification.userInfo[@"imageView"];
    
    imageView.image = [persistencyManager getImage:[coverUrl lastPathComponent]];
    
    if (imageView.image == nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            UIImage *image = [httpClient downloadImage:coverUrl];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                imageView.image = image;
                [persistencyManager saveImage:image filename:[coverUrl lastPathComponent]];
            });
        });
    }
}

-(NSArray *)getAlbums
{
    return [persistencyManager getAlbums];
}

-(void)addAlbum:(Album *)album atIndex:(int)index
{
    [persistencyManager addAlbum:album atIndex:index];
    if (isOnline) {
        [httpClient postRequest:@"/api/addAlbum" body:[album description]];
    }
}


-(void)deleteAlbumAtIndex:(int)index
{
    [persistencyManager deleteAlbumAtIndex:index];
    if (isOnline) {
        [httpClient postRequest:@"/api/deleteAlbum" body:[@(index)description]];
    }
}


+(LibraryAPI *)sharedInstance
{
    static LibraryAPI *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[LibraryAPI alloc]init];
    });
    
    return _sharedInstance;
}

-(void)saveAlbums
{
    [persistencyManager saveAlbums];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
