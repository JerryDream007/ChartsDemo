//
//  FirstViewController.m
//  ChartsDemo
//
//  Created by 宋澎 on 2018/3/8.
//  Copyright © 2018年 宋澎. All rights reserved.
//#import "ChartsDemo-Swift.h"

#import "FirstViewController.h"

#import "ChartsDemo-Bridging-Header.h"

#import "PriceTrendModel.h"

#import "PriceChartMarkView.h"

@interface FirstViewController () <ChartViewDelegate,IChartAxisValueFormatter>

@property (nonatomic,strong) NSMutableArray <PriceTrendModel *> * priceTrendDataSource;     //折线图的数据源

@property (nonatomic,strong) LineChartView * lineChartView;                                 //折线图

@property (nonatomic,strong) PriceChartMarkView * subPriceView;                             //折线图上的浮层上的子视图

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.lineChartView];
    
    NSMutableArray * tempArray = [NSMutableArray array];
    
    for (int i = 1; i<=31; i++) {
        
        PriceTrendModel * model = [[PriceTrendModel alloc] init];
        
        model.formatDate = [NSString stringWithFormat:@"2018-03-%d",i];
        
        model.trend_X = [NSString stringWithFormat:@"03-%d",i];
        
        model.trend_Y = (CGFloat)(6666 + (arc4random() % (8888 - 6666 + 1)));
        
        [tempArray addObject:model];
    }
    
    self.priceTrendDataSource = tempArray;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    self.lineChartView.frame = CGRectMake(0, 64, kSCREEN_WIDTH, 300);
}

- (void)setPriceTrendDataSource:(NSMutableArray<PriceTrendModel *> *)priceTrendDataSource{
    
    _priceTrendDataSource = priceTrendDataSource;
    
    [self.lineChartView setData:self.getLineData];
    
    [self.lineChartView animateWithXAxisDuration:1.0f];
    
    [self addLimitLine:self.lineChartView.leftAxis.axisMaxValue];
}

#pragma mark - 懒加载

- (LineChartView *)lineChartView{
    if(!_lineChartView){
        _lineChartView = [[LineChartView alloc] initWithFrame:CGRectZero];
        [_lineChartView setExtraOffsetsWithLeft:15 top:0 right:15 bottom:10];//距离边缘的间隙
        _lineChartView.delegate = self;//设置代理
        _lineChartView.backgroundColor =  [UIColor whiteColor];
        _lineChartView.noDataText = @"暂无此产品的价格趋势";
        _lineChartView.noDataFont = [UIFont systemFontOfSize:15];
        _lineChartView.noDataTextColor = HEXCOLOR(0x444444);
        _lineChartView.chartDescription.enabled = YES;
        _lineChartView.scaleYEnabled = NO;//取消Y轴缩放
        _lineChartView.scaleXEnabled = NO;//取消X轴缩放
        _lineChartView.doubleTapToZoomEnabled = NO;//取消双击缩放
        _lineChartView.dragEnabled = YES;//启用拖拽
        _lineChartView.dragDecelerationEnabled = YES;//拖拽后是否有惯性效果
        _lineChartView.dragDecelerationFrictionCoef = 0.9;//拖拽后惯性效果的摩擦系数(0~1)，数值越小，惯性越不明显
        //描述及图例样式
        [_lineChartView setDescriptionText:@""];
        _lineChartView.legend.enabled = NO;
        
        //设置左侧Y轴
        _lineChartView.rightAxis.enabled = YES;//绘制右边轴
        ChartYAxis *leftAxis = _lineChartView.leftAxis;//获取左边Y轴
        leftAxis.labelCount = 5;//Y轴label数量，数值不一定，如果forceLabelsEnabled等于YES, 则强制绘制制定数量的label, 但是可能不平均
        leftAxis.forceLabelsEnabled = NO;//不强制绘制指定数量的labe
        leftAxis.axisLineWidth = 0.6;     //设置Y轴线宽
        leftAxis.axisLineColor = [UIColor blackColor];  //设置Y轴颜色
        // leftAxis.axisMinValue = 0;//设置Y轴的最小值
        //leftAxis.axisMaxValue = 105;//设置Y轴的最大值
        leftAxis.inverted = NO;//是否将Y轴进行上下翻转
        leftAxis.axisLineColor = [UIColor blackColor];//Y轴颜色
        leftAxis.labelPosition = YAxisLabelPositionInsideChart;//label位置
        leftAxis.labelTextColor = [UIColor blackColor];//文字颜色
        leftAxis.labelFont = [UIFont systemFontOfSize:10.0f];//文字字体
        //leftAxis.valueFormatter = [[SymbolsValueFormatter alloc]init];//设置y轴的数据格式
        leftAxis.gridLineDashLengths = @[@3.0f, @3.0f];//设置虚线样式的网格线
        leftAxis.gridColor = [UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1];//网格线颜色
        leftAxis.gridAntialiasEnabled = YES;//开启抗锯齿
        
        //设置Z轴
        ChartYAxis *rightAxis = _lineChartView.rightAxis;//获取右边Z轴
        rightAxis.axisLineWidth = 0.6;
        rightAxis.axisLineColor = [UIColor blackColor];//Z轴颜色
        rightAxis.drawGridLinesEnabled = NO;
        rightAxis.drawLabelsEnabled = NO;
        
        //设置X轴
        ChartXAxis *xAxis = _lineChartView.xAxis;
        xAxis.valueFormatter = self;            //这里才是最最最最最最关键的代码
        xAxis.granularityEnabled = YES;//设置重复的值不显示
        xAxis.labelCount = 5;
        xAxis.spaceMin = 0;             //设置坐标轴额外的最小空间
        xAxis.forceLabelsEnabled = YES;
        xAxis.labelPosition = XAxisLabelPositionBottom;//设置x轴数据在底部
        xAxis.labelTextColor = [UIColor blackColor];//文字颜色
        xAxis.axisLineWidth = 0.6;
        xAxis.axisLineColor = [UIColor blackColor]; //X轴的颜色
        xAxis.gridLineDashLengths = @[@3.0f, @3.0f];//设置虚线样式的网格线
        xAxis.gridColor = [UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1];//网格线颜色
        xAxis.gridAntialiasEnabled = YES;//开启抗锯齿
        //_lineChartView.maxVisibleCount = 999;//设置能够显示的数据数量
        
        //设置浮层
        _lineChartView.drawMarkers = YES;
        ChartMarkerView * makerView = [[ChartMarkerView alloc]init];
        makerView.offset = CGPointMake(-self.subPriceView.frame.size.width,-self.subPriceView.frame.size.height/2);
        makerView.chartView = _lineChartView;
        _lineChartView.marker = makerView;
        [makerView addSubview:self.subPriceView];
    }
    return _lineChartView;
}

//添加限制线
- (void)addLimitLine:(double)limitValue{
    ChartYAxis *leftAxis = self.lineChartView.leftAxis; //获取左侧的Y轴
    [leftAxis removeAllLimitLines];
    ChartLimitLine *limitLine = [[ChartLimitLine alloc] initWithLimit:limitValue label:@""];
    limitLine.lineWidth = 0.6;
    limitLine.lineColor = [UIColor blackColor];
    limitLine.drawLabelEnabled = NO;
    limitLine.labelPosition = ChartLimitLabelPositionRightTop;//位置
    [leftAxis addLimitLine:limitLine];//添加到Y轴上
    leftAxis.drawLimitLinesBehindDataEnabled = YES;//设置限制线绘制在折线图的后面
}

- (PriceChartMarkView *)subPriceView{
    if (!_subPriceView) {
        _subPriceView = [PriceChartMarkView createViewFromNib];
    }
    return _subPriceView;
}

- (LineChartData *)getLineData{
    
    if(self.priceTrendDataSource.count == 0) return nil;
    
    //X轴上面需要显示的数据
    NSMutableArray *xVals = [NSMutableArray array];
    
    //对应Y轴上面需要显示的数据,价格
    NSMutableArray *yVals = [NSMutableArray array];
    
    NSInteger index = 0;
    
    for (PriceTrendModel * model in self.priceTrendDataSource) {
        
        [xVals addObject:[NSString stringWithFormat:@"%@",model.trend_X]];
        
        ChartDataEntry *entry_Y = [[ChartDataEntry alloc] initWithX:index y:model.trend_Y];
        [yVals addObject:entry_Y];
        
        index ++;
    }
    LineChartDataSet *lineSet = [[LineChartDataSet alloc] initWithValues:yVals label:@""];
    lineSet.mode = LineChartModeCubicBezier;
    lineSet.lineWidth = 1.0f;
    lineSet.drawValuesEnabled = NO;
    lineSet.valueColors = @[[UIColor purpleColor]]; //折线上的数值的颜色
    [lineSet setColor:HEXCOLOR(0x24A5EA)];   //折线本身的颜色
    lineSet.drawSteppedEnabled = NO;//是否开启绘制阶梯样式的折线图
    lineSet.drawCirclesEnabled = NO;
    lineSet.drawFilledEnabled = NO;//是否填充颜色
    lineSet.circleRadius = 1.0f;
    lineSet.drawCircleHoleEnabled = NO;
    lineSet.circleHoleRadius = 0.0f;
    lineSet.circleHoleColor = [UIColor whiteColor];
    
    lineSet.highlightEnabled = YES;//选中拐点,是否开启高亮效果(显示十字线)
    //lineSet.highlightColor = HEXCOLOR(0xc83c23);//点击选中拐点的十字线的颜色
    lineSet.highlightColor = [HEXCOLOR(0x444444) colorWithAlphaComponent:0.5];//点击选中拐点的十字线的颜色
    lineSet.highlightLineWidth = 0.5;//十字线宽度
    //lineSet.highlightLineDashLengths = @[@5,@5];  //设置十字线的虚线宽度
    
    lineSet.valueFont = [UIFont systemFontOfSize:12];
    lineSet.axisDependency = AxisDependencyLeft;
    
    LineChartData *lineData = [[LineChartData alloc] initWithDataSet:lineSet];
    
    return lineData;
}

#pragma mark - LineChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * _Nonnull)chartView entry:(ChartDataEntry * _Nonnull)entry highlight:(ChartHighlight * _Nonnull)highlight {
    
    //_markLabel.text = [NSString stringWithFormat:@"%ld%%",(NSInteger)entry.y];//改变选中的数据时候，label的值跟着变化
    
    PriceTrendModel * currentModel = self.priceTrendDataSource[(NSInteger)entry.x];
    
    PriceTrendModel * lastModel = self.priceTrendDataSource[(NSInteger)(entry.x - 1)];
    
    [self.subPriceView setUpTrendModel:currentModel lastPrice:lastModel];
    
    //将点击的数据滑动到中间
    [_lineChartView centerViewToAnimatedWithXValue:entry.x yValue:entry.y axis:[_lineChartView.data getDataSetByIndex:highlight.dataSetIndex].axisDependency duration:1.0];
    
}

#pragma mark - ChartView x-Titles Datasource
- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis{
    
    NSInteger index = (int)value;
    
    PriceTrendModel * model = self.priceTrendDataSource[index];
    
    if(index == 0){
        return [@"       " stringByAppendingString:model.trend_X];
    }else if(index == self.priceTrendDataSource.count - 1){
        return [NSString stringWithFormat:@"%@     .",model.trend_X];
    }else{
        return model.trend_X;
    }
}

- (void)startLineChartAnimation{
    [self.lineChartView animateWithXAxisDuration:1.0f];
}

@end
