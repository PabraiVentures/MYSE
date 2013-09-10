//
//  BT_TickerView.h
//  BayTrade
//
//  Created by John Luttig on 9/10/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BT_TickerView : UIScrollView

@property (nonatomic, retain) NSMutableArray *tickerItems;

- (NSString*) symbolForItemAtIndex:(NSUInteger) index;
- (NSString*) percentForItemAtIndex:(NSUInteger) index;
- (NSString*) priceForItemAtIndex:(NSUInteger) index;
- (UIImage*) imageForItemAtIndex:(NSUInteger) index;

-(void) reloadData;
-(void) startAnimation;
-(void) loadTickerData;

@end

@interface TickerItemView : UIView {
    
    NSString *symbol;
    NSString *price;
    NSString *percent;
    UIImage *image;
}

- (void) setSymbol:(NSString *) symbolToSet percent:(NSString*) percentToSet price:(NSString*) priceToSet image:(UIImage*) imageToSet;

@end