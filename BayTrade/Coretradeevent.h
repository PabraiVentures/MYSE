//
//  Coretradeevent.h
//  BayTrade
//
//  Created by Nathan Pabrai on 7/27/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Coretradeevent : NSManagedObject

@property (nonatomic, retain) NSNumber * actionid;
@property (nonatomic, retain) NSString * ticker;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSNumber * tradeamount;
@property (nonatomic, retain) NSString * tradeevents_id;
@property (nonatomic, retain) NSNumber * tradeprice;

@end
