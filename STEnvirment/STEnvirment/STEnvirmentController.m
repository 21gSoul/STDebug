//
//  STEnvirmentController.m
//  STEnvirment
//
//  Created by 石破天 on 2017/7/17.
//  Copyright © 2017年 msxf. All rights reserved.
//

#import "STEnvirmentController.h"
#import "STMutiTabView.h"
#import "Masonry.h"
#import "STLogCell.h"
#import "common.h"
#import "STCustomAdressCell.h"

static NSString * const kEnvirmentStorageKey = @"com.stone.envirment.storagekey";
static NSString * const kMainEnvStorageKey = @"com.stone.mainenvirment.storagekey";


typedef NS_ENUM(NSInteger, STLogNavTag) {
    STLogNavTagDel,
    STLogNavTagAdd,
    STLogNavTagSearch,
    STLogNavTagDone
};

@interface STEnvirmentController ()<STMutiTabViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UIAlertViewDelegate>

@property (nonatomic, strong) NSDictionary *envConfig;
@property (nonatomic, strong) NSArray *allKeys;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *result;
@property (nonatomic, copy) NSString *selectedKey;
@property (nonatomic, strong) UIView *picker;
@property (nonatomic, strong) STMutiTabView *mutiTabView;
@property (nonatomic, strong) NSMutableArray <UITextField *>*urlLabels;
@property (nonatomic, strong) STLogCell *logCell;
@property (nonatomic, copy) NSString *lastSearchText;

@end

@implementation STEnvirmentController

+ (instancetype)shared {
    static STEnvirmentController *s_envirmentController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_envirmentController = [[[self class] alloc ]init];
    });
    return s_envirmentController;
}

+ (void)load {
    // 获取沙盒路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    // 获取打印输出文件路径
    NSString *fileName = [NSString stringWithFormat:@"log.txt"];
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    fileName = [NSString stringWithFormat:@"err.txt"];
//    NSString *errFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
//    // 先删除已经存在的文件
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:logFilePath error:nil];
    // 将NSLog的输出重定向到文件，因为C语言的printf打印是往stdout打印的，这里也把它重定向到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+", stderr);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    STMutiTabView *tab = [[STMutiTabView alloc] init];
    self.mutiTabView = tab;
    tab.titles = @[@"日志", @"环境", @"快捷功能"];
    self.title = @"DEBUG";
    tab.delegate = self;
    [self.view addSubview:tab];
    [tab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    self.urlLabels=[NSMutableArray arrayWithCapacity:32];
    self.result = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kEnvirmentStorageKey]];
    self.selectedKey = [[NSUserDefaults standardUserDefaults] objectForKey:kMainEnvStorageKey];
}

- (void)mutiTabView:(STMutiTabView *)mutiTabView didSelectIndexFrom:(NSInteger)fromIndex changeTo:(NSInteger)toIndex {
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_didButtonClick:)];
    done.tag = STLogNavTagDone;
    if (!toIndex) {
        UIBarButtonItem *del = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(_didButtonClick:)];
        del.tag = STLogNavTagDel;
        UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(_didButtonClick:)];
        add.tag = STLogNavTagAdd;
        UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(_didButtonClick:)];
        search.tag = STLogNavTagSearch;
        self.navigationItem.leftBarButtonItems = @[search,del];
        self.navigationItem.rightBarButtonItems = @[done,add];
    } else {
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.rightBarButtonItems = @[done];
    }
}


- (void)mutiTabView:(STMutiTabView *)mutiTabView beginToRefreshAtTabIndex:(NSUInteger)tabIndex {
    UITableView *table = [mutiTabView tableViewWithTabIndex:tabIndex];
    [table reloadData];
    [table endRefreshing];
    
}

- (NSInteger)numberOfSectionsInMutiTabView:(STMutiTabView *)mutiTabView atTabIndex:(NSUInteger)tabIndex {
    if (tabIndex == 1) {
        if (!self.selectedKey.length) {
            self.selectedKey = [self.allKeys firstObject];
        }
        NSArray *arr = self.envConfig[self.selectedKey];
        return arr.count + 1;
    }
    return 1;
}

- (NSInteger)mutiTabView:(STMutiTabView *)mutiTabView numberOfRowsInSection:(NSInteger)section tabIndex:(NSUInteger)tabIndex {
    return 1;
}

- (CGFloat)mutiTabView:(STMutiTabView *)mutiTabView heightForHeaderInSection:(NSInteger)section atTabIndex:(NSUInteger)tabIndex {
    if (tabIndex == 1) {
        return 40;
    }
    return 0;
}

- (UIView *)mutiTabView:(STMutiTabView *)mutiTabView viewForHeaderInSection:(NSInteger)section atTabIndex:(NSUInteger)tabIndex {
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

- (CGFloat)mutiTabView:(STMutiTabView *)mutiTabView heightForRowAtIndexPath:(NSIndexPath *)indexPath tabIndex:(NSUInteger)tabIndex {
    if (tabIndex == 0) {
        return [mutiTabView tableViewWithTabIndex:tabIndex].frame.size.height;
    }
    return 40;
}

- (UITableViewCell *)mutiTabView:(STMutiTabView *)mutiTabView cellForRowAtIndexPath:(NSIndexPath *)indexPath tabIndex:(NSUInteger)tabIndex {
    NSString *idf = @"cell";
    if (tabIndex == 0) {
        idf = @"STLogCell";
    } else if (tabIndex == 1) {
        idf = @"STCustomAdressCell";
    }
    __kindof UITableViewCell *cell = [[mutiTabView tableViewWithTabIndex:tabIndex] dequeueReusableCellWithIdentifier:idf];
    if (!cell) {
        if (tabIndex == 0) {
            STLogCell *logCell = [[STLogCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idf];
            cell =logCell;
            self.logCell = logCell;
            
        } else if (tabIndex == 1) {
            cell = [[STCustomAdressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idf];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idf];
            
        }
    }
    if (tabIndex == 0) {
        STLogCell *logCell = cell;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSString *fileName = [NSString stringWithFormat:@"log.txt"];
        NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
        NSString *text = [NSString stringWithContentsOfFile:logFilePath encoding:NSASCIIStringEncoding error:nil];
        [logCell setLog:text?:@""];
    } else  if (tabIndex == 1) {
        STCustomAdressCell *caCell = cell;
        if (indexPath.section == 0) {
            [caCell setEditable:NO];
            [caCell setAddress:self.selectedKey];
        } else {
            [caCell setEditable:YES];
            if (self.result.count) {
                
                NSString *address = self.result[self.envConfig[self.selectedKey][indexPath.section-1][@"name"]];
                [caCell setAddress:address];
            } else {
                [caCell setAddress: self.envConfig[self.selectedKey][indexPath.section-1][@"url"]];
            }
            self.urlLabels[indexPath.section-1] = caCell.textField;
        }
    }
    return cell;
}

- (void)mutiTabView:(STMutiTabView *)mutiTabView didSelectRowAtIndexPath:(NSIndexPath *)indexPath tabIndex:(NSUInteger)tabIndex {
    [[mutiTabView tableViewWithTabIndex:tabIndex] deselectRowAtIndexPath:indexPath animated:YES];
    if (tabIndex == 1) {
        if (!indexPath.section) {
            self.picker.hidden = NO;
            if ([self.allKeys indexOfObject:self.selectedKey] != NSNotFound) {
//                [self.picker selectRow:[self.allKeys indexOfObject:self.selectedKey]  inComponent:0 animated:YES];
            }
        }
    }
}

- (BOOL)mutiTabView:(STMutiTabView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath atTabIndex:(NSUInteger)tabIndex {
    if (tabIndex != 1) {
        return NO;
    }
    return indexPath.section;
}

- (void)mutiTabView:(STMutiTabView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath atTabIndex:(NSUInteger)tabIndex {
    
}

- (NSString *)mutiTabView:(STMutiTabView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath atTabIndex:(NSUInteger)tabIndex {
    return @"清空";
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
    [self.result removeAllObjects];
    [[self.mutiTabView tableViewWithTabIndex:1] reloadData];
}



+ (void)showWithEnvConfig:(NSDictionary *)config {
    STEnvirmentController *controller = [STEnvirmentController shared];
    controller.envConfig = config;
    controller.allKeys = [config.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    UINavigationController *nav =[[UINavigationController alloc] initWithRootViewController:controller];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
    
}

- (void) _didButtonClick:(id) sender {
    UIBarButtonItem *item = sender;
    switch (item.tag) {
        case STLogNavTagAdd:
            NSLog(@"------------separator---------------");
            self.lastSearchText = nil;
            [[self.mutiTabView tableViewWithTabIndex:0] reloadData];
            break;
        case STLogNavTagDone:
            [self.result removeAllObjects];
            for (NSInteger i=0; i<[self.envConfig[self.selectedKey] count]; ++i) {
                [self.result setObject:self.urlLabels[i].text?:@"" forKey:self.envConfig[self.selectedKey][i][@"name"]?:@""];
            }
            [[NSUserDefaults standardUserDefaults] setObject:self.result forKey:kEnvirmentStorageKey];
            [[NSUserDefaults standardUserDefaults] setObject:self.selectedKey?:@"" forKey:kMainEnvStorageKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            break;
        case STLogNavTagDel:
            [self deleteLog];
            break;
        case STLogNavTagSearch:
            [self beginSearch];
            break;
        default:
            break;
    }
    if (item.tag == 2) {
        
    }

}

- (UIView *)picker {
    if (!_picker) {
        UIView *view = [[UIView alloc] init];
        _picker = view;
        view.backgroundColor = [UIColor colorWithRed:210/256.0 green:213/256.0 blue:218/256.0 alpha:0.95];
        [self.view addSubview:view];
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

+ (NSDictionary *)envirment {
    return [STEnvirmentController shared].result;
}

+ (void)showWithConfigFile:(NSString *)fileName {
    NSString *fullPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithContentsOfFile:fullPath];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    [self showWithEnvConfig:dic];
}

- (void) beginSearch {
    if (self.lastSearchText) {
        [self.logCell searchNext];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请输入查找的字符串（支持正则表达式）" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查找", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex) {
        self.lastSearchText = [alertView textFieldAtIndex:0].text;
        [self.logCell searchText:self.lastSearchText];
        
    }
}

- (void)deleteLog {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"log.txt"];
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] removeItemAtPath:logFilePath error:nil];
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+", stderr);
    [[self.mutiTabView tableViewWithTabIndex:0] reloadData];
}

@end
