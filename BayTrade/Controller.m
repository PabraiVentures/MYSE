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
    @try {
    NSMutableString *query = [NSMutableString stringWithString: QUOTE_QUERY_PREFIX];
    
    for (int i = 0; i < [tickers count]; i++) {
        NSString *ticker = [tickers objectAtIndex:i];
        [query appendString:[NSString stringWithFormat:@"%%22%@%%22", ticker]];
        if (i != [tickers count] - 1) [query appendString:@"%2C"];
    }
    [query appendString:QUOTE_QUERY_SUFFIX];
        NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil] : nil;
        return [results valueForKeyPath:@"query.results.quote"];
    }
    @catch (NSException *exception) {
        UIAlertView *quoteRetrievalAlert = [[UIAlertView alloc] initWithTitle:@"Error!" message:[ NSString stringWithFormat:@"Could not retrieve stock quote. Please try again later. Exception: %@", exception] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [quoteRetrievalAlert show];
        return nil;
    }
}

+ (NSDictionary *)fetchQuotesAndMoreFor:(NSArray *)tickers {
    @try {
        NSMutableString *query = [NSMutableString stringWithString: QUOTE_QUERY_PREFIX];
        
        for (int i = 0; i < [tickers count]; i++) {
            NSString *ticker = [tickers objectAtIndex:i];
            [query appendString:[NSString stringWithFormat:@"%%22%@%%22", ticker]];
            if (i != [tickers count] - 1) [query appendString:@"%2C"];
        }
        [query appendString:QUOTE_QUERY_SUFFIX];
        NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil] : nil;
        NSLog(@"quote-L0%@", [results valueForKeyPath:@"query.results.quote"]);
        return [results valueForKeyPath:@"query.results.quote"];
    }
    @catch (NSException *exception) {
        UIAlertView *quoteRetrievalAlert = [[UIAlertView alloc] initWithTitle:@"Error!" message:[ NSString stringWithFormat:@"Could not retrieve stock quote. Please try again later. Exception: %@", exception] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [quoteRetrievalAlert show];
        return nil;
    }
}

+ (NSNumber*) currentPriceForSymbol: (NSString*) symbol
{
///  if (<#condition#>) {
//    <#statements#>
//  }
    NSDictionary *quote = [Controller fetchQuotesFor:[NSArray arrayWithObject:symbol]];
    NSLog(@" ++++++ OUT\n %@%@",symbol,quote);
    return quote[@"LastTradePriceOnly"];
}

@end