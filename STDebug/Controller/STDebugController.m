//
//  STDebugController.m
//  STDebug
//
//  Created by 石破天 on 2017/7/26.
//  Copyright © 2017年 stone. All rights reserved.
//

#import "STDebugController.h"
#import "STDebugView.h"
#import "STLogTool.h"

typedef NS_ENUM(NSInteger, STLogNavTag) {
    STLogNavTagDel,
    STLogNavTagAdd,
    STLogNavTagSearch,
    STLogNavTagDone,
    STLogNavTagSwitch
};

extern NSString * const kEnvirmentStorageKey;
extern NSString * const kMainEnvStorageKey;
extern NSString * const kShouldLogKey;
extern NSString * const kFiltersKey;

@interface STDebugController ()<STDebugViewDelegate, STLogToolDelegate>

@property (nonatomic, strong) STDebugView *debugView;
@property (nonatomic, copy) NSString *lastSearchText;
@property (nonatomic, copy) NSString *selectedKey;
@property (nonatomic, assign) BOOL shouldRedirectLog;
@property (nonatomic, copy) NSArray <NSString *> *allKeys;

@end

@implementation STDebugController

+ (void)load {
    BOOL shouldRedirectLog = [[[NSUserDefaults standardUserDefaults] objectForKey:@"com.stone.STDebug.shouldRedirectLog"] boolValue];
    if (!shouldRedirectLog) {
        return;
    }
    STLogTool *tool = [STLogTool shared];
    [tool redirectFileDescriptor:STDERR_FILENO];
}

+ (instancetype)shared {
    static STDebugController *s_debugController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_debugController = [[STDebugController alloc] init];
    });
    return s_debugController;
}

- (instancetype)init {
    if (self = [super init]) {
        self.result = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kEnvirmentStorageKey]];
        self.selectedKey = [[NSUserDefaults standardUserDefaults] objectForKey:kMainEnvStorageKey];
        self.shouldRedirectLog = [[[NSUserDefaults standardUserDefaults] objectForKey:@"com.stone.STDebug.shouldRedirectLog"] boolValue];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"STDebug";
    self.debugView = [[STDebugView alloc] init];
    self.debugView.delegate = self;
    self.view = self.debugView;
    self.debugView.envConfig = self.envConfig;
    self.debugView.result = self.result;
    self.debugView.allKeys = self.allKeys;
    self.debugView.selectedKey = self.selectedKey;
    self.debugView.extendDelegate = self.extendDelegate;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
}

- (void)setEnvConfig:(NSDictionary *)envConfig {
    _envConfig = envConfig;
    self.allKeys = [self.envConfig.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    if ([self.allKeys indexOfObject:self.selectedKey] == NSNotFound) {
        self.selectedKey = self.allKeys.firstObject;
    }
    NSArray <NSDictionary*>* selectedDefaultArray = self.envConfig[self.selectedKey ?: @""];
    if (!self.result.count) {
        self.result = [NSMutableDictionary dictionaryWithCapacity:64];
        for (NSDictionary *dic in selectedDefaultArray) {
            [self.result setObject:dic[@"url"] ?: @"" forKey:dic[@"name"] ?: @""];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.debugView.shouldAutoScrollToEnd = YES;
    [self.debugView enableFreshTimer:YES];
    self.showing = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.debugView enableFreshTimer:NO];
    self.showing = NO;
}

#pragma mark ======== STDebugViewDelegate ========

- (void)debugView:(STDebugView *)debugView didSelectIndex:(NSUInteger)index {
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_didButtonClick:)];
    done.tag = STLogNavTagDone;
    if (!index) {
        UIBarButtonItem *del = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(_didButtonClick:)];
        del.tag = STLogNavTagDel;
        UIBarButtonSystemItem style = self.shouldRedirectLog ? UIBarButtonSystemItemPause : UIBarButtonSystemItemPlay;
        UIBarButtonItem *sw = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:style target:self action:@selector(_didButtonClick:)];
        sw.tag = STLogNavTagSwitch;
        
        UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(_didButtonClick:)];
        add.tag = STLogNavTagAdd;
        UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(_didButtonClick:)];
        search.tag = STLogNavTagSearch;
        self.navigationItem.leftBarButtonItems = @[search,del, sw];
        self.navigationItem.rightBarButtonItems = @[done,add];
    } else {
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.rightBarButtonItems = @[done];
    }
}

#pragma mark ======== ButtonAction ======== 
- (void) _didButtonClick:(id) sender {
    UIBarButtonItem *item = sender;
    switch (item.tag) {
        case STLogNavTagAdd:
            self.lastSearchText = nil;
            NSLog(@"-------------separator-------------");
            break;
        case STLogNavTagDone:
            [self.view endEditing:YES];
            [self.debugView saveEnv];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            break;
        case STLogNavTagDel:
            self.lastSearchText = nil;
            [[STLogTool shared] clearLogs];
            break;
        case STLogNavTagSearch:
            [self beginSearch];
            break;
        case STLogNavTagSwitch:
            self.shouldRedirectLog = !self.shouldRedirectLog;
            [self debugView:nil didSelectIndex:0];
            [[NSUserDefaults standardUserDefaults] setObject:@(self.shouldRedirectLog) forKey:@"com.stone.STDebug.shouldRedirectLog"];
            NSLog(self.shouldRedirectLog ? @"日志已开启，重启生效" : @"日志已关闭，重启生效");
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        default:
            break;
    }
}

#pragma mark ======== STLogToolDelegate ========

- (void) beginSearch {
    if (self.lastSearchText.length) {
        [self.debugView searchNext];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请输入查找的字符串（暂不支持正则表达式）" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查找", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex) {
        self.lastSearchText = [alertView textFieldAtIndex:0].text;
        [self.debugView searchLog:self.lastSearchText];
    }
}

@end
