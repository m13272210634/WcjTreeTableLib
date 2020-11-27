//
//  WcjTableTreeCell.m
//  WJDemo
//
//  Created by 王纯杰 on 2020/11/26.
//  Copyright © 2020 王纯杰. All rights reserved.
//

#import "WcjTableTreeCell.h"

@interface WcjTableTreeCell()

@property(nonatomic, strong)id<WcjTableTreeItemProtocol> treeItem;
@property (nonatomic, strong) UIButton *checkButton;

@end


@implementation WcjTableTreeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateWith:(id<WcjTableTreeItemProtocol>)item indexPath:(NSIndexPath *)indexPath{
    self.treeItem = item;
    self.indentationLevel =self.treeItem.level;
    self.textLabel.text   = self.treeItem.name;
    self.imageView.image  = self.treeItem.isLeaf ? nil : [self imagesNamedFromCustomBundle:@"arrow"];
    self.accessoryView    = self.checkButton;
    [self refreshArrow];
    [self.checkButton setImage:[self getCheckImage] forState:UIControlStateNormal];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font   = [UIFont systemFontOfSize:14];
        self.indentationWidth = 15;
        self.selectionStyle   = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat minX = 15 + self.indentationLevel * self.indentationWidth;
    
    if (!self.treeItem.isLeaf) {
        CGRect imageViewFrame = self.imageView.frame;
        imageViewFrame.origin.x = minX;
        self.imageView.frame = imageViewFrame;
    }
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = minX + (self.treeItem.isLeaf ? 0 : (self.imageView.bounds.size.width + 2));
    self.textLabel.frame = textLabelFrame;
}

#pragma mark - Lazy Load

- (UIButton *)checkButton {
    if (!_checkButton) {
        
        UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkButton addTarget:self action:@selector(checkButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [checkButton setImage:[self getCheckImage] forState:UIControlStateNormal];
        checkButton.adjustsImageWhenHighlighted = NO;
        checkButton.frame = CGRectMake(0, 0, self.contentView.bounds.size.height, self.contentView.bounds.size.height);
        CGFloat aEdgeInset = (checkButton.frame.size.height - checkButton.imageView.image.size.height) / 2;
        checkButton.contentEdgeInsets = UIEdgeInsetsMake(aEdgeInset, aEdgeInset, aEdgeInset, aEdgeInset);
        
        _checkButton = checkButton;
    }
    return _checkButton;
}

- (void)updateItem {
    // 刷新 title 前面的箭头方向
    [UIView animateWithDuration:0.25 animations:^{
        [self refreshArrow];
    }];
}


#pragma mark - Private Method

- (void)refreshArrow {
    
    if (self.treeItem.isExpand) {
        self.imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    } else {
        self.imageView.transform = CGAffineTransformMakeRotation(0);
    }
}

- (void)checkButtonClick:(UIButton *)sender {
    if (self.checkButtonClickBlock) {
        self.checkButtonClickBlock(self.treeItem);
    }
}

- (UIImage *)getCheckImage {
    
    switch (self.treeItem.checkState) {
        case TreeItemDefault:
            return [self imagesNamedFromCustomBundle:@"checkbox-uncheck"];
            break;
        case TreeItemChecked:
            return [self imagesNamedFromCustomBundle:@"checkbox-checked"];
            break;
        case TreeItemHalfChecked:
            return [self imagesNamedFromCustomBundle:@"checkbox-partial"];
            break;
        default:
            return nil;
            break;
    }
}

- (UIImage *)imagesNamedFromCustomBundle:(NSString *)imgName
{
    
     NSBundle *bundle = [NSBundle bundleForClass:[self class]];
     [bundle URLForResource:@"treeTable" withExtension:@"bundle"];
    
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    // 获取屏幕pt和px之间的比例
    NSInteger scale = [UIScreen mainScreen].scale;
    NSString *imagefailName = [NSString stringWithFormat:@"%@@%zdx.png",imgName,scale];
    // 获取图片的路径,其中BMCH5WebView是组件名
    NSString *imagePath = [currentBundle pathForResource:imagefailName ofType:nil inDirectory:nil];
    // 获取图片
    return [UIImage imageWithContentsOfFile:imagePath];

}


@synthesize checkButtonClickBlock;

@end
