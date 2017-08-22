//
//  STDebugController.h
//  STDebug
//
//  Created by 石破天 on 2017/7/26.
//  Copyright © 2017年 stone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STDebugger.h"

@interface STDebugController : UIViewController

+ (instancetype) shared;

@property (nonatomic, strong) NSMutableDictionary *result;
@property (nonatomic, copy) NSDictionary *envConfig;
@property (nonatomic, assign) BOOL showing;
@property (nonatomic, weak) id<STDebugExtendDelegate> extendDelegate;

@end
