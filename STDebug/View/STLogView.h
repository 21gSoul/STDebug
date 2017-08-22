//
//  STTextView.h
//  STDebug
//
//  Created by 石破天 on 2017/7/26.
//  Copyright © 2017年 stone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STLogView : UITextView

@property (nonatomic, assign) BOOL shouldAutoScrollToEnd;

- (void) appendLog:(NSString *)log;
- (void) clearLog;
- (void) searchWithText:(NSString *)text;
- (void) searchNext;

@end
