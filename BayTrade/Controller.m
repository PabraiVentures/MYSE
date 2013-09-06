//
//  Controller.m
//  BayTrade
//
//  Created by Jamie Tahirkheli on 6/24/13.
//  Copyright (c) 2013 Jamie Tahirkheli. All rights reserved.
//

#import "Controller.h"

@implementation Controller


/**
 This method takes an array of stock symbols and returns data for each of them in a dictionary.
 */
+ (NSDictionary *)fetchQuotesFor:(NSArray *)tickers {
    NSMutableDictionary *quotes=nil;
    
    if (tickers && [tickers count] > 0) {
        NSMutableString *query = [[NSMutableString alloc] init];
        [query appendString:QUOTE_QUERY_PREFIX];
        
        for (int i = 0; i < [tickers count]; i++) {
            NSString *ticker = [tickers objectAtIndex:i];
            [query appendFormat:@"%%22%@%%22", ticker];
            if (i != [tickers count] - 1) [query appendString:@"%2C"];
        }
        
        [query appendString:QUOTE_QUERY_SUFFIX];
        
        NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil] : nil;
        NSDictionary *quoteEntry = nil;
        NSLog(@"results in fetchquotes: %@", results);
        quoteEntry = [results valueForKeyPath:@"query.results.quote"];
        return quoteEntry;
    }
    else {
        NSLog(@"no tickers given.");
    }
    return quotes;
}


@end
