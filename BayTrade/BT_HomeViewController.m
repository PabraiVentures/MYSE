//
//  BT_FirstViewController.m
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//
#import "BT_HomeViewController.h"
#import "Cache.h"
#import <QuartzCore/QuartzCore.h>
#import "CoreStock.h"
#import "BT_AppDelegate.h"
#import "StackMob.h"
#import "CorePortfolioHistory.h"
#import "PortfolioLog.h"

@interface BT_HomeViewController ()

@end

@implementation BT_HomeViewController
@synthesize userCache, welcomeLabel, tickerView, pieChart, hostView, logs;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userCache = [((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) userCache];
    [self.pieChart setStocks:[self.userCache.coreModel.portfolio.stocks allObjects]];
    [self.pieChart calculateCurrentPrices];
    [self.pieChart setTotalPortfolioValue: self.userCache.coreModel.portfolio.totalportfoliovalue.doubleValue];
    [self.pieChart initPieView];
    
    [self.tickerView loadTickerData];
    [self.tickerView reloadData];
    self.rankLabel.text=[NSString stringWithFormat:@"%@", self.userCache.coreModel.portfolio.ranking];
    
    [self initPlot];
}

-(void)initPlot {
    NSLog(@"initializing plot.");
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"PortfolioLog"];
    // query for stockorder for THIS user
    NSString* getRightEvents=[NSString stringWithFormat:@"portfolio == '%@'",self.userCache.coreModel.portfolio.coreportfolio_id];
    NSLog(@"getrightevents: %@", getRightEvents);
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:getRightEvents]];
    /**********START CODE BLOCK FOR REQUEST ACTION************/
    [self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *logData) {
        if([logData count] > 0) {
            /** Sort the tradeEvents by time/supposed order of events **/
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"logtime" ascending:NO] ;
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            [self setLogs:[NSMutableArray arrayWithArray:[logData sortedArrayUsingDescriptors:sortDescriptors]]];
            NSLog(@"logdata: %@", logData);
            NSLog(@"logs: %@", logs);
        }
        else {
            NSLog(@"couldn't get historical data.");
        }
    } onFailure:^(NSError *error) {
        NSLog(@"Error fetching: %@", error);
    }];
    
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
    NSLog(@"finished initializing plot.");
}

-(void)configureHost {
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.height/2, self.view.frame.size.width)];
    self.hostView.allowPinchScaling = YES;
    [self.view addSubview:self.hostView];
}

-(void)configureGraph {
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.hostView.hostedGraph = graph;
    // 2 - Set graph title
    NSString *title = @"Portfolio Prices: April 2012";
    graph.title = title;
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:30.0f];
    [graph.plotAreaFrame setPaddingBottom:30.0f];
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
}

-(void)configurePlots {
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    // 2 - Create the three plots
    CPTScatterPlot *historyPlot = [[CPTScatterPlot alloc] init];
    historyPlot.dataSource = self;
    historyPlot.identifier = @"history";
    CPTColor *aaplColor = [CPTColor redColor];
    [graph addPlot:historyPlot toPlotSpace:plotSpace];
    // 3 - Set up plot space
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:historyPlot, nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
    // 4 - Create styles and symbols
    CPTMutableLineStyle *historyLineStyle = [historyPlot.dataLineStyle mutableCopy];
    historyLineStyle.lineWidth = 2.5;
    historyLineStyle.lineColor = aaplColor;
    historyPlot.dataLineStyle = historyLineStyle;
    CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    aaplSymbolLineStyle.lineColor = aaplColor;
    CPTPlotSymbol *historySymbol = [CPTPlotSymbol ellipsePlotSymbol];
    historySymbol.fill = [CPTFill fillWithColor:aaplColor];
    historySymbol.lineStyle = aaplSymbolLineStyle;
    historySymbol.size = CGSizeMake(6.0f, 6.0f);
    historyPlot.plotSymbol = historySymbol;
}

-(void)configureAxes {
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    x.title = @"Day of Month";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    CGFloat dateCount = 10;//TODO
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSInteger i = 0;
    //TODO
    
    for (NSString *date in logs) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date  textStyle:x.labelTextStyle];
        CGFloat location = i++;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    y.title = @"Price";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -40.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = 100;
    NSInteger minorIncrement = 50;
    CGFloat yMax = 700.0f;  // should determine dynamically based on max price
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels = yLabels;    
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"received memory warning!");
    [super didReceiveMemoryWarning];
}

/*Check if page has been updated in the last 1 minute.*/
-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"last updated: %@", lastUpdated);
    if (!lastUpdated) {
        NSLog(@"initializing lastupdated in home.");
        lastUpdated = [NSDate date];
        return;
    }
    NSTimeInterval timeSinceUpdate = [lastUpdated timeIntervalSinceNow];
    NSLog(@"time since update: %f", timeSinceUpdate);
    if (timeSinceUpdate < -60) { //60 seconds
        NSLog(@"updating. time since update: %f", timeSinceUpdate);
        [(BT_AppDelegate*)[[UIApplication sharedApplication] delegate] downloadCurrentStocksInfo];
        [self viewDidLoad];
    }
    self.managedObjectContext = [[[SMClient defaultClient]coreDataStore] contextForCurrentThread];
    [self loadWelcomeLabel];
}

-(void) loadWelcomeLabel
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"Name"];
    if (userName != nil) {
        
        [welcomeLabel setText: [NSString stringWithFormat: @"Welcome, %@!", userName]];
    }
}

-(NSUInteger) numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSLog(@"logs count = %i", [logs count]);
    return [logs count];//TODO
}

-(NSNumber*) numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    return [((PortfolioLog*)[logs objectAtIndex:idx]) accountvalue];
    //TODO return historical data
    return [NSDecimalNumber zero];
}

@end