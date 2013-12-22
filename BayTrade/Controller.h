//
//  Controller.h
//  BayTrade
//
//  Created by Jamie Tahirkheli on 6/24/13.
//  Copyright (c) 2013 Jamie Tahirkheli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cache.h"

@interface Controller : NSObject

+ (NSDictionary*) fetchQuotesFor: (NSArray *) tickers;
+ (NSDictionary*) fetchQuoteFor: (NSArray *) tickers;

+ (NSNumber*) currentPriceForSymbol: (NSString*) symbol;

@end