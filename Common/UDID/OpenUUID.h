//
//  OpenUUID.h
//  ka360
//
//  Created by laoliu on 14-6-24.
//  Copyright (c) 2014年 laoliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenUUID : NSObject

+ (OpenUUID *)sharedOpenUUID;

- (NSString*)getUDID;

- (NSString *)getIDfA;

- (NSString *)getMac;
@end
