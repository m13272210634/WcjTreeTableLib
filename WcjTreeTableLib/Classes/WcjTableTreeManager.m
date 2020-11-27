//
//  WcjTableTreeManager.m
//  WJDemo
//
//  Created by 王纯杰 on 2020/11/26.
//  Copyright © 2020 王纯杰. All rights reserved.
//

#import "WcjTableTreeManager.h"

@interface WcjTableTreeManager()

@property (nonatomic, strong) NSMutableDictionary<NSString *, id<WcjTableTreeItemProtocol>> *itemsMap;
@property (nonatomic, strong) NSMutableArray < id<WcjTableTreeItemProtocol>>*topItems;
@property (nonatomic, strong) NSMutableArray < id<WcjTableTreeItemProtocol>>*tmpItems;
@property (nonatomic, assign) NSInteger maxLevel;   // 获取最大等级
@property (nonatomic, assign) NSInteger showLevel;  // 设置最大的等级
@property(nonatomic, assign)NSInteger  normalLevel;

@end
@implementation WcjTableTreeManager

- (instancetype)initWithItems:(NSArray<id<WcjTableTreeItemProtocol>> *)items andExpandLevel:(NSInteger)level{
    self = [super init];
    if (self) {
        [self initioanData:items ExpandLevel:level];
    }
    return self;
}

- (void)initioanData:(NSArray*)items ExpandLevel:(NSInteger)level{
    // 1. 建立 MAP
    [self setupItemsMapByItems:items];
    
    // 2. 建立父子关系，并得到顶级节点
    [self setupTopItemsWithFilterField:nil];
    
    // 3. 设置等级
    [self setupItemsLevel];
    
    // 4. 根据展开等级设置 showItems
    [self setupShowItemsWithShowLevel:level];
    
    self.normalLevel = level;
}

//下拉刷新
- (void)refreshPullDown:(NSMutableArray*)dataArray andExpandLevel:(NSInteger)level{
    [self.allItems removeAllObjects];
    [self.showItems removeAllObjects];
    [self.topItems removeAllObjects];
    [self.tmpItems removeAllObjects];
    self.itemsMap = nil;
    [self initioanData:dataArray ExpandLevel:self.normalLevel];
}

//上拉
- (void)refreshLoadMore:(NSMutableArray*)dataArray andExpandLevel:(NSInteger)level{
    [self initioanData:dataArray ExpandLevel:self.normalLevel];
}

// 根据 id 获取 item
- (id<WcjTableTreeItemProtocol> )getItemById:(NSString *)itemId {
    
    if (itemId) {
        return self.itemsMap[itemId];
    } else {
        return nil;
    }
}

// 建立 MAP
- (void)setupItemsMapByItems:(NSArray *)items {
    NSMutableDictionary *itemsMap = [NSMutableDictionary dictionary];
    for (id<WcjTableTreeItemProtocol> item in items) {
        [itemsMap setObject:item forKey:item.ID];
    }
    if (self.itemsMap == nil) {
        self.itemsMap = [[NSMutableDictionary alloc]initWithDictionary:itemsMap];
    }else{
        [self.itemsMap setValuesForKeysWithDictionary:itemsMap];
    }
}

// 建立父子关系，并得到顶级节点
- (void)setupTopItemsWithFilterField:(NSString *)field {
    
    self.tmpItems = self.itemsMap.allValues.mutableCopy;
    // 建立父子关系
    NSMutableArray *topItems = [NSMutableArray array];
    for ( id<WcjTableTreeItemProtocol> item in self.tmpItems) {
        item.isExpand = NO;
        id<WcjTableTreeItemProtocol> parent = self.itemsMap[item.parentID];
        if (parent) { // 根据parent判断是否是顶级节点
            item.parentItem = parent;
            if (![parent.childItems containsObject:item]) {
                [parent.childItems addObject:item];
            }
        } else {
            [topItems addObject:item];
        }
    }
    
    // 顶级节点排序
    self.topItems = [topItems sortedArrayUsingComparator:^NSComparisonResult( id<WcjTableTreeItemProtocol> obj1,  id<WcjTableTreeItemProtocol> obj2) {
        return [obj1.orderNo compare:obj2.orderNo];
    }].mutableCopy;
    
    // 所有 item 排序
    for ( id<WcjTableTreeItemProtocol> item in self.tmpItems) {
        item.childItems = [item.childItems sortedArrayUsingComparator:^NSComparisonResult( id<WcjTableTreeItemProtocol> obj1,  id<WcjTableTreeItemProtocol> obj2) {
            return [obj1.orderNo compare:obj2.orderNo];
        }].mutableCopy;
    }
}

// 设置等级
- (void)setupItemsLevel {
    for ( id<WcjTableTreeItemProtocol> item in self.tmpItems) {
        int tmpLevel = 0;
        id<WcjTableTreeItemProtocol> p = item.parentItem;
        while (p) {
            tmpLevel++;
            p = p.parentItem;
        }
        item.level = tmpLevel;
        // 设置最大等级
        _maxLevel = MAX(_maxLevel, tmpLevel);
    }
}

// 根据展开等级设置 showItems
- (void)setupShowItemsWithShowLevel:(NSInteger)level {
    
    _showLevel = MAX(level, 0);
    _showLevel = MIN(level, _maxLevel);
    
    NSMutableArray *showItems = [NSMutableArray array];
    for ( id<WcjTableTreeItemProtocol> item in self.topItems) {
        [self addItem:item toShowItems:showItems andAllowShowLevel:_showLevel];
    }
    _showItems = showItems;
}

//添加要显示的数组到数组中
- (void)addItem:(id<WcjTableTreeItemProtocol>)item toShowItems:(NSMutableArray *)showItems andAllowShowLevel:(NSInteger)level {
    if (item.level <= level) {
        [showItems addObject:item];
        item.isExpand = !(item.level == level);
        item.childItems = [item.childItems sortedArrayUsingComparator:^NSComparisonResult(id<WcjTableTreeItemProtocol> obj1, id<WcjTableTreeItemProtocol> obj2) {
            return [obj1.orderNo compare:obj2.orderNo];
        }].mutableCopy;
        
        //递归查找所有要显示的item加入数组
        for (id<WcjTableTreeItemProtocol> childItem in item.childItems) {
            [self addItem:childItem toShowItems:showItems andAllowShowLevel:level];
        }
    }
}

// 获取所有已经勾选的 item
- (NSArray<id<WcjTableTreeItemProtocol>> *)allCheckItem {
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    for (id<WcjTableTreeItemProtocol> item in _showItems) {
        // 防止重复遍历
        if (item.level == 0) {
            [self getAllCheckItem:tmpArray andItem:item];
        }
    }
    
    return tmpArray.copy;
}

// 展开/收起 Item，返回所改变的 Item 的个数
- (NSInteger)expandItem:(id<WcjTableTreeItemProtocol>)item {
    return [self expandItem:item isExpand:!item.isExpand];
}

- (NSInteger)expandItem:(id<WcjTableTreeItemProtocol>)item isExpand:(BOOL)isExpand {
    
    if (item.isExpand == isExpand) return 0;
    item.isExpand = isExpand;
    NSMutableArray *tmpArray = [NSMutableArray array];
    // 如果展开
    if (isExpand) {
        for (id<WcjTableTreeItemProtocol> tmpItem in item.childItems) {//把子节点展开
            [self addItem:tmpItem toTmpItems:tmpArray]; //把子节点加入显示的数组
        }
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self.showItems indexOfObject:item] + 1, tmpArray.count)];
        [self.showItems insertObjects:tmpArray atIndexes:indexSet];
    }
    // 如果折叠
    else {
        for (id<WcjTableTreeItemProtocol> tmpItem in self.showItems) {
            BOOL isParent = NO;
            id<WcjTableTreeItemProtocol> parentItem = tmpItem.parentItem;
            while (parentItem) { //不是顶级节点的情况
                if (parentItem == item) {
                    isParent = YES;
                    break;
                }
                parentItem = parentItem.parentItem;
            }
            if (isParent) {
                [tmpArray addObject:tmpItem];
            }
        }
        [self.showItems removeObjectsInArray:tmpArray];
    }
    
    return tmpArray.count;
}

//把展开的字节点加入到显示的数组中
- (void)addItem:(id<WcjTableTreeItemProtocol>)item toTmpItems:(NSMutableArray *)tmpItems {
    [tmpItems addObject:item];
    if (item.isExpand) {
        item.childItems = [item.childItems sortedArrayUsingComparator:^NSComparisonResult(id<WcjTableTreeItemProtocol> obj1, id<WcjTableTreeItemProtocol> obj2) {
            return [obj1.orderNo compare:obj2.orderNo];
        }].mutableCopy;
        for (id<WcjTableTreeItemProtocol> tmpItem in item.childItems) {
            [self addItem:tmpItem toTmpItems:tmpItems];//递归添加
        }
    }
}

// 展开/折叠到多少层级
- (void)expandItemWithLevel:(NSInteger)expandLevel completed:(void (^)(NSArray *))noExpandCompleted andCompleted:(void (^)(NSArray *))expandCompleted {
    
    expandLevel = MAX(expandLevel, 0);
    expandLevel = MIN(expandLevel, self.maxLevel);
    
    // 先一级一级折叠
    for (NSInteger level = self.maxLevel; level >= expandLevel; level--) {
        
        NSMutableArray *itemArray = [NSMutableArray array];
        for (NSInteger i = 0; i < self.showItems.count; i++) {
            
            id<WcjTableTreeItemProtocol> item = self.showItems[i];
            if (item.isExpand && item.level == level) {
                [itemArray addObject:item];
            }
        }
        
        if (itemArray.count) {
            if (noExpandCompleted) {
                noExpandCompleted(itemArray);
            }
        }
    }
    
    // 再一级一级展开
    for (NSInteger level = 0; level < expandLevel; level++) {
        
        NSMutableArray *itemArray = [NSMutableArray array];
        for (NSInteger i = 0; i < self.showItems.count; i++) {
            
            id<WcjTableTreeItemProtocol> item = self.showItems[i];
            if (!item.isExpand && item.level == level) {
                [itemArray addObject:item];
            }
        }
        
        if (itemArray.count) {
            if (expandCompleted) {
                expandCompleted(itemArray);
            }
        }
    }
}

// 递归，将已经勾选的 Item 添加到临时数组中
- (void)getAllCheckItem:(NSMutableArray <id<WcjTableTreeItemProtocol>>*)tmpArray andItem:(id<WcjTableTreeItemProtocol>)tmpItem {
    
    if (tmpItem.checkState == TreeItemDefault) return;
    if (tmpItem.checkState == TreeItemChecked) [tmpArray addObject:tmpItem];
    
    for (id<WcjTableTreeItemProtocol> item in tmpItem.childItems) {
        [self getAllCheckItem:tmpArray andItem:item];
    }
}

- (void)checkItem:(id<WcjTableTreeItemProtocol>)item isChildItemCheck:(BOOL)isChildItemCheck {
    [self checkItem:item isCheck:!(item.checkState == TreeItemChecked) isChildItemCheck:isChildItemCheck];
}

- (void)checkItem:(id<WcjTableTreeItemProtocol>)item isCheck:(BOOL)isCheck isChildItemCheck:(BOOL)isChildItemCheck {
    
    if (item.checkState == TreeItemChecked && isCheck) return;
    if (item.checkState == TreeItemDefault && !isCheck) return;
    
    // 勾选/取消勾选所有子 item
    [self checkChildItemWithItem:item isCheck:isCheck isChildItemCheck:isChildItemCheck];
    // 刷新父 item 勾选状态
    [self refreshParentItemWithItem:item isChildItemCheck:isChildItemCheck];
}

// 递归，勾选/取消勾选子 item
- (void)checkChildItemWithItem:(id<WcjTableTreeItemProtocol> )item isCheck:(BOOL)isCheck isChildItemCheck:(BOOL)isChildItemCheck {
    
    item.checkState = isCheck ? TreeItemChecked : TreeItemDefault;
    
    for (id<WcjTableTreeItemProtocol> tmpItem in item.childItems) {
        // 如果是多选，勾选了 item 可以作用于子 item
        if (isChildItemCheck) {
            [self checkChildItemWithItem:tmpItem isCheck:isCheck isChildItemCheck:isChildItemCheck];
        } else {
            [self checkChildItemWithItem:tmpItem isCheck:NO isChildItemCheck:isChildItemCheck];
        }
    }
}

// 递归，刷新父 item 勾选状态
- (void)refreshParentItemWithItem:(id<WcjTableTreeItemProtocol> )item isChildItemCheck:(BOOL)isChildItemCheck {
    
    if (isChildItemCheck) {
        
        NSInteger defaultNum = 0;
        NSInteger checkedNum = 0;
        
        for (id<WcjTableTreeItemProtocol> tmpItem in item.parentItem.childItems) {
            
            switch (tmpItem.checkState) {
                case TreeItemDefault:
                    defaultNum++;
                    break;
                case TreeItemChecked:
                    checkedNum++;
                    break;
                case TreeItemHalfChecked:
                    break;
            }
        }
        
        if (defaultNum == item.parentItem.childItems.count) {
            item.parentItem.checkState = TreeItemDefault;
        }
        else if (checkedNum == item.parentItem.childItems.count) {
            item.parentItem.checkState = TreeItemChecked;
        }
        else {
            item.parentItem.checkState = TreeItemHalfChecked;
        }
        
    } else {
        item.parentItem.checkState = TreeItemDefault;
    }
    
    if (item.parentItem) {
        [self refreshParentItemWithItem:item.parentItem isChildItemCheck:isChildItemCheck];
    }
}


@end
