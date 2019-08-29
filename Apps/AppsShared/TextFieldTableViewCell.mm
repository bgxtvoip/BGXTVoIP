#import "TextFieldTableViewCell.h"

@implementation TextFieldTableViewCell

#pragma mark - property

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.textField.enabled = selected;
    if (selected) {
        if ([self.textField isFirstResponder] == NO) {
            [self.textField becomeFirstResponder];
        }
    }
    else {
        if ([self.textField isFirstResponder] == YES) {
            [self.textField resignFirstResponder];
        }
    }
    
    return;
}

@end
