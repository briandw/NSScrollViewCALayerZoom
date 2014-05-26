//
//  RLContentView.m
//  ScrollZoomLayerTest
//
//  Created by brian on 11/1/13.
//  Copyright (c) 2013 Rantlab. All rights reserved.
//

#import "RLDocumentView.h"
#import <QuartzCore/QuartzCore.h>

@interface RLDocumentView ()
{
    CGRect _naturalSize;
}

@property NSMutableDictionary *rects;
@end

@implementation RLDocumentView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSImage *image = [NSImage imageNamed:@"test"];
    self = [self initWithImage:image];
    
    return self;
}

- (id)initWithImage:(NSImage *)image
{
    _naturalSize = CGRectMake(0.0, 0.0, [image size].width, [image size].height);
    
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
        
        CGSize stride = CGSizeMake(_naturalSize.size.width/100.0, _naturalSize.size.height/100.0);
        for (int i = 0; i < 100; i++)
        {
            NSString *widgetkey = [NSString stringWithFormat:@"%i", i];
            CGRect rect = CGRectMake(i*stride.width, i*stride.height, stride.width, stride.height);
            [self.rects setObject:[NSValue valueWithRect:rect] forKey:widgetkey];
            
            CALayer *rectLayer = [CALayer layer];
            rectLayer.bounds = CGRectMake(0, 0, stride.width, stride.height);
            rectLayer.position = rect.origin;
            [rectLayer setValue:widgetkey forKey:@"widgetId"];
            rectLayer.anchorPoint = CGPointZero;
            rectLayer.borderColor = [NSColor redColor].CGColor;
            rectLayer.borderWidth = 1.0;
            [self.layer addSublayer:rectLayer];
        }
    }
    
	return self;
}

- (void)contentBoundsDidChange:(NSNotification *)notification
{
    CGRect clipViewBounds = self.layer.bounds;
   // NSLog(@"%0.2f, %0.2f, %0.2f, %0.2f,", clipViewBounds.origin.x, clipViewBounds.origin.y, clipViewBounds.size.width, clipViewBounds.size.height);
    
    CGFloat zoom = clipViewBounds.size.width / _naturalSize.size.width;
    NSLog(@"%f",zoom);
    [self setZoom:zoom];
}

- (void)setZoom:(CGFloat)zoom
{
    _zoom = zoom;

    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
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

- (IBAction)zoomOut:(id)sender
{
    [self setZoom:self.zoom*0.5];
}

- (IBAction)zoomIn:(id)sender
{
    [self setZoom:self.zoom*2.0];
}

/*
 float zoomFactor = 1.3;
 
 -(void)zoomIn
 {
 NSRect visible = [scrollView documentVisibleRect];
 NSRect newrect = NSInsetRect(visible, NSWidth(visible)*(1 - 1/zoomFactor)/2.0, NSHeight(visible)*(1 - 1/zoomFactor)/2.0);
 NSRect frame = [scrollView.documentView frame];
 
 [scrollView.documentView scaleUnitSquareToSize:NSMakeSize(zoomFactor, zoomFactor)];
 [scrollView.documentView setFrame:NSMakeRect(0, 0, frame.size.width * zoomFactor, frame.size.height * zoomFactor)];
 
 [[scrollView documentView] scrollPoint:newrect.origin];
 }
 
 -(void)zoomOut
 {
 NSRect visible = [scrollView documentVisibleRect];
 NSRect newrect = NSOffsetRect(visible, -NSWidth(visible)*(zoomFactor - 1)/2.0, -NSHeight(visible)*(zoomFactor - 1)/2.0);
 
 NSRect frame = [scrollView.documentView frame];
 
 [scrollView.documentView scaleUnitSquareToSize:NSMakeSize(1/zoomFactor, 1/zoomFactor)];
 [scrollView.documentView setFrame:NSMakeRect(0, 0, frame.size.width / zoomFactor, frame.size.height / zoomFactor)];
 
 [[scrollView documentView] scrollPoint:newrect.origin];
 }
 */

@end
