#include <ifaddrs.h>
#include <arpa/inet.h>
#import "MBVoIPManager.h"
#import "MBClientAppEvent.h"

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

// Configuration
NSString * const kMBVoIPUserDefaultsConfigurationKey = @"mb_voip_configuration";
/// VoIP
NSString * const kMBVoIPConfigurationUsernameKey = @"voip_username";
NSString * const kMBVoIPConfigurationPasswordKey = @"voip_password";
NSString * const kMBVoIPConfigurationRegisterIPKey = @"voip_register_IP";
NSString * const kMBVoIPConfigurationRegisterPortKey = @"voip_register_port";
NSString * const kMBVoIPConfigurationLocalIPKey = @"voip_local_IP";
NSString * const kMBVoIPConfigurationLocalPortKey = @"voip_local_port";
NSString * const kMBVoIPConfigurationDisplayNameKey = @"voip_display_name";
NSString * const kMBVoIPConfigurationAudioCodecEnableG711AKey = @"voip_audio_codec_enable_G711A";
NSString * const kMBVoIPConfigurationAudioCodecEnableG711UKey = @"voip_audio_codec_enable_G711U";
NSString * const kMBVoIPConfigurationAudioCodecEnableG729Key = @"voip_audio_codec_enable_G729";
NSString * const kMBVoIPConfigurationAudioCodecEnableG723Key = @"voip_audio_codec_enable_G723";
NSString * const kMBVoIPConfigurationAudioCodecEnableAMRKey = @"voip_audio_codec_enable_AMR";
NSString * const kMBVoIPConfigurationAudioCodecEnableAMRWBKey = @"voip_audio_codec_enable_AMRWB";
NSString * const kMBVoIPConfigurationAudioCodecEnableAACKey = @"voip_audio_codec_enable_AAC";
NSString * const kMBVoIPConfigurationAudioCodecEnableiLBCKey = @"voip_audio_codec_enable_iLBC";
NSString * const kMBVoIPConfigurationAudioCodecEnableSILKKey = @"voip_audio_codec_enable_SILK";
NSString * const kMBVoIPConfigurationAudioCodecEnableGSMKey = @"voip_audio_codec_enable_GSM";
NSString * const kMBVoIPConfigurationAudioCodecEnableG722Key = @"voip_audio_codec_enable_G722";
NSString * const kMBVoIPConfigurationAudioCodecEnableFECKey = @"voip_audio_codec_enable_FEC_audio";
NSString * const kMBVoIPConfigurationAudioCodecEnableKeysKey = @"voip_audio_codec_enable_keys";
NSString * const kMBVoIPConfigurationVideoCodecEnableFECKey = @"voip_video_codec_enable_FEC_video";
//NSString * const kMBVoIPConfigurationVideoCodecEnableH263Key = @"voip_video_codec_enable_H263";
NSString * const kMBVoIPConfigurationVideoCodecEnableH264Key = @"voip_video_codec_enable_H264";
NSString * const kMBVoIPConfigurationVideoCodecEnableKeysKey = @"voip_video_codec_enable_keys";
/// Audio
NSString * const kMBVoIPConfigurationAudioAECKey = kMBMediaEngineConfigurationAudioAECKey;
NSString * const kMBVoIPConfigurationAudioMicGainBeforeAECVolumeKey = kMBMediaEngineConfigurationAudioMicGainBeforeAECVolumeKey;
NSString * const kMBVoIPConfigurationAudioMicGainAfterAECVolumeKey = kMBMediaEngineConfigurationAudioMicGainAfterAECVolumeKey;
NSString * const kMBVoIPConfigurationAudioAGCKey = kMBMediaEngineConfigurationAudioAGCKey;
NSString * const kMBVoIPConfigurationAudioDenoiserKey = kMBMediaEngineConfigurationAudioDenoiserKey;
NSString * const kMBVoIPConfigurationAudioVolumeKey = kMBMediaEngineConfigurationAudioVolumeKey;
/// Video
NSString * const kMBVoIPConfigurationVideoResolutionKey = kMBMediaEngineConfigurationVideoResolutionKey;
NSString * const kMBVoIPConfigurationVideoBitrateKey = kMBMediaEngineConfigurationVideoBitrateKey;
NSString * const kMBVoIPConfigurationVideoFramerateKey = kMBMediaEngineConfigurationVideoFramerateKey;
NSString * const kMBVoIPConfigurationVideoIframeRequestKey = kMBMediaEngineConfigurationVideoIframeRequestKey;
NSString * const kMBVoIPConfigurationVideoIframeIntervalKey = kMBMediaEngineConfigurationVideoIframeIntervalKey;

@interface MBVoIPManager ()

// core
@property (assign, nonatomic) CMBVoipClient *voipClient;
@property (assign, nonatomic) MBClientAppEvent *clientAppEvent;
// service
@property (strong, nonatomic) NSMutableArray *delegates;
// etc
@property (assign, nonatomic) BOOL isStarted;
@property (assign, nonatomic) BOOL isRegistered;
@property (assign, nonatomic) NSInteger callCount;
@property (assign, nonatomic) BOOL isVideo;
// configuration
@property (retain, nonatomic) NSMutableArray *audioCodecs;
@property (retain, nonatomic) NSMutableArray *videoCodecs;

@end

@implementation MBVoIPManager

#pragma mark - singleton

+ (MBVoIPManager *)sharedInstance
{
    static MBVoIPManager *s_instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[self alloc] init];
    });
    
    return s_instance;
}

#pragma mark - NSObject

- (void)dealloc
{
    if (self.clientAppEvent != NULL) {
        self.clientAppEvent->delegate = nil;
        self.clientAppEvent = NULL;
    }
    if (self.voipClient != NULL) {
        self.voipClient->ClientRegisterEvents(NULL);
        self.voipClient = NULL;
    }

#if !__has_feature(objc_arc)
    [super dealloc];
#else
#endif
    
    return;
}

- (id)init
{
    self = [super init];
    if (self) {
        CMBVoipClient *voipClient = NULL;
        MBClientAppEvent *clientAppEvent = NULL;
        MBMediaEngineManager *sharedInstance = nil;
        @try {
            sharedInstance = [MBMediaEngineManager sharedInstance];
            if (![sharedInstance isKindOfClass:[MBMediaEngineManager class]]) {
                NSString *reason = [NSString stringWithFormat:@"failed to get a media engine manager."];
                @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
            }
            sharedInstance.delegate = self;
            
            voipClient = CMBVoipClient::GetInstance();
            if (voipClient == NULL) {
                NSString *reason = [NSString stringWithFormat:@"failed to get a voip client."];
                @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
            }
            clientAppEvent = MBClientAppEvent::GetInstance();
            if (clientAppEvent == NULL) {
                NSString *reason = [NSString stringWithFormat:@"failed to get a client app event."];
                @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
            }
            voipClient->ClientRegisterEvents(clientAppEvent);
            clientAppEvent->delegate = self;
            
            voipClient->config.transportType = MBClientTransportTypeUDP;
            voipClient->config.autoAnswer = false;
            voipClient->config.logType = "COUT"; // COUT | FILE
            voipClient->config.logLevel = "DEBUG"; // NONE | ERR | WARNING | INFO | DEBUG
            voipClient->config.logFileMaxSize = 5242880;
            
            self.voipClient = voipClient;
            self.clientAppEvent = clientAppEvent;
            
            self.isRestart = NO;
            self.isStarted = NO;
            self.isRegistered = NO;
            self.callCount = 0;
        }
        @catch (NSException *exception) {
            NSLog(@"exception : %@", exception.reason);
            if (clientAppEvent != NULL) {
                clientAppEvent->delegate = nil;
            }
            if (voipClient != NULL) {
                voipClient->ClientRegisterEvents(NULL);
            }
            self = nil;
        }
        @finally {
        }
    }
    
    return self;
}

#pragma mark - property

// service

- (NSMutableArray *)delegates
{
    if (_delegates == nil) {
        _delegates = [[NSMutableArray alloc] init];
    }
    return _delegates;
}

- (BOOL)isCalling
{
    return (self.callCount > 0);
}

#pragma mark - MBMediaEngineDelegate

// IMediaEngineEvent

- (void)nErrorCb:(MediaEngine_ErrorCodes)errorCodes value:(int)value errorReason:(char *)errorReason channelId:(int)channelId
{
    switch(errorCodes)
    {
        case ME_ERROR_AUDIO_MIC:
            if(value == ME_STATE_OPEN_FAILURE)
            {
            }
            if(value == ME_STATE_START_FAILURE)
            {
            }
            if(value == ME_STATE_STOP_FAILURE)
            {
            }
            if(value == ME_STATE_CLOSE_FAILURE)
            {
            }
            break;
        case ME_ERROR_AUDIO_CODEC:
        case ME_ERROR_VIDEO_CODEC:
        case ME_ERROR_AUDIO_SPEAKER:
            if (value == (int)ME_ERROR_VALUE_AUDIO_NO_DATA)
            {
                int callId = [MBMediaEngineManager sharedInstance].mediaEngineWrapper->channels[channelId].callid;
                self.voipClient->CallDrop(callId);
            }
            break;
            
        default:
            break;
    }
}

- (void)notify_require_fastupdate:(int)channelId
{
    int callId = [MBMediaEngineManager sharedInstance].mediaEngineWrapper->channels[channelId].callid;
    self.voipClient->CallSendVideoFastUpdateReq(callId,0);
}

#pragma mark - MBVoIPDelegate

- (void)registered:(BOOL)success
{
    self.isRegistered = (success == YES);
    @synchronized(self.delegates) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<MBVoIPDelegate> delegate in self.delegates) {
                if ([[delegate class] conformsToProtocol:@protocol(MBVoIPDelegate)]) {
                    if ([delegate respondsToSelector:@selector(registered:)]) {
                        [delegate registered:success];
                    }
                }
            }
            
            return ;
        });
    }
    
    if (self.isRegistered == NO) {
        [self dropCalls];
    }
    
    return;
}

- (void)unregistered
{
    self.isRegistered = NO;
    @synchronized(self.delegates) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<MBVoIPDelegate> delegate in self.delegates) {
                if ([[delegate class] conformsToProtocol:@protocol(MBVoIPDelegate)]) {
                    if ([delegate respondsToSelector:@selector(unregistered)]) {
                        [delegate unregistered];
                    }
                }
            }
            
            return ;
        });
    }
    
    [self dropCalls];
    
    return;
}

- (void)changedCallState:(int)callId localName:(NSString *)localName remoteDisplayName:(NSString *)remoteDisplayName remoteUserName:(NSString *)remoteUserName state:(MBVoIPCallState)state responseCode:(int)responseCode
{
    switch (state) {
        case MBVoIPCallStateInvite:
            self.callCount++;
            self.isVideo = NO;
            break;
        case MBVoIPCallStateIncoming:
            self.callCount++;
            self.isVideo = NO;
            break;
        case MBVoIPCallStateConnected:
            break;
        case MBVoIPCallStateDisconnected:
            self.callCount--;
            self.isVideo = NO;
            break;
        case MBVoIPCallStateVideo:
            self.isVideo = YES;
            break;
        default:
            break;
    }
    
    @synchronized(self.delegates) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<MBVoIPDelegate> delegate in self.delegates) {
                if ([[delegate class] conformsToProtocol:@protocol(MBVoIPDelegate)]) {
                    if ([delegate respondsToSelector:@selector(changedCallState:localName:remoteDisplayName:remoteUserName:state:responseCode:)]) {
                        [delegate changedCallState:callId localName:localName remoteDisplayName:remoteDisplayName remoteUserName:remoteUserName state:state responseCode:responseCode];
                    }
                }
            }
            
            return ;
        });
    }
    
    return;
}

- (void)holded:(int)callId
{
    @synchronized(self.delegates) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<MBVoIPDelegate> delegate in self.delegates) {
                if ([[delegate class] conformsToProtocol:@protocol(MBVoIPDelegate)]) {
                    if ([delegate respondsToSelector:@selector(holded:)]) {
                        [delegate holded:callId];
                    }
                }
            }
            
            return ;
        });
    }
    
    return;
}

- (void)unholded:(int)callId
{
    @synchronized(self.delegates) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<MBVoIPDelegate> delegate in self.delegates) {
                if ([[delegate class] conformsToProtocol:@protocol(MBVoIPDelegate)]) {
                    if ([delegate respondsToSelector:@selector(unholded:)]) {
                        [delegate unholded:callId];
                    }
                }
            }
            
            return ;
        });
    }
    
    return;
}

// Pager Message

- (void)hasSentMessage:(BOOL)isSuccess callId:(int)callId {
    @synchronized(self.delegates) {
        for (id<MBVoIPDelegate> delegate in self.delegates) {
            if ([[delegate class] conformsToProtocol:@protocol(MBVoIPDelegate)]) {
                if ([delegate respondsToSelector:@selector(hasSentMessage:callId:)]) {
                    [delegate hasSentMessage:isSuccess callId:callId];
                }
            }
        }
    }
    return;
}

- (void)hasReceivedMessage:(NSString *)message callId:(int)callId from:(NSString *)from {
    @synchronized(self.delegates) {
        for (id<MBVoIPDelegate> delegate in self.delegates) {
            if ([[delegate class] conformsToProtocol:@protocol(MBVoIPDelegate)]) {
                if ([delegate respondsToSelector:@selector(hasReceivedMessage:callId:from:)]) {
                    [delegate hasReceivedMessage:message callId:callId from:from];
                }
            }
        }
    }
    return;
}

- (void)hasReceivedMessage:(NSString *)message time:(NSString *)time type:(NSString *)type sender:(NSString *)sender senderId:(int)senderId receiverId:(int)receiverId messageId:(int)messageId {
    @synchronized(self.delegates) {
        for (id<MBVoIPDelegate> delegate in self.delegates) {
            if ([[delegate class] conformsToProtocol:@protocol(MBVoIPDelegate)]) {
                if ([delegate respondsToSelector:@selector(hasReceivedMessage:time:type:sender:senderId:receiverId:messageId:)]) {
                    [delegate hasReceivedMessage:message time:time type:type sender:sender senderId:senderId receiverId:receiverId messageId:messageId];
                }
            }
        }
    }
    return;
}

#pragma mark - configuration

- (NSMutableDictionary *)defaultConfiguration
{
    NSMutableDictionary *configuration = [[MBMediaEngineManager sharedInstance] defaultConfiguration];
    
    [configuration setValue:[NSString string] forKey:kMBVoIPConfigurationUsernameKey];
    [configuration setValue:[NSString string] forKey:kMBVoIPConfigurationPasswordKey];
    [configuration setValue:[NSString string] forKey:kMBVoIPConfigurationRegisterIPKey];
    [configuration setValue:[NSString string] forKey:kMBVoIPConfigurationRegisterPortKey];
    [configuration setValue:[NSString string] forKey:kMBVoIPConfigurationLocalIPKey];
    [configuration setValue:[NSString string] forKey:kMBVoIPConfigurationLocalPortKey];
    [configuration setValue:[NSString string] forKey:kMBVoIPConfigurationDisplayNameKey];
    
    [configuration setValue:[NSNumber numberWithBool:YES] forKey:kMBVoIPConfigurationAudioCodecEnableG711AKey];
    [configuration setValue:[NSNumber numberWithBool:YES] forKey:kMBVoIPConfigurationAudioCodecEnableG711UKey];
    [configuration setValue:[NSNumber numberWithBool:NO] forKey:kMBVoIPConfigurationAudioCodecEnableG729Key];
    [configuration setValue:[NSNumber numberWithBool:NO] forKey:kMBVoIPConfigurationAudioCodecEnableG723Key];
    [configuration setValue:[NSNumber numberWithBool:NO] forKey:kMBVoIPConfigurationAudioCodecEnableAMRKey];
    [configuration setValue:[NSNumber numberWithBool:NO] forKey:kMBVoIPConfigurationAudioCodecEnableAMRWBKey];
    [configuration setValue:[NSNumber numberWithBool:NO] forKey:kMBVoIPConfigurationAudioCodecEnableAACKey];
    [configuration setValue:[NSNumber numberWithBool:NO] forKey:kMBVoIPConfigurationAudioCodecEnableiLBCKey];
    [configuration setValue:[NSNumber numberWithBool:NO] forKey:kMBVoIPConfigurationAudioCodecEnableSILKKey];
    [configuration setValue:[NSNumber numberWithBool:NO] forKey:kMBVoIPConfigurationAudioCodecEnableGSMKey];
    [configuration setValue:[NSNumber numberWithBool:YES] forKey:kMBVoIPConfigurationAudioCodecEnableG722Key];
    [configuration setValue:[NSNumber numberWithBool:NO] forKey:kMBVoIPConfigurationAudioCodecEnableFECKey];
    //[configuration setValue:[NSNumber numberWithBool:NO] forKey:kMBVoIPConfigurationVideoCodecEnableH263Key];
    [configuration setValue:[NSNumber numberWithBool:YES] forKey:kMBVoIPConfigurationVideoCodecEnableH264Key];
    [configuration setValue:[NSNumber numberWithBool:NO] forKey:kMBVoIPConfigurationVideoCodecEnableFECKey];
    NSMutableArray *audioCodecEnableKeys = [NSMutableArray array];
    [audioCodecEnableKeys addObject:kMBVoIPConfigurationAudioCodecEnableG722Key];
    [audioCodecEnableKeys addObject:kMBVoIPConfigurationAudioCodecEnableG711AKey];
    [audioCodecEnableKeys addObject:kMBVoIPConfigurationAudioCodecEnableG711UKey];
    [audioCodecEnableKeys addObject:kMBVoIPConfigurationAudioCodecEnableG729Key];
    [audioCodecEnableKeys addObject:kMBVoIPConfigurationAudioCodecEnableG723Key];
    [audioCodecEnableKeys addObject:kMBVoIPConfigurationAudioCodecEnableAMRKey];
    [audioCodecEnableKeys addObject:kMBVoIPConfigurationAudioCodecEnableAMRWBKey];
    [audioCodecEnableKeys addObject:kMBVoIPConfigurationAudioCodecEnableAACKey];
    [audioCodecEnableKeys addObject:kMBVoIPConfigurationAudioCodecEnableiLBCKey];
    [audioCodecEnableKeys addObject:kMBVoIPConfigurationAudioCodecEnableSILKKey];
    [audioCodecEnableKeys addObject:kMBVoIPConfigurationAudioCodecEnableGSMKey];
    [audioCodecEnableKeys addObject:kMBVoIPConfigurationAudioCodecEnableFECKey];
    [configuration setValue:audioCodecEnableKeys forKey:kMBVoIPConfigurationAudioCodecEnableKeysKey];
    NSMutableArray *videoCodecEnableKeys = [NSMutableArray array];
    [videoCodecEnableKeys addObject:kMBVoIPConfigurationVideoCodecEnableH264Key];
    //[videoCodecEnableKeys addObject:kMBVoIPConfigurationVideoCodecEnableH263Key];
    [videoCodecEnableKeys addObject:kMBVoIPConfigurationVideoCodecEnableFECKey];
    [configuration setValue:videoCodecEnableKeys forKey:kMBVoIPConfigurationVideoCodecEnableKeysKey];
    
    return configuration;
}

- (void)commitConfiguration:(NSMutableDictionary *)configuration
{
    CMBVoipClient *voipClient = self.voipClient;
    id value = nil;
    // Media Engine Manager
    [[MBMediaEngineManager sharedInstance] commitConfiguration:configuration];
    // SIP
    value = [configuration valueForKey:kMBVoIPConfigurationUsernameKey];
    if ([value isKindOfClass:[NSString class]]) {
        NSString *username = value;
        voipClient->config.username = [username UTF8String];
        voipClient->config.authname = [username UTF8String];
    }
    value = [configuration valueForKey:kMBVoIPConfigurationPasswordKey];
    if ([value isKindOfClass:[NSString class]]) {
        NSString *password = value;
        voipClient->config.password = [password UTF8String];
    }
    value = [configuration valueForKey:kMBVoIPConfigurationRegisterIPKey];
    if ([value isKindOfClass:[NSString class]]) {
        NSString *registerIP = value;
	//NSString *registerIP = [self remoteIPAddress:value];
        voipClient->config.SetDomainAddr((char *)[registerIP UTF8String]);
        voipClient->config.SetRegisterIP((char *)[registerIP UTF8String]);
    }
    value = [configuration valueForKey:kMBVoIPConfigurationRegisterPortKey];
    if ([value isKindOfClass:[NSString class]]) {
        NSString *registerPort = value;
        string registerPortUTF8String = [registerPort UTF8String];
        voipClient->config.SetRegisterPort(atoi((char *)registerPortUTF8String.c_str()));
    }
    value = [configuration valueForKey:kMBVoIPConfigurationLocalIPKey];
    if ([value isKindOfClass:[NSString class]]) {
        NSString *localIP = value;
        voipClient->config.localIP = [localIP UTF8String];
    }
    value = [configuration valueForKey:kMBVoIPConfigurationLocalPortKey];
    if ([value isKindOfClass:[NSString class]]) {
        NSString *localPort = value;
        string localPortUTF8String = [localPort UTF8String];
        voipClient->config.localPort = atoi((char *)localPortUTF8String.c_str());
    }
    value = [configuration valueForKey:kMBVoIPConfigurationDisplayNameKey];
    if ([value isKindOfClass:[NSString class]]) {
        NSString *displayName = value;
        voipClient->config.displayName = [displayName UTF8String];
    }
    
    voipClient->config.regExpires = 200;
    voipClient->config.regErrRetryTime = 60;
    voipClient->config.udpKeepAlives = 15;
    voipClient->config.tcpKeepAlives = 180;
    
    voipClient->config.noAnswerTimeout = 60;
    
    value = [configuration valueForKey:kMBVoIPConfigurationAudioCodecEnableKeysKey];
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray *audioCodecEnableKeys = value;
        NSMutableArray *audioCodecs = [NSMutableArray array];
        for (NSString *audioCodecEnableKey in audioCodecEnableKeys) {
            BOOL enable = [[configuration valueForKey:audioCodecEnableKey] boolValue];
            if (enable == YES) {
                if ([audioCodecEnableKey isEqualToString:kMBVoIPConfigurationAudioCodecEnableG711AKey]) {
                    [audioCodecs addObject:[NSNumber numberWithInt:MBVOIP_MEDIA_CODEC_G711_PCMA]];
                }
                else if ([audioCodecEnableKey isEqualToString:kMBVoIPConfigurationAudioCodecEnableG711UKey]) {
                    [audioCodecs addObject:[NSNumber numberWithInt:MBVOIP_MEDIA_CODEC_G711_PCMU]];
                }
                else if ([audioCodecEnableKey isEqualToString:kMBVoIPConfigurationAudioCodecEnableG729Key]) {
                    [audioCodecs addObject:[NSNumber numberWithInt:MBVOIP_MEDIA_CODEC_G729]];
                }
                else if ([audioCodecEnableKey isEqualToString:kMBVoIPConfigurationAudioCodecEnableG723Key]) {
                    [audioCodecs addObject:[NSNumber numberWithInt:MBVOIP_MEDIA_CODEC_G7231]];
                }
                else if ([audioCodecEnableKey isEqualToString:kMBVoIPConfigurationAudioCodecEnableAMRKey]) {
                    [audioCodecs addObject:[NSNumber numberWithInt:MBVOIP_MEDIA_CODEC_AMR_NB]];
                }
                else if ([audioCodecEnableKey isEqualToString:kMBVoIPConfigurationAudioCodecEnableAMRWBKey]) {
                    [audioCodecs addObject:[NSNumber numberWithInt:MBVOIP_MEDIA_CODEC_AMR_WB]];
                }
                else if ([audioCodecEnableKey isEqualToString:kMBVoIPConfigurationAudioCodecEnableAACKey]) {
                    [audioCodecs addObject:[NSNumber numberWithInt:MBVOIP_MEDIA_CODEC_AAC]];
                }
                else if ([audioCodecEnableKey isEqualToString:kMBVoIPConfigurationAudioCodecEnableiLBCKey]) {
                    [audioCodecs addObject:[NSNumber numberWithInt:MBVOIP_MEDIA_CODEC_ILBC]];
                }
                else if ([audioCodecEnableKey isEqualToString:kMBVoIPConfigurationAudioCodecEnableSILKKey]) {
                    [audioCodecs addObject:[NSNumber numberWithInt:MBVOIP_MEDIA_CODEC_SILK]];
                }
                else if ([audioCodecEnableKey isEqualToString:kMBVoIPConfigurationAudioCodecEnableGSMKey]) {
                    [audioCodecs addObject:[NSNumber numberWithInt:MBVOIP_MEDIA_CODEC_GSM]];
                }
                else if ([audioCodecEnableKey isEqualToString:kMBVoIPConfigurationAudioCodecEnableG722Key]) {
                    [audioCodecs addObject:[NSNumber numberWithInt:MBVOIP_MEDIA_CODEC_G722]];
                }
                else if ([audioCodecEnableKey isEqualToString:kMBVoIPConfigurationAudioCodecEnableFECKey]) {
                    [audioCodecs addObject:[NSNumber numberWithInt:MBVOIP_MEDIA_CODEC_FEC_AUDIO]];
                }
            }
        }
        self.audioCodecs = audioCodecs;
    }
    value = [configuration valueForKey:kMBVoIPConfigurationVideoCodecEnableKeysKey];
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray *videoCodecEnableKeys = value;
        NSMutableArray *videoCodecs = [NSMutableArray array];
        for (NSString *videoCodecEnableKey in videoCodecEnableKeys) {
            BOOL enable = [[configuration valueForKey:videoCodecEnableKey] boolValue];
            if (enable == YES) {
//                if ([videoCodecEnableKey isEqualToString:kMBVoIPConfigurationVideoCodecEnableH263Key]) {
//                    [videoCodecs addObject:[NSNumber numberWithInt:MBVOIP_MEDIA_CODEC_H263]];
//                }
                if ([videoCodecEnableKey isEqualToString:kMBVoIPConfigurationVideoCodecEnableH264Key]) {
                    [videoCodecs addObject:[NSNumber numberWithInt:MBVOIP_MEDIA_CODEC_H264]];
                }
                else if ([videoCodecEnableKey isEqualToString:kMBVoIPConfigurationVideoCodecEnableFECKey]) {
                    [videoCodecs addObject:[NSNumber numberWithInt:MBVOIP_MEDIA_CODEC_FEC_VIDEO]];
                }
            }
        }
        self.videoCodecs = videoCodecs;
    }
    
    return;
}

#pragma mark - service

- (void)addDelegate:(id <MBVoIPDelegate>)delegate
{
    @synchronized(self.delegates) {
        if ([[delegate class] conformsToProtocol:@protocol(MBVoIPDelegate)]) {
            [self.delegates addObject:delegate];
        }
    }
    
    return;
}

- (void)removeDelegate:(id)delegate
{
    @synchronized(self.delegates) {
        [self.delegates removeObject:delegate];
    }
    
    return;
}

- (BOOL)start:(NSError **)error
{
    BOOL result = NO;
    @try {
        if ([self.audioCodecs count] == 0) {
            NSString *reason = [NSString stringWithFormat:@"more than 1 enabled audio codec is required."];
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        }
        CMBVoipClient *voipClient = self.voipClient;
        if (voipClient->config.username.length() == 0) {
            NSString *reason = [NSString stringWithFormat:@"username is required."];
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        }
        if (voipClient->config.password.length() == 0) {
            NSString *reason = [NSString stringWithFormat:@"password is required."];
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        }
        if (voipClient->config.GetRegisterIP().length() == 0) {
            NSString *reason = [NSString stringWithFormat:@"register IP is required."];
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        }
        if (voipClient->config.GetRegisterPort() <= 0) {
            NSString *reason = [NSString stringWithFormat:@"register port is required."];
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        }
        if (voipClient->config.localIP.length() == 0) {
            NSString *reason = [NSString stringWithFormat:@"local IP is required."];
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        }
        if (voipClient->config.localPort <= 0) {
            NSString *reason = [NSString stringWithFormat:@"local port is required."];
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        }
        if (voipClient->config.displayName.length() == 0) {
            NSString *reason = [NSString stringWithFormat:@"display name is required."];
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        }
        
        vector<MBVoipMediaCodecType> codecs;
        codecs.clear();
        for (NSNumber *audioCodec in self.audioCodecs) {
            codecs.push_back((MBVoipMediaCodecType)[audioCodec intValue]);
        }
        for (NSNumber *videoCodec in self.videoCodecs) {
            codecs.push_back((MBVoipMediaCodecType)[videoCodec intValue]);
        }
        codecs.push_back(MBVOIP_MEDIA_CODEC_RFC2833);
        
        MB_Status status = voipClient->ClientStart();
        if (status != MB_STATUS_OK) {
            NSString *reason = [NSString stringWithFormat:@"failed to start VoIP client."];
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
        voipClient->ClientSetCodecs(codecs.size(), &codecs[0]);
        self.isStarted = YES;
        
        result = YES;
    }
    @catch (NSException *exception) {
        NSLog(@"exception : %@", exception.reason);
        if (error) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            NSString *localizedDescription = exception.reason;
            [userInfo setValue:localizedDescription forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"application" code:999 userInfo:userInfo];
        }
    }
    @finally {
    }
    
    return result;
}

- (void)stop
{
    self.voipClient->ClientStop();
    self.isStarted = NO;
    
    return;
}

- (BOOL)makeVideoCall:(NSString *)remoteUsername
{
    return [self makeCall:remoteUsername clientCallType:MBVoIPCallTypeVideo];
}

- (BOOL)makeAudioOnlyCall:(NSString *)remoteUsername
{
    return [self makeCall:remoteUsername clientCallType:MBVoIPCallTypeAudio];
}

- (BOOL)makeCall:(NSString *)remoteUsername clientCallType:(MBVoIPCallType)callType
{
    MB_Status status;
    string remoteUsernameUTF8String = [remoteUsername UTF8String];
    MBClientCallType clientCallType = MBClientCallTypeNone;
    switch (callType) {
        case MBVoIPCallTypeAudio:
            clientCallType = MBClientCallTypeAudio;
            break;
        case MBVoIPCallTypeVideo:
            clientCallType = MBClientCallTypeVideo;
            break;
        default:
            break;
    }
    status = self.voipClient->CallMake(remoteUsernameUTF8String, clientCallType);
    return (status == MB_STATUS_OK);
}

- (void)dropCall:(int)callId
{
    self.voipClient->CallDrop(callId);
    
    return;
}

- (void)dropCalls
{
    CMediaEngineWrapper *mediaEngineWrapper = [MBMediaEngineManager sharedInstance].mediaEngineWrapper;
    CMBVoipClient *voipClient = self.voipClient;
    int lastCallId = -1;
    for (int i = 0; i < MB_TOTAL_CHANNEL_NUM; i++) {
        int callId = mediaEngineWrapper->channels[i].callid;
        if (callId > -1 && lastCallId != callId) {
            lastCallId = callId;
            voipClient->CallDrop(callId);
        }
    }
    
    return;
}

- (BOOL)rejectCall:(int)callId code:(unsigned int)code
{
    CMBVoipClient *voipClient = self.voipClient;
    MB_Status status = voipClient->CallReject(callId, code);
    return (status == MB_STATUS_OK);
}

- (BOOL)rejectCall:(int)callId
{
    return [self rejectCall:callId code:486];
}

- (BOOL)answerCall:(int)callId clientCallType:(MBVoIPCallType)callType
{
    CMBVoipClient *voipClient = self.voipClient;
    MBClientCallType clientCallType = MBClientCallTypeNone;
    switch (callType) {
        case MBVoIPCallTypeAudio:
            clientCallType = MBClientCallTypeAudio;
            break;
        case MBVoIPCallTypeVideo:
            clientCallType = MBClientCallTypeVideo;
            break;
        default:
            break;
    }

    MB_Status status = voipClient->CallAnswer(callId, clientCallType);
    return (status == MB_STATUS_OK);
}

- (BOOL)sendMessage:(NSString *)message to:(NSString *)to
{
    MBMessageSend *messageSend = new MBMessageSend;
    messageSend->receiver = [to UTF8String];
    messageSend->content = [message UTF8String];
    messageSend->senderid = 0;
    messageSend->receiverid = 0;
    messageSend->type = MSG_TEXT;
    CMBVoipClient *voipClient = self.voipClient;
    MB_Status status = voipClient->SendPagerMessage(*messageSend);
    delete messageSend;
    return (status == MB_STATUS_OK);
}

#pragma mark - network

- (NSString *)localIPAddress
{
    NSString *result = [NSString string];
    
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *wifiAddress = nil;
    NSString *cellAddress = nil;
    
    if(!getifaddrs(&interfaces)) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            sa_family_t sa_type = temp_addr->ifa_addr->sa_family;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(sa_type == AF_INET || sa_type == AF_INET6) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *type = nil;
                if(sa_type == AF_INET)
                {
                    const struct sockaddr_in *addr = (const struct sockaddr_in*)temp_addr->ifa_addr;
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN))
                        type = IP_ADDR_IPv4;
                }
                else
                {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)temp_addr->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN))
                        type = IP_ADDR_IPv6;
                }
                if(type)
                {
                    if([name isEqualToString:IOS_WIFI])
                        wifiAddress = [NSString stringWithUTF8String:addrBuf]; // wifi
                    else if([name isEqualToString:IOS_CELLULAR])
                        cellAddress = [NSString stringWithUTF8String:addrBuf]; // cellular
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
        freeifaddrs(interfaces);
    }
    
    if ([wifiAddress isKindOfClass:[NSString class]]) {
        result = wifiAddress;
    }
    else if ([cellAddress isKindOfClass:[NSString class]]) {
        result = cellAddress;
    }
    
    return result;
}

- (NSString *)remoteIPAddress:(NSString*)hostName {
    Boolean result;
    CFHostRef hostRef;
    CFArrayRef addresses;
    NSString *ipAddress = nil;
    hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostName);
    result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL);
    if (result == TRUE) {
        addresses = CFHostGetAddressing(hostRef, &result);
        for(int i = 0; i < CFArrayGetCount(addresses); i++) {
            struct sockaddr* addr;
            CFDataRef saData = (CFDataRef)CFArrayGetValueAtIndex(addresses, i);
            addr = (struct sockaddr*)CFDataGetBytePtr(saData);
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr->sa_family == AF_INET || addr->sa_family == AF_INET6) {
                bool bFind = false;
                if(addr->sa_family == AF_INET)
                {
                    const struct sockaddr_in *addr = (const struct sockaddr_in*)CFDataGetBytePtr(saData);
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN))
                        bFind = true;
                }
                else
                {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)CFDataGetBytePtr(saData);
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN))
                        bFind = true;
                }
                if(bFind)
                {
                    ipAddress = [NSString stringWithUTF8String:addrBuf];
                    NSLog(@"Get ipAddress=%@", ipAddress);
                    break;
                }
            }
        }
    }
    return ipAddress;
}
@end
