//
//  User.m
//  BayTrade
//
//  Created by Jamie Tahirkheli on 8/14/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "User.h"


@implementation User

@dynamic user_id;
@dynamic coremodel;
-(NSString*)primaryKeyField{
    return @"user_id";
}
@end
