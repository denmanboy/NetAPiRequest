//
//  SCHttpTools.h
//  SinaCar
//
//  Created by denman on 16/3/21.
//  Copyright © 2016年 sina.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIWindow+SCShowMessage.h"
typedef void(^SuccessBlock)(NSURLSessionDataTask *task,id responseObject);
typedef void(^FailureBlock)(NSError *error);

/**
 * 网络请求
 */
@interface SCHttpTools : NSObject

/**
 *  网络请求单利
 *
 *  @return 单利
 */
+ (SCHttpTools*)sharedHttpTools;
/**
 *  请求数据
 *  @param URLString   url
 *  @param parameters  参数
 *  @param reqIdentify 请求的标识
 *  @param success     成功的回调
 *  @param failure     失败的回调
 *
 *  @return task
 */
- (NSURLSessionDataTask*)POSTWithUrlString:(NSString*)URLString
                                parameters:(NSDictionary *)parameters
                               reqIdentify:(NSString*)reqIdentify
                              successBlock:(SuccessBlock)success
                                 failBlock:(FailureBlock)failure;


/**
 *  提交图片
 *
 *  @param URLString   Url地址
 *  @param parameters  参数
 *  @param image       要提交的图片
    @param fileKey     文件字段
 *  @param reqIdentify 请求的标识
 *  @param success     成功的回调
 *  @param fail        失败的回调
 */
- (NSURLSessionDataTask*)POSTWithUrlString:(NSString*)URLString
                                parameters:(NSDictionary *)parameters
                                    andPic:(UIImage *)image
                                andFileKey:(NSString*)fileKey
                               reqIdentify:(NSString*)reqIdentify
                              successBlock:(SuccessBlock)success
                                 failBlock:(FailureBlock)failure;

/**
 *  post请求下载图片
 *
 *  @param URLString  Url地址
 *  @param parameters 参数
 *  @param reqIdentify 请求的标识
 *  @param success    成功的回调
 *  @param failure    失败的回调
 */
- (NSURLSessionDataTask*)DownloadPicWithUrlString:(NSString*)URLString
                                       parameters:(NSDictionary *)parameters
                                      reqIdentify:(NSString*)reqIdentify
                                     successBlock:(SuccessBlock)success
                                        failBlock:(FailureBlock)failure;

/**
 *  get请求
 *
 *  @param URLString 地址
 *  @param parameters 参数
 *  @param reqIdentify 请求的标识
 *  @param success    成功的回调
 *  @param fail       失败的回调
 */
- (NSURLSessionDataTask*)GETWithUrlString:(NSString*)URLString
                               parameters:(NSDictionary *)parameters
                              reqIdentify:(NSString*)reqIdentify
                             successBlock:(SuccessBlock)success
                                failBlock:(FailureBlock)failure;


/**
 *  取消请求
 *
 *  @param reqIdentify 要取消的请求标识
 */
- (void)cancelTaskRequestWithReqIdentify:(NSString*)reqIdentify;

/**
 *  取消所有的网络请求
 */
- (void)cancelAllTaskRequest;
@end