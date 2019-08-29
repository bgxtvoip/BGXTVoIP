//
//  VoipManager.h
//  VOIP
//
//  Created by qinyihui on 2019/8/19.
//  Copyright © 2019年 qinyihui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoipManager : NSObject
@property (strong, nonatomic) NSMutableDictionary *voipConfiguration;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userPwd;
@property (strong, nonatomic) NSString *userId;
@property (assign, nonatomic) NSInteger roomId;
@property (assign, nonatomic) NSInteger queuePosition;
+(instancetype)shareManager;

- (void)getTempUser:(void(^)(BOOL))completion;
- (void)releaseTempUser:(void(^)(BOOL))completion;
- (void)makeVideoCall:(void(^)(BOOL))completion;
- (void)cancelVideoCall:(void(^)(BOOL))completion;
- (void)getQueuePosition:(void(^)(BOOL))completion;
@end

NS_ASSUME_NONNULL_END
