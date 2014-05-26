//
//  RLAppDelegate.m
//  ScrollZoomLayerTest
//
//  Created by brian on 11/1/13.
//  Copyright (c) 2013 Rantlab. All rights reserved.
//

#import "RLAppDelegate.h"
#import "RLDocumentView.h"
#import "RLClipView.h"

@implementation RLAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSRect frame = NSMakeRect(512, 1024, 800, 600);
    self.window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:NSResizableWindowMask | NSTitledWindowMask | NSClosableWindowMask
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    
    // create the scroll view so that it fills the entire window
    // to do that we'll grab the frame of the window's contentView
    // theWindow is an outlet connected to a window instance in Interface Builder
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:frame];
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
    [scrollView.contentView setPostsBoundsChangedNotifications:YES];
    
    RLClipView *clipView = [[RLClipView alloc] initWithFrame:frame];
    [scrollView setContentView:clipView];
    
    // set the scrollView as the window's contentView
    // this replaces the existing contentView and retains
    // the scrollView, so we can release it now
    [self.window setContentView:scrollView];
    
    NSImage *image = [NSImage imageNamed:@"test"];
    CGRect imageRect = CGRectZero;
    imageRect.size = image.size;
    
    
    RLDocumentView *documentView = [[RLDocumentView alloc] initWithImage:image];
    documentView.scrollView = scrollView;
    [scrollView setDocumentView:documentView];
    
    [[NSNotificationCenter defaultCenter] addObserver:documentView selector:@selector(contentBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:scrollView.contentView];
    
    [self.window makeKeyAndOrderFront:nil];
}

@end
