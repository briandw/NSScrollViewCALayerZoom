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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSImage *image = [NSImage imageNamed:@"test"];
    self = [self initWithImage:image];
    
    return self;
}

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

- (void)zoom:(CGFloat)zoom
{
    _zoom += zoom;
    if (_zoom < 0.2) _zoom = 0.2;
    
    CGSize originalSize = self.frame.size;
    CGSize newSize = CGSizeMake(_naturalSize.size.width * _zoom, _naturalSize.size.height * _zoom);
    
    CGRect visibleRect = [self visibleRect];
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    [self setFrameSize:newSize];
    
    NSScrollView *scrollView = [self enclosingScrollView];
    NSClipView *clipView = [scrollView contentView];
    CGRect clipBounds = clipView.bounds;
    clipBounds.origin.x -= (originalSize.width - newSize.width)/2.0;
    clipBounds.origin.y -= (originalSize.height - newSize.height)/2.0;
    
    clipView.bounds = clipBounds;

    
    //NSLog(@"f%0.2f, %0.2f", xScale, yScale);
    for (CALayer *subLayer in self.layer.sublayers)
    {
        NSString *widgetKey = [subLayer valueForKey:@"widgetId"];
        CGRect rect = [[self.rects objectForKey:widgetKey] rectValue];
        
        rect.origin.x *= _zoom;
        rect.origin.y *= _zoom;
        rect.size.width *= _zoom;
        rect.size.height *= _zoom;
        
        subLayer.position = rect.origin;
        rect.origin = CGPointZero;
        subLayer.bounds = rect;
    }
    
    [CATransaction commit];
}

- (void)magnifyWithEvent:(NSEvent *)event
{
    [self zoom:[event magnification]];
        /*
    NSScrollView *scrollView = [self enclosingScrollView];
    NSClipView *clipView = [scrollView contentView];
    CGRect clipViewBounds = [clipView bounds];
    CGPoint clipViewOrigin = clipViewBounds.origin;
    CGPoint clipCenter = CGPointMake(CGRectGetMidX(clipViewBounds), CGRectGetMidY(clipViewBounds));
    
    CGPoint delta = CGPointMake(clipCenter.x - clipViewOrigin.x, clipCenter.y - clipViewOrigin.y);
    
    CGFloat mag = event.magnification;
    [self zoom:mag];
   
    clipCenter.x *= 1.0+mag;
    clipCenter.y *= 1.0+mag;
    
    CGPoint newOrigin = CGPointMake(clipCenter.x - delta.x, clipCenter.y - delta.y);
    clipViewBounds = clipView.bounds;
    clipViewBounds.origin = newOrigin;
    
    clipView.bounds = clipViewBounds;
    [scrollView reflectScrolledClipView:clipView];
     */
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [self setZoom:_zoom];
}

- (BOOL)wantsUpdateLayer
{
    return YES;
}

- (BOOL)isOpaque
{
    return YES;
}

- (BOOL)acceptsFirstResponder:(NSEvent *)theEvent
{
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void)mouseDown:(NSEvent *)event
{
    NSScrollView *scrollView = [self enclosingScrollView];
    NSClipView *clipView = [scrollView contentView];
    
    NSPoint windowPoint = [event locationInWindow];
    NSPoint loc = [self convertPoint:windowPoint fromView:nil];
    NSLog(@"nsview point %0.2f, %0.2f", loc.x, loc.y);
    
    loc = [clipView convertPoint:windowPoint fromView:nil];
    NSLog(@"clipview point %0.2f, %0.2f", loc.x, loc.y);
    
    CGRect visibleRect = [self visibleRect];
    NSLog(@"viz rect %@", NSStringFromRect(visibleRect));
    
    visibleRect.size.width *= _zoom;
    visibleRect.size.height *= _zoom;
    visibleRect.origin.x *= _zoom;
    visibleRect.origin.y *= _zoom;
    
    NSLog(@"center point %0.2f, %0.2f", CGRectGetMinX(visibleRect), CGRectGetMidY(visibleRect));
    
    //[self scrollPoint:loc];
}

- (NSRect)adjustScroll:(NSRect)proposedVisibleRect
{
    return proposedVisibleRect;
}

- (IBAction)zoomIn:(id)sender
{
    _zoom += 1;
    
    CGSize newSize = CGSizeMake(_naturalSize.size.width * _zoom, _naturalSize.size.height * _zoom);
    
    CGRect visibleRect = [self visibleRect];
    visibleRect.size.width *= _zoom;
    visibleRect.size.height *= _zoom;
    visibleRect.origin.x *= _zoom;
    visibleRect.origin.y *= _zoom;
    
    CGPoint zoomPoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    CGPoint boundsOrigin = CGPointMake(zoomPoint.x-visibleRect.size.width/2.0, zoomPoint.y-visibleRect.size.height/2.0);
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    [self setFrameSize:newSize];
    
    NSScrollView *scrollView = [self enclosingScrollView];
    NSClipView *clipView = [scrollView contentView];
    CGRect clipBounds = clipView.bounds;
    clipBounds.origin = boundsOrigin;
    clipView.bounds = clipBounds;
    
    
    //NSLog(@"f%0.2f, %0.2f", xScale, yScale);
    for (CALayer *subLayer in self.layer.sublayers)
    {
        NSString *widgetKey = [subLayer valueForKey:@"widgetId"];
        CGRect rect = [[self.rects objectForKey:widgetKey] rectValue];
        
        rect.origin.x *= _zoom;
        rect.origin.y *= _zoom;
        rect.size.width *= _zoom;
        rect.size.height *= _zoom;
        
        subLayer.position = rect.origin;
        rect.origin = CGPointZero;
        subLayer.bounds = rect;
    }
    
    [CATransaction commit];
}

- (IBAction)zoomOut:(id)sender
{
    [self zoom:-1.0];
}

- (IBAction)zoom1:(id)sender
{
    _zoom = 1;
    [self zoom:0];
}

- (IBAction)zoom2:(id)sender
{
    _zoom = 2;
    [self zoom:0];
}

- (IBAction)zoom4:(id)sender
{
    _zoom = 4;
     [self zoom:0];
}

@end
