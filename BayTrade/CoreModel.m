//
//  Coremodel.m
//  BayTrade
//
//  Created by Nathan Pabrai on 7/27/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "CoreModel.h"
#import "CorePortfolio.h"
#import "CoreTradeEvent.h"

@implementation CoreModel

@synthesize model_id;
@synthesize portfolio;
@synthesize tradeevents;

//-(id) init
//{
//    if(self = [super init])
//    {
//        self.portfolio = [[CorePortfolio alloc] init];
//        //self.modelPort.value = [self.modelPort totalPortfolioValue];
//        self.eventArray = [NSMutableArray arrayWithCapacity:0];
//    }
//    return self;
//}

@end