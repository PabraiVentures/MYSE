//
//  Coremodel.h
//  BayTrade
//
//  Created by Nathan Pabrai on 7/27/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CorePortfolio.h"
#import "CoreTradeEvent.h"

//@class CorePortfolio, CoreTradeEvent;

@interface CoreModel : NSManagedObject

@property (nonatomic, retain) NSString * model_id;
@property (nonatomic, retain) CorePortfolio *portfolio;
@property (nonatomic, retain) NSSet *tradeevents;
@end

@interface CoreModel (CoreDataGeneratedAccessors)

- (void)addTradeeventsObject:(CoreTradeEvent *)value;
- (void)removeTradeeventsObject:(CoreTradeEvent *)value;
- (void)addTradeevents:(NSSet *)values;
- (void)removeTradeevents:(NSSet *)values;

@end