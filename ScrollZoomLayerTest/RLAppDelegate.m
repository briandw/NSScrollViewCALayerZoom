//
//  RLAppDelegate.m
//  ScrollZoomLayerTest
//
//  Created by brian on 11/1/13.
//  Copyright (c) 2013 Rantlab. All rights reserved.
//

#import "RLAppDelegate.h"
#import "RLContentView.h"
#import "RLClipView.h"

@implementation RLAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    /*
    // theWindow is an IBOutlet that is connected to a window
    // theImage is assumed to be declared and populated already
    // determine the image size as a rectangle
    // theImage is assumed to be declared elsewhere
    
    NSImage *image = [NSImage imageNamed:@"test"];
    RLContentView *theImageView = [[RLContentView alloc] initWithImage:image];
    
       // create the scroll view so that it fills the entire window
    // to do that we'll grab the frame of the window's contentView
    // theWindow is an outlet connected to a window instance in Interface Builder
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:
                                [[self.window contentView] frame]];
    scrollView.allowsMagnification = YES;
    // the scroll view should have both horizontal
    // and vertical scrollers
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:YES];
    // configure the scroller to have no visible border
    [scrollView setBorderType:NSNoBorder];
    // set the autoresizing mask so that the scroll view will
    // resize with the window
    [scrollView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    // set theImageView as the documentView of the scroll view
    
    RLClipView *clipView = [[RLClipView alloc] initWithFrame:theImageView.frame];
    [scrollView setContentView:clipView];
    [scrollView setDocumentView:theImageView];
    
    NSRect frame = scrollView.frame;
    [scrollView centerScanRect:frame];
    scrollView.frame = frame;
    
    theImageView.frame = [scrollView centerScanRect:theImageView.frame];
    
    // setting the documentView retains theImageView
    // so we can now release the imageView
    
    // set the scrollView as the window's contentView
    // this replaces the existing contentView and retains
    // the scrollView, so we can release it now
    [self.window setContentView:scrollView];
*/
    // display the window
    [self.window makeKeyAndOrderFront:nil];
}

@end
