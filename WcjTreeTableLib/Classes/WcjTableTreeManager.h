//
//  WcjTableTreeManager.h
//  WJDemo
//
//  Created by 王纯杰 on 2020/11/26.
//  Copyright © 2020 王纯杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WcjTableTreeItemProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface WcjTableTreeManager : NSObject

/** 获取所有的 items */
@property (nonatomic, strong, readonly) NSMutableArray<id<WcjTableTreeItemProtocol>> *allItems;
/** 获取可见的 items */
@property (nonatomic, strong, readonly) NSMutableArray<id<WcjTableTreeItemProtocol>> *showItems;
/** 获取所有已经勾选的 item */
@property (nonatomic, strong, readonly) NSArray<id<WcjTableTreeItemProtocol>> *allCheckItem;


- (instancetype)initWithItems:(NSArray<id<WcjTableTreeItemProtocol>> *)items andExpandLevel:(NSInteger)level;

/** 展开/收起 item，返回所改变的 item 的个数 */
- (NSInteger)expandItem:(id<WcjTableTreeItemProtocol>)item;

- (NSInteger)expandItem:(id<WcjTableTreeItemProtocol>)item isExpand:(BOOL)isExpand;
/** 勾选/取消勾选 item */
- (void)checkItem:(id<WcjTableTreeItemProtocol>)item isChildItemCheck:(BOOL)isChildItemCheck;

- (void)checkItem:(id<WcjTableTreeItemProtocol>)item isCheck:(BOOL)isCheck isChildItemCheck:(BOOL)isChildItemCheck;

- (id<WcjTableTreeItemProtocol> )getItemById:(NSString *)itemId;
//下拉
- (void)refreshPullDown:(NSMutableArray*)dataArray andExpandLevel:(NSInteger)level;
//上拉
- (void)refreshLoadMore:(NSMutableArray*)dataArray andExpandLevel:(NSInteger)level;

@end

NS_ASSUME_NONNULL_END
