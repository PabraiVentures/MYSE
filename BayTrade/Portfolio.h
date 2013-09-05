//
//  Portfolio.h
//  Stocks
//
//  Created by Jamie Tahirkheli on 6/8/13.
//  Copyright (c) 2013 Jamie Tahirkheli. All rights reserved.
//

#import "Stock.h"
#ifndef Stocks_Portfolio_h
#define Stocks_Portfolio_h

@interface Portfolio : NSObject
@property (nonatomic, retain) NSString *owner;
@property (nonatomic, retain) NSMutableArray *stockList;
@property (nonatomic) double value;
@property (nonatomic) double cash;



//add methods for initWithStock and such

+(id) initSelf;
-(id) initWithStock:(Stock *) theStock;
-(Stock *) addStock: (Stock *) addedStock;
-(Stock *) findStock: (NSString *) symbol;
-(void) calculateValue;
@end


#endif
