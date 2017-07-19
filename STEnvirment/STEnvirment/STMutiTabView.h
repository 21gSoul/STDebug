//
//  STMutiTabView.h
//  Finance
//
//  Created by 石破天 on 2016/12/30.
//  Copyright © 2016年 MaShang Consumer Finance. All rights reserved.
//
//  STMutiTabView，一个支持多标签页的View，支持的功能如下：
//  1. 支持下拉刷新，上拉加载更多，只需要实现代理中的mutiTabView: beginToRefreshAtTabIndex:
//      和mutiTabView: beginToLoadMoreInPage: atTabIndex:方法即可
//  2. 支持左右滑动页面切换标签
//  3. 支持任意数量的标签页和任意长度的标题，自动排版
//  4. 支持顶部标签和底部按钮形式标签
//  5. 支持页面无数据时自动使用空视图填充
//  6. 支持属性变化，自动更新视图
//
//  看头文件即可快速掌握用法，或参考STMyLoanViewController.m
//  高封装可复用，非作者请勿修改, 作者  xizhu.lu@msxf.com


#import <UIKit/UIKit.h>


#define STMutiTabThemeColor [UIColor blueColor]
//  STMutiTabView支持的两种tab样式，可同时选
typedef NS_OPTIONS(NSUInteger, STMutiTabViewStyle){
    STMutiTabViewStyleNone                  =0,         //不显示
    STMutiTabViewStyleTopTab               = 1,        //顶部Tab样式
    STMutiTabViewStyleBottomButton         = STMutiTabViewStyleTopTab << 1    //底部button样式
};

@class STMutiTabView;

@protocol STMutiTabViewDelegate <NSObject>

@optional
-(CGFloat) mutiTabView:(STMutiTabView *) mutiTabView heightForRowAtIndexPath:(NSIndexPath *) indexPath tabIndex:(NSUInteger) tabIndex;

- (NSInteger)numberOfSectionsInMutiTabView:(STMutiTabView *)mutiTabView atTabIndex:(NSUInteger) tabIndex;

-(NSInteger) mutiTabView:(STMutiTabView *) mutiTabView numberOfRowsInSection:(NSInteger)section tabIndex:(NSUInteger) tabIndex;

-(__kindof UITableViewCell *) mutiTabView:(STMutiTabView *) mutiTabView cellForRowAtIndexPath:(NSIndexPath *) indexPath tabIndex:(NSUInteger) tabIndex;

-(void) mutiTabView:(STMutiTabView *) mutiTabView didSelectRowAtIndexPath:(NSIndexPath *)indexPath tabIndex:(NSUInteger) tabIndex;

-(void) mutiTabView:(STMutiTabView *) mutiTabView beginToRefreshAtTabIndex:(NSUInteger) tabIndex;

-(void) mutiTabView:(STMutiTabView *) mutiTabView beginToLoadMoreInPage:(NSUInteger)pageIndex atTabIndex:(NSUInteger) tabIndex;

- (void) mutiTabView:(STMutiTabView *) mutiTabView didSelectIndexFrom:(NSInteger) fromIndex changeTo:(NSInteger)toIndex;

- (__kindof UIView *)mutiTabView:(STMutiTabView *)mutiTabView viewForHeaderInSection:(NSInteger)section atTabIndex:(NSUInteger)tabIndex;

- (CGFloat)mutiTabView:(STMutiTabView *)mutiTabView heightForHeaderInSection:(NSInteger)section atTabIndex:(NSUInteger)tabIndex;

- (BOOL)mutiTabView:(STMutiTabView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath atTabIndex:(NSUInteger)tabIndex;

- (void)mutiTabView:(STMutiTabView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath atTabIndex:(NSUInteger)tabIndex;

- (NSString *)mutiTabView:(STMutiTabView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath atTabIndex:(NSUInteger)tabIndex;
@end


@interface STMutiTabView : UIView

@property (nonatomic, assign, readonly) NSUInteger tabCount;
@property (nonatomic, assign, readwrite) NSUInteger selectedIndex;
@property (nonatomic, strong, readwrite) UIColor *selectedColor;          //标题选定及指示器颜色
@property (nonatomic, strong, readwrite) UIColor *titleColor;             //标题未选定颜色
@property (nonatomic, strong, readwrite) UIColor *themeColor;             //页面背景色
@property (nonatomic, assign, readwrite) STMutiTabViewStyle style;      //tab页样式,默认为STMutiTabViewStyleTopTab
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) NSArray<UIView *> *emptyViews;
@property (nonatomic, copy) NSArray<NSString *> *titles;
@property (nonatomic, weak) id<STMutiTabViewDelegate> delegate;

- (UITableView *) tableViewWithTabIndex:(NSUInteger) tabIndex;

- (void) setSelectedIndexWithoutAnimation:(NSUInteger) selectedIndex;

- (void) reloadData;

- (void) endRefreshing;
@end


@interface UITableView (STMutiTabView)
- (void) beginRefreshing;
- (void) endRefreshing;
@end
