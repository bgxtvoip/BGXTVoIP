#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioConferenceViewController : UIViewController

// Views

@property (strong, nonatomic) IBOutlet UIButton *micMuteButton;
@property (strong, nonatomic) IBOutlet UIButton *powerButton;

@property (strong, nonatomic) IBOutlet UIView *menuOpenView;
@property (strong, nonatomic) IBOutlet UIButton *menuArrowCloseButton;

@property (strong, nonatomic) IBOutlet UIButton *menuSpeakerButton;

@property (strong, nonatomic) IBOutlet UIView *menuCloseView;
@property (strong, nonatomic) IBOutlet UIButton *menuArrowOpenButton;


@end
