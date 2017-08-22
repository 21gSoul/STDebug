//
//  STDebugMutiTabView.m
//  Finance
//
//  Created by 石破天 on 2016/12/30.
//  Copyright © 2016年 MaShang Consumer Finance. All rights reserved.
//

#import "STDebugMutiTabView.h"
#import "Masonry.h"
#import "UIScrollView+STDebugMutiTabView.h"
#import "common.h"
#import <objc/runtime.h>
//#import "MJRefresh.h"

@interface UITableView()
@property (nonatomic, assign) BOOL empty;
@end

@interface STDebugMutiTabView ()<UITableViewDelegate, UITableViewDataSource>{
    NSUInteger _selectedIndex;
    UIColor *_selectedColor;          //标题选定及指示器颜色
    UIColor *_titleColor;             //标题未选定颜色
    UIColor *_themeColor;             //页面背景色
    STDebugMutiTabViewStyle _style;
}
#pragma mark ===== All properties =====
@property (nonatomic, strong) UIScrollView *topTab;
@property (nonatomic, strong) UIScrollView *bottomTab;
@property (nonatomic, strong) NSArray<UIButton *> *topButtons;
@property (nonatomic, strong) NSArray<UIButton *> *bottomButtons;
@property (nonatomic, strong) NSArray<UITableView *> *tableViews;
@property (nonatomic, strong) UIView *indicator;
@property (nonatomic, strong) UIView *scrollAssistView;
@property (nonatomic, strong) UIView *topAssistView;
@property (nonatomic, strong) UIView *bottomAssistView;
@end

@implementation STDebugMutiTabView

-(instancetype)init {
    if (self = [super init]) {
        self.topAssistView = [[UIView alloc] init];
        [self addSubview:self.topAssistView];
        self.backgroundColor = RGBCOLOR(236, 236, 236);
        self.topTab = [[UIScrollView alloc] init];
        self.topTab.showsVerticalScrollIndicator = self.topTab.showsHorizontalScrollIndicator = NO;
        self.topTab.backgroundColor = HEXRGBCOLOR(0xF0F8FF);
        [self.topAssistView addSubview:self.topTab];
        [self.topTab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.topAssistView);
        }];
        
        self.indicator = [[UIView alloc] init];
        self.indicator.backgroundColor = self.selectedColor;
        
        self.bottomAssistView = [[UIView alloc] init];
        [self addSubview:self.bottomAssistView];
        
        self.bottomTab = [[UIScrollView alloc] init];
        self.bottomTab.backgroundColor = [UIColor whiteColor];
        self.bottomTab.showsVerticalScrollIndicator = self.bottomTab.showsHorizontalScrollIndicator = NO;
        [self.bottomAssistView addSubview:self.bottomTab];
        [self.bottomTab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.bottomAssistView);
        }];
        
        self.scrollAssistView = [[UIView alloc] init];
        [self addSubview:self.scrollAssistView];
        [self.scrollAssistView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self.topAssistView.mas_bottom).offset(5);
            make.bottom.equalTo(self.bottomTab.mas_top);
        }];
        
        self.topTab.bounces = self.bottomTab.bounces = NO;
        
        _scrollView = [[UIScrollView alloc] init];
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = self.scrollView.showsVerticalScrollIndicator = NO;
        [self.scrollAssistView addSubview: self.scrollView];
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.scrollAssistView);
        }];
        
        self.style = STDebugMutiTabViewStyleTopTab;
    }
    return self;
}

#pragma mark ===== Rewrite getter and setter =====
-(void)setTitles:(NSArray<NSString *> *)titles {
    _titles = titles;
    [self.topTab st_removeAllSubviews];
    [self.bottomTab st_removeAllSubviews];
    [self.scrollView st_removeAllSubviews];
    _tabCount = titles.count;
    UIButton *lastTopButton = nil, *lastBottomButton = nil;
    UITableView *lastTableView = nil;
    NSMutableArray *topButtons = [NSMutableArray arrayWithCapacity:8];
    NSMutableArray *bottomButtons = [NSMutableArray arrayWithCapacity:8];
    NSMutableArray *tableViews = [NSMutableArray arrayWithCapacity:8];
    for (NSUInteger i = 0; i<self.tabCount; ++i) {
        UIButton *button = [[UIButton alloc] init];
        button.tag = i;
        NSString *title = titles[i];
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16*kSCREEN_RATE];
        [button setTitleColor:self.titleColor forState:UIControlStateNormal];
        [button setTitleColor:self.selectedColor forState:UIControlStateDisabled];
        [button addTarget:self action:@selector(_didButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.topTab addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.topAssistView);
            make.width.mas_greaterThanOrEqualTo(70*kSCREEN_RATE);
            make.width.mas_lessThanOrEqualTo(150*kSCREEN_RATE);
            if (lastTopButton) {
                make.width.equalTo(lastTopButton);
                make.left.equalTo(lastTopButton.mas_right);
            } else {
                make.left.equalTo(self.topTab);
            }
            if (i == self.tabCount - 1) {
                make.right.equalTo(self.topTab);
            }
        }];
        lastTopButton = button;
        
        button = [[UIButton alloc] init];
        button.tag = i;
        button.layer.borderWidth = 1;
        button.layer.borderColor = self.titleColor.CGColor;
        button.titleLabel.font = [UIFont systemFontOfSize:16*kSCREEN_RATE];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:self.titleColor forState:UIControlStateNormal];
        [button setTitleColor:self.selectedColor forState:UIControlStateDisabled];
        [button addTarget:self action:@selector(_didButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomTab addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.bottomAssistView);
            make.width.mas_greaterThanOrEqualTo(70*kSCREEN_RATE);
            make.width.mas_lessThanOrEqualTo(150*kSCREEN_RATE);
            if (lastBottomButton) {
                make.width.equalTo(lastBottomButton).offset(i==1?1:0);
                make.left.equalTo(lastBottomButton.mas_right).offset(-1);
            } else {
                make.left.equalTo(self.bottomTab);
            }
            if (i == self.tabCount - 1) {
                make.right.equalTo(self.bottomTab);
            }
        }];
        lastBottomButton = button;
        
        UITableView *tableView = [[UITableView alloc] init];
        tableView.tag = i;
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = self.themeColor;
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.scrollView addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.scrollAssistView);
            make.width.equalTo(self.scrollAssistView);
            if (lastTableView) {
                make.left.equalTo(lastTableView.mas_right);
            } else {
                make.left.equalTo(self.scrollView);
            }
            if (i == self.tabCount - 1) {
                make.right.equalTo(self.scrollView);
            }
        }];
        lastTableView = tableView;
        
        [topButtons addObject:lastTopButton];
        [bottomButtons addObject:lastBottomButton];
        [tableViews addObject:lastTableView];
    }
    [self.topTab addSubview:self.indicator];
    
    self.topButtons = topButtons;
    self.bottomButtons = bottomButtons;
    self.tableViews = tableViews;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.selectedIndex = self.selectedIndex;
        BOOL needAdjust = lastTopButton.frame.origin.x+lastTopButton.frame.size.width < self.topAssistView.frame.size.width;
        if (needAdjust) {
            [lastTopButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.topAssistView);
            }];
            [lastBottomButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.bottomAssistView);
            }];
        }
    });
    
}

-(void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex >= self.titles.count) {
        return;
    }
    [self layoutIfNeeded];
    NSInteger orginalIndex = self.selectedIndex;
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.contentOffset = CGPointMake(self.scrollAssistView.frame.size.width * selectedIndex, 0);
        self.topButtons[self.selectedIndex].enabled = YES;
        UIButton * button = self.topButtons[selectedIndex];
        button.enabled = NO;
        [self.indicator mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(button);
            make.height.mas_equalTo(2*kSCREEN_RATE);
        }];
        if (button.frame.origin.x < self.topTab.contentOffset.x) {
            self.topTab.contentOffset = CGPointMake(button.frame.origin.x, 0);
        } else if (button.frame.origin.x + button.frame.size.width > self.topTab.contentOffset.x + self.topAssistView.frame.size.width) {
            self.topTab.contentOffset = CGPointMake(button.frame.origin.x+button.frame.size.width-self.topAssistView.frame.size.width, 0);
        }
        
        button = self.bottomButtons[self.selectedIndex];
        button.backgroundColor = [UIColor whiteColor];
        button = self.bottomButtons[selectedIndex];
        button.backgroundColor = self.selectedColor;
        if (button.frame.origin.x < self.bottomTab.contentOffset.x) {
            self.bottomTab.contentOffset = CGPointMake(button.frame.origin.x, 0);
        } else if (button.frame.origin.x + button.frame.size.width > self.bottomTab.contentOffset.x + self.bottomAssistView.frame.size.width) {
            self.bottomTab.contentOffset = CGPointMake(button.frame.origin.x+button.frame.size.width-self.bottomAssistView.frame.size.width, 0);
        }
        [self layoutIfNeeded];
        _selectedIndex = selectedIndex;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(mutiTabView:didSelectIndexFrom:changeTo:)]) {
            [self.delegate mutiTabView:self didSelectIndexFrom:orginalIndex changeTo:selectedIndex];
        }
    }];
    
    
}

- (void)setSelectedIndexWithoutAnimation:(NSUInteger)selectedIndex {
    if (selectedIndex >= self.titles.count) {
        return;
    }
    [self layoutIfNeeded];
    NSInteger orginalIndex = self.selectedIndex;
    [UIView animateWithDuration:0.3 animations:^{
//        self.scrollView.contentOffset = CGPointMake(self.scrollAssistView.frame.size.width * selectedIndex, 0);
        self.topButtons[self.selectedIndex].enabled = YES;
        UIButton * button = self.topButtons[selectedIndex];
        button.enabled = NO;
        [self.indicator mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(button);
            make.height.mas_equalTo(2*kSCREEN_RATE);
        }];
        if (button.frame.origin.x < self.topTab.contentOffset.x) {
            self.topTab.contentOffset = CGPointMake(button.frame.origin.x, 0);
        } else if (button.frame.origin.x + button.frame.size.width > self.topTab.contentOffset.x + self.topAssistView.frame.size.width) {
            self.topTab.contentOffset = CGPointMake(button.frame.origin.x+button.frame.size.width-self.topAssistView.frame.size.width, 0);
        }
        
        button = self.bottomButtons[self.selectedIndex];
        button.backgroundColor = [UIColor whiteColor];
        button = self.bottomButtons[selectedIndex];
        button.backgroundColor = self.selectedColor;
        if (button.frame.origin.x < self.bottomTab.contentOffset.x) {
            self.bottomTab.contentOffset = CGPointMake(button.frame.origin.x, 0);
        } else if (button.frame.origin.x + button.frame.size.width > self.bottomTab.contentOffset.x + self.bottomAssistView.frame.size.width) {
            self.bottomTab.contentOffset = CGPointMake(button.frame.origin.x+button.frame.size.width-self.bottomAssistView.frame.size.width, 0);
        }
        [self layoutIfNeeded];
        _selectedIndex = selectedIndex;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(mutiTabView:didSelectIndexFrom:changeTo:)]) {
            [self.delegate mutiTabView:self didSelectIndexFrom:orginalIndex changeTo:selectedIndex];
        }
    }];
}

- (void)setStyle:(STDebugMutiTabViewStyle)style {
    _style = style;
    [self.topAssistView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo((style & STDebugMutiTabViewStyleTopTab) ? @(45*kSCREEN_RATE) :@0);
    }];
    [self.bottomAssistView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.mas_equalTo((style & STDebugMutiTabViewStyleBottomButton) ? @(45*kSCREEN_RATE) : @0);
    }];
}


- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    for (NSInteger index = 0; index < self.tabCount; ++index) {
        [self.topButtons[index] setTitleColor:selectedColor forState:UIControlStateDisabled];
        
    }
    if (self.selectedIndex < self.tabCount) {
        self.bottomButtons[self.selectedIndex].backgroundColor = selectedColor;
    }
    self.indicator.backgroundColor = selectedColor;
}

- (UIColor *)selectedColor {
    if (!_selectedColor) {
        _selectedColor = [UIColor colorWithRed:0.055 green:0.600 blue:0.988 alpha:1.000];
    }
    return _selectedColor;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    for (NSInteger index = 0; index < self.tabCount; ++index) {
        if (index != self.selectedIndex) {
            [self.topButtons[index] setTitleColor:titleColor forState:UIControlStateNormal];
            [self.bottomButtons[index]setTitleColor:titleColor forState:UIControlStateNormal];
            self.bottomButtons[index].layer.borderColor = titleColor.CGColor;
        }
    }
}

- (UIColor *)titleColor {
    if (!_titleColor) {
        _titleColor = [UIColor grayColor];
    }
    return _titleColor;
}

- (void)setThemeColor:(UIColor *)themeColor {
    _themeColor = themeColor;
    for (UITableView *tableView in self.tableViews) {
        tableView.backgroundColor = themeColor;
    }
}

- (UIColor *)themeColor {
    if (!_themeColor) {
        _themeColor = [UIColor colorWithWhite:0.933 alpha:1.000];
    }
    return _themeColor;
}

#pragma mark ===== Other public methods =====
- (UITableView *) tableViewWithTabIndex:(NSUInteger) tabIndex {
    return tabIndex >= self.tabCount ? nil : self.tableViews[tabIndex];
}

- (void)reloadData {
    for (UITableView *tableView in self.tableViews) {
        [tableView reloadData];
    }
}

#pragma mark ===== UITableViewDelegate & UITableViewDataSource =====
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([self.delegate respondsToSelector:@selector(mutiTabView:didEndDraggingAtTabIndex:)]) {
        [self.delegate mutiTabView:self didEndDraggingAtTabIndex:scrollView.tag];
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 250.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.empty) {
        return self.scrollAssistView.frame.size.height;
    }
    if ([self.delegate respondsToSelector:@selector(mutiTabView:heightForRowAtIndexPath:tabIndex:)]) {
        return [self.delegate mutiTabView:self heightForRowAtIndexPath:indexPath tabIndex:tableView.tag];
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.delegate respondsToSelector:@selector(numberOfSectionsInMutiTabView:atTabIndex:)]) {
        return [self.delegate numberOfSectionsInMutiTabView:self atTabIndex:tableView.tag];
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(mutiTabView:viewForHeaderInSection:atTabIndex:)]) {
        return [self.delegate mutiTabView:self viewForHeaderInSection:section atTabIndex:tableView.tag];
    }
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(mutiTabView:heightForHeaderInSection:atTabIndex:)]) {
        return [self.delegate mutiTabView:self heightForHeaderInSection:section atTabIndex:tableView.tag];
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    if ([self.delegate respondsToSelector:@selector(mutiTabView:numberOfRowsInSection:tabIndex:)]) {
        number = [self.delegate mutiTabView:self numberOfRowsInSection:section tabIndex:tableView.tag];
    }
    //如果没有，则显示空视图
    if (section == 0 && number == 0) {
        tableView.empty = YES;
        return 1;
    } else {
        tableView.empty = NO;
    }
    return number;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if ([self.delegate respondsToSelector:@selector(mutiTabView:cellForRowAtIndexPath:tabIndex:)] && !tableView.empty) {
        return [self.delegate mutiTabView:self cellForRowAtIndexPath:indexPath tabIndex:tableView.tag];
    }
    cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    UIView *view = self.emptyViews[tableView.tag];
    if (view) {
        [view removeFromSuperview];
        [cell.contentView addSubview:view];
        [view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.contentView);
        }];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.empty) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(mutiTabView:didSelectRowAtIndexPath:tabIndex:)]) {
        [self.delegate mutiTabView:self didSelectRowAtIndexPath:indexPath tabIndex:tableView.tag];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(mutiTabView:canEditRowAtIndexPath:atTabIndex:)]) {
        return [self.delegate mutiTabView:self canEditRowAtIndexPath:indexPath atTabIndex:tableView.tag];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self.delegate respondsToSelector:@selector(mutiTabView:commitEditingStyle:forRowAtIndexPath:atTabIndex:)]) {
        [self.delegate mutiTabView:self commitEditingStyle:editingStyle forRowAtIndexPath:indexPath atTabIndex:tableView.tag];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(mutiTabView:titleForDeleteConfirmationButtonForRowAtIndexPath:atTabIndex:)]) {
        return [self.delegate mutiTabView:self titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath atTabIndex:tableView.tag];
    }
    return @"";
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    static NSUInteger lastPage = 0;
    if ([scrollView isKindOfClass:[UITableView class]]) {
        return;
    }
    NSUInteger page = scrollView.contentOffset.x / self.scrollAssistView.frame.size.width + 0.5f;
    if (page == lastPage) {
        return;
    }
    lastPage = page;
    [self setSelectedIndexWithoutAnimation:page];
}

#pragma mark ===== Events =====
-(void)_didButtonClick:(UIButton *)sender {
    [UIView animateWithDuration:.3 animations:^{
        self.selectedIndex = sender.tag;
        [self layoutIfNeeded];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.selectedIndex = self.selectedIndex;
}
@end




@implementation UITableView(STDebugMutiTabView)
- (void)setEmpty:(BOOL)empty {
    objc_setAssociatedObject(self, "empty", @(empty), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)empty {
    NSNumber *number = objc_getAssociatedObject(self, "empty");
    return number.boolValue;
}

@end
