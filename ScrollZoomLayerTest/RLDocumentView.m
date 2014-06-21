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

@property NSMutableArray *widgets;
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
        
        self.widgets = [NSMutableArray array];
        
        CGSize stride = CGSizeMake(100, 100);
        for (int i = 0; i < 10; i++)
        {
            CGRect rect = CGRectMake(i*stride.width, i*stride.height, 10, 10);
            CALayer *rectLayer = [CALayer layer];
            rectLayer.bounds = CGRectMake(0, 0,10, 10);
            rectLayer.position = rect.origin;
            [rectLayer setValue:[NSValue valueWithRect:rect] forKey:@"rectValue"];
            rectLayer.anchorPoint = CGPointZero;
            rectLayer.borderColor = [NSColor redColor].CGColor;
            rectLayer.borderWidth = 1.0;
            [self.layer addSublayer:rectLayer];
            [self.widgets addObject:rectLayer];
        }
    }
    
	return self;
}

- (void)contentBoundsDidChange:(NSNotification *)notification
{
    NSScrollView *scrollView = [self enclosingScrollView];
    NSView *contentView = scrollView.contentView;
    CGRect contentBounds = contentView.bounds;
    
    NSLog(@"%0.2f, %0.2f, %0.2f, %0.2f,", contentBounds.origin.x, contentBounds.origin.y, contentBounds.size.width, contentBounds.size.height);

    
    CGRect clipViewBounds = self.layer.bounds;
    
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
    for (CALayer *widget in self.widgets)
    {
        CGRect rect = [[widget valueForKey:@"rectValue"] rectValue];
        rect.origin.x *= _zoom;
        rect.origin.y *= _zoom;
        rect.size.width *= _zoom;
        rect.size.height *= _zoom;
        
        widget.position = rect.origin;
        rect.origin = CGPointZero;
        widget.bounds = rect;
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
    NSPoint windowPoint = [event locationInWindow];
    NSPoint loc = [self convertPoint:windowPoint fromView:nil];
    //NSLog(@"nsview point %0.2f, %0.2f", loc.x, loc.y);
    
    int i = 0;
    for (NSValue *widget in self.widgets)
    {
        CGRect rect = [[widget valueForKey:@"rectValue"] rectValue];
        if (CGRectContainsPoint(rect, loc))
        {
            NSLog(@"Hit %i!", i);
        }
        i++;
    }
/*

    NSScrollView *scrollView = [self enclosingScrollView];
    NSClipView *clipView = [scrollView contentView];
    loc = [clipView convertPoint:windowPoint fromView:nil];
    NSLog(@"clipview point %0.2f, %0.2f", loc.x, loc.y);
    
    CGRect visibleRect = [self visibleRect];
    NSLog(@"viz rect %@", NSStringFromRect(visibleRect));
    
    visibleRect.size.width *= _zoom;
    visibleRect.size.height *= _zoom;
    visibleRect.origin.x *= _zoom;
    visibleRect.origin.y *= _zoom;
    
    NSLog(@"center point %0.2f, %0.2f", CGRectGetMinX(visibleRect), CGRectGetMidY(visibleRect));
   */
    //[self scrollPoint:loc];
}

- (NSRect)adjustScroll:(NSRect)proposedVisibleRect
{
    return proposedVisibleRect;
}

#define ZOOM_FACTOR 1.5
- (IBAction)zoomOut:(id)sender
{
    NSScrollView *scrollView = [self enclosingScrollView];
    NSView *contentView = scrollView.contentView;
    CGRect contentBounds = contentView.bounds;
    contentBounds.size.width *= ZOOM_FACTOR;
    contentBounds.size.height *= ZOOM_FACTOR;
    contentBounds.origin.x /= ZOOM_FACTOR;
    contentBounds.origin.y /= ZOOM_FACTOR;
    scrollView.contentView.bounds = contentBounds;
}

- (IBAction)zoomIn:(id)sender
{
    NSScrollView *scrollView = [self enclosingScrollView];
    NSView *contentView = scrollView.contentView;
    CGRect contentBounds = contentView.bounds;
    contentBounds.size.width /= ZOOM_FACTOR;
    contentBounds.size.height /= ZOOM_FACTOR;
    contentBounds.origin.x *= ZOOM_FACTOR;
    contentBounds.origin.y *= ZOOM_FACTOR;
    scrollView.contentView.bounds = contentBounds;
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
