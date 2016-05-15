//
//  SCApiToken.m
//  SinaCar
//
//  Created by denman on 15/12/9.
//  Copyright © 2015年 sina.com. All rights reserved.
//


#import "SCApiToken.h"
#import "NSString+MD5String.h"
static NSString *const app_key = @"example123";
static NSString *const app_secret = @"example456";

@implementation SCApiToken

+ (NSString*)apiGetTokenAppendTimestampStringWithParams:(NSDictionary *)paramDic
{
    NSString *token = nil;
    //1.按参数key排序
    NSArray *sortArray = [self keySortWithArray:[paramDic allKeys]];
    //2.拼接app_key
    token = [NSString stringWithFormat:@"%@",app_key];
    //3.拼接key——value
    for (NSString *key in sortArray) {
        token = [NSString stringWithFormat:@"%@%@%@",token,key,[paramDic objectForKey:key]];
    }
    //4.拼接时间戳
    NSString *timestamp = [self timestamp];
    token = [NSString stringWithFormat:@"%@%@",token,timestamp];
    //5.拼接app_secret
    token = [NSString stringWithFormat:@"%@%@",token ,app_secret];
    //6.MD5加密
    token = [[token MD5String] uppercaseString];
    //7.返回拼接好的token + timestamp
    return [NSString stringWithFormat:@"token=%@&timestamp=%@",token,timestamp];
}
//根据key排序
+ (NSArray*)keySortWithArray:(NSArray*)keyArray
{

    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:descriptor];
    NSArray *resultArray = [keyArray sortedArrayUsingDescriptors:descriptors];
    return resultArray;
}

+ (NSString*)timestamp
{
    //获取系统所在时区的时间
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    double timeInterval = [localeDate timeIntervalSince1970];
    return [NSString stringWithFormat:@"%.0f",timeInterval];
}
@end