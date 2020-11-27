//
//  WcjTableTreeConfige.h
//  WJDemo
//
//  Created by 王纯杰 on 2020/11/26.
//  Copyright © 2020 王纯杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface WcjTableTreeConfige : NSObject

@property (nonatomic, assign) BOOL isShowExpandedAnimation;   // 是否显示展开/折叠动画，默认 YES
@property (nonatomic, assign) BOOL isShowArrowIfNoChildNode;  // 是否没有子节点就不显示箭头，默认 NO
@property (nonatomic, assign) BOOL isShowArrow;               // 是否显示文字前方的箭头图片，默认 YES
@property (nonatomic, assign) BOOL isShowCheck;               // 是否显示文字后方的勾选框，默认 YES
@property (nonatomic, assign) BOOL isSingleCheck;             // 是否是单选，默认 NO
@property (nonatomic, assign) BOOL isCancelSingleCheck;       // 是否单选时再次点击取消选择，默认 NO
@property (nonatomic, assign) BOOL isExpandCheckedNode;       // 是否展开已选择的节点，默认 YES
@property (nonatomic, assign) BOOL isShowLevelColor;          // 是否展示层级颜色，默认 YES
@property (nonatomic, assign) BOOL isShowSearchBar;           // 是否显示搜索框，默认 YES
@property (nonatomic, assign) BOOL isSearchRealTime;          // 是否实时查询，默认 YES
@property (nonatomic, strong) NSArray <UIColor*>*levelColorArray;  // 层级颜色，默认一级和二级分别为深灰色和浅灰色
@property (nonatomic, strong) UIColor *normalBackgroundColor;       // 默认背景色，默认为白色


+(instancetype)shareConfige;


@end

NS_ASSUME_NONNULL_END
