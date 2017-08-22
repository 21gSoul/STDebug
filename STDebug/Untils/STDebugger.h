//
//  STDebuger.h
//  STDebug
//
//  Created by 石破天 on 2017/7/26.
//  Copyright © 2017年 stone. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ENVIRMENT [STDebugger envirment]

typedef NS_ENUM(NSInteger, STLogHeaderStyle) {
    STLogHeaderStyleAll,
    STLogHeaderStyleSimple,
    STLogHeaderStyleNone
};


@protocol STDebugExtendDelegate <NSObject>

@optional
- (NSInteger) numberOfRowsInExtendView;
- (NSString *) titleForRowInExtendView:(NSInteger)row;
- (void) didSelectRowInExtendView:(NSInteger)row;

@end

@interface STDebugger : NSObject

+ (void) setExtendDelegate:(id<STDebugExtendDelegate>) delegate;
+ (void) showOnConsole:(BOOL)show;
+ (void) setLogHeaderStyle:(STLogHeaderStyle)style;
+ (void) setConfig:(NSDictionary *)config;
+ (void) setConfigWithFile:(NSString *)fileName;
+ (NSDictionary *) envirment;
+ (void) setFilters:(NSArray *)filters;
+ (void) show;

@end
