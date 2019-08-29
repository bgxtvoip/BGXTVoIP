#import "MBMediaEngineManager.h"
#import <MBVoIP/MBVoIP.h>
#import "MBVoIPDelegate.h"

using namespace voipclient;

@interface MBVoIPManager : NSObject <MBMediaEngineDelegate, MBVoIPDelegate>

@property (assign, nonatomic) BOOL isRestart;
@property (readonly, nonatomic) BOOL isStarted;
@property (readonly, nonatomic) BOOL isRegistered;
@property (readonly, nonatomic) NSInteger callCount;
@property (readonly, nonatomic) BOOL isVideo;
@property (readonly, nonatomic) BOOL isCalling;

#pragma mark - singleton
+ (MBVoIPManager *)sharedInstance;
#pragma mark - configuration
- (NSMutableDictionary *)defaultConfiguration;
- (void)commitConfiguration:(NSMutableDictionary *)configuration;
#pragma mark - service
- (void)addDelegate:(id <MBVoIPDelegate>)delegate;
- (void)removeDelegate:(id)delegate;
- (BOOL)start:(NSError **)error;
- (void)stop;
- (BOOL)makeVideoCall:(NSString *)remoteUsername;
- (BOOL)makeAudioOnlyCall:(NSString *)remoteUsername;
- (BOOL)makeCall:(NSString *)remoteUsername clientCallType:(MBVoIPCallType)callType;
- (void)dropCall:(int)callId;
- (void)dropCalls;
- (BOOL)rejectCall:(int)callId code:(unsigned int)code;
- (BOOL)rejectCall:(int)callId;
- (BOOL)answerCall:(int)callId clientCallType:(MBVoIPCallType)callType;
- (BOOL)sendMessage:(NSString *)message to:(NSString *)to;
#pragma mark - network
- (NSString *)localIPAddress;
- (NSString *)remoteIPAddress:(NSString*)hostName;

@end

// Configuration
extern NSString * const kMBVoIPUserDefaultsConfigurationKey;
/// VoIP
extern NSString * const kMBVoIPConfigurationUsernameKey;
extern NSString * const kMBVoIPConfigurationPasswordKey;
extern NSString * const kMBVoIPConfigurationRegisterIPKey;
extern NSString * const kMBVoIPConfigurationRegisterPortKey;
extern NSString * const kMBVoIPConfigurationLocalIPKey;
extern NSString * const kMBVoIPConfigurationLocalPortKey;
extern NSString * const kMBVoIPConfigurationDisplayNameKey;
extern NSString * const kMBVoIPConfigurationAudioCodecEnableG711AKey;
extern NSString * const kMBVoIPConfigurationAudioCodecEnableG711UKey;
extern NSString * const kMBVoIPConfigurationAudioCodecEnableG729Key;
extern NSString * const kMBVoIPConfigurationAudioCodecEnableG723Key;
extern NSString * const kMBVoIPConfigurationAudioCodecEnableAMRKey;
extern NSString * const kMBVoIPConfigurationAudioCodecEnableAMRWBKey;
extern NSString * const kMBVoIPConfigurationAudioCodecEnableAACKey;
extern NSString * const kMBVoIPConfigurationAudioCodecEnableiLBCKey;
extern NSString * const kMBVoIPConfigurationAudioCodecEnableSILKKey;
extern NSString * const kMBVoIPConfigurationAudioCodecEnableGSMKey;
extern NSString * const kMBVoIPConfigurationAudioCodecEnableG722Key;
extern NSString * const kMBVoIPConfigurationAudioCodecEnableFECKey;
extern NSString * const kMBVoIPConfigurationAudioCodecEnableKeysKey;
extern NSString * const kMBVoIPConfigurationVideoCodecEnableFECKey;
//extern NSString * const kMBVoIPConfigurationVideoCodecEnableH263Key;
extern NSString * const kMBVoIPConfigurationVideoCodecEnableH264Key;
extern NSString * const kMBVoIPConfigurationVideoCodecEnableKeysKey;
/// Audio
extern NSString * const kMBVoIPConfigurationAudioAECKey;
extern NSString * const kMBVoIPConfigurationAudioMicGainBeforeAECVolumeKey;
extern NSString * const kMBVoIPConfigurationAudioMicGainAfterAECVolumeKey;
extern NSString * const kMBVoIPConfigurationAudioAGCKey;
extern NSString * const kMBVoIPConfigurationAudioDenoiserKey;
extern NSString * const kMBVoIPConfigurationAudioVolumeKey;
/// Video
extern NSString * const kMBVoIPConfigurationVideoResolutionKey;
extern NSString * const kMBVoIPConfigurationVideoBitrateKey;
extern NSString * const kMBVoIPConfigurationVideoFramerateKey;
extern NSString * const kMBVoIPConfigurationVideoIframeRequestKey;
extern NSString * const kMBVoIPConfigurationVideoIframeIntervalKey;