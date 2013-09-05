//
//  BT_TradeEvent.h
//  BayTrade
//
//  Created by Nathan Pabrai on 7/26/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BT_TradeEvent : NSObject
@property (nonatomic,strong)NSString* ticker;
@property (nonatomic)double tradePrice;
@property (nonatomic)int actionID;
@property (nonatomic)int tradeAmount; //change to NSInteger later
@property (nonatomic, retain) NSString* date;
//potentially add user id for data analysis based on trades by type of user
@end
