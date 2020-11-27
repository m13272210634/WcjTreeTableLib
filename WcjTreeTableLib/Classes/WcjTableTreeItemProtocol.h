//
//  WcjTableTreeItemProtocol.h
//  WJDemo
//
//  Created by 王纯杰 on 2020/11/26.
//  Copyright © 2020 王纯杰. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TreeItemCheckState) {
    TreeItemDefault,      // 不选择（默认）
    TreeItemChecked,      // 全选
    TreeItemHalfChecked,  // 半选
};

NS_ASSUME_NONNULL_BEGIN

@protocol WcjTableTreeItemProtocol <NSObject>

@property (nonatomic,  copy) NSString *name;      // 名称
@property (nonatomic,  copy) NSString *ID;        // 唯一标识
@property (nonatomic,  copy) NSString *parentID;  // 父级节点唯一标识
@property (nonatomic,  copy) NSString *orderNo;   // 序号
@property (nonatomic,  copy) NSString *type;      // 类型
@property (nonatomic,  assign) BOOL isLeaf;       // 是否叶子节点
@property (nonatomic,  strong) id data;           // 原始数据
// 下列数据为 MYTreeTableManager 中内部设置，不能在外部直接设置
@property (nonatomic, assign) NSUInteger level;
@property (nonatomic, assign) BOOL isExpand;
@property (nonatomic, assign) TreeItemCheckState checkState;
@property (nonatomic, weak)   id<WcjTableTreeItemProtocol> parentItem;
@property (nonatomic, strong) NSMutableArray<id<WcjTableTreeItemProtocol>> *childItems;

@end

NS_ASSUME_NONNULL_END
