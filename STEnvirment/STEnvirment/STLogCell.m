//
//  STLogCell.m
//  STEnvirment
//
//  Created by 石破天 on 2017/7/17.
//  Copyright © 2017年 msxf. All rights reserved.
//

#import "STLogCell.h"
#import "Masonry.h"
#import "common.h"

@interface STLogCell ()
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSMutableArray *lastSearchResult;
@property (nonatomic, assign) NSUInteger lastSearchShowIndex;
@end

@implementation STLogCell

- (void)setLog:(NSString *)log {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:log attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    self.textView.attributedText = text;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length, 1)];
    });
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.lastSearchResult = [NSMutableArray arrayWithCapacity:64];
        self.textView = [[UITextView alloc] init];
        self.textView.font = [UIFont systemFontOfSize:16];
        self.textView.editable = NO;
        self.textView.layoutManager.allowsNonContiguousLayout = NO;
        [self.contentView addSubview:self.textView];
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
    }
    return self;
}

- (void)searchText:(NSString *)text {
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:text options:0 error:nil];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]initWithAttributedString: self.textView.attributedText];
    [self.lastSearchResult removeAllObjects];
    [regularExpression enumerateMatchesInString:attString.string options:NSMatchingReportCompletion range:NSMakeRange(0, attString.string.length-1) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (!result) {
            return ;
        }
        [self.lastSearchResult addObject:result];
        NSLog(@"range1 = %@", NSStringFromRange(result.range));
        [attString setAttributes:@{
                                   NSBackgroundColorAttributeName:RGBCOLOR(200, 200, 200),
                                   NSFontAttributeName:[UIFont systemFontOfSize:16]
                                   }
                           range:result.range];
    }];
    self.textView.attributedText = attString;
    self.lastSearchShowIndex = self.lastSearchResult.count?self.lastSearchResult.count-1:0;
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
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]initWithAttributedString: self.textView.attributedText];
    [attString setAttributes:@{NSBackgroundColorAttributeName:color,NSFontAttributeName:[UIFont systemFontOfSize:16]} range:[self.lastSearchResult[self.lastSearchShowIndex] range]];
    self.textView.attributedText = attString;
}


- (void)scrollToCurrentSearchIndex {
    if (self.lastSearchShowIndex < self.lastSearchResult.count) {
        NSRange range = [self.lastSearchResult[self.lastSearchShowIndex] range];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.textView scrollRangeToVisible:range];
//        });
    }
}

@end
