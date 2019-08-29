#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "MediaEngineWrapper.h"
#import <MBVoIP/MBVoIP.h>
#import "MBMediaEngineDelegate.h"

@interface MBMediaEngineManager : NSObject <MBMediaEngineDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

// core
@property (readonly, nonatomic) CMediaEngineWrapper *mediaEngineWrapper;
@property (readonly, nonatomic) CMediaEngineWrapperSetting *mediaEngineWrapperSetting;
@property (readonly, nonatomic) MBVideoInDevice *videoInDevice;
// control
@property (readonly, nonatomic) AVCaptureSession *captureSession;
@property (readonly, nonatomic) CAEAGLLayer *remoteLayer;
// delegate
@property (assign, nonatomic) id <MBMediaEngineDelegate> delegate;

#pragma mark - singleton
+ (MBMediaEngineManager *)sharedInstance;
#pragma mark - configuration
- (NSMutableDictionary *)defaultConfiguration;
- (void)commitConfiguration:(NSMutableDictionary *)configuration;

@end

// Configuration
extern NSString * const kMBMediaEngineUserDefaultsConfigurationKey;
/// Audio
extern NSString * const kMBMediaEngineConfigurationAudioCodecTypeKey;
extern NSString * const kMBMediaEngineConfigurationAudioAECKey;
extern NSString * const kMBMediaEngineConfigurationAudioAGCKey;
extern NSString * const kMBMediaEngineConfigurationAudioDenoiserKey;
extern NSString * const kMBMediaEngineConfigurationAudioMicGainBeforeAECVolumeKey;
extern NSString * const kMBMediaEngineConfigurationAudioMicGainAfterAECVolumeKey;
extern NSString * const kMBMediaEngineConfigurationAudioVolumeKey;
/// Video
extern NSString * const kMBMediaEngineConfigurationVideoCodecTypeKey;
extern NSString * const kMBMediaEngineConfigurationVideoResolutionKey;
extern NSString * const kMBMediaEngineConfigurationVideoBitrateKey;
extern NSString * const kMBMediaEngineConfigurationVideoFramerateKey;
extern NSString * const kMBMediaEngineConfigurationVideoIframeRequestKey;
extern NSString * const kMBMediaEngineConfigurationVideoIframeIntervalKey;
/// Transport
extern NSString * const kMBMediaEngineConfigurationTransportSRTPEnableKey;
extern NSString * const kMBMediaEngineConfigurationTransportExternalSocketEnableKey;
extern NSString * const kMBMediaEngineConfigurationTransportExternalSocketTypeKey;
extern NSString * const kMBMediaEngineConfigurationTransportExternalSocketRoleKey;