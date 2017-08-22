//
//  STDebugView.m
//  STDebug
//
//  Created by 石破天 on 2017/7/26.
//  Copyright © 2017年 stone. All rights reserved.
//

#import "STDebugView.h"
#import "STDebugMutiTabView.h"
#import "Masonry.h"
#import "STLogCell.h"
#import "common.h"
#import "STLogTool.h"

NSString * const kEnvirmentStorageKey = @"com.stone.envirment.storagekey";
NSString * const kMainEnvStorageKey = @"com.stone.mainenvirment.storagekey";
NSString * const kShouldLogKey = @"com.stone.shouldlogkey";
NSString * const kFiltersKey = @"com.stone.STDebug.filtersKey";


@interface STDebugView ()<STDebugMutiTabViewDelegate, STLogToolDelegate, UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate>

@property (nonatomic, strong) STDebugMutiTabView *mutiTabView;
@property (nonatomic, strong) NSMutableArray <NSString *> *allLogs;
@property (nonatomic, strong) NSTimer *freshTimer;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIView *disableView;
@property (nonatomic, assign) BOOL shouldReload;
@property (nonatomic, assign) NSInteger countOfReload;
@property (nonatomic, assign) NSInteger lastSearchIndex;
@property (nonatomic, strong) NSEnumerator *lastSearchItor;
@property (nonatomic, copy) NSString *lastSearchText;
@property (nonatomic, strong) UIView *picker;

@end

@implementation STDebugView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        STDebugMutiTabView *tab = [[STDebugMutiTabView alloc] init];
        self.mutiTabView = tab;
        tab.titles = @[@"日志", @"环境", @"快捷功能"];
        tab.delegate = self;
        [STLogTool shared].delegate = self;
        [self addSubview:tab];
        [tab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        
        self.disableView = [[UIView alloc] init];
        self.disableView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        [self addSubview:self.disableView];
        [self.disableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.disableView addSubview:self.activityIndicator];
        [self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@68);
            make.center.equalTo(@0);
        }];
        self.disableView.hidden = YES;
        self.allLogs = [NSMutableArray arrayWithCapacity:4096];
        self.shouldAutoScrollToEnd = YES;
        
        [[self.mutiTabView tableViewWithTabIndex:0] registerClass:[STLogCell class] forCellReuseIdentifier:NSStringFromClass([STLogCell class])];
        [[self.mutiTabView tableViewWithTabIndex:1] registerClass:[STLogCell class] forCellReuseIdentifier:NSStringFromClass([STLogCell class])];
        [[self.mutiTabView tableViewWithTabIndex:2] registerClass:[STLogCell class] forCellReuseIdentifier:NSStringFromClass([STLogCell class])];
        [self.mutiTabView tableViewWithTabIndex:0].allowsMultipleSelection = YES;
        
        
    }
    return self;
}





#pragma mark ======== STDebugMutiTabViewDelegate ========

- (void)mutiTabView:(STDebugMutiTabView *)mutiTabView didSelectIndexFrom:(NSInteger)fromIndex changeTo:(NSInteger)toIndex {
    if ([self.delegate respondsToSelector:@selector(debugView:didSelectIndex:)]) {
        [self.delegate debugView:self didSelectIndex:toIndex];
    }
}


- (NSInteger)numberOfSectionsInMutiTabView:(STDebugMutiTabView *)mutiTabView atTabIndex:(NSUInteger)tabIndex {
    if (tabIndex == 0) {
        return 1;
    }
    if (tabIndex == 1) {
        NSArray *arr = self.envConfig[self.selectedKey];
        return arr.count + 1;
    }
    return 1;
}

- (NSInteger)mutiTabView:(STDebugMutiTabView *)mutiTabView numberOfRowsInSection:(NSInteger)section tabIndex:(NSUInteger)tabIndex {
    if (tabIndex == 0) {
        return self.allLogs.count;
    }
    if (tabIndex == 1) {
        return 1;
    }
    if (tabIndex == 2 && [self.extendDelegate respondsToSelector:@selector(numberOfRowsInExtendView)]) {
        return [self.extendDelegate numberOfRowsInExtendView];
    }
    return 0;
}

- (CGFloat)mutiTabView:(STDebugMutiTabView *)mutiTabView heightForHeaderInSection:(NSInteger)section atTabIndex:(NSUInteger)tabIndex {
    if (tabIndex == 1) {
        return 40;
    }
    return 0;
}

- (UIView *)mutiTabView:(STDebugMutiTabView *)mutiTabView viewForHeaderInSection:(NSInteger)section atTabIndex:(NSUInteger)tabIndex {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
    view.backgroundColor =RGBCOLOR(236, 236, 236);
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:25];
    if (section == 0) {
        label.text = @"主要环境配置";
    } else {
        label.text = self.envConfig[self.selectedKey][section-1][@"des"];
    }
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.centerY.equalTo(@0);
    }];
    
    return view;
}

- (CGFloat)mutiTabView:(STDebugMutiTabView *)mutiTabView heightForRowAtIndexPath:(NSIndexPath *)indexPath tabIndex:(NSUInteger)tabIndex {
    if (tabIndex == 0) {
        return 20;
    }
    return 40;
}

- (UITableViewCell *)mutiTabView:(STDebugMutiTabView *)mutiTabView cellForRowAtIndexPath:(NSIndexPath *)indexPath tabIndex:(NSUInteger)tabIndex {
    NSString *idf = @"STLogCell";
    __kindof UITableViewCell *cell = [[mutiTabView tableViewWithTabIndex:tabIndex] dequeueReusableCellWithIdentifier:idf];
    if (tabIndex == 0) {
        STLogCell *logCell = cell;
        logCell.textField.text = self.allLogs[indexPath.row];
        logCell.tag = indexPath.row;
    } else if (tabIndex == 1) {
        cell.tag = indexPath.section;
        STLogCell *caCell = cell;
        caCell.textField.tag = indexPath.section;
        caCell.textField.delegate = self;
        if (indexPath.section == 0) {
            caCell.textField.enabled = NO;
            caCell.textField.text = self.selectedKey;
        } else {
            caCell.textField.enabled = YES;
            NSString *address = self.result[self.envConfig[self.selectedKey][indexPath.section-1][@"name"]];
            caCell.textField.text = address;
        }
    } else if ( tabIndex == 2 && [self.extendDelegate respondsToSelector:@selector(titleForRowInExtendView:)]) {
        STLogCell *logCell = cell;
        logCell.textField.enabled = NO;
        logCell.textField.text = [self.extendDelegate titleForRowInExtendView:indexPath.row];
    }
    return cell;
}

- (void)mutiTabView:(STDebugMutiTabView *)mutiTabView didSelectRowAtIndexPath:(NSIndexPath *)indexPath tabIndex:(NSUInteger)tabIndex {
    UITableView *table = [mutiTabView tableViewWithTabIndex:tabIndex];
    if (tabIndex == 0) {
    } else if (tabIndex == 1) {
        [table deselectRowAtIndexPath:indexPath animated:YES];
        if (!indexPath.section) {
            self.picker.hidden = NO;
        }
    }
    if (tabIndex == 2) {
        [table deselectRowAtIndexPath:indexPath animated:YES];
        if ([self.extendDelegate respondsToSelector:@selector(didSelectRowInExtendView:)]) {
            [self.extendDelegate didSelectRowInExtendView:indexPath.row];
        }
    }
}

- (void)mutiTabView:(STDebugMutiTabView *)mutiTabView didEndDraggingAtTabIndex:(NSUInteger)tabIndex {
    if (!tabIndex) {
        UITableView *table = [mutiTabView tableViewWithTabIndex:0];
        self.shouldAutoScrollToEnd = table.contentSize.height - table.contentOffset.y < table.frame.size.height+16;
    }
    
}

#pragma mark ======== STLogToolDelegate ========
- (void)logTool:(STLogTool *)logTool shouldShowNewLogs:(NSArray<NSString *> *)logs {
    self.countOfReload += logs.count;
    self.shouldReload = YES;
    [self.allLogs addObjectsFromArray:logs];
}

- (void)logTool:(STLogTool *)logTool reloadCompletedWithLogs:(NSArray<NSString *> *)logs {
    self.countOfReload += logs.count;
    self.shouldReload = YES;
    [self.allLogs removeAllObjects];
    [self.allLogs addObjectsFromArray:logs];
}

- (void)logToolFormatCompleted:(STLogTool *)logTool {
    [self reloadLog];
    self.disableView.hidden = YES;
    [self.activityIndicator stopAnimating];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.frame.size.width && fabs(self.frame.size.width - [STLogTool shared].formatWidth - 40) < 1) {
        return;
    }
    self.disableView.hidden = NO;
    [self.activityIndicator startAnimating];
    [self bringSubviewToFront:self.disableView];
    [[STLogTool shared] setFormatWidth:self.frame.size.width-40];
}

- (void)timerAction:(NSTimer *)sender {
    if (sender == self.freshTimer) {
        if (!self.shouldReload) {
            return;
        }
        UITableView *table = [self.mutiTabView tableViewWithTabIndex:0];
        [self reloadLog];
        self.shouldReload = NO;
        if (!self.shouldAutoScrollToEnd) {
            return;
        }
        [table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.allLogs.count?self.allLogs.count-1:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:self.countOfReload<50];
        self.countOfReload = 0;
    }
}

- (void)enableFreshTimer:(BOOL)enable {
    if (enable) {
        self.freshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
        [self reloadLog];
    } else {
        [self.freshTimer invalidate];
    }
}

- (void)dealloc {
    [self.freshTimer invalidate];
}

- (void)searchLog:(NSString *)log {
    self.lastSearchText = log;
    self.lastSearchItor = [self.allLogs reverseObjectEnumerator];
    self.lastSearchIndex = self.allLogs.count;
    [self searchNext];
    
}

- (void)searchNext {
    NSString *str = nil;
    NSString *secondLine = self.lastSearchItor.nextObject;
    NSString *firstLine = self.lastSearchItor.nextObject;
    self.lastSearchIndex -= 2;
    str = firstLine;
    if (str) {
        str = [str stringByAppendingString:secondLine];
    } else {
        str = secondLine;
    }
    while (str) {
        if(self.lastSearchIndex<0){
            self.lastSearchIndex = 0;
        }
        if ([str rangeOfString:self.lastSearchText].location != NSNotFound) {
            UITableView *table = [self.mutiTabView tableViewWithTabIndex:0];
            [table selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.lastSearchIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            if (self.lastSearchIndex+1<self.allLogs.count) {
                [table selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.lastSearchIndex+1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            [table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.lastSearchIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            self.shouldAutoScrollToEnd = NO;
            return;
        }
        secondLine = firstLine;
        firstLine = self.lastSearchItor.nextObject;
        str = firstLine;
        if (str) {
            str = [str stringByAppendingString:secondLine];
        } else {
            str = secondLine;
        }
        self.lastSearchIndex --;
    }
    if (!str) {
        self.lastSearchItor = [self.allLogs reverseObjectEnumerator];
        self.lastSearchIndex = self.allLogs.count;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.allKeys.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.allKeys[row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.picker.hidden = YES;
    self.selectedKey = self.allKeys[row];
    NSArray <NSDictionary*>* selectedDefaultArray = self.envConfig[self.selectedKey];
    self.result = [NSMutableDictionary dictionaryWithCapacity:64];
    for (NSDictionary *dic in selectedDefaultArray) {
        [self.result setObject:dic[@"url"] ?: @"" forKey:dic[@"name"] ?: @""];
    }
    [[self.mutiTabView tableViewWithTabIndex:1] reloadData];
}

- (UIView *)picker {
    if (!_picker) {
        UIView *view = [[UIView alloc] init];
        _picker = view;
        view.backgroundColor = [UIColor colorWithRed:210/256.0 green:213/256.0 blue:218/256.0 alpha:0.95];
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(@0);
            make.height.equalTo(@250);
        }];
        
        UIView *header = [[UIView alloc] init];
        header.backgroundColor = RGBCOLOR(240, 240, 240);
        header.layer.borderColor=RGBCOLOR(191, 192, 194).CGColor;
        header.layer.borderWidth = 1;
        [view addSubview:header];
        [header mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(@0);
            make.height.equalTo(@50);
        }];
        UILabel *label = [[UILabel alloc] init];
        label.text = @"请选择主要环境";
        [header addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(@0);
        }];
        
        UIPickerView * picker = [[UIPickerView alloc] init];
        picker.delegate = self;
        picker.dataSource = self;
        [view addSubview:picker];
        [picker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(@0);
            make.top.equalTo(header.mas_bottom);
        }];
        
    }
    return _picker;
}

- (void)saveEnv {
    [[NSUserDefaults standardUserDefaults] setObject:self.result forKey:kEnvirmentStorageKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.selectedKey?:@"" forKey:kMainEnvStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)reloadLog {
    UITableView *table = [self.mutiTabView tableViewWithTabIndex:0];
    NSArray *selectedIndexPathes = table.indexPathsForSelectedRows;
    [table reloadData];
    for (NSIndexPath *indexPath in selectedIndexPathes) {
        [table selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (!textField.tag) {
        return YES;
    }
    NSString *key = self.envConfig[self.selectedKey][textField.tag-1][@"name"];
    [self.result setObject:textField.text forKey:key];
    return YES;
}

@end
