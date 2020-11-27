//
//  WcjTableTreeView.h
//  WJDemo
//
//  Created by 王纯杰 on 2020/11/26.
//  Copyright © 2020 王纯杰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WcjTableTreeItemProtocol.h"
#import "WcjTableTreeManager.h"
#import "WcjTableTreeCell.h"
#import "WcjTableTreeConfige.h"

NS_ASSUME_NONNULL_BEGIN

@class WcjTableTreeView;

@protocol WcjTableTreeViewDelegate <NSObject>

@optional
//返回自己的cell
- (Class)treeViewCell:(WcjTableTreeView*)treeView indexPath:(NSIndexPath*)indexPath;
/** 如果是单选，点击 cell 会直接调用，如果是多选，通过 prepareCommit 方法会调用 */
- (void)tableView:(WcjTableTreeView *)treeView checkItems:(NSArray <id<WcjTableTreeItemProtocol>>*)items;
/** 监听 cell 点击事件 */
- (void)tableView:(WcjTableTreeView *)treeView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
/** 监听 cell 的 checkbox 点击事件 */
- (void)tableView:(WcjTableTreeView *)treeView didSelectCheckBoxRowAtIndexPath:(NSIndexPath *)indexPath;
//headerView
- (UIView*)tableView:(WcjTableTreeView *)tableView viewForFooterInSection:(NSInteger)section;
//footerView
- (UIView*)tableView:(WcjTableTreeView *)tableView viewForHeaderInSection:(NSInteger)section;
//headerView高度
- (CGFloat)tableView:(WcjTableTreeView *)tableView heightForHeaderInSection:(NSInteger)section;
//footerView高度
- (CGFloat)tableView:(WcjTableTreeView *)tableView heightForFooterInSection:(NSInteger)section;

@end

@interface WcjTableTreeView : UIView

@property (nonatomic, strong) NSArray <NSString *>*checkItemIds;    // 从外部传进来的所选择的 itemIds

@property(nonatomic, weak)id<WcjTableTreeViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame manager:(WcjTableTreeManager*)manager style:(UITableViewStyle)style treeViewDelegate:(id<WcjTableTreeViewDelegate>)delegate;
//下拉刷新数据
- (void)refreshPullDown:(NSMutableArray*)dataArray andExpandLevel:(NSInteger)level;
//上拉加载更多
- (void)refreshLoadMore:(NSMutableArray*)dataArray andExpandLevel:(NSInteger)level;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
