//
//  WcjTableTreeCellProtocol.h
//  WJDemo
//
//  Created by 王纯杰 on 2020/11/26.
//  Copyright © 2020 王纯杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WcjTableTreeItemProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WcjTableTreeCellProtocol <NSObject>

- (void)updateItem;

- (void)updateWith:(id<WcjTableTreeItemProtocol>) item indexPath:(NSIndexPath*)indexPath;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, copy)   void (^checkButtonClickBlock)(id<WcjTableTreeItemProtocol> item);

@end

NS_ASSUME_NONNULL_END
