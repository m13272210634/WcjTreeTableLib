//
//  WcjTableTreeView.m
//  WJDemo
//
//  Created by 王纯杰 on 2020/11/26.
//  Copyright © 2020 王纯杰. All rights reserved.
//

#import "WcjTableTreeView.h"

@interface WcjTableTreeView ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)UITableView*wcj_tableView;
@property(nonatomic, strong)WcjTableTreeManager*manager;
@end

@implementation WcjTableTreeView

- (instancetype)initWithFrame:(CGRect)frame manager:(WcjTableTreeManager*)manager style:(UITableViewStyle)style treeViewDelegate:(id<WcjTableTreeViewDelegate>)delegate{
    self = [super initWithFrame:frame];
    if (self) {
        _manager = manager;
        _delegate = delegate;
        [self buildView:style];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style treeViewDelegate:(id<WcjTableTreeViewDelegate>)delegate{
    self = [super initWithFrame:frame];
    if (self) {
        _delegate = delegate;
        _manager = [[WcjTableTreeManager alloc]init];
        [self buildView:style];
    }return self;
}

- (void)wcj_reloadData{
    if (self.delegate && [self.delegate respondsToSelector:@selector(treeViewCellCount:)]) {
        NSArray * array = [self.delegate treeViewCellCount:self];
        [self.manager initioanData:array ExpandLevel:0];
        [self.wcj_tableView reloadData];
    }
}

//外部传近来已选择的
- (void)setCheckItemIds:(NSArray<NSString *> *)checkItemIds{
    // 遍历外部传来的所选择的 itemId
    WcjTableTreeConfige * confige = [WcjTableTreeConfige shareConfige];
    for (NSString *itemId in self.checkItemIds) {
        id<WcjTableTreeItemProtocol> item = [self.manager getItemById:itemId];
        if (item) {
            // 1. 勾选所选择的节点
            [self.manager checkItem:item isCheck:YES isChildItemCheck:!confige.isSingleCheck];
            // 2. 展开所选择的节点
            if (confige.isExpandCheckedNode) {
                
                NSMutableArray *expandParentItems = [NSMutableArray array];
                
                id<WcjTableTreeItemProtocol> parentItem = item.parentItem;
                while (parentItem) {
                    [expandParentItems addObject:parentItem];
                    parentItem = parentItem.parentItem;
                }
                for (NSUInteger i = (expandParentItems.count - 1); i < expandParentItems.count; i--) {
                    [self.manager expandItem:expandParentItems[i] isExpand:YES];
                }
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.wcj_tableView reloadData];
    });
}

- (void)buildView:(UITableViewStyle)style{
    UITableView * tableView = [[UITableView alloc]initWithFrame:self.bounds style:style];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.wcj_tableView = tableView;
    [self addSubview:tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.manager.showItems.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id<WcjTableTreeItemProtocol> item = self.manager.showItems[indexPath.row];
    Class cls;
    if (self.delegate && [self.delegate respondsToSelector:@selector(treeViewCell:indexPath:)]) {
        cls = [self.delegate treeViewCell:self indexPath:indexPath];
    }else{
        cls = [WcjTableTreeCell class];
    }
    WcjTableTreeCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(cls)];
    if (cell == nil) {
        cell = [[cls alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:NSStringFromClass(cls)];
    }
    
    WcjTableTreeConfige * confige = [WcjTableTreeConfige shareConfige];
    
    if ((item.level < confige.levelColorArray.count) && confige.isShowLevelColor) {
        cell.backgroundColor = confige.levelColorArray[item.level];
    } else {
        cell.backgroundColor = confige.normalBackgroundColor;
    }
    
    if ([cell conformsToProtocol:@protocol(WcjTableTreeCellProtocol)]) {
        id<WcjTableTreeCellProtocol> _cell = cell;
        [_cell updateWith:item indexPath:indexPath];
        __weak typeof(self)weakSelf = self;
        _cell.checkButtonClickBlock = ^(id<WcjTableTreeItemProtocol>  _Nonnull item) {
            if (confige.isSingleCheck) {//单选
                if (confige.isCancelSingleCheck && (item.checkState == TreeItemChecked)) {// // 如果再次点击已经选中的 item 则取消选择
                    [weakSelf.manager checkItem:item isCheck:NO isChildItemCheck:NO];
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(tableView:checkItems:)]) {
                        [weakSelf.delegate tableView:self checkItems:@[]];
                    }
                }else{
                    [weakSelf.manager checkItem:item isCheck:YES isChildItemCheck:NO];
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(tableView:checkItems:)]) {
                        [weakSelf.delegate tableView:self checkItems:@[item]];
                    }
                }
            }else{//多选
                [weakSelf.manager checkItem:item isChildItemCheck:YES];
            }
            if ([weakSelf.delegate respondsToSelector:@selector(tableView:didSelectCheckBoxRowAtIndexPath:)]) {
                [weakSelf.delegate tableView:weakSelf didSelectCheckBoxRowAtIndexPath:indexPath];
            }
            [weakSelf.wcj_tableView reloadData];
        };
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id<WcjTableTreeItemProtocol> item = self.manager.showItems[indexPath.row];
    [self tableView:tableView didSelectItems:@[item] isExpand:!item.isExpand];
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate tableView:self didSelectRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectItems:(NSArray <id<WcjTableTreeItemProtocol>>*)items isExpand:(BOOL)isExpand {
    NSMutableArray *updateIndexPaths = [NSMutableArray array];
    NSMutableArray *editIndexPaths   = [NSMutableArray array];
    for ( id<WcjTableTreeItemProtocol> item in items) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.manager.showItems indexOfObject:item] inSection:0];
        [updateIndexPaths addObject:indexPath];
        NSInteger updateNum = [self.manager expandItem:item];
        NSArray *tmp = [self getUpdateIndexPathsWithCurrentIndexPath:indexPath andUpdateNum:updateNum];
        [editIndexPaths addObjectsFromArray:tmp];
    }
    
    if ([WcjTableTreeConfige shareConfige].isShowExpandedAnimation) {
        if (isExpand) {
            [tableView insertRowsAtIndexPaths:editIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [tableView deleteRowsAtIndexPaths:editIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } else {
        [tableView reloadData];
    }
    
    for (NSIndexPath *indexPath in updateIndexPaths) {
        WcjTableTreeCell *cell = (WcjTableTreeCell*)[tableView cellForRowAtIndexPath:indexPath];
        if ([cell conformsToProtocol:@protocol(WcjTableTreeCellProtocol)]) {
            id<WcjTableTreeCellProtocol> _cell = cell;
            [_cell updateItem];
        }
    }
}

- (NSArray <NSIndexPath *>*)getUpdateIndexPathsWithCurrentIndexPath:(NSIndexPath *)indexPath andUpdateNum:(NSInteger)updateNum {
    
    NSMutableArray *tmpIndexPaths = [NSMutableArray arrayWithCapacity:updateNum];
    for (int i = 0; i < updateNum; i++) {
        NSIndexPath *tmp = [NSIndexPath indexPathForRow:(indexPath.row + 1 + i) inSection:indexPath.section];
        [tmpIndexPaths addObject:tmp];
    }
    return tmpIndexPaths;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        [self.delegate tableView:self viewForHeaderInSection:section];
    }
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        [self.delegate tableView:self viewForFooterInSection:section];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        [self.delegate tableView:self heightForHeaderInSection:section];
    }
    return .1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        [self.delegate tableView:self heightForFooterInSection:section];
    }
    return .1;
}

//下拉刷新数据
- (void)refreshPullDown:(NSMutableArray*)dataArray andExpandLevel:(NSInteger)level{
    [self.manager refreshPullDown:dataArray andExpandLevel:level];
}
//上拉加载更多
- (void)refreshLoadMore:(NSMutableArray*)dataArray andExpandLevel:(NSInteger)level{
    [self.manager refreshLoadMore:dataArray andExpandLevel:level];
}

//所有选择
- (NSArray<id<WcjTableTreeItemProtocol>> *)wcj_getAllCheckItem{
    return [self.manager allCheckItem];
}


@end
