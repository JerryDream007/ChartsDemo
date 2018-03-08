//
//  PriceTrendModel.h
//  ChartsDemo
//
//  Created by 宋澎 on 2018/3/8.
//  Copyright © 2018年 宋澎. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface PriceTrendModel : NSObject

@property (nonatomic,copy) NSString * formatDate;   //日期

@property (nonatomic,copy) NSString * trend_X;      //X轴值

@property (nonatomic,assign) CGFloat trend_Y;      //Y轴值

@end
