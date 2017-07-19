//
//  UIScrollView+STMutiTabView.m
//  STEnvirment
//
//  Created by 石破天 on 2017/7/17.
//  Copyright © 2017年 msxf. All rights reserved.
//

#import "UIScrollView+STMutiTabView.h"

@implementation UIScrollView (STMutiTabView)

///删除所有子视图
- (void)removeAllSubviews{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
