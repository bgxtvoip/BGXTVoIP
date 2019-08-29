//
//  VoipHTTPHelper.m
//  VOIP
//
//  Created by qinyihui on 2019/8/19.
//  Copyright © 2019年 qinyihui. All rights reserved.
//

#import "VoipHTTPHelper.h"
#import <AFNetworking.h>

@implementation VoipHTTPHelper
+ (void)sendHTTPRequest:(NSString *)URLString method:(VHTTPMethod)method parameters:(nullable NSDictionary *)parameters success:(nullable void (^)(id _Nullable))success failure:(nullable void (^)(NSError * _Nonnull))failure{
    if (method == VHTTPMethodPost) {
        [[self manager] POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
        }];
    }else{
        [[self manager] GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
        }];
    }

}

+ (AFHTTPSessionManager *)manager{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //最大请求并发任务数
    manager.operationQueue.maxConcurrentOperationCount = 5;

    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    // 超时时间
    manager.requestSerializer.timeoutInterval = 30.0f;

    manager.responseSerializer = [AFJSONResponseSerializer serializer];//返回格式 JSON
    manager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/json",nil];

    return manager;
}
@end
