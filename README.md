# ChartsDemo介绍了Charts的Object-C的使用方法
#### 使用的是Charts 3.0.4版本,基于Swift4.0

![image](https://github.com/308823810/ChartsDemo/blob/master/ChartDemo.gif)   

### 1.集成Charts
#### 这里只是做一个简略说明,具体的可以参考官方的集成方法 [Charts](https://github.com/danielgindi/Charts)
#### 如果使用的Swift开发,可以直接import Charts
#### 如果使用OC开发,则需要混编,建立ProjectName-Bridging-Header.h桥接文件,这里详细介绍混编开发
1. 利用CocoaPods,在Podfile文件中写入 : pod 'Charts',然后pod install
2. 在桥接文件中@import Charts;
3. 在需要使用Charts的文件中,#import "ProjectName-Bridging-Header.h",就可以使用Charts中的代码了

### 2.折线图
```
//初始化折线图
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

```
```
//折线图的数据源
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
```

### 3.饼状图
```
//初始化饼状图
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
```

```
//饼状图的数据源
- (PieChartData *)getPieData{
    
    //每个区块的金额数
    NSMutableArray * moneyArray = [NSMutableArray arrayWithArray:@[@33.33,@66.66]];
    
    //每个区块的名称或描述
    //NSArray * xVals = @[@"充值诚意金",@"充值会员费",@"赠送诚意金",@"赠送会员费",@"被冻结资金"];
//    NSMutableArray * xVals = [NSMutableArray array];
    
    //每个区块的颜色
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    
    switch (_forecastType) {
        case ForecastPriceTypeUp:{
            [colors addObject:HEXCOLOR(0xFF1F32)];
            [moneyArray removeAllObjects];
            [moneyArray addObject:@(self.forecastModel.upRate)];
            [moneyArray addObject:@(1 - self.forecastModel.upRate)];
            break;
        }
        case ForecastPriceTypeDown:{
            [colors addObject:HEXCOLOR(0x5FD954)];
            [moneyArray removeAllObjects];
            [moneyArray addObject:@(self.forecastModel.downRate)];
            [moneyArray addObject:@(1 - self.forecastModel.downRate)];
            break;
        }
        case ForecastPriceTypeLevel:{
            [colors addObject:HEXCOLOR(0x00D6F6)];
            [moneyArray removeAllObjects];
            [moneyArray addObject:@(self.forecastModel.rate)];
            [moneyArray addObject:@(1 - self.forecastModel.rate)];
            break;
        }
        default:
            break;
    }
    
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
```

### 4.分享交流
* 欢迎提Issues
* 如果疑问,可以联系我的QQ:308823810,请备注Charts
* 若有帮助,希望给个Star
