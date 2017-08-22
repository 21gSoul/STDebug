//
//  STDebugMutiTabView.h
//  Finance
//
//  Created by 石破天 on 2016/12/30.
//  Copyright © 2016年 MaShang Consumer Finance. All rights reserved.
//


#import <UIKit/UIKit.h>


#define STMutiTabThemeColor [UIColor blueColor]
//  STDebugMutiTabView支持的两种tab样式，可同时选
typedef NS_OPTIONS(NSUInteger, STDebugMutiTabViewStyle){
    STDebugMutiTabViewStyleNone                  =0,         //不显示
    STDebugMutiTabViewStyleTopTab               = 1,        //顶部Tab样式
    STDebugMutiTabViewStyleBottomButton         = STDebugMutiTabViewStyleTopTab << 1    //底部button样式
};

@class STDebugMutiTabView;

@protocol STDebugMutiTabViewDelegate <NSObject>

@optional
-(CGFloat) mutiTabView:(STDebugMutiTabView *) mutiTabView heightForRowAtIndexPath:(NSIndexPath *) indexPath tabIndex:(NSUInteger) tabIndex;

- (NSInteger)numberOfSectionsInMutiTabView:(STDebugMutiTabView *)mutiTabView atTabIndex:(NSUInteger) tabIndex;

-(NSInteger) mutiTabView:(STDebugMutiTabView *) mutiTabView numberOfRowsInSection:(NSInteger)section tabIndex:(NSUInteger) tabIndex;

-(__kindof UITableViewCell *) mutiTabView:(STDebugMutiTabView *) mutiTabView cellForRowAtIndexPath:(NSIndexPath *) indexPath tabIndex:(NSUInteger) tabIndex;

-(void) mutiTabView:(STDebugMutiTabView *) mutiTabView didSelectRowAtIndexPath:(NSIndexPath *)indexPath tabIndex:(NSUInteger) tabIndex;

-(void) mutiTabView:(STDebugMutiTabView *) mutiTabView beginToRefreshAtTabIndex:(NSUInteger) tabIndex;

-(void) mutiTabView:(STDebugMutiTabView *) mutiTabView beginToLoadMoreInPage:(NSUInteger)pageIndex atTabIndex:(NSUInteger) tabIndex;

- (void) mutiTabView:(STDebugMutiTabView *) mutiTabView didSelectIndexFrom:(NSInteger) fromIndex changeTo:(NSInteger)toIndex;

- (__kindof UIView *)mutiTabView:(STDebugMutiTabView *)mutiTabView viewForHeaderInSection:(NSInteger)section atTabIndex:(NSUInteger)tabIndex;

- (CGFloat)mutiTabView:(STDebugMutiTabView *)mutiTabView heightForHeaderInSection:(NSInteger)section atTabIndex:(NSUInteger)tabIndex;

- (BOOL)mutiTabView:(STDebugMutiTabView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath atTabIndex:(NSUInteger)tabIndex;

- (void)mutiTabView:(STDebugMutiTabView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath atTabIndex:(NSUInteger)tabIndex;

- (NSString *)mutiTabView:(STDebugMutiTabView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath atTabIndex:(NSUInteger)tabIndex;
- (void)mutiTabView:(STDebugMutiTabView *)mutiTabView didEndDraggingAtTabIndex:(NSUInteger) tabIndex;

@end


@interface STDebugMutiTabView : UIView

@property (nonatomic, assign, readonly) NSUInteger tabCount;
@property (nonatomic, assign, readwrite) NSUInteger selectedIndex;
@property (nonatomic, strong, readwrite) UIColor *selectedColor;          //标题选定及指示器颜色
@property (nonatomic, strong, readwrite) UIColor *titleColor;             //标题未选定颜色
@property (nonatomic, strong, readwrite) UIColor *themeColor;             //页面背景色
@property (nonatomic, assign, readwrite) STDebugMutiTabViewStyle style;      //tab页样式,默认为STDebugMutiTabViewStyleTopTab
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) NSArray<UIView *> *emptyViews;
@property (nonatomic, copy) NSArray<NSString *> *titles;
@property (nonatomic, weak) id<STDebugMutiTabViewDelegate> delegate;

- (UITableView *) tableViewWithTabIndex:(NSUInteger) tabIndex;

- (void) setSelectedIndexWithoutAnimation:(NSUInteger) selectedIndex;

- (void) reloadData;

//- (void) endRefreshing;
@end


@interface UITableView (STDebugMutiTabView)
//- (void) beginRefreshing;
//- (void) endRefreshing;
@end
