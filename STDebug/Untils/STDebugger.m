//
//  STDebuger.m
//  STDebug
//
//  Created by 石破天 on 2017/7/26.
//  Copyright © 2017年 stone. All rights reserved.
//

#import "STDebugger.h"
#import "STDebugController.h"
#import "STLogTool.h"

@implementation STDebugger

+ (void)setExtendDelegate:(id<STDebugExtendDelegate>)delegate {
    [STDebugController shared].extendDelegate = delegate;
}

+ (void)showOnConsole:(BOOL)show {
    [STLogTool shared].showOnConsole = show;
}

+ (void)setLogHeaderStyle:(STLogHeaderStyle)style {
    [STLogTool shared].headerStyle = style;
}

+ (void)setConfig:(NSDictionary *)config {
    [STDebugController shared].envConfig = config;
}

+ (void)setConfigWithFile:(NSString *)fileName {
    NSString *fullPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithContentsOfFile:fullPath];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    [self setConfig:dic];
}

+ (void)setFilters:(NSArray *)filters {
    [STLogTool shared].filters = filters;
}

+ (NSDictionary *)envirment {
    return [STDebugController shared].result;
}

+ (void)show {
    STDebugController *controller = [STDebugController shared];
    if (controller.showing) {
        return;
    }
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
}

@end
