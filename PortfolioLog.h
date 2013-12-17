//
//  PortfolioLog.h
//  BayTrade
//
//  Created by Nathan Pabrai on 12/16/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CorePortfolio;

@interface PortfolioLog : NSManagedObject

@property (nonatomic, retain) NSString * logtime;
@property (nonatomic, retain) NSNumber * accountvalue;
@property (nonatomic, retain) CorePortfolio *portfolio;

@end
