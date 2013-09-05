//
//  Stock.h
//  Stocks
//
//  Created by Jamie Tahirkheli on 6/8/13.
//  Copyright (c) 2013 Jamie Tahirkheli. All rights reserved.
//

#ifndef Stocks_Stock_h
#define Stocks_Stock_h

@interface Stock : NSObject 
//instance variables
@property (nonatomic, retain) NSString *symbol;
@property (nonatomic, retain) NSString *name;
@property (nonatomic) double buyPrice;
@property (nonatomic) double sellPrice;
@property (nonatomic) double openPrice;
@property (nonatomic) double closePrice;
@property (nonatomic) double crntPrice;
@property (nonatomic) int amount;
@property (nonatomic) double totalValue;
@property (nonatomic) double purchasedPrice;



//method declarations.
//-(id) init;
+(Stock*) initWithSymbol: (NSString *) theSymbol AndPrice: (double) theOpen AndAmount: (int) theAmount;
-(void) initToZero;
-(void) transfer;
-(void) setName;
-(void) calculateValue;

@end


#endif
