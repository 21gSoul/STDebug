//
//  STLogTool.h
//  STDebug
//
//  Created by 石破天 on 2017/7/26.
//  Copyright © 2017年 stone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "STDebugger.h"

@class STLogTool;

@protocol STLogToolDelegate <NSObject>

@optional
- (void) logTool:(STLogTool *) logTool didLogWithText:(NSString *)log;
- (void) logTool:(STLogTool *) logTool shouldShowNewLogs:(NSArray <NSString *> *) logs;
- (void) logTool:(STLogTool *) logTool reloadCompletedWithLogs:(NSArray <NSString *> *) logs;
- (void) logToolFormatCompleted:(STLogTool *) logTool;

@end

@interface STLogTool : NSObject

+ (instancetype)shared;

@property (nonatomic, weak) id<STLogToolDelegate> delegate;

@property(nonatomic, copy, readonly) NSArray <NSString *> *linedLogs;
@property(nonatomic, assign) float formatWidth;
@property(nonatomic, strong) UIFont *formatFont;
@property (nonatomic, copy) NSArray *filters;
@property(nonatomic, assign) STLogHeaderStyle headerStyle;
@property(nonatomic, assign) BOOL showOnConsole;

- (void)redirectFileDescriptor:(int)fileDescriptor;
- (void)stopRedirectFileDescriptor:(int)fileDescriptor;
- (void)clearLogs;

@end
