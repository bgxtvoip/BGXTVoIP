//
//  VoipManager.m
//  VOIP
//
//  Created by qinyihui on 2019/8/19.
//  Copyright © 2019年 qinyihui. All rights reserved.
//

#import "VoipManager.h"
#import "VoipHTTPHelper.h"


@implementation VoipManager
+ (instancetype)shareManager{
    static VoipManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[VoipManager alloc] init];
    });
    return manager;
}

- (void)getTempUser:(void (^)(bool))completion{
    [VoipHTTPHelper sendHTTPRequest:@"http://192.168.10.239:9000/api/v2/video/user/getTempUser" method:VHTTPMethodGet parameters:@{@"channel":@"smartsee"} success:^(id  _Nullable responseObject) {
        @try {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *res = (NSDictionary *)responseObject;
                id statusCode = [res objectForKey:@"statusCode"];
                if (statusCode) {
                    long status = [((NSNumber *)statusCode) longValue];
                    if (status == 0) {
                        NSDictionary *user = [res objectForKey:@"user"];
                        NSString *userName = [user objectForKey:@"userName"];
                        NSString *userPwd = [user objectForKey:@"userPwd"];
                        self.userName = userName;
                        self.userPwd = userPwd;
                        completion(YES);
                    }else{
                        completion(NO);
                    }
                }else{
                    completion(NO);
                }
            }else{
                completion(NO);
            }
        } @catch (NSException *exception) {
            completion(NO);
        } @finally {
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        completion(NO);
    }];
}

- (void)releaseTempUser:(void (^)(BOOL))completion{
    if (!self.userName) {
        completion(NO);
        return;
    }
    [VoipHTTPHelper sendHTTPRequest:@"http://192.168.10.239:9000/api/v2/video/user/releaseTempUser" method:VHTTPMethodGet parameters:@{@"channel":@"smartsee",@"userName":self.userName} success:^(id  _Nullable responseObject) {
        @try {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *res = (NSDictionary *)responseObject;
                id statusCode = [res objectForKey:@"statusCode"];
                if (statusCode) {
                    long status = [((NSNumber *)statusCode) longValue];
                    if (status == 0) {                        
                        self.userName = @"";
                        self.userPwd = @"";
                        completion(YES);
                    }else{
                        completion(NO);
                    }
                }else{
                    completion(NO);
                }
            }else{
                completion(NO);
            }
        } @catch (NSException *exception) {
            completion(NO);
        } @finally {
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        completion(NO);
    }];
}

- (void)makeVideoCall:(void (^)(BOOL))completion{
    if (!self.userName) {
        completion(NO);
        return;
    }    
    [VoipHTTPHelper sendHTTPRequest:@"http://192.168.10.239:9000/api/v2/video/call/makeVideoCall" method:VHTTPMethodPost parameters:@{@"userId":self.userName,@"channel":@"smartsee",@"accountId":@"webchat_0e9a41424e6049ce91815e84191fae25"} success:^(id  _Nullable responseObject) {
        @try {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *res = (NSDictionary *)responseObject;
                id statusCode = [res objectForKey:@"statusCode"];
                if (statusCode) {
                    long status = [((NSNumber *)statusCode) longValue];
                    if (status == 0) {
                        NSDictionary *room = [res objectForKey:@"room"];
                        self.userId= [room objectForKey:@"userId"];
                        self.roomId = [[room objectForKey:@"roomId"] integerValue];
                        completion(YES);
                    }else{
                        completion(NO);
                    }
                }else{
                    completion(NO);
                }
            }else{
                completion(NO);
            }
        } @catch (NSException *exception) {
            completion(NO);
        } @finally {
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        completion(NO);
    }];
}

- (void)cancelVideoCall:(void (^)(BOOL))completion{
    if (!self.userName) {
        completion(NO);
        return;
    }
    [VoipHTTPHelper sendHTTPRequest:@"http://192.168.10.239:9000/api/v2/video/call/cancelVideoCall" method:VHTTPMethodPost parameters:@{@"userId":self.userName,@"channel":@"smartsee",@"accountId":@"webchat_0e9a41424e6049ce91815e84191fae25"} success:^(id  _Nullable responseObject) {
        @try {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *res = (NSDictionary *)responseObject;
                id statusCode = [res objectForKey:@"statusCode"];
                if (statusCode) {
                    long status = [((NSNumber *)statusCode) longValue];
                    if (status == 0) {
                        self.userId = @"";
                        self.roomId = 0;
                        completion(YES);
                    }else{
                        completion(NO);
                    }
                }else{
                    completion(NO);
                }
            }else{
                completion(NO);
            }
        } @catch (NSException *exception) {
            completion(NO);
        } @finally {
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        completion(NO);
    }];
}

- (void)getQueuePosition:(void (^)(BOOL))completion{
    if (!self.roomId) {
        completion(NO);
        return;
    }
    [VoipHTTPHelper sendHTTPRequest:[NSString stringWithFormat:@"http://192.168.10.239:9000/api/v1/video/queueinfo/%ld",(long)self.roomId] method:VHTTPMethodGet parameters:nil success:^(id  _Nullable responseObject) {
        @try {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *res = (NSDictionary *)responseObject;
                id statusCode = [res objectForKey:@"statusCode"];
                if (statusCode) {
                    long status = [((NSNumber *)statusCode) longValue];
                    if (status == 0) {
                        NSDictionary *queueinfo = [res objectForKey:@"queueinfo"];
                        if (![self objectIsNull:queueinfo]) {
                            self.roomId = [[queueinfo objectForKey:@"roomId"] integerValue];
                            self.queuePosition = [[queueinfo objectForKey:@"queueNum"] integerValue];
                        }
                        completion(YES);
                    }else{
                        completion(NO);
                    }
                }else{
                    completion(NO);
                }
            }else{
                completion(NO);
            }
        } @catch (NSException *exception) {
            completion(NO);
        } @finally {
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        completion(NO);
    }];
}

- (NSMutableDictionary *)voipConfiguration {
    NSMutableDictionary *mutableDictionary = nil;
//    NSDictionary *dictionary = [self valueFromUserDefaultsForKey:kUserDefaultsVoipConfigurationKey];
//    if ([dictionary isKindOfClass:[NSDictionary class]]) {
//        mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
//    }
//    else {
//        mutableDictionary = [[MBVoIPManager sharedInstance] defaultConfiguration];
//        [mutableDictionary setValue:@"10003" forKey:kMBVoIPConfigurationUsernameKey];
//        [mutableDictionary setValue:@"10003" forKey:kMBVoIPConfigurationPasswordKey];
//        [mutableDictionary setValue:@"192.168.10.167" forKey:kMBVoIPConfigurationRegisterIPKey];
//        [mutableDictionary setValue:@"5070" forKey:kMBVoIPConfigurationRegisterPortKey];
//        [mutableDictionary setValue:@"5090" forKey:kMBVoIPConfigurationLocalPortKey];
//        [mutableDictionary setValue:@"10003" forKey:kMBVoIPConfigurationDisplayNameKey];
//        self.voipConfiguration = mutableDictionary;
//    }
    return mutableDictionary;
}

#pragma mark - UserDefaults
- (id)valueFromUserDefaultsForKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    id value = [userDefaults valueForKey:key];
    
    return value;
}

- (BOOL)setValue:(id)value toUserDefaultsForKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:value forKey:key];
    
    return [userDefaults synchronize];
}

- (BOOL)objectIsNull:(NSObject *)obj{
    if ([obj isKindOfClass:[NSNull class]] || [obj isEqual:[NSNull null]] || obj == nil) {
        return YES;//
    }else {
        return NO;
    }
}
@end
