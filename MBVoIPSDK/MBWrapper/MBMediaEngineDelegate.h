#ifndef MBMediaEngineDelegate_h
#define MBMediaEngineDelegate_h

#import <MBVoIP/MBVoIP.h>
class MBVideoInDevice;
class MBVideoOutDevice;

@protocol MBMediaEngineDelegate <NSObject>

@optional

// IMediaEngine_internal_videoInDevice
- (BOOL)createVideoInDevice:(MBVideoInDevice *)videoInDevice id:(int)id;
- (BOOL)openVideoInDevice:(MBVideoInDevice *)videoInDevice params:(IMediaEngine_VideoParams *)params receiver:(void *)receiver;
- (BOOL)startVideoInDevice:(MBVideoInDevice *)videoInDevice params:(IMediaEngine_VideoParams *)params;
- (void)stopVideoInDevice:(MBVideoInDevice *)videoInDevice params:(IMediaEngine_VideoParams *)params;
- (void)closeVideoInDevice:(MBVideoInDevice *)videoInDevice params:(IMediaEngine_VideoParams *)params;
- (void)terminateVideoInDevice:(MBVideoInDevice *)videoInDevice params:(IMediaEngine_VideoParams *)params;
// IMediaEngine_internal_videoOutDevice
- (BOOL)createVideoOutDevice:(MBVideoOutDevice *)videoOutDevice id:(int)id;
- (BOOL)openVideoOutDevice:(MBVideoOutDevice *)videoOutDevice params:(IMediaEngine_VideoParams *)params receiver:(void *)receiver;
- (BOOL)startVideoOutDevice:(MBVideoOutDevice *)videoOutDevice params:(IMediaEngine_VideoParams *)params;
- (void)stopVideoOutDevice:(MBVideoOutDevice *)videoOutDevice params:(IMediaEngine_VideoParams *)params;
- (void)closeVideoOutDevice:(MBVideoOutDevice *)videoOutDevice params:(IMediaEngine_VideoParams *)params;
- (void)displayVideoOutDevice:(MBVideoOutDevice *)videoOutDevice params:(IMediaEngine_VideoParams *)params data:(char *)data length:(int)length videoFrame:(MBVideoFrame *)videoFrame;
- (void)terminateVideoOutDevice;
// IMediaEngineEvent
- (void)nErrorCb:(MediaEngine_ErrorCodes)errorCodes value:(int)value errorReason:(char *)errorReason channelId:(int)channelId;
- (void)notify_require_fastupdate:(int)channelId;

@end

#endif
