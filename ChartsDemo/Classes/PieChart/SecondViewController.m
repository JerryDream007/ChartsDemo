//
//  SecondViewController.m
//  ChartsDemo
//
//  Created by 宋澎 on 2018/3/8.
//  Copyright © 2018年 宋澎. All rights reserved.
//

#import "SecondViewController.h"

#import "ChartsDemo-Bridging-Header.h"

@interface SecondViewController ()

@property (strong,nonatomic) PieChartView *pieChartView;        //饼状图

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.pieChartView];
    
    self.pieChartView.data = self.getPieData;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    self.pieChartView.frame = CGRectMake(0, 64, kSCREEN_WIDTH, 300);
    
    [self.pieChartView animateWithXAxisDuration:1];
    
    [self.pieChartView animateWithYAxisDuration:1];
}

#pragma mark - 懒加载

- (PieChartView *)pieChartView{
    if (!_pieChartView) {
        _pieChartView = [[PieChartView alloc] initWithFrame:CGRectZero];
        
        _pieChartView.backgroundColor = [UIColor whiteColor];
        
        //基本样式
        //[_pieChartView setExtraOffsetsWithLeft:30 top:10 right:30 bottom:10];//饼状图距离边缘的间隙
        
        [_pieChartView setExtraOffsetsWithLeft:0 top:0 right:0 bottom:0];//饼状图距离边缘的间隙
        
        _pieChartView.usePercentValuesEnabled = NO;//是否根据所提供的数据, 将显示数据转换为百分比格式
        _pieChartView.dragDecelerationEnabled = YES;//拖拽饼状图后是否有惯性效果
        _pieChartView.drawSliceTextEnabled = NO;//是否显示区块文本
        
        //空心样式
        _pieChartView.drawHoleEnabled = YES;//饼状图是否是空心
        _pieChartView.holeRadiusPercent = 0.8;//空心半径占比
        _pieChartView.holeColor = [UIColor clearColor];//空心颜色
        _pieChartView.transparentCircleRadiusPercent = 0.52;//半透明空心半径占比
        _pieChartView.transparentCircleColor = [UIColor colorWithRed:210/255.0 green:145/255.0 blue:165/255.0 alpha:0.3];//半透明空心的颜色
        
        //设置空心文字
        
        if (_pieChartView.isDrawHoleEnabled == YES) {
            _pieChartView.drawCenterTextEnabled = YES;//是否显示中间文字
            //普通文本
            //_pieChartView.centerText = @"资产";//中间文字
            //富文本
            NSMutableAttributedString *centerText = [[NSMutableAttributedString alloc] initWithString:@"收支详情"];
            [centerText setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                                        NSForegroundColorAttributeName: HEXCOLOR(0x444444)}
                                range:NSMakeRange(0, centerText.length)];
            _pieChartView.centerAttributedText = centerText;
        }
        
        //设置饼状图描述
        _pieChartView.descriptionText = @"";
        //_pieChartView.descriptionFont = [UIFont systemFontOfSize:10];
        //_pieChartView.descriptionTextColor = [UIColor grayColor];
        
        //设置图例样式
        _pieChartView.legend.maxSizePercent = 0;//图例在饼状图中的大小占比, 这会影响图例的宽高
        _pieChartView.legend.formToTextSpace = 5;//文本间隔
        _pieChartView.legend.yEntrySpace = 12;//10;
        _pieChartView.legend.xEntrySpace = 15;
        _pieChartView.legend.font = [UIFont systemFontOfSize:10];//字体大小
        _pieChartView.legend.textColor = [UIColor grayColor];//字体颜色
        _pieChartView.legend.position = ChartLegendPositionBelowChartCenter;//图例在饼状图中的位置
        _pieChartView.legend.form = ChartLegendFormCircle;//图示样式: 方形、线条、圆形
        _pieChartView.legend.formSize = 0;//图示大小
    }
    return _pieChartView;
}

- (PieChartData *)getPieData{
    
    //每个区块的金额数
    NSMutableArray * moneyArray = [NSMutableArray arrayWithArray:@[@33.33,@100,@12,@66.66]];
    
    //每个区块的颜色
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    
    [colors addObject:HEXCOLOR(0xFF1F32)];
    
    [colors addObject:HEXCOLOR(0x5FD954)];
    
    [colors addObject:HEXCOLOR(0x00D6F6)];
    
    [colors addObject:HEXCOLOR(0xF2F2F2)];
    
    //每个区块的数据
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < moneyArray.count; i++) {
        
        double randomVal = [moneyArray[i] doubleValue];
        
        //BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithValue:randomVal xIndex:i];
        
        //ChartDataEntry * entry = [[ChartDataEntry alloc] initWithValue:randomVal xIndex:i];
        
        ChartDataEntry * entry = [[ChartDataEntry alloc] initWithX:i y:randomVal];
        
        [yVals addObject:entry];
    }
    
    //dataSet
    //PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithYVals:yVals label:@""];
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithValues:yVals label:@""];
    dataSet.drawValuesEnabled = NO;//是否绘制显示数据
    dataSet.colors = colors;//区块颜色
    dataSet.sliceSpace = 3;//相邻区块之间的间距
    dataSet.selectionShift = 2;//选中区块时, 放大的半径
    dataSet.xValuePosition = PieChartValuePositionInsideSlice;//名称位置
    dataSet.yValuePosition = PieChartValuePositionOutsideSlice;//数据位置
    //数据与区块之间的用于指示的折线样式
    dataSet.valueLinePart1OffsetPercentage = 0.85;//折线中第一段起始位置相对于区块的偏移量, 数值越大, 折线距离区块越远
    dataSet.valueLinePart1Length = 0.5;//折线中第一段长度占比
    dataSet.valueLinePart2Length = 0.4;//折线中第二段长度最大占比
    dataSet.valueLineWidth = 1;//折线的粗细
    dataSet.valueLineColor = [UIColor brownColor];//折线颜色
    dataSet.valueLineVariableLength = YES;
    
    //data
    //PieChartData *data = [[PieChartData alloc] initWithXVals:xVals dataSet:dataSet];
    PieChartData *data = [[PieChartData alloc] initWithDataSet:dataSet];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = kCFNumberFormatterDecimalStyle;//NSNumberFormatterPercentStyle;
    [formatter setPositiveFormat:@"###,##0.00;"];
    formatter.maximumFractionDigits = 2;//小数位数
    formatter.multiplier = @1.f;
    formatter.paddingPosition = kCFNumberFormatterPadBeforeSuffix;
    formatter.positiveSuffix = @"元";
    //[data setValueFormatter:formatter];//设置显示数据格式
    [data setValueTextColor:[UIColor brownColor]];
    [data setValueFont:[UIFont systemFontOfSize:10]];
    
    return data;
}

@end
