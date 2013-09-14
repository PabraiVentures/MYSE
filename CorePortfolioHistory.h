//
//  CorePortfolioHistory.h
//  BayTrade
//
//  Created by Nathan Pabrai on 9/13/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CorePortfolioHistory : NSManagedObject

@property (nonatomic, retain) NSString * coreportfoliohistory_id;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSString * sm_owner;
@property (nonatomic, retain) NSNumber * createddate;

@end
