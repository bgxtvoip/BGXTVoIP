#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import <MBVoIP/MBVoIP.h>

#include "MediaEngineWrapper.h"
#include "MediaEngineWrapperSetting.h"

#import "VoipClientManager.h"

#import "TextFieldTableViewCell.h"
#import "PickerViewTableViewCell.h"

@interface SettingsViewController : UITableViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    CMediaEngineWrapper *mediaEngineWrapper;
    CMediaEngineWrapperSetting *mediaEngineWrapperSetting;
}

// input accessory
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UIBarButtonItem *doneBarButtonItem;
// navigation
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;
// cells
@property (strong, nonatomic) IBOutlet TextFieldTableViewCell *displaynameCell;
@property (strong, nonatomic) IBOutlet TextFieldTableViewCell *usernameCell;
@property (strong, nonatomic) IBOutlet TextFieldTableViewCell *passwordCell;
@property (strong, nonatomic) IBOutlet TextFieldTableViewCell *serverIPCell;
@property (strong, nonatomic) IBOutlet TextFieldTableViewCell *serverPortCell;
@property (strong, nonatomic) IBOutlet TextFieldTableViewCell *localPortCell;
@property (strong, nonatomic) IBOutlet UISwitch *FECAudioSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *FECVideoSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *AECSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *AGCSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *NRSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *G711Switch;
@property (strong, nonatomic) IBOutlet UISwitch *G723Switch;
@property (strong, nonatomic) IBOutlet UISwitch *G729Switch;
@property (strong, nonatomic) IBOutlet UISwitch *AMRSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *AMRWBSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *GSMSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *iLBCSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *SILKSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *AACSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *G722Switch;
@property (strong, nonatomic) IBOutlet PickerViewTableViewCell *bitrateCell;
@property (strong, nonatomic) IBOutlet PickerViewTableViewCell *resolutionCell;
@property (strong, nonatomic) IBOutlet UISwitch *H263Switch;
@property (strong, nonatomic) IBOutlet UISwitch *H264Switch;
// data source
@property (strong, nonatomic) NSArray *bitrates;
@property (strong, nonatomic) NSArray *resolutions;

@end
