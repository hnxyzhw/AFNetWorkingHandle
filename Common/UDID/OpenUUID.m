//
//  OpenUUID.m
//  ka360
//
//  Created by laoliu on 14-6-24.
//  Copyright (c) 2014年 laoliu. All rights reserved.
//

#import "OpenUUID.h"
#import "SFHFKeychainUtils.h"
#import <AdSupport/ASIdentifierManager.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#pragma mark MAC


static OpenUUID * _sharedOpenUUID;
@implementation OpenUUID

+ (OpenUUID *)sharedOpenUUID{
    if(!_sharedOpenUUID){
        _sharedOpenUUID = [[OpenUUID alloc]init];
    }
    
    return _sharedOpenUUID;
}


#pragma mark - 获取 手机唯一标示
//获取 唯一标示
- (NSString*)getUDID
{
    NSError * error;
    NSString * userName = @"卡360";
    NSString * serviceName = @"com.andson.ka360";
    
    NSString * udid = [SFHFKeychainUtils getPasswordForUsername:userName andServiceName:serviceName error:&error];
    if (udid) {
        return udid;
        
    }else{
        NSString * UDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        if ([SFHFKeychainUtils storeUsername:userName andPassword:UDID forServiceName:serviceName updateExisting:YES error:&error]){
            
        }
        return UDID;
    }
}

- (NSString *)getIDfA{
    NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    return adId;
}


- (NSString *) getMac{
    if(isIOS7){
        return @"";
    }
	int                    mib[6];
	size_t                len;
	char                *buf;
	unsigned char        *ptr;
	struct if_msghdr    *ifm;
	struct sockaddr_dl    *sdl;
	
	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;
	
	if ((mib[5] = if_nametoindex("en0")) == 0) {
		printf("Error: if_nametoindex error/n");
		return NULL;
	}
	
	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 1/n");
		return NULL;
	}
	
	if ((buf = malloc(len)) == NULL) {
		printf("Could not allocate memory. error!/n");
		return NULL;
	}
	
	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 2");
		return NULL;
	}
	
	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
	// NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	free(buf);
	return [outstring uppercaseString];
	
}
@end
