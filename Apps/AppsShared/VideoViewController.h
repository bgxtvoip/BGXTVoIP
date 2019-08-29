#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import <MBVoIP/MBVoIP.h>
#import "MediaEngineWrapper.h"
#import "MediaEngineWrapperSetting.h"

#import "VideoGLView.h"

@interface VideoViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, MBDisplayDelegate> {
    CMediaEngineWrapper *mediaEngineWrapper;
    CMediaEngineWrapperSetting *mediaEngineWrapperSetting;
    
    void *_remoteVideoData;
}

@property (strong, nonatomic) IBOutlet VideoGLView *remoteView;
@property (assign, nonatomic) CGSize currentRemoteVideoSize;
@property (strong, nonatomic) IBOutlet UIView *localView;

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDevice *backCaptureDevice;
@property (strong, nonatomic) AVCaptureDevice *frontCaptureDevice;
@property (strong, nonatomic) NSString *sessionPreset;

@end