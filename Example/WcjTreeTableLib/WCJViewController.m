//
//  WCJViewController.m
//  WcjTreeTableLib
//
//  Created by m13272210634 on 11/27/2020.
//  Copyright (c) 2020 m13272210634. All rights reserved.
//

#import "WCJViewController.h"
#import "WcjTableTreeView.h"
#import "WcjTableTreeItem.h"
@interface WCJViewController ()<WcjTableTreeViewDelegate>
@property(nonatomic, strong)NSMutableArray*array;

@end

@implementation WCJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WcjTableTreeView * treeView = [[WcjTableTreeView alloc]initWithFrame:self.view.bounds style:(UITableViewStylePlain) treeViewDelegate:self];
    [self.view addSubview:treeView];
    self.array = [self getManagerOfCity];
    [treeView wcj_reloadData];
    
    // Do any additional setup after loading the view.
}

- (NSArray<id<WcjTableTreeItemProtocol>> *)treeViewCellCount:(WcjTableTreeView *)treeView{
    return self.array;
}

- (NSArray<id<WcjTableTreeItemProtocol>> *)getManagerOfCity {
    
    // 获取数据并创建树形结构
    NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cityResource" ofType:@"json"]];
    NSArray *provinceArray = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
    
    NSMutableArray *items = [NSMutableArray new];
    
    //     1. 遍历省份
    [provinceArray enumerateObjectsUsingBlock:^(NSDictionary *province, NSUInteger idx, BOOL * _Nonnull stop) {
        
        WcjTableTreeItem *provinceItem = [[WcjTableTreeItem alloc] init];
        provinceItem.name = province[@"name"];
        provinceItem.ID = province[@"code"];
        provinceItem.parentID = nil;
        provinceItem.orderNo = [NSString stringWithFormat:@"%lu", (unsigned long)idx];
        provinceItem.type = @"province";
        provinceItem.isLeaf = NO;
        provinceItem.data = province;
        [items addObject:provinceItem];
        
        // 2. 遍历城市
        NSArray *cityArray = province[@"children"];
        [cityArray enumerateObjectsUsingBlock:^(NSDictionary *city, NSUInteger idx, BOOL * _Nonnull stop) {
            
            WcjTableTreeItem *cityItem = [[WcjTableTreeItem alloc] init];
            cityItem.name = city[@"name"];
            cityItem.ID = city[@"code"];
            cityItem.parentID = provinceItem.ID;
            cityItem.orderNo = [NSString stringWithFormat:@"%lu", (unsigned long)idx];
            cityItem.type = @"city";
            cityItem.isLeaf = NO;
            cityItem.data = city;
            [items addObject:cityItem];
            
            // 3. 遍历区
            NSArray *districtArray = city[@"children"];
            [districtArray enumerateObjectsUsingBlock:^(NSDictionary *district, NSUInteger idx, BOOL * _Nonnull stop) {
                
                WcjTableTreeItem *districtItem = [[WcjTableTreeItem alloc] init];
                districtItem.name = district[@"name"];
                districtItem.ID = district[@"code"];
                districtItem.parentID = cityItem.ID;
                districtItem.orderNo = [NSString stringWithFormat:@"%lu", (unsigned long)idx];
                districtItem.type = @"district";
                districtItem.isLeaf = YES;
                districtItem.data = district;
                [items addObject:districtItem];
            }];
        }];
    }];
    
    // ExpandLevel 为 0 全部折叠，为 1 展开一级，以此类推，为 NSIntegerMax 全部展开
    return items;
}

@end
