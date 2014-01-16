//
//  RLContentView.h
//  ScrollZoomLayerTest
//
//  Created by brian on 11/1/13.
//  Copyright (c) 2013 Rantlab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RLContentView : NSView

- (id)initWithImage:(NSImage *)image;

@property (nonatomic, strong) IBOutlet NSScrollView *scrollView;
@property (nonatomic, assign) CGFloat zoom;
@end
