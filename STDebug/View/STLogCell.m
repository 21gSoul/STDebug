//
//  STLogCell.m
//  STDebug
//
//  Created by 石破天 on 2017/7/26.
//  Copyright © 2017年 stone. All rights reserved.
//

#import "STLogCell.h"
#import "Masonry.h"

@implementation STLogCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.textField = [[UITextField alloc] init];
        self.textField.font = [UIFont systemFontOfSize:16];
        self.textField.textAlignment = NSTextAlignmentLeft;
        self.textField.returnKeyType = UIReturnKeyDone;
        self.textField.enabled = NO;
        [self.contentView addSubview:self.textField];
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(@0);
            make.top.bottom.equalTo(@0);
            make.left.equalTo(@10);
        }];
    }
    return self;
}

@end
