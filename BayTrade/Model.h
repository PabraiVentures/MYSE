//
//  Model.h
//  BayTrade
//
//  Created by Jamie Tahirkheli on 6/22/13.
//  Copyright (c) 2013 Jamie Tahirkheli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePortfolio.h"
#import "CoreModel.h"
#import "BT_TradeEvent.h"

#define QUOTE_QUERY_PREFIX @"http://query.yahooapis.com/v1/public/yql?q=select%20symbol%2C%20Open%20from%20yahoo.finance.quotes%20where%20symbol%20in%20("
#define QUOTE_QUERY_SUFFIX @")&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="
#import "BT_TradeEvent.h"

@interface Model : NSObject

@property (nonatomic, retain) CorePortfolio *modelPort;
@property (nonatomic, retain) NSMutableArray* eventArray;
@property (nonatomic,retain) NSString* userID;
@property (nonatomic, retain) CoreModel* coreModel;


//-(void)assignPort: (Portfolio*) myPort;
-(void) updateHistory:(CoreStock*)theStock andAmount: (int) theAmount andID: (int) ID;

-(double) calcValue;

@end
