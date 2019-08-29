#import "SettingsViewController.h"

#import "VideoViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

NSString *const kDictionaryNameKey = @"name";
NSString *const kDictionaryValueKey = @"value";

#pragma mark - lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // media engine
    mediaEngineWrapper = CMediaEngineWrapper::getEngineWrapperInstance();
    mediaEngineWrapperSetting = CMediaEngineWrapperSetting::getInstance();
    
    // cells
    NSDictionary *configuration = [VoipClientManager configuration];
    self.displaynameCell.textField.text = [configuration valueForKey:kVoipClientManagerConfigurationDisplayNameKey];
    self.usernameCell.textField.text = [configuration valueForKey:kVoipClientManagerConfigurationUsernameKey];
    self.passwordCell.textField.text = [configuration valueForKey:kVoipClientManagerConfigurationPasswordKey];
    self.serverIPCell.textField.text = [configuration valueForKey:kVoipClientManagerConfigurationRegisterIPKey];
    self.serverPortCell.textField.text = [configuration valueForKey:kVoipClientManagerConfigurationRegisterPortKey];
    self.localPortCell.textField.text = [configuration valueForKey:kVoipClientManagerConfigurationLocalPortKey];
    self.FECAudioSwitch.on = [[configuration valueForKey:kVoipClientManagerConfigurationEnableFECAudioKey] boolValue];
    self.FECVideoSwitch.on = [[configuration valueForKey:kVoipClientManagerConfigurationEnableFECVideoKey] boolValue];
    self.AECSwitch.on = [[configuration valueForKey:kVoipClientManagerConfigurationEnableAECKey] boolValue];
    self.AGCSwitch.on = [[configuration valueForKey:kVoipClientManagerConfigurationEnableAGCKey] boolValue];
    self.NRSwitch.on = [[configuration valueForKey:kVoipClientManagerConfigurationEnableNRKey] boolValue];
    self.G711Switch.on = [[configuration valueForKey:kVoipClientManagerConfigurationEnableG711Key] boolValue];
    self.G723Switch.on = [[configuration valueForKey:kVoipClientManagerConfigurationEnableG723Key] boolValue];
    self.G729Switch.on = [[configuration valueForKey:kVoipClientManagerConfigurationEnableG729Key] boolValue];
    self.AMRSwitch.on = [[configuration valueForKey:kVoipClientManagerConfigurationEnableAMRKey] boolValue];
    self.AMRWBSwitch.on = [[configuration valueForKey:kVoipClientManagerConfigurationEnableAMRWBKey] boolValue];
    self.GSMSwitch.on = [[configuration valueForKey:kVoipClientManagerConfigurationEnableGSMKey] boolValue];
    self.iLBCSwitch.on = [[configuration valueForKey:kVoipClientManagerConfigurationEnableiLBCKey] boolValue];
    self.SILKSwitch.on = [[configuration valueForKey:kVoipClientManagerConfigurationEnableSILKKey] boolValue];
    self.AACSwitch.on = [[configuration valueForKey:kVoipClientManagerConfigurationEnableAACKey] boolValue];
    self.G722Switch.on = [[configuration valueForKey:kVoipClientManagerConfigurationEnableG722Key] boolValue];
    NSUInteger index = 0;
    int bitrate = [[configuration valueForKey:kVoipClientManagerConfigurationBitrateKey] integerValue];
    for (int i = 0; i < self.bitrates.count; i++) {
        if (bitrate == [[[self.bitrates objectAtIndex:i] valueForKey:kDictionaryValueKey] intValue]) {
            index = i;
            break;
        }
    }
    if (index >= self.bitrates.count) {
        index = 0;
    }
    self.bitrateCell.contentLabel.text = [[self.bitrates objectAtIndex:index] valueForKey:kDictionaryNameKey];
    [self.bitrateCell.pickerView selectRow:index inComponent:0 animated:NO];
    
    MediaVideoSize mediaVideoSize = (MediaVideoSize)[[configuration valueForKey:kVoipClientManagerConfigurationResolutionKey] integerValue];
    for (int i = 0; i < self.resolutions.count; i++) {
        if (mediaVideoSize == (MediaVideoSize)[[[self.resolutions objectAtIndex:i] valueForKey:kDictionaryValueKey] intValue]) {
            index = i;
            break;
        }
    }
    if (index >= self.resolutions.count) {
        index = 0;
    }
    self.resolutionCell.contentLabel.text = [[self.resolutions objectAtIndex:index] valueForKey:kDictionaryNameKey];
    [self.resolutionCell.pickerView selectRow:index inComponent:0 animated:NO];
    
    self.H263Switch.on = [[configuration valueForKey:kVoipClientManagerConfigurationEnableH263Key] boolValue];
    self.H264Switch.on = [[configuration valueForKey:kVoipClientManagerConfigurationEnableH264Key] boolValue];
    
    return;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if ([indexPath isKindOfClass:[NSIndexPath class]]) {
        [self.tableView.dataSource tableView:self.tableView cellForRowAtIndexPath:indexPath];
    }
    
    [super viewWillAppear:animated];
    
    return;
}

#pragma mark - property

- (UIView *)inputAccessoryView
{
    return self.toolbar;
}

- (UIToolbar *)toolbar
{
    if (_toolbar == nil) {
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [toolbar sizeToFit];
        
        UIBarButtonItem *flexibleSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneBarButtonItem = self.doneBarButtonItem;
        NSArray *items = [NSArray arrayWithObjects:flexibleSpaceBarButtonItem, doneBarButtonItem, nil];
        [toolbar setItems:items];
        
        _toolbar = toolbar;
    }
    
    return _toolbar;
}

- (UIBarButtonItem *)doneBarButtonItem
{
    if (_doneBarButtonItem == nil) {
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selector:)];
        _doneBarButtonItem = barButtonItem;
    }
    return _doneBarButtonItem;
}

- (NSArray *)bitrates
{
    if (_bitrates == nil) {
        NSMutableArray *array = [NSMutableArray array];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:[NSString stringWithFormat:@"64000"] forKey:kDictionaryNameKey];
        [dictionary setValue:[NSNumber numberWithInt:64000] forKey:kDictionaryValueKey];
        [array addObject:dictionary];
        
        dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:[NSString stringWithFormat:@"128000"] forKey:kDictionaryNameKey];
        [dictionary setValue:[NSNumber numberWithInt:128000] forKey:kDictionaryValueKey];
        [array addObject:dictionary];
        
        dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:[NSString stringWithFormat:@"192000"] forKey:kDictionaryNameKey];
        [dictionary setValue:[NSNumber numberWithInt:192000] forKey:kDictionaryValueKey];
        [array addObject:dictionary];
        
        dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:[NSString stringWithFormat:@"256000"] forKey:kDictionaryNameKey];
        [dictionary setValue:[NSNumber numberWithInt:256000] forKey:kDictionaryValueKey];
        [array addObject:dictionary];
        
        dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:[NSString stringWithFormat:@"384000"] forKey:kDictionaryNameKey];
        [dictionary setValue:[NSNumber numberWithInt:384000] forKey:kDictionaryValueKey];
        [array addObject:dictionary];
        
        dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:[NSString stringWithFormat:@"512000"] forKey:kDictionaryNameKey];
        [dictionary setValue:[NSNumber numberWithInt:512000] forKey:kDictionaryValueKey];
        [array addObject:dictionary];
        
        dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:[NSString stringWithFormat:@"768000"] forKey:kDictionaryNameKey];
        [dictionary setValue:[NSNumber numberWithInt:768000] forKey:kDictionaryValueKey];
        [array addObject:dictionary];
        
        dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:[NSString stringWithFormat:@"1024000"] forKey:kDictionaryNameKey];
        [dictionary setValue:[NSNumber numberWithInt:1024000] forKey:kDictionaryValueKey];
        [array addObject:dictionary];
        
        self.bitrates = array;
    }
    
    return _bitrates;
}

- (NSArray *)resolutions
{
    if (_resolutions == nil) {
        NSMutableArray *array = [NSMutableArray array];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:[NSString stringWithFormat:@"CIF"] forKey:kDictionaryNameKey];
        [dictionary setValue:[NSNumber numberWithInt:(int)MEDIA_VIDEO_SIZE_CIF] forKey:kDictionaryValueKey];
        [array addObject:dictionary];
        
        dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:[NSString stringWithFormat:@"VGA"] forKey:kDictionaryNameKey];
        [dictionary setValue:[NSNumber numberWithInt:(int)MEDIA_VIDEO_SIZE_VGA] forKey:kDictionaryValueKey];
        [array addObject:dictionary];
        
        dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:[NSString stringWithFormat:@"720p"] forKey:kDictionaryNameKey];
        [dictionary setValue:[NSNumber numberWithInt:(int)MEDIA_VIDEO_SIZE_720P] forKey:kDictionaryValueKey];
        [array addObject:dictionary];
        
        self.resolutions = array;
    }
    
    return _resolutions;
}

#pragma mark - Table view data source
// depend on GUI resource.

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle == UITableViewCellSelectionStyleGray) {
        return nil;
    }
    else {
        return indexPath;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    return;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    return;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == self.bitrateCell.pickerView) {
        return ([self.bitrates count] != 0);
    }
    if (pickerView == self.resolutionCell.pickerView) {
        return ([self.resolutions count] != 0);
    }
    
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.bitrateCell.pickerView) {
        return [self.bitrates count];
    }
    if (pickerView == self.resolutionCell.pickerView) {
        return [self.resolutions count];
    }
    
    return 0;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.bitrateCell.pickerView) {
        return [[self.bitrates objectAtIndex:row] valueForKey:kDictionaryNameKey];
    }
    if (pickerView == self.resolutionCell.pickerView) {
        return [[self.resolutions objectAtIndex:row] valueForKey:kDictionaryNameKey];
    }
    
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.bitrateCell.pickerView) {
        self.bitrateCell.contentLabel.text = [[self.bitrates objectAtIndex:row] valueForKey:kDictionaryNameKey];
        
        return;
    }
    if (pickerView == self.resolutionCell.pickerView) {
        self.resolutionCell.contentLabel.text = [[self.resolutions objectAtIndex:row] valueForKey:kDictionaryNameKey];
        
        return;
    }
    
    return;
}

#pragma mark - selector

- (IBAction)selector:(id)sender
{
    if (sender == self.doneBarButtonItem) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if ([indexPath isKindOfClass:[NSIndexPath class]]) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        
        return;
    }
    
    if (sender == self.saveBarButtonItem) {
        // save
        NSMutableDictionary *configuration = [NSMutableDictionary dictionaryWithDictionary:[VoipClientManager configuration]];
        [configuration setValue:self.displaynameCell.textField.text forKey:kVoipClientManagerConfigurationDisplayNameKey];
        [configuration setValue:self.usernameCell.textField.text forKey:kVoipClientManagerConfigurationUsernameKey];
        [configuration setValue:self.passwordCell.textField.text forKey:kVoipClientManagerConfigurationPasswordKey];
        [configuration setValue:self.serverIPCell.textField.text forKey:kVoipClientManagerConfigurationRegisterIPKey];
        [configuration setValue:self.serverPortCell.textField.text forKey:kVoipClientManagerConfigurationRegisterPortKey];
        [configuration setValue:self.localPortCell.textField.text forKey:kVoipClientManagerConfigurationLocalPortKey];
        [configuration setValue:[NSNumber numberWithBool:self.FECAudioSwitch.on] forKey:kVoipClientManagerConfigurationEnableFECAudioKey];
        [configuration setValue:[NSNumber numberWithBool:self.FECVideoSwitch.on] forKey:kVoipClientManagerConfigurationEnableFECVideoKey];
        [configuration setValue:[NSNumber numberWithBool:self.AECSwitch.on] forKey:kVoipClientManagerConfigurationEnableAECKey];
        [configuration setValue:[NSNumber numberWithBool:self.AGCSwitch.on] forKey:kVoipClientManagerConfigurationEnableAGCKey];
        [configuration setValue:[NSNumber numberWithBool:self.NRSwitch.on] forKey:kVoipClientManagerConfigurationEnableNRKey];
        [configuration setValue:[NSNumber numberWithBool:self.G711Switch.on] forKey:kVoipClientManagerConfigurationEnableG711Key];
        [configuration setValue:[NSNumber numberWithBool:self.G723Switch.on] forKey:kVoipClientManagerConfigurationEnableG723Key];
        [configuration setValue:[NSNumber numberWithBool:self.G729Switch.on] forKey:kVoipClientManagerConfigurationEnableG729Key];
        [configuration setValue:[NSNumber numberWithBool:self.AMRSwitch.on] forKey:kVoipClientManagerConfigurationEnableAMRKey];
        [configuration setValue:[NSNumber numberWithBool:self.AMRWBSwitch.on] forKey:kVoipClientManagerConfigurationEnableAMRWBKey];
        [configuration setValue:[NSNumber numberWithBool:self.GSMSwitch.on] forKey:kVoipClientManagerConfigurationEnableGSMKey];
        [configuration setValue:[NSNumber numberWithBool:self.iLBCSwitch.on] forKey:kVoipClientManagerConfigurationEnableiLBCKey];
        [configuration setValue:[NSNumber numberWithBool:self.SILKSwitch.on] forKey:kVoipClientManagerConfigurationEnableSILKKey];
        [configuration setValue:[NSNumber numberWithBool:self.AACSwitch.on] forKey:kVoipClientManagerConfigurationEnableAACKey];
        [configuration setValue:[NSNumber numberWithBool:self.G722Switch.on] forKey:kVoipClientManagerConfigurationEnableG722Key];
        NSUInteger index = 0;
        index = [self.bitrateCell.pickerView selectedRowInComponent:0];
        [configuration setValue:[[self.bitrates objectAtIndex:index] valueForKey:kDictionaryValueKey] forKey:kVoipClientManagerConfigurationBitrateKey];
        index = [self.resolutionCell.pickerView selectedRowInComponent:0];
        [configuration setValue:[[self.resolutions objectAtIndex:index] valueForKey:kDictionaryValueKey] forKey:kVoipClientManagerConfigurationResolutionKey];
        [configuration setValue:[NSNumber numberWithBool:self.H263Switch.on] forKey:kVoipClientManagerConfigurationEnableH263Key];
        [configuration setValue:[NSNumber numberWithBool:self.H264Switch.on] forKey:kVoipClientManagerConfigurationEnableH264Key];
        
        if ([VoipClientManager setConfiguration:configuration]) {
            [VoipClientManager unregisterVoipClient];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"알림" message:@"저장하지 못하였습니다." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        
        return;
    }
    
    return;
}

@end