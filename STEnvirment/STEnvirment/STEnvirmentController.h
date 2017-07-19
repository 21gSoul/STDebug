//
//  STEnvirmentController.h
//  STEnvirment
//
//  Created by 石破天 on 2017/7/17.
//  Copyright © 2017年 msxf. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ENVIRMENT [STEnvirmentController envirment]

@interface STEnvirmentController : UIViewController

+ (void)showWithEnvConfig:(NSDictionary *)config;

+ (void)showWithConfigFile:(NSString *)fileName;

+ (instancetype) shared;

+ (NSDictionary *)envirment;

@end
