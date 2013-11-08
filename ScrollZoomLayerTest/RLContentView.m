//
//  RLContentView.m
//  ScrollZoomLayerTest
//
//  Created by brian on 11/1/13.
//  Copyright (c) 2013 Rantlab. All rights reserved.
//

#import "RLContentView.h"
#import <QuartzCore/QuartzCore.h>

@interface RLContentView ()
{
    CGRect _naturalSize;
}

@property NSMutableDictionary *rects;
@end

@implementation RLContentView

- (id)initWithImage:(NSImage *)image
{
    _naturalSize = CGRectMake(0.0,0.0,[image size].width,[image size].height);
    
	if (self = [super initWithFrame:_naturalSize])
    {
        CALayer *backingLayer = [CALayer layer];
        backingLayer.anchorPoint = CGPointZero;
        backingLayer.bounds = self.bounds;
        backingLayer.delegate = self;
        self.layer = backingLayer;
        self.layer.borderWidth = 5.0;
        self.layer.borderColor = [NSColor redColor].CGColor;
        [self setWantsLayer:YES];
    
        // create the image view with a frame the size of the image
        self.layer.contents = (__bridge id)([image CGImageForProposedRect:&_naturalSize context:[NSGraphicsContext currentContext] hints:nil]);
        
        self.layer.bounds = _naturalSize;
        
        self.rects = [NSMutableDictionary dictionary];
        for (int i = 0; i < 100; i++)
        {
            NSString *widgetkey = [NSString stringWithFormat:@"%i", i];
            CGRect rect = CGRectMake(i*5, i*5, 20, 20);
            [self.rects setObject:[NSValue valueWithRect:rect] forKey:widgetkey];
            
            CALayer *rectLayer = [CALayer layer];
            [rectLayer setValue:widgetkey forKey:@"widgetId"];
            rectLayer.anchorPoint = CGPointZero;
            rectLayer.borderColor = [NSColor redColor].CGColor;
            rectLayer.borderWidth = 1.0;
            [self.layer addSublayer:rectLayer];
        }
    }
    
	return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    CGFloat xScale = layer.bounds.size.width / _naturalSize.size.width;
    CGFloat yScale = layer.bounds.size.height / _naturalSize.size.height;
    
    //NSLog(@"%0.2f, %0.2f", xScale, yScale);
    for (CALayer *subLayer in layer.sublayers)
    {
        NSString *widgetKey = [subLayer valueForKey:@"widgetId"];
        CGRect rect = [[self.rects objectForKey:widgetKey] rectValue];
        
        rect.origin.x *= xScale;
        rect.origin.y *= yScale;
        rect.size.width *= xScale;
        rect.size.height *= yScale;
        
        subLayer.position = rect.origin;
        rect.origin = CGPointZero;
        subLayer.bounds = rect;
    }
    
    [CATransaction commit];
}

- (BOOL)wantsUpdateLayer
{
    return YES;
}

- (BOOL)isOpaque
{
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void)mouseDown:(NSEvent *)event
{
//    NSPoint dragLocation;
//    dragLocation = [self convertPoint:[event locationInWindow] toView:self];
//    [self scrollPoint:dragLocation];
}

- (NSRect)adjustScroll:(NSRect)proposedVisibleRect
{
    return proposedVisibleRect;
}

@end
