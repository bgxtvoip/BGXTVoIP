//
//  VoipHTTPHelper.h
//
//  Created by qinyihui on 2019/8/19.
//  Copyright © 2019年 qinyihui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    VHTTPMethodGet,
    VHTTPMethodPost,    
} VHTTPMethod;

@interface VoipHTTPHelper : NSObject
+ (void)sendHTTPRequest:(NSString *)URLString method:(VHTTPMethod)method parameters:(nullable NSDictionary *)parameters success:(nullable void (^)(id _Nullable responseObject))success
                failure:(nullable void (^)(NSError *error))failure;;


@end

NS_ASSUME_NONNULL_END
