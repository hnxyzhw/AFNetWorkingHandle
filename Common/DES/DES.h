//
//  DES.h
//  ka360
//
//  Created by laoliu on 14-6-28.
//  Copyright (c) 2014年 laoliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DES : NSObject

//加密
+(NSString *) encryptUseDES:(id)plainText;

//+ (NSString *)encryptUseDES:(NSString *)plainText andKey:(NSString *)authKey andIv:(NSString *)authIv;
@end
