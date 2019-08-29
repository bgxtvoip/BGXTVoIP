#import "AudioConferenceViewController.h"
#import "MBVoIPManager.h"
#import "AppDelegate.h"

@interface AudioConferenceViewController ()

@end

@implementation AudioConferenceViewController

#pragma mark - NSObject

- (void)dealloc {
    // NSNotification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // NSNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAudioSessionRouteNotification:) name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BOOL statusBarHidden = YES;
    if ([UIApplication sharedApplication].statusBarHidden != statusBarHidden) {
        UIStatusBarAnimation statusBarAnimation = UIStatusBarAnimationNone;
        if (animated) {
            statusBarAnimation = UIStatusBarAnimationFade;
        }
        [[UIApplication sharedApplication] setStatusBarHidden:statusBarHidden withAnimation:statusBarAnimation];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

#pragma mark - UIViewController (UIViewControllerRotation)

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.view setNeedsLayout];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - NSNotification

- (void)changeAudioSessionRouteNotification:(NSNotification *)notification {
}

#pragma mark - IBAction

- (IBAction)selector:(id)sender {
    if (sender == self.micMuteButton) { // Button
        BOOL enable = !self.micMuteButton.selected;
        if ([self updateMute:enable isInput:YES]) {
            self.micMuteButton.selected = enable;
        }
    } else if (sender == self.powerButton) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [[MBVoIPManager sharedInstance] dropCalls];
    } else if (sender == self.menuArrowCloseButton) { // Menu
        self.menuOpenView.hidden = YES;
        self.menuCloseView.hidden = NO;
    } else if (sender == self.menuSpeakerButton) {
        BOOL enable = !self.menuSpeakerButton.selected;
        if ([self updateMute:enable isInput:NO]) {
            self.menuSpeakerButton.selected = enable;
        }
    } else if (sender == self.menuArrowOpenButton) {
        self.menuOpenView.hidden = NO;
        self.menuCloseView.hidden = YES;
    }
}

- (BOOL)updateMute:(BOOL)enable isInput:(BOOL)isInput {
    BOOL result = NO;
    @try {
        CMediaEngineWrapper *mediaEngineWrapper = CMediaEngineWrapper::getEngineWrapperInstance();
        if (mediaEngineWrapper == NULL) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"failed to get a media engine." userInfo:nil];
        }
        int channelID = -1;
        MediaChannelDirection mediaChannelDirection = (isInput) ? MEDIA_CHANNEL_SENDER : MEDIA_CHANNEL_RECEIVER;
        for (int i = 0; i < MB_TOTAL_CHANNEL_NUM; i++) {
            if (mediaEngineWrapper->channels[i].id > -1 &&
                mediaEngineWrapper->channels[i].type == MEDIA_TYPE_AUDIO &&
                mediaEngineWrapper->channels[i].direction == mediaChannelDirection) {
                channelID = mediaEngineWrapper->channels[i].id;
                break;
            }
        }
        if (channelID == -1) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"failed to get a channel ID." userInfo:nil];
        }
        MbStatus status = mediaEngineWrapper->SetMute(channelID, enable);
        if (status != MB_STATUS_OK) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"failed to set a mute enable." userInfo:nil];
        }

        result = YES;
    }
    @catch (NSException *exception) {
        NSLog(@"exception : %@", exception.reason);
    }
    @finally {
    }

    return result;
}

@end
