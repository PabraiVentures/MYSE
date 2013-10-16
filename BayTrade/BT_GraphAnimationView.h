//
//  BT_GraphAnimationView.h
//  BayTrade
//
//  Created by John Luttig on 10/16/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BT_GraphAnimationView : UIView {
    CAShapeLayer *bezier;
    NSMutableArray *linepoints;
}

@end
