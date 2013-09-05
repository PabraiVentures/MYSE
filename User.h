//
//  User.h
//  BayTrade
//
//  Created by Jamie Tahirkheli on 8/14/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "StackMob.h"

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, retain) NSManagedObject *coremodel;


@end
