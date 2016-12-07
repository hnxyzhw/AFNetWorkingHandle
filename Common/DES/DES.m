//
//  DES.m
//  ka360
//
//  Created by laoliu on 14-6-28.
//  Copyright (c) 2014年 laoliu. All rights reserved.
//

#import "DES.h"


#import <CommonCrypto/CommonCrypto.h>
#import "NSData+Des.h"



@implementation DES

static Byte iv[] = {1,2,3,4,5,6,7,8};



+(NSString *) encryptUseDES:(id)plainText
{
    
    NSString * authKey = @"cardm360";
    NSString *ciphertext = nil;
    NSData *textData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [textData length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [authKey UTF8String],
                                          kCCKeySizeDES,
                                          iv,
                                          [textData bytes],
                                          dataLength,
                                          buffer,
                                          1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        
        ciphertext = [data base64Encoding];
        
        NSString *oriStr = [NSString stringWithFormat:@"%@",ciphertext];
        NSCharacterSet *cSet = [NSCharacterSet characterSetWithCharactersInString:@"< >"];
        ciphertext = [[oriStr componentsSeparatedByCharactersInSet:cSet] componentsJoinedByString:@""];
        
    }
    return ciphertext;

    
}
+(NSString *) parseByteArray2HexString:(Byte[]) bytes

{
    
    NSMutableString *hexStr = [[NSMutableString alloc]init];
    int i = 0;
   
    
    if(bytes){
        while (bytes[i] != '\0'){
            int temp = bytes[i];
            while (temp < 0) {
                temp = temp + 256;
            }
            if(temp < 16){
                [hexStr appendFormat:@"0"];
                
            }
            
            [hexStr appendFormat:@"%d",temp];
            i++;
        }
    }
    
    return hexStr;
    
}


@end
