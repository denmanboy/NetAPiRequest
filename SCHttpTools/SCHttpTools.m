//
//  SCHttpTools.m
//  SinaCar
//
//  Created by denman on 16/3/21.
//  Copyright © 2016年 sina.com. All rights reserved.
//

#import "SCHttpTools.h"
#import "AFNetworking.h"
#import "SCApiToken.h"
#import "KeychainUUID.h"
#import "SCUserInfo.h"

#ifdef DEVELOP_ENVIRONMENT
static NSString *const SC_HOST = @"htttp://www.baidu.com";
#else
static NSString *const SC_HOST = @"http://www.qq.com";
#endif

static NSString * const customErrorDomain  = @"com.alibabagroup";
@interface SCHttpTools ()
//task列表
@property(strong,nonatomic)NSMutableDictionary *tasksDic;
//网络监测
@property(strong,nonatomic)AFNetworkReachabilityManager *reachabilityManager;
@end

@implementation SCHttpTools
#pragma mark - init
+ (SCHttpTools*)sharedHttpTools
{
    static SCHttpTools *httpTools = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpTools = [[self alloc] init];
    });
    return httpTools;
}
- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}
#pragma mark - post
- (NSURLSessionDataTask*)POSTWithUrlString:(NSString *)URLString
                                parameters:(NSDictionary *)parameters
                               reqIdentify:(NSString*)reqIdentify
                              successBlock:(SuccessBlock)success
                                 failBlock:(FailureBlock)failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //json数据
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //设置可接受的类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *urlString = [self getFullURLStringWithString:URLString queryValues:parameters];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSURLSessionDataTask *task = [manager POST:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [self removeTaskWithReqIdentify:reqIdentify];
        if (success) {
            success(task,responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self  removeTaskWithReqIdentify:reqIdentify];
        [self showError:error];
        if (failure) {
            failure(error);
        }
        //接口有问题上报 - 有网才上报
        if (error.code != -1009){
            NSMutableDictionary*dic = [manager valueForKey:@"mutableTaskDelegatesKeyedByTaskIdentifier"];
            if (dic.count) {
            id taskDelegate =  dic[@(task.taskIdentifier)];
                NSData *data = [taskDelegate valueForKey:@"mutableData"];
                [self errorReportwithUrl:task.originalRequest.URL.absoluteString andParam:parameters andData:data];
            }
        }
    }];
#pragma clang diagnostic pop
    [self addTask:task withreqIdentify:reqIdentify];
    return task;
}

- (NSURLSessionDataTask*)DownloadPicWithUrlString:(NSString *)URLString
                                       parameters:(NSDictionary *)parameters
                                      reqIdentify:(NSString*)reqIdentify
                                     successBlock:(SuccessBlock)success
                                        failBlock:(FailureBlock)failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //自动转化为图片
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    //设置可接受的类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *urlString = [self getFullURLStringWithString:URLString queryValues:parameters];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSURLSessionDataTask *task = [manager POST:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [self removeTaskWithReqIdentify:reqIdentify];
        if (success) {
            success(task,responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self removeTaskWithReqIdentify:reqIdentify];
        [self showError:error];
        if (failure) {
            failure(error);
        }
        
    }];
#pragma clang diagnostic pop
    [self addTask:task withreqIdentify:reqIdentify];
    return task;
}
- (NSURLSessionDataTask*)POSTWithUrlString:(NSString *)URLString
                                parameters:(NSDictionary *)parameters
                                    andPic:(UIImage *)image
                                andFileKey:(NSString*)fileKey
                               reqIdentify:(NSString*)reqIdentify
                              successBlock:(SuccessBlock)success
                                 failBlock:(FailureBlock)failure
{
    
    __block NSURLSessionDataTask *tempTask = nil;
    //压缩图片放在 子线程里 压缩
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data =UIImageJPEGRepresentation(image, 0.5);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString*urlString = [self getFullURLStringWithString:URLString queryValues:parameters];
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            //设置可接受的类型
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            NSURLSessionDataTask *task = [manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileData:data name:fileKey fileName:@"a.jpg" mimeType:@"image/jpeg"];
            } success:^(NSURLSessionDataTask *task, id responseObject) {
                [self removeTaskWithReqIdentify:reqIdentify];
                if (success) {
                    success(task,responseObject);
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self removeTaskWithReqIdentify:reqIdentify];
                [self showError:error];
                if (failure) {
                    failure(error);
                }
            }];
#pragma clang diagnostic pop
            [self addTask:task withreqIdentify:reqIdentify];
            tempTask =  task;
        });
    });
    return nil;
}
#pragma mark - get
- (NSURLSessionDataTask*)GETWithUrlString:(NSString *)URLString
                               parameters:(NSDictionary *)parameters
                              reqIdentify:(NSString*)reqIdentify
                             successBlock:(SuccessBlock)success
                                failBlock:(FailureBlock)failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //设置可接受的类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *urlString = [self getFullURLStringWithString:URLString queryValues:parameters];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSURLSessionDataTask *task = [manager GET:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [self removeTaskWithReqIdentify:reqIdentify];
        if (success) {
            success(task,responseObject);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self removeTaskWithReqIdentify:reqIdentify];
        [self showError:error];
        if (failure) {
            failure(error);
        }
    }];
#pragma clang diagnostic pop
    [self addTask:task withreqIdentify:reqIdentify];
    return task;
}
#pragma mark - 取消请求
- (void)cancelTaskRequestWithReqIdentify:(NSString*)reqIdentify
{
    if (!reqIdentify.length) return;
    NSURLSessionDataTask *task = [self.tasksDic objectForKey:reqIdentify];
    if (task && task.state == NSURLSessionTaskStateRunning ) {
        [task cancel];
    }
    
}
- (void)cancelAllTaskRequest
{
    NSArray *tasks = [self.tasksDic allValues];
    [tasks makeObjectsPerformSelector:@selector(cancel)];
}

/**
 *  移除标记的task
 *
 *  @param reqIdentify 与task绑定的标识
 */
- (void)removeTaskWithReqIdentify:(NSString*)reqIdentify
{
    if (reqIdentify.length) {
        [self.tasksDic removeObjectForKey:reqIdentify];
    }
}
/**
 *  添加任务
 *
 *  @param task        task
 *  @param reqIdentify  与task绑定的标识
 */
- (void)addTask:(NSURLSessionDataTask*)task withreqIdentify:(NSString*)reqIdentify
{
    if (reqIdentify.length && task){
        [self.tasksDic setObject:task forKey:reqIdentify];
    }
}
#pragma mark - 懒加载
- (NSMutableDictionary *)tasksDic
{
    if (!_tasksDic) {
        _tasksDic = [[NSMutableDictionary alloc]initWithCapacity:0];
    }
    return _tasksDic;
}
- (AFNetworkReachabilityManager *)reachabilityManager
{
    if (!_reachabilityManager) {
        _reachabilityManager = [AFNetworkReachabilityManager sharedManager];
        [_reachabilityManager startMonitoring];
    }
    return _reachabilityManager;
}

#pragma mark - 参数加密
- (NSString *)getFullURLStringWithString:(NSString *)string queryValues:(id)queryValues
{
    //拼接url
    NSString * jionString = [NSString stringWithFormat:@"%@%@",SC_HOST,string];
    NSString * fullURLString = @"";
    NSString *resourceString = @"&resource=3&device_id=";
    resourceString = [NSString stringWithFormat:@"%@%@",resourceString,[KeychainUUID value]];
    NSString *tokenAppendTimestamp = [SCApiToken apiGetTokenAppendTimestampStringWithParams:queryValues];
    if ([jionString hasSuffix:@"?"]) {//以？结尾
        fullURLString = [NSString stringWithFormat:@"%@%@%@",jionString,tokenAppendTimestamp,resourceString];
    }else{
        //包含？
        if ([jionString rangeOfString:@"?"].length) {
            fullURLString= [NSString stringWithFormat:@"%@&%@%@",jionString,tokenAppendTimestamp,resourceString];
        }else{
            fullURLString = [NSString stringWithFormat:@"%@?%@%@",jionString,tokenAppendTimestamp,resourceString];
        }
    }
    return fullURLString;
}
#pragma mark - 接口有问题上报
- (void)errorReportwithUrl:(NSString*)url andParam:(NSDictionary*)paraDic andData:(NSData*)data
{
    NSMutableDictionary *errorReportDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [errorReportDic setObject:url forKey:@"url"];
    NSString *params = @"";
    NSArray *keys = [paraDic allKeys];
    for (NSString *key in keys) {
        if (params.length > 0) {
            params = [NSString stringWithFormat:@"%@&%@=%@",params,key,[paraDic objectForKey:key]];
        }else{
            params = [NSString stringWithFormat:@"%@=%@",key,[paraDic objectForKey:key]];
        }
    }
    if (params.length > 0) {
        [errorReportDic setObject:params forKey:@"param"];
    }
    if ([SCUserInfo sharedUserInfo].mobile.length) {
        [errorReportDic setObject:[SCUserInfo sharedUserInfo].mobile forKey:@"mobile"];
    }
    [errorReportDic setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey] forKey:@"app_version"];
    [errorReportDic setObject:[UIDevice currentDevice].systemVersion forKey:@"sys_version"];
    
    NSString *netStates = [self getNetWorkStates];
    NSString *network = @"";
    switch ([netStates intValue]) {
        case 0:{
            network = @"无网络";
        }break;
        case 2:{
            network = @"wifi";
        }
        case 3:{
            network = @"unknown";
        }
            break;
        case 4:{
            network = @"2G";
        }
            break;
        case 5:{
            network = @"3G";
        }
            break;
        case 6:{
            network = @"4G";
        }
            break;
        default:
            break;
    }
    [errorReportDic setObject:network  forKey:@"network"];
    if (data) {
        NSString *responString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [errorReportDic setObject:responString forKey:@"result"];
    }
    //上传到服务器
//    [self POSTWithUrlString:@"example" parameters: errorReportDic reqIdentify:nil successBlock:nil failBlock:nil];
}
#pragma mark - UI框-显示错误
/**
 *  只显示网络无连接 信息
 *
 *  @param error 错误
 */
- (void)showError:(NSError*)error
{
    if (error.code == -1009) {
        [UIWindow autoShowMsg:@"网络错误，请检查您的网络" duration:1 completion:nil];
    }
}

#pragma mark - 网络监测
- (NSString*)getNetWorkStates
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"]valueForKeyPath:@"foregroundView"]subviews];
    NSString *state = [[NSString alloc]init];
    int netType = 0;
    //获取到网络返回码
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏
            netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
            
            switch (netType) {
                case 0:
                    state = @"0";//@"无网络"
                    //无网模式
                    break;
                case 1:
                    state = @"4";//2G
                    break;
                case 2:
                    state = @"5";//3G
                    break;
                case 3:
                    state = @"6";//4G
                    break;
                case 5:
                    state = @"2";//WIFI
                    break;
                default:
                    state = @"3";//cellular network-unknown generation
                    break;
            }
        }
    }
    //根据状态选择
    return state;
}

/**
 *  防止copy出另一份
 *
 *  @return <#return value description#>
 */
- (id)copy
{
    return self;
}
- (id)mutableCopy
{
    return self;
}
@end

