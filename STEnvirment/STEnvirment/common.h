//
//  common.h
//  IRImageRecognition
//
//  Created by 石破天 on 2017/6/28.
//  Copyright © 2017年 msxf. All rights reserved.
//

#ifndef common_h
#define common_h

#define RGBCOLOR(r,g,b)     [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define HEXRGBCOLOR(h)      RGBCOLOR(((h>>16)&0xFF), ((h>>8)&0xFF), (h&0xFF))

// 屏幕尺寸
#define SCREEN_RECT         [UIScreen mainScreen].bounds
#define SCREEN_SIZE         [UIScreen mainScreen].bounds.size
#define SCREEN_WIDTH        (SCREEN_SIZE.width)
#define SCREEN_HEIGHT       (SCREEN_SIZE.height)
#define NAVIGATIONBAR_HEIGHT  64
#define TABBAR_HEIGHT  49

#define kSCREEN_RATE (CGRectGetWidth([UIScreen mainScreen].bounds)/375.0f)

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self


#endif /* common_h */
