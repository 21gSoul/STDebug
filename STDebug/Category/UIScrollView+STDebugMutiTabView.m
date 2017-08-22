//
//  UIScrollView+STDebugMutiTabView.m
//  STEnvirment
//
//  Created by 石破天 on 2017/7/17.
//  Copyright © 2017年 msxf. All rights reserved.
//

#import "UIScrollView+STDebugMutiTabView.h"

@implementation UIScrollView (STDebugMutiTabView)

///删除所有子视图
- (void)st_removeAllSubviews{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
