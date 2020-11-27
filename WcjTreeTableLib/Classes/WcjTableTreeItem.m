//
//  WcjTableTreeItem.m
//  WJDemo
//
//  Created by 王纯杰 on 2020/11/26.
//  Copyright © 2020 王纯杰. All rights reserved.
//

#import "WcjTableTreeItem.h"

@implementation WcjTableTreeItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.childItems = [NSMutableArray new];
    }
    return self;
}

@synthesize checkState;

@synthesize childItems;

@synthesize data;

@synthesize ID;

@synthesize isExpand;

@synthesize isLeaf;

@synthesize level;

@synthesize name;

@synthesize orderNo;

@synthesize parentID;

@synthesize parentItem;

@synthesize type;

@end
