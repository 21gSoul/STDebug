//
//  STLogCell.h
//  STEnvirment
//
//  Created by 石破天 on 2017/7/17.
//  Copyright © 2017年 msxf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STLogCell : UITableViewCell

- (void) setLog:(NSString *)log;

- (void) searchText:(NSString *)text;

- (void)searchNext;

@end
