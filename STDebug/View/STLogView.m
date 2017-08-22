//
//  STTextView.m
//  STDebug
//
//  Created by 石破天 on 2017/7/26.
//  Copyright © 2017年 stone. All rights reserved.
//

#import "STLogView.h"
#import "common.h"

@interface STLogView()<UITextViewDelegate>

@property (nonatomic, strong) NSMutableAttributedString *attributedLog;
@property (nonatomic, strong) NSMutableArray <NSTextCheckingResult *>*lastSearchResult;
@property (nonatomic, assign) NSUInteger lastSearchShowIndex;

@end

@implementation STLogView

- (instancetype)init {
    if (self = [super init]) {
        self.editable = NO;
        self.layoutManager.allowsNonContiguousLayout = NO;
        self.attributedLog = [[NSMutableAttributedString alloc] init];
        self.lastSearchResult = [NSMutableArray arrayWithCapacity:256];
        self.delegate = self;
        self.shouldAutoScrollToEnd = YES;
    }
    return self;
}

- (void)appendLog:(NSString *)log {
    [self.attributedLog appendAttributedString:[[NSAttributedString alloc] initWithString:log attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}]];
    self.attributedText = self.attributedLog;
    if (self.shouldAutoScrollToEnd) {
        [self scrollRangeToVisible:NSMakeRange(self.attributedLog.length, 1)];
    }
    
}

- (void)clearLog {
    [self.attributedLog setAttributedString:[[NSAttributedString alloc]init]];
    self.attributedText = self.attributedLog;
}

- (void)searchWithText:(NSString *)text {
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:text options:0 error:nil];
    [self.lastSearchResult removeAllObjects];
    [regularExpression enumerateMatchesInString:self.attributedLog.string options:NSMatchingReportCompletion range:NSMakeRange(0, self.attributedLog.length-1) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (!result) {
            return ;
        }
        [self.lastSearchResult addObject:result];
        //        NSLog(@"range1 = %@", NSStringFromRange(result.range));
        [self.attributedLog setAttributes:@{
                                   NSBackgroundColorAttributeName:RGBCOLOR(200, 200, 200),
                                   NSFontAttributeName:[UIFont systemFontOfSize:16]
                                   }
                           range:result.range];
    }];
    self.attributedText = self.attributedLog;
    self.lastSearchShowIndex = self.lastSearchResult.count ? self.lastSearchResult.count-1 : 0;
    [self paintCurrentSearchIndexWithColor:[UIColor grayColor]];
    [self scrollToCurrentSearchIndex];
}

- (void)searchNext {
    [self paintCurrentSearchIndexWithColor:RGBCOLOR(200, 200, 200)];
    self.lastSearchShowIndex = self.lastSearchShowIndex?self.lastSearchShowIndex-1:(self.lastSearchResult.count?self.lastSearchResult.count-1:1);
    [self paintCurrentSearchIndexWithColor:[UIColor grayColor]];
    [self scrollToCurrentSearchIndex];
}

- (void) paintCurrentSearchIndexWithColor:(UIColor *)color {
    if (self.lastSearchShowIndex >= self.lastSearchResult.count) {
        return;
    }
    [self.attributedLog setAttributes:@{NSBackgroundColorAttributeName:color,NSFontAttributeName:[UIFont systemFontOfSize:16]} range:[self.lastSearchResult[self.lastSearchShowIndex] range]];
    self.attributedText = self.attributedLog;
}


- (void)scrollToCurrentSearchIndex {
    if (self.lastSearchShowIndex < self.lastSearchResult.count) {
        NSRange range = [self.lastSearchResult[self.lastSearchShowIndex] range];
        [self scrollRangeToVisible:range];
    }
}

#pragma mark ======== UITextViewDelegate ========
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    self.shouldAutoScrollToEnd = scrollView.contentSize.height - scrollView.contentOffset.y< scrollView.frame.size.height+5;
}

@end
