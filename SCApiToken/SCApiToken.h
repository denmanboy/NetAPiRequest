//
//  SCApiToken.h
//  SinaCar
//
//  Created by denman on 15/12/9.
//  Copyright © 2015年 sina.com. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  接口加密
 *
 *  @param NSString <#NSString description#>
 *
 *  @return <#return value description#>
 */
/**
 *  对 api的参数 app_key app_secret 时间戳加密 获取token
 */
@interface SCApiToken : NSObject

//获取token
+ (NSString *)apiGetTokenAppendTimestampStringWithParams:(NSDictionary *)paramDic;

////获取系统距离1970的时间间隔
//+ (NSString*)timestamp;
@end
