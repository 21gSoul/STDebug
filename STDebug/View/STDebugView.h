//
//  STDebugView.h
//  STDebug
//
//  Created by 石破天 on 2017/7/26.
//  Copyright © 2017年 stone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STLogView.h"
#import "STDebugger.h"

@class STDebugView;
@protocol STDebugViewDelegate <NSObject>

@optional
- (void)debugView:(STDebugView *)debugView didSelectIndex:(NSUInteger)index;

@end

@interface STDebugView : UIView

@property (nonatomic, weak) id<STDebugViewDelegate> delegate;
@property (nonatomic, weak) id<STDebugExtendDelegate> extendDelegate;
@property (nonatomic, weak) STLogView *logView;
@property (nonatomic, assign) BOOL shouldAutoScrollToEnd;
@property (nonatomic, strong) NSDictionary *envConfig;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *result;
@property (nonatomic, copy) NSString *selectedKey;
@property (nonatomic, strong) NSArray *allKeys;

- (void)enableFreshTimer:(BOOL)enable;
- (void)searchLog:(NSString *)log;
- (void)searchNext;
- (void)saveEnv;

@end
