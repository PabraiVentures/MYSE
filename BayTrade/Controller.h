//
//  Controller.h
//  BayTrade
//
//  Created by Jamie Tahirkheli on 6/24/13.
//  Copyright (c) 2013 Jamie Tahirkheli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cache.h"

//#define QUOTE_QUERY_PREFIX @"http://query.yahooapis.com/v1/public/yql?q=select%20BidRealtime%2C%20Open%2C%20symbol%20from%20yahoo.finance.quotes%20where%20symbol%20in%20("
//#define QUOTE_QUERY_SUFFIX @")&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="
@interface Controller : NSObject

+ (NSDictionary *)fetchQuotesFor:(NSArray *)tickers;

+ (NSNumber*) currentPriceForSymbol: (NSString*) symbol;

@end