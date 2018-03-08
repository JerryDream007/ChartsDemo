//
//  PriceChartMarkView.m
//  ChartsDemo
//
//  Created by 宋澎 on 2018/3/8.
//  Copyright © 2018年 宋澎. All rights reserved.
//

#import "PriceChartMarkView.h"

#import "PriceTrendModel.h"

@interface PriceChartMarkView ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastPriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;

@end

@implementation PriceChartMarkView

+ (instancetype)createViewFromNib{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil].lastObject;
}

- (void)setUpTrendModel:(PriceTrendModel *)currentModel lastPrice:(PriceTrendModel *)lastModel{
    
    self.dateLabel.text = currentModel.formatDate;
    
    self.lastPriceLabel.text = lastModel.trend_Y > 0 ? [NSString stringWithFormat:@"%0.2f元",lastModel.trend_Y] : @"暂无数据";
    
    self.currentPriceLabel.text = currentModel.trend_Y > 0 ? [NSString stringWithFormat:@"%0.2f元",currentModel.trend_Y] : @"暂无数据";
    
    CGFloat currentPriceWidth = [self.currentPriceLabel.text boundingRectWithSize:CGSizeMake(kSCREEN_WIDTH, 500) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size.width;
    
    CGFloat lastPriceWidth = [self.currentPriceLabel.text boundingRectWithSize:CGSizeMake(kSCREEN_WIDTH, 500) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size.width;
    
    CGFloat maxWidth = currentPriceWidth > lastPriceWidth ? currentPriceWidth : lastPriceWidth;
    
    [self.lastPriceLabel sizeToFit];
    
    [self.currentPriceLabel sizeToFit];
    
    CGRect rect = self.frame;
    
    rect.size = CGSizeMake(95 + maxWidth, 65);
    
    self.frame = rect;
}

@end
