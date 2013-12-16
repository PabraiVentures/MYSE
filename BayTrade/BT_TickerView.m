//
//  BT_TickerView.m
//  BayTrade
//
//  Created by John Luttig on 9/10/13.
//  Copyright (c) 2013 byteNsell. All rights reserved.
//

#import "BT_TickerView.h"
#import "Controller.h"
#import "BT_AppDelegate.h"
#define kMaxWidth 200

/**Single Stock View**/

@implementation TickerItemView

static UIFont *symbolFont = nil;
static UIFont *detailFont = nil;

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        self.frame = CGRectMake(0, 0, 10, 26);
        self.opaque = YES;
        self.contentMode = UIViewContentModeCenter;
    }
    return self;
}

+(void) initialize
{
    symbolFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
    detailFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
}

-(CGFloat) symbolWidth
{
    return [symbol sizeWithFont:symbolFont
              constrainedToSize:CGSizeMake(kMaxWidth, self.frame.size.height)].width;
}

-(CGFloat) percentWidth
{
    return [percent sizeWithFont:detailFont
               constrainedToSize:CGSizeMake(kMaxWidth, self.frame.size.height)].width;
}

-(CGFloat) priceWidth
{
    return [price sizeWithFont:detailFont
               constrainedToSize:CGSizeMake(kMaxWidth, self.frame.size.height)].width;
}

-(CGFloat) width
{
    return 18 + [self symbolWidth] + [self percentWidth] + [self priceWidth] + 20;
}

- (void) setSymbol:(NSString *) symbolToSet percent:(NSString*) percentToSet price:(NSString*) priceToSet image:(UIImage*) imageToSet
{
    symbol = symbolToSet;
    percent = percentToSet;
    price = priceToSet;
    image = imageToSet;
    self.frame = CGRectMake(0, 0, [self width], 26);
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextFillRect(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor blackColor].CGColor);
    
    [symbol drawInRect:CGRectMake(0, 2, [self symbolWidth], 26) withFont:symbolFont];
    [price drawInRect:CGRectMake(10 + [self symbolWidth], 2, [self priceWidth], 26) withFont:detailFont];
    [image drawInRect:CGRectMake([self symbolWidth] + [self percentWidth] + 23, 9, 12, 7)];
    [percent drawInRect:CGRectMake(36 + [self symbolWidth] + [self percentWidth], 2, [self percentWidth], 26) withFont:detailFont];
    
    [super drawRect:rect];
}

@end

@implementation BT_TickerView

-(void) awakeFromNib
{
    self.bounces = YES;
    self.scrollEnabled = YES;
    self.alwaysBounceHorizontal = YES;
    self.alwaysBounceVertical = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}

-(void)loadTickerData
{
    self.tickerItems = [((BT_AppDelegate*)[[UIApplication sharedApplication] delegate]) tickerItems];
}

-(void) reloadData
{
    int itemCount = [self numberOfItemsForTickerView];
    
    int xPos = 0;
    for(int i = 0 ; i < itemCount; i ++)
    {
        TickerItemView *tickerItemView = [[TickerItemView alloc] init];
        [tickerItemView setSymbol:[self  symbolForItemAtIndex:i]
                          percent:[self percentForItemAtIndex:i]
                            price:[self   priceForItemAtIndex:i]
                            image:[self  imageForItemAtIndex:i]];
        tickerItemView.frame = CGRectMake(xPos, 0, [tickerItemView width], self.frame.size.height);
        xPos += ([tickerItemView width] + 30);
        [self addSubview:tickerItemView];
    }
    
    self.contentSize = CGSizeMake(xPos + self.frame.size.width + 100, self.frame.size.height);
    self.contentOffset = CGPointMake(- self.frame.size.width/2, 0);
    
    xPos += 100;
    
    CGFloat breakWidth = 0;
    for(int counter = 0 ; breakWidth < self.frame.size.width; counter ++)
    {
        if (itemCount == 0) continue;
        int i = counter % itemCount;
        TickerItemView *tickerItemView = [[TickerItemView alloc] init];
        [tickerItemView setSymbol:[self symbolForItemAtIndex:i]
                          percent:[self percentForItemAtIndex:i]
                            price:[self priceForItemAtIndex:i]
                           image:[self imageForItemAtIndex:i]];
        
        tickerItemView.frame = CGRectMake(xPos, 0, [tickerItemView width], self.frame.size.height);
        xPos += ([tickerItemView width] + 30);
        breakWidth += ([tickerItemView width] + 30);
        [self addSubview:tickerItemView];
    }
    [self startAnimation];
}

-(void) startAnimation
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self cache:YES];
    [UIView setAnimationDuration:self.contentSize.width/100];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    self.contentOffset = CGPointMake(self.contentSize.width - self.frame.size.width, 0);
    
    [UIView commitAnimations];
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    self.contentOffset = CGPointMake(0, 0);
    [self startAnimation];
}

#pragma mark - Data Source Methods

- (int) numberOfItemsForTickerView
{
    return [self.tickerItems count];
}

- (NSString*) symbolForItemAtIndex:(NSUInteger)index
{
    NSDictionary *thisDict = [self.tickerItems objectAtIndex:index];
    return [thisDict objectForKey:@"Symbol"];
}

- (NSString*) percentForItemAtIndex:(NSUInteger)index
{
    NSDictionary *thisDict = [self.tickerItems objectAtIndex:index];
    NSString *percent = [NSString stringWithFormat:@"%.2f%%",[[thisDict objectForKey:@"PercentChange"]doubleValue]];
    return percent;
}

- (NSString*) priceForItemAtIndex:(NSUInteger) index
{
    NSDictionary *thisDict = [self.tickerItems objectAtIndex:index];
    NSString *price = [NSString stringWithFormat:@"$%.2f",[[thisDict objectForKey:@"CurrentPrice"] doubleValue]];
    return price;
}

- (UIImage*) imageForItemAtIndex:(NSUInteger) index
{
    NSDictionary *thisDict = [self.tickerItems objectAtIndex:index];
    NSString *imageFileName = [[thisDict objectForKey:@"Positive"] boolValue] ? @"greenArrow" : @"redArrow";
    return [UIImage imageNamed:imageFileName];
}

@end