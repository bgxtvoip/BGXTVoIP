#import "AppDelegate+MBVoIP.h"
#import "AppDelegate+UserDefaults.h"
#import "AudioConferenceViewController.h"
#import "VideoConferenceViewController.h"

@interface AppDelegate ()

@property (readonly) NSMutableDictionary *alertViewDictionary;

@end

@implementation AppDelegate (MBVoIP)

static NSString * const kAlertViewButtonTitleAccept = @"Accept";
static NSString * const kAlertViewButtonTitleReject = @"Reject";
static NSString * const kAlertViewButtonTitleCancel = @"Cancel";
static NSString * const kAlertViewButtonTitleOK = @"OK";

static NSString * const kAlertViewAssociatedCallIdKey = @"associated_call_id";
static NSString * const kAlertViewAssociatedCallStateKey = @"associated_call_state";
static NSString * const kAssociatedAlertViewDictionaryKey = @"associated_alert_view_dictionary";

static NSString * const kUserDefaultsVoipConfigurationKey = @"voip_configuration";

#pragma mark - MBVoIPDelegate

- (void)registered:(BOOL)success {
    return;
}

- (void)unregistered {
    return;
}

- (void)changedCallState:(int)callId localName:(NSString *)localName remoteDisplayName:(NSString *)remoteDisplayName remoteUserName:(NSString *)remoteUserName state:(MBVoIPCallState)state responseCode:(int)responseCode {
    switch (state) {
        case MBVoIPCallStateUndefined:
            break;
        case MBVoIPCallStateInitialize:
            break;
        case MBVoIPCallStateInvite:
        case MBVoIPCallStateIncoming: {
            UIAlertView *alertView = [[UIAlertView alloc] init];
            alertView.delegate = self;
            if (state == MBVoIPCallStateInvite) {
                alertView.title = [NSString stringWithFormat:@"Invite"];
                alertView.message = [NSString stringWithFormat:@"to : %@", remoteUserName];
                [alertView addButtonWithTitle:kAlertViewButtonTitleCancel];
            }
            else {
                alertView.title = [NSString stringWithFormat:@"Incoming"];
                alertView.message = [NSString stringWithFormat:@"from : %@", remoteUserName];
                [alertView addButtonWithTitle:kAlertViewButtonTitleReject];
                [alertView addButtonWithTitle:kAlertViewButtonTitleAccept];
            }
            NSNumber *callIdValue = [NSNumber numberWithInt:callId];
            objc_setAssociatedObject(alertView, (void *)&kAlertViewAssociatedCallIdKey, callIdValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            NSNumber *callStateValue = [NSNumber numberWithInt:state];
            objc_setAssociatedObject(alertView, (void *)&kAlertViewAssociatedCallStateKey, callStateValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [self.alertViewDictionary setValue:alertView forKey:[callIdValue stringValue]];
            [alertView show];
        }
            break;
        case MBVoIPCallStateProceeding:
            break;
        case MBVoIPCallStateConnected:
        case MBVoIPCallStateDisconnected: {
            NSNumber *callIdValue = [NSNumber numberWithInt:callId];
            UIAlertView *alertView = [self.alertViewDictionary valueForKey:[callIdValue stringValue]];
            if ([alertView isKindOfClass:[UIAlertView class]]) {
                [self.alertViewDictionary setValue:nil forKey:[callIdValue stringValue]];
                [alertView dismissWithClickedButtonIndex:0 animated:YES];
            }
            
            if ([[MBVoIPManager sharedInstance] callCount] > 0) {
                if (![self.window.rootViewController.presentedViewController isKindOfClass:[VideoConferenceViewController class]] && ![self.window.rootViewController.presentedViewController isKindOfClass:[AudioConferenceViewController class]]) {
                    if ([self.window.rootViewController.presentedViewController isKindOfClass:[UIViewController class]] == YES) {
                        [self.window.rootViewController dismissViewControllerAnimated:NO completion:^{
                            return ;
                        }];
                    }
                    if ([[MBVoIPManager sharedInstance] isVideo]) {
                        VideoConferenceViewController *videoConferenceViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([VideoConferenceViewController class])];
                        [self.window.rootViewController presentViewController:videoConferenceViewController animated:NO completion:^{
                            // options
                            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
                            UIDevice *device = [UIDevice currentDevice];
                            device.proximityMonitoringEnabled = YES;
                            
                            return ;
                        }];
                    } else {
                        AudioConferenceViewController *audioConferenceViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([AudioConferenceViewController class])];
                        [self.window.rootViewController presentViewController:audioConferenceViewController animated:NO completion:nil];
                        
                    }
                }
            } else {
                if ([self.window.rootViewController.presentedViewController isKindOfClass:[VideoConferenceViewController class]]) {
                    [self.window.rootViewController dismissViewControllerAnimated:NO completion:^{
                        // options
                        UIDevice *device = [UIDevice currentDevice];
                        device.proximityMonitoringEnabled = NO;
                        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                        
                        return ;
                    }];
                } else if ([self.window.rootViewController.presentedViewController isKindOfClass:[AudioConferenceViewController class]]) {
                    [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
                }
                
                if(responseCode > 0)
                {
                    UIAlertView *alertView = [[UIAlertView alloc] init];
                    alertView.delegate = self;
                    alertView.title = [NSString stringWithFormat:@"Call Rejected"];
                    if(responseCode == 486)
                        alertView.message = [NSString stringWithFormat:@"상대방이 통화 중입니다. 다음에 다시 시도하세요."];
                    else if(responseCode == 480)
                        alertView.message = [NSString stringWithFormat:@"상대방 정보를 알수 없어 요청을 시도하지 못했습니다."];
                    else
                        alertView.message = [NSString stringWithFormat:@"알 수 없는 오류입니다. 에러코드(%d). 관리자에게 문의하세요.", responseCode];
                    [alertView addButtonWithTitle:kAlertViewButtonTitleOK];
                    [alertView show];
                }
            }
            if([[MBVoIPManager sharedInstance] isRestart]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [[MBVoIPManager sharedInstance] setIsRestart:NO];
                    [[MBVoIPManager sharedInstance] stop];
                    [[MBVoIPManager sharedInstance] start:nil];
                });
            }
        }
            break;
            
        default:
            break;
    }
    
    return;
}

- (void)holded:(int)callId {
    return;
}

- (void)unholded:(int)callId {
    return;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSNumber *associatedCallId = objc_getAssociatedObject(alertView, (void *)&kAlertViewAssociatedCallIdKey);
    if ([associatedCallId isKindOfClass:[NSNumber class]] == NO) {
        return;
    }
    NSNumber *associatedCallState = objc_getAssociatedObject(alertView, (void *)&kAlertViewAssociatedCallStateKey);
    if ([associatedCallState isKindOfClass:[NSNumber class]] == NO) {
        return;
    }
    
    switch ([associatedCallState intValue]) {
        case MBVoIPCallStateInvite: {
            if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:kAlertViewButtonTitleCancel]) {
                [[MBVoIPManager sharedInstance] dropCall:[associatedCallId intValue]];
            }
        }
            break;
        case MBVoIPCallStateIncoming: {
            if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:kAlertViewButtonTitleReject]) {
                [[MBVoIPManager sharedInstance] rejectCall:[associatedCallId intValue]];
            }
            else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:kAlertViewButtonTitleAccept]) {
                [[MBVoIPManager sharedInstance] answerCall:[associatedCallId intValue] clientCallType:MBVoIPCallTypeVideo];
            }
        }
            break;
        
        default:
            break;
    }
    
    return;
}

#pragma mark - property

- (NSMutableDictionary *)alertViewDictionary {
    NSMutableDictionary *mutableDictionary = objc_getAssociatedObject(self, (void *)&kAssociatedAlertViewDictionaryKey);
    if ([mutableDictionary isKindOfClass:[NSMutableDictionary class]]) {
        return mutableDictionary;
    }
    mutableDictionary = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(self, (void *)&kAssociatedAlertViewDictionaryKey, mutableDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return mutableDictionary;
}

- (NSMutableDictionary *)voipConfiguration {
    NSMutableDictionary *mutableDictionary = nil;
    NSDictionary *dictionary = [self valueFromUserDefaultsForKey:kUserDefaultsVoipConfigurationKey];
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    }
    else {
        mutableDictionary = [[MBVoIPManager sharedInstance] defaultConfiguration];
        [mutableDictionary setValue:[NSString string] forKey:kMBVoIPConfigurationUsernameKey];
        [mutableDictionary setValue:[NSString string] forKey:kMBVoIPConfigurationPasswordKey];
        [mutableDictionary setValue:@"c" forKey:kMBVoIPConfigurationRegisterIPKey];
        [mutableDictionary setValue:@"5070" forKey:kMBVoIPConfigurationRegisterPortKey];
        [mutableDictionary setValue:@"5090" forKey:kMBVoIPConfigurationLocalPortKey];
        [mutableDictionary setValue:[NSString string] forKey:kMBVoIPConfigurationDisplayNameKey];
        self.voipConfiguration = mutableDictionary;
    }
    return mutableDictionary;
}

- (void)setVoipConfiguration:(NSMutableDictionary *)voipConfiguration {
    [self setValue:voipConfiguration toUserDefaultsForKey:kUserDefaultsVoipConfigurationKey];
    return;
}

@end
