//
//  STCustomAdressCell.m
//  STEnvirment
//
//  Created by 石破天 on 2017/7/18.
//  Copyright © 2017年 msxf. All rights reserved.
//

#import "STCustomAdressCell.h"
#import "Masonry.h"

@interface STCustomAdressCell ()<UITextFieldDelegate>



@end

@implementation STCustomAdressCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textField = [[UITextField alloc] init];
        self.textField.font = [UIFont systemFontOfSize:16];
        self.textField.returnKeyType = UIReturnKeyDone;
        self.textField.delegate = self;
        [self.contentView addSubview:self.textField];
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15);
            make.top.bottom.equalTo(@0);
            make.right.equalTo(@(-15));
        }];
    }
    return self;
}

- (void)setAddress:(NSString *)url {
    self.textField.text = url;
}

- (void)setEditable:(BOOL)editable {
    self.textField.enabled = editable;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
