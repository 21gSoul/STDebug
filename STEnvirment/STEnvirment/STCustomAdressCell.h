//
//  STCustomAdressCell.h
//  STEnvirment
//
//  Created by 石破天 on 2017/7/18.
//  Copyright © 2017年 msxf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STCustomAdressCell : UITableViewCell

@property (nonatomic, strong) UITextField *textField;

- (void)setAddress:(NSString *)url;

- (void)setEditable:(BOOL)editable;

@end
