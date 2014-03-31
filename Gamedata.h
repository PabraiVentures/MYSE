//
//  Gamedata.h
//  BayTrade
//
//  Created by Nathan Pabrai on 3/31/14.
//  Copyright (c) 2014 byteNsell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Gamedata : NSManagedObject

@property (nonatomic, retain) NSNumber * marketopen;
@property (nonatomic, retain) NSString * gamedata_id;

@end
