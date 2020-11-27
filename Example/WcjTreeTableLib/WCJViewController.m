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

@end

@implementation WCJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WcjTableTreeManager * manager = [self getManagerOfCity];
    WcjTableTreeView * treeView = [[WcjTableTreeView alloc]initWithFrame:self.view.bounds manager:manager style:(UITableViewStylePlain) treeViewDelegate:self];
    [self.view addSubview:treeView];
    // Do any additional setup after loading the view.
}

- (WcjTableTreeManager *)getManagerOfCity {
    
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
    WcjTableTreeManager *manager = [[WcjTableTreeManager alloc] initWithItems:items andExpandLevel:0];
    
    return manager;
}

@end
