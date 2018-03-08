//
//  PriceChartMarkView.h
//  ChartsDemo
//
//  Created by 宋澎 on 2018/3/8.
//  Copyright © 2018年 宋澎. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PriceTrendModel;

@interface PriceChartMarkView : UIView

+ (instancetype)createViewFromNib;

- (void)setUpTrendModel:(PriceTrendModel *)currentModel lastPrice:(PriceTrendModel *)lastModel;

@end
