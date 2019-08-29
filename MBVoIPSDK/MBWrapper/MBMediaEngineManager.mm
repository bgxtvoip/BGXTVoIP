#import "MBMediaEngineManager.h"
#import "MBLayer.h"

// Configuration
NSString * const kMBMediaEngineUserDefaultsConfigurationKey = @"mb_media_engine_configuration";
/// Audio
NSString * const kMBMediaEngineConfigurationAudioCodecTypeKey = @"media_engine_audio_codec_type";
NSString * const kMBMediaEngineConfigurationAudioAECKey = @"media_engine_audio_aec";
NSString * const kMBMediaEngineConfigurationAudioAGCKey = @"media_engine_audio_agc";
NSString * const kMBMediaEngineConfigurationAudioDenoiserKey = @"media_engine_audio_denoiser";
NSString * const kMBMediaEngineConfigurationAudioMicGainBeforeAECVolumeKey = @"media_engine_audio_mic_gain_before_aec_volume";
NSString * const kMBMediaEngineConfigurationAudioMicGainAfterAECVolumeKey = @"media_engine_audio_mic_gain_after_aec_volume";
NSString * const kMBMediaEngineConfigurationAudioVolumeKey = @"media_engine_audio_volume";
/// Video
NSString * const kMBMediaEngineConfigurationVideoCodecTypeKey = @"media_engine_video_codec_type";
NSString * const kMBMediaEngineConfigurationVideoResolutionKey = @"media_engine_video_resolution";
NSString * const kMBMediaEngineConfigurationVideoBitrateKey = @"media_engine_video_bitrate";
NSString * const kMBMediaEngineConfigurationVideoFramerateKey = @"media_engine_video_framerate";
NSString * const kMBMediaEngineConfigurationVideoIframeRequestKey = @"media_engine_video_iframe_request";
NSString * const kMBMediaEngineConfigurationVideoIframeIntervalKey = @"media_engine_video_iframe_interval";
/// Transport
NSString * const kMBMediaEngineConfigurationTransportSRTPEnableKey = @"media_engine_transport_srtp_enable";
NSString * const kMBMediaEngineConfigurationTransportExternalSocketEnableKey = @"media_engine_transport_external_socket_enable";
NSString * const kMBMediaEngineConfigurationTransportExternalSocketTypeKey = @"media_engine_transport_external_socket_type";
NSString * const kMBMediaEngineConfigurationTransportExternalSocketRoleKey = @"media_engine_transport_external_socket_role";

@interface MBMediaEngineManager ()

// core
@property (assign, nonatomic) CMediaEngineWrapper *mediaEngineWrapper;
@property (assign, nonatomic) CMediaEngineWrapperSetting *mediaEngineWrapperSetting;
@property (assign, nonatomic) MBVideoInDevice *videoInDevice;
// control
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) CAEAGLLayer *remoteLayer;

@end

@implementation MBMediaEngineManager

#pragma mark - singleton

+ (MBMediaEngineManager *)sharedInstance
{
    static MBMediaEngineManager *s_instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[self alloc] init];
    });
    
    return s_instance;
}

#pragma mark - NSObject

- (void)dealloc
{
    self.remoteLayer = nil;
    if ([self.captureSession isRunning]) {
        [self.captureSession stopRunning];
    }
    self.captureSession = nil;
    self.videoInDevice = NULL;
    if (self.mediaEngineWrapperSetting != NULL) {
        self.mediaEngineWrapperSetting->deleteInstance();
        self.mediaEngineWrapperSetting = NULL;
    }
    if (self.mediaEngineWrapper != NULL) {
        self.mediaEngineWrapper->DeleteEngine();
        CMediaEngineWrapper::deleteEngineWrapperInstance();
        self.mediaEngineWrapper = NULL;
    }
    
    return;
}

- (id)init
{
    self = [super init];
    if (self) {
        CMediaEngineWrapper *mediaEngineWrapper = NULL;
        CMediaEngineWrapperSetting *mediaEngineWrapperSetting = NULL;
        @try {
            mediaEngineWrapper = CMediaEngineWrapper::getEngineWrapperInstance();
            if (mediaEngineWrapper == NULL) {
                NSString *reason = [NSString stringWithFormat:@"failed to get a media engine wrapper."];
                @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
            }
            mediaEngineWrapper->CreateEngine();
            mediaEngineWrapper->m_mediaSetting->setLogEnable(false);
            mediaEngineWrapper->delegate = self;
            
            mediaEngineWrapperSetting = CMediaEngineWrapperSetting::getInstance();
            
            self.mediaEngineWrapper = mediaEngineWrapper;
            self.mediaEngineWrapperSetting = mediaEngineWrapperSetting;
        }
        @catch (NSException *exception) {
            NSLog(@"exception : %@", exception.reason);
            if (mediaEngineWrapperSetting != NULL) {
                mediaEngineWrapperSetting->deleteInstance();
            }
            if (mediaEngineWrapper != NULL) {
                mediaEngineWrapper->delegate = nil;
                mediaEngineWrapper->DeleteEngine();
                CMediaEngineWrapper::deleteEngineWrapperInstance();
            }
            self = nil;
        }
        @finally {
        }
    }
    
    return self;
}

#pragma mark - MBMediaEngineDelegate

// IMediaEngine_internal_videoInDevice

- (BOOL)createVideoInDevice:(MBVideoInDevice *)videoInDevice id:(int)id
{
    BOOL result = NO;
    if ([[self.delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(createVideoInDevice:id:)]) {
            return [self.delegate createVideoInDevice:videoInDevice id:id];
        }
    }
    
    result = YES;
    
    return result;
}

- (BOOL)openVideoInDevice:(MBVideoInDevice *)videoInDevice params:(IMediaEngine_VideoParams *)params receiver:(void *)receiver
{
    BOOL result = NO;
    if ([[self.delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(openVideoInDevice:params:receiver:)]) {
            return [self.delegate openVideoInDevice:videoInDevice params:params receiver:receiver];
        }
    }
    
    @try {
        AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        // Set camera device when start time.
        NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for(AVCaptureDevice *dev in devices)
        {
            if([dev position] == AVCaptureDevicePositionFront) { // Check front camera.
                device = dev;
                break;
            }
        }
        AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        if (![captureSession canAddInput:captureDeviceInput]) {
            NSString *reason = [NSString stringWithFormat:@"failed to get a capture device input."];
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
        [captureSession addInput:captureDeviceInput];
        
        AVCaptureVideoDataOutput *captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        NSMutableDictionary *videoSettings = [NSMutableDictionary dictionary];
        [videoSettings setValue:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        captureVideoDataOutput.videoSettings = videoSettings;
        captureVideoDataOutput.alwaysDiscardsLateVideoFrames = YES;
        if (![captureSession canAddOutput:captureVideoDataOutput]) {
            NSString *reason = [NSString stringWithFormat:@"failed to add a capture video data output."];
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
        [captureSession addOutput:captureVideoDataOutput];
        
        dispatch_queue_t queue = dispatch_queue_create("camera_queue", NULL);
        [captureVideoDataOutput setSampleBufferDelegate:self queue:queue];
        
        NSString *sessionPreset = nil;
        if (params->iWidth == 352 && params->iHeight == 288) {
            sessionPreset = AVCaptureSessionPreset352x288;
        }
        else if (params->iWidth == 640 && params->iHeight == 480) {
            sessionPreset = AVCaptureSessionPreset640x480;
        }
        else if (params->iWidth == 1280 && params->iHeight == 720) {
            sessionPreset = AVCaptureSessionPreset1280x720;
        }
        else if (params->iWidth == 1920 && params->iHeight == 1080) {
            sessionPreset = AVCaptureSessionPreset1920x1080;
        }
        if (![sessionPreset isKindOfClass:[NSString class]]) {
            NSString *reason = [NSString stringWithFormat:@"unsupported resolution."];
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
        if (![captureSession canSetSessionPreset:sessionPreset]) {
            NSString *reason = [NSString stringWithFormat:@"failed to set a capture session preset."];
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
        [captureSession setSessionPreset:sessionPreset];
        
        self.videoInDevice = videoInDevice;
        self.captureSession = captureSession;
        
        result = YES;
    }
    @catch (NSException *exception) {
        NSLog(@"exception : %@", exception.reason);
    }
    @finally {
    }
    
    return result;
}

- (BOOL)startVideoInDevice:(MBVideoInDevice *)videoInDevice params:(IMediaEngine_VideoParams *)params
{
    BOOL result = NO;
    if ([[self.delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(startVideoInDevice:params:)]) {
            return [self.delegate startVideoInDevice:videoInDevice params:params];
        }
    }
    
    @try {
        [self.captureSession startRunning];
        
        result = YES;
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    return result;
}

- (void)stopVideoInDevice:(MBVideoInDevice *)videoInDevice params:(IMediaEngine_VideoParams *)params
{
    if ([[self.delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(stopVideoInDevice:params:)]) {
            return [self.delegate stopVideoInDevice:videoInDevice params:params];
        }
    }
    
    if ([self.captureSession isRunning]) {
        [self.captureSession stopRunning];
    }
    
    return;
}

- (void)closeVideoInDevice:(MBVideoInDevice *)videoInDevice params:(IMediaEngine_VideoParams *)params
{
    if ([[self.delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(closeVideoInDevice:params:)]) {
            return [self.delegate closeVideoInDevice:videoInDevice params:params];
        }
    }
    
    if ([self.captureSession isRunning]) {
        [self.captureSession stopRunning];
    }
    self.captureSession = nil;
    self.videoInDevice = NULL;
    
    return;
}

- (void)terminateVideoInDevice:(MBVideoInDevice *)videoInDevice params:(IMediaEngine_VideoParams *)params
{
    if ([[self.delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(terminateVideoInDevice:params:)]) {
            return [self.delegate terminateVideoInDevice:videoInDevice params:params];
        }
    }
    
    return;
}

// IMediaEngine_internal_videoOutDevice

- (BOOL)createVideoOutDevice:(MBVideoOutDevice *)videoOutDevice id:(int)id
{
    BOOL result = NO;
    if ([[self.delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(createVideoOutDevice:id:)]) {
            return [self.delegate createVideoOutDevice:videoOutDevice id:id];
        }
    }
    
    result = YES;
    
    return result;
}

- (BOOL)openVideoOutDevice:(MBVideoOutDevice *)videoOutDevice params:(IMediaEngine_VideoParams *)params receiver:(void *)receiver
{
    BOOL result = NO;
    if ([[self.delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(openVideoOutDevice:params:receiver:)]) {
            return [self.delegate openVideoOutDevice:videoOutDevice params:params receiver:receiver];
        }
    }
    
    @try {
        MBLayer *layer = [MBLayer layer];
        if (![layer isKindOfClass:[MBLayer class]]) {
            NSString *reason = [NSString stringWithFormat:@"failed to get a layer for video output."];
            @throw [NSException exceptionWithName:NSGenericException reason:reason userInfo:nil];
        }
        self.remoteLayer = layer;
        
        result = YES;
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    return result;
}

- (BOOL)startVideoOutDevice:(MBVideoOutDevice *)videoOutDevice params:(IMediaEngine_VideoParams *)params
{
    BOOL result = NO;
    if ([[self.delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(startVideoOutDevice:params:)]) {
            return [self.delegate startVideoOutDevice:videoOutDevice params:params];
        }
    }
    
    result = ([self.remoteLayer isKindOfClass:[CALayer class]]);
    
    return result;
}

- (void)stopVideoOutDevice:(MBVideoOutDevice *)videoOutDevice params:(IMediaEngine_VideoParams *)params
{
    if ([[self.delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(stopVideoOutDevice:params:)]) {
            return [self.delegate stopVideoOutDevice:videoOutDevice params:params];
        }
    }
    
    return;
}

- (void)closeVideoOutDevice:(MBVideoOutDevice *)videoOutDevice params:(IMediaEngine_VideoParams *)params
{
    if ([[self.delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(closeVideoOutDevice:params:)]) {
            return [self.delegate closeVideoOutDevice:videoOutDevice params:params];
        }
    }
    
    self.remoteLayer = nil;
    
    return;
}

- (void)displayVideoOutDevice:(MBVideoOutDevice *)videoOutDevice params:(IMediaEngine_VideoParams *)params data:(char *)data length:(int)length videoFrame:(MBVideoFrame *)videoFrame
{
    if ([[self.delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(displayVideoOutDevice:params:data:length:videoFrame:)]) {
            return [self.delegate displayVideoOutDevice:videoOutDevice params:params data:data length:length videoFrame:videoFrame];
        }
    }
    
    if ([self.remoteLayer isKindOfClass:[MBLayer class]]) {
        [(MBLayer *)(self.remoteLayer) render:(UInt8 *)data width:(NSUInteger)(params->iWidth) height:(NSUInteger)(params->iHeight) error:nil];
    }
    
    return;
}

- (void)terminateVideoOutDevice
{
    if ([[self.delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(terminateVideoOutDevice)]) {
            return [self.delegate terminateVideoOutDevice];
        }
    }
    
    return;
}

// IMediaEngineEvent

- (void)nErrorCb:(MediaEngine_ErrorCodes)errorCodes value:(int)value errorReason:(char *)errorReason channelId:(int)channelId
{
    if ([[self.delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(nErrorCb:value:errorReason:channelId:)]) {
            return [self.delegate nErrorCb:errorCodes value:value errorReason:errorReason channelId:channelId];
        }
    }
    
    return;
}

- (void)notify_require_fastupdate:(int)channelId
{
    if ([[self.delegate class] conformsToProtocol:@protocol(MBMediaEngineDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(notify_require_fastupdate:)]) {
            return [self.delegate notify_require_fastupdate:channelId];
        }
    }
    
    return;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(imageBufferRef, 0);
    
    size_t width = CVPixelBufferGetWidth(imageBufferRef);
    size_t height = CVPixelBufferGetHeight(imageBufferRef);
    unsigned char *buffer = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(imageBufferRef, 0);
    if (self.videoInDevice != NULL) {
        self.videoInDevice->SendRawVideoData(buffer, (int)width, (int)height);
    }
    
    CVPixelBufferUnlockBaseAddress(imageBufferRef, 0);
    
    return;
}

#pragma mark - configuration

- (NSMutableDictionary *)defaultConfiguration
{
    NSMutableDictionary *configuration = [NSMutableDictionary dictionary];
    
    // Audio
    [configuration setValue:[NSNumber numberWithInt:(int)MEDIA_CODEC_G722] forKey:kMBMediaEngineConfigurationAudioCodecTypeKey];
    [configuration setValue:[NSNumber numberWithInt:0] forKey:kMBMediaEngineConfigurationAudioAECKey];
    [configuration setValue:[NSNumber numberWithInt:0] forKey:kMBMediaEngineConfigurationAudioAGCKey];
    [configuration setValue:[NSNumber numberWithInt:0] forKey:kMBMediaEngineConfigurationAudioDenoiserKey];
    [configuration setValue:[NSNumber numberWithFloat:1.0f] forKey:kMBMediaEngineConfigurationAudioMicGainBeforeAECVolumeKey];
    [configuration setValue:[NSNumber numberWithFloat:1.0f] forKey:kMBMediaEngineConfigurationAudioMicGainAfterAECVolumeKey];
    [configuration setValue:[NSNumber numberWithFloat:2.0f] forKey:kMBMediaEngineConfigurationAudioVolumeKey];
    // Video
    [configuration setValue:[NSNumber numberWithInt:(int)MEDIA_CODEC_H264] forKey:kMBMediaEngineConfigurationVideoCodecTypeKey];
    [configuration setValue:[NSNumber numberWithInt:(int)MEDIA_VIDEO_SIZE_VGA] forKey:kMBMediaEngineConfigurationVideoResolutionKey];
    [configuration setValue:[NSNumber numberWithInt:512000] forKey:kMBMediaEngineConfigurationVideoBitrateKey];
    [configuration setValue:[NSNumber numberWithInt:15] forKey:kMBMediaEngineConfigurationVideoFramerateKey];
    [configuration setValue:[NSNumber numberWithInt:1] forKey:kMBMediaEngineConfigurationVideoIframeRequestKey];
    [configuration setValue:[NSNumber numberWithInt:3] forKey:kMBMediaEngineConfigurationVideoIframeIntervalKey];
    // Transport
    [configuration setValue:[NSNumber numberWithBool:NO] forKey:kMBMediaEngineConfigurationTransportSRTPEnableKey];
    [configuration setValue:[NSNumber numberWithBool:NO] forKey:kMBMediaEngineConfigurationTransportExternalSocketEnableKey];
    [configuration setValue:[NSNumber numberWithBool:NO] forKey:kMBMediaEngineConfigurationTransportExternalSocketTypeKey];
    [configuration setValue:[NSNumber numberWithBool:NO] forKey:kMBMediaEngineConfigurationTransportExternalSocketRoleKey];
    
    return configuration;
}

- (void)commitConfiguration:(NSMutableDictionary *)configuration
{
    CMediaEngineWrapper *mediaEngineWrapper = self.mediaEngineWrapper;
    CMediaEngineWrapperSetting *mediaEngineWrapperSetting = self.mediaEngineWrapperSetting;
    id value = nil;
    // Audio
    value = [configuration valueForKey:kMBMediaEngineConfigurationAudioCodecTypeKey];
    if ([value isKindOfClass:[NSNumber class]]) {
        MediaCodecType audioCodecType = (MediaCodecType)[value intValue];
        // default is MEDIA_CODEC_G722
        switch (audioCodecType) {
            case MEDIA_CODEC_G711_PCMU:
            case MEDIA_CODEC_G711_PCMA:
            case MEDIA_CODEC_G729:
            case MEDIA_CODEC_G7231:
            case MEDIA_CODEC_AMR_NB:
            case MEDIA_CODEC_AMR_WB:
            case MEDIA_CODEC_AAC:
            case MEDIA_CODEC_PCM_WB:
            case MEDIA_CODEC_iLBC:
            case MEDIA_CODEC_SILK:
            case MEDIA_CODEC_GSM:
            case MEDIA_CODEC_G722:
                mediaEngineWrapperSetting->m_codecType = audioCodecType;
                break;
                
            default:
                // failed
                break;
        }
    }
    value = [configuration valueForKey:kMBMediaEngineConfigurationAudioAECKey];
    if ([value isKindOfClass:[NSNumber class]]) {
        int audioAEC = [value intValue];
        // 0:None, 1:Normal, 2:Good
        if (audioAEC < 0) {
            audioAEC = 0;
        }
        else if (audioAEC > 2) {
            audioAEC = 2;
        }
        mediaEngineWrapperSetting->setAECMode(audioAEC);
    }
    value = [configuration valueForKey:kMBMediaEngineConfigurationAudioAGCKey];
    if ([value isKindOfClass:[NSNumber class]]) {
        int audioAGC = [value intValue];
        // bounds is 0 to 15
        if (audioAGC < 0) {
            audioAGC = 0;
        }
        else if (audioAGC > 15) {
            audioAGC = 15;
        }
        int agcMode = 2;
        mediaEngineWrapperSetting->setAGCMode(agcMode, audioAGC);
    }
    value = [configuration valueForKey:kMBMediaEngineConfigurationAudioDenoiserKey];
    if ([value isKindOfClass:[NSNumber class]]) {
        int audioDenoiser = [value intValue];
        // bounds is 0 to 4
        if (audioDenoiser < 0) {
            audioDenoiser = 0;
        }
        else if (audioDenoiser > 4) {
            audioDenoiser = 4;
        }
        mediaEngineWrapperSetting->setNSValue(0, audioDenoiser);
    }
    value = [configuration valueForKey:kMBMediaEngineConfigurationAudioMicGainBeforeAECVolumeKey];
    if ([value isKindOfClass:[NSNumber class]]) {
        float audioMicGainBeforeAEC = [value floatValue];
        // bounds is 0 to 3
        if (audioMicGainBeforeAEC < 0.0f) {
            audioMicGainBeforeAEC = 0.0f;
        }
        else if (audioMicGainBeforeAEC > 3.0f) {
            audioMicGainBeforeAEC = 3.0f;
        }
        mediaEngineWrapperSetting->setMicrophoneGainBeforeAECVolume(audioMicGainBeforeAEC);
    }
    value = [configuration valueForKey:kMBMediaEngineConfigurationAudioMicGainAfterAECVolumeKey];
    if ([value isKindOfClass:[NSNumber class]]) {
        float audioMicGainAfterAEC = [value floatValue];
        // bounds is 0 to 3
        if (audioMicGainAfterAEC < 0.0f) {
            audioMicGainAfterAEC = 0.0f;
        }
        else if (audioMicGainAfterAEC > 3.0f) {
            audioMicGainAfterAEC = 3.0f;
        }
        mediaEngineWrapperSetting->SetMicGainAfterAECVolume(audioMicGainAfterAEC);
    }
    value = [configuration valueForKey:kMBMediaEngineConfigurationAudioVolumeKey];
    if ([value isKindOfClass:[NSNumber class]]) {
        float audioVolume = [value floatValue];
        // bounds is 0 to 3
        if (audioVolume < 0.0f) {
            audioVolume = 0.0f;
        }
        else if (audioVolume > 3.0f) {
            audioVolume = 3.0f;
        }
        mediaEngineWrapperSetting->setAudioVolume(audioVolume);
    }
    /// Audio defaults
    int audioSampleRate = 16000; // iOS raw samplerate : 16000.
    mediaEngineWrapper->m_audioDriver.setSampleRate((float)audioSampleRate);
    mediaEngineWrapperSetting->setSpeakerSampleRate(audioSampleRate, audioSampleRate);
    mediaEngineWrapperSetting->setVad(0, 1);
    mediaEngineWrapperSetting->setAudioDelayTest(0);
    mediaEngineWrapperSetting->setAudioDelayTime(40);
    // Video
    value = [configuration valueForKey:kMBMediaEngineConfigurationVideoCodecTypeKey];
    if ([value isKindOfClass:[NSNumber class]]) {
        MediaCodecType videoCodecType = (MediaCodecType)[value intValue];
        // Default is MEDIA_CODEC_H264
        switch (videoCodecType) {
            case MEDIA_CODEC_H263:
            case MEDIA_CODEC_MPEG4:
            case MEDIA_CODEC_H264:
                mediaEngineWrapperSetting->m_videoCodecType = videoCodecType;
                break;
                
            default:
                // failed
                break;
        }
    }
    MBMediaWrapperSet mediaWrapperSet = {0};
    mediaWrapperSet.size = mediaEngineWrapper->localVideoParams.size;
    mediaWrapperSet.width = mediaEngineWrapper->localVideoParams.iWidth;
    mediaWrapperSet.height = mediaEngineWrapper->localVideoParams.iHeight;
    mediaWrapperSet.bitrate = mediaEngineWrapper->localVideoParams.iTargetBitrate;
    mediaWrapperSet.framerate = mediaEngineWrapper->localVideoParams.iFrameRate;
    mediaWrapperSet.iframeinterval = mediaEngineWrapper->localVideoParams.iIFrameInterval;
    value = [configuration valueForKey:kMBMediaEngineConfigurationVideoResolutionKey];
    if ([value isKindOfClass:[NSNumber class]]) {
        MediaVideoSize videoResolution = (MediaVideoSize)[value intValue];
        switch (videoResolution) {
            case MEDIA_VIDEO_SIZE_QCIF:
                mediaEngineWrapperSetting->resolution = videoResolution;
                mediaWrapperSet.size = videoResolution;
                mediaWrapperSet.width = 176;
                mediaWrapperSet.height = 144;
                break;
            case MEDIA_VIDEO_SIZE_CIF:
                mediaEngineWrapperSetting->resolution = videoResolution;
                mediaWrapperSet.size = videoResolution;
                mediaWrapperSet.width = 352;
                mediaWrapperSet.height = 288;
                break;
            case MEDIA_VIDEO_SIZE_VGA:
                mediaEngineWrapperSetting->resolution = videoResolution;
                mediaWrapperSet.size = videoResolution;
                mediaWrapperSet.width = 640;
                mediaWrapperSet.height = 480;
                break;
            case MEDIA_VIDEO_SIZE_720P:
                mediaEngineWrapperSetting->resolution = videoResolution;
                mediaWrapperSet.size = videoResolution;
                mediaWrapperSet.width = 1280;
                mediaWrapperSet.height = 720;
                break;
            case MEDIA_VIDEO_SIZE_1080p:
                mediaEngineWrapperSetting->resolution = videoResolution;
                mediaWrapperSet.size = videoResolution;
                mediaWrapperSet.width = 1920;
                mediaWrapperSet.height = 1080;
                break;
                
            default:
                break;
        }
    }
    value = [configuration valueForKey:kMBMediaEngineConfigurationVideoBitrateKey];
    if ([value isKindOfClass:[NSNumber class]]) {
        int videoBitrate = [value intValue];
        mediaWrapperSet.bitrate = videoBitrate;
    }
    else {
        switch (mediaWrapperSet.size) {
            case MEDIA_VIDEO_SIZE_QCIF:
                mediaWrapperSet.bitrate = 256000;
                break;
            case MEDIA_VIDEO_SIZE_CIF:
                mediaWrapperSet.bitrate = 256000;
                break;
            case MEDIA_VIDEO_SIZE_VGA:
                mediaWrapperSet.bitrate = 512000;
                break;
            case MEDIA_VIDEO_SIZE_720P:
                mediaWrapperSet.bitrate = 1024000;
                break;
            case MEDIA_VIDEO_SIZE_1080p:
                mediaWrapperSet.bitrate = 2048000;
                break;
            default:
                mediaWrapperSet.bitrate = 256000;
                break;
        }
    }
    value = [configuration valueForKey:kMBMediaEngineConfigurationVideoFramerateKey];
    if ([value isKindOfClass:[NSNumber class]]) {
        int videoFramerate = [value intValue];
        mediaWrapperSet.framerate = videoFramerate;
    }
    value = [configuration valueForKey:kMBMediaEngineConfigurationVideoIframeRequestKey];
    if ([value isKindOfClass:[NSNumber class]]) {
        int videoIframeRequest = ([value intValue] * 1000);
        mediaEngineWrapperSetting->setVideoParametersInt((char *)"use_video_minimum_iframe_interval", videoIframeRequest);
    }
    value = [configuration valueForKey:kMBMediaEngineConfigurationVideoIframeIntervalKey];
    if ([value isKindOfClass:[NSNumber class]]) {
        int videoIframeInterval = [value intValue];
        mediaWrapperSet.iframeinterval = videoIframeInterval;
    }
    mediaEngineWrapper->MBSetMediaInfo(MB_LOCAL_REAL_TIME_VIDEO, &mediaWrapperSet);
    
    // Transport
//    value = [configuration valueForKey:kMBMediaEngineConfigurationTransportSRTPEnableKey];
//    if ([value isKindOfClass:[NSNumber class]]) {
//        if ([value boolValue] == YES) {
//            mediaEngineWrapper->m_IsSrtp = true;
//        }
//        else {
//            mediaEngineWrapper->m_IsSrtp = false;
//        }
//    }
//    value = [configuration valueForKey:kMBMediaEngineConfigurationTransportExternalSocketEnableKey];
//    if ([value isKindOfClass:[NSNumber class]]) {
//        if ([value boolValue] == YES) {
//            mediaEngineWrapper->bExternalTransport = true;
//        }
//        else {
//            mediaEngineWrapper->bExternalTransport = false;
//        }
//    }
//    value = [configuration valueForKey:kMBMediaEngineConfigurationTransportExternalSocketTypeKey];
//    if ([value isKindOfClass:[NSNumber class]]) {
//        if ([value boolValue] == YES) {
//            mediaEngineWrapper->m_IsTcp = true;
//        }
//        else {
//            mediaEngineWrapper->m_IsTcp = false;
//        }
//    }
//    value = [configuration valueForKey:kMBMediaEngineConfigurationTransportExternalSocketRoleKey];
//    if ([value isKindOfClass:[NSNumber class]]) {
//        if ([value boolValue] == YES) {
//            mediaEngineWrapper->m_IsServer = true;
//        }
//        else {
//            mediaEngineWrapper->m_IsServer = false;
//        }
//    }
    return;
}

@end
