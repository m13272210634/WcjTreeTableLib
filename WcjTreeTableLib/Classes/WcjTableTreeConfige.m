//
//  WcjTableTreeConfige.m
//  WJDemo
//
//  Created by 王纯杰 on 2020/11/26.
//  Copyright © 2020 王纯杰. All rights reserved.
//

#import "WcjTableTreeConfige.h"

@implementation WcjTableTreeConfige

+(instancetype)shareConfige{
    static WcjTableTreeConfige * _confige = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _confige = [[super allocWithZone:NULL] init];
    });
    return _confige;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [WcjTableTreeConfige shareConfige];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isShowExpandedAnimation  = YES;
        _isShowArrowIfNoChildNode = NO;
        _isShowArrow              = YES;
        _isShowCheck              = YES;
        _isSingleCheck            = NO;
        _isCancelSingleCheck      = NO;
        _isExpandCheckedNode      = YES;
        _isShowLevelColor         = YES;
        _isShowSearchBar          = YES;
        _isSearchRealTime         = YES;
        _normalBackgroundColor = [UIColor whiteColor];
        _levelColorArray = @[[self getColorWithRed:230 green:230 blue:230],
                            [self getColorWithRed:238 green:238 blue:238]];
    }
    return self;
}

- (UIColor *)getColorWithRed:(NSInteger)redNum green:(NSInteger)greenNum blue:(NSInteger)blueNum {
    return [UIColor colorWithRed:redNum/255.0 green:greenNum/255.0 blue:blueNum/255.0 alpha:1.0];
}

@end
