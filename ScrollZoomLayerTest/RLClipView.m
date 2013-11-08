//
//  RLClipView.m
//  ScrollZoomLayerTest
//
//  Created by brian on 11/7/13.
//  Copyright (c) 2013 Rantlab. All rights reserved.
//

#import "RLClipView.h"

@implementation RLClipView

- (NSRect)constrainBoundsRect:(NSRect)proposedBounds
{
    NSRect docRect = [self.documentView frame];
    if (docRect.size.width >= proposedBounds.size.width &&
        docRect.size.height >= proposedBounds.size.height)
    {
        return proposedBounds;
    }

    NSRect clipRect = [self bounds];
    CGFloat maxX = docRect.size.width - clipRect.size.width;
    CGFloat maxY = docRect.size.height - clipRect.size.height;
    
    if (docRect.size.width < proposedBounds.size.width)
    {
        proposedBounds.origin.x = roundf(maxX / 2.0);
    } else
    {
        proposedBounds.origin.x = roundf(MAX(0, MIN(proposedBounds.origin.x, maxX)));
    }
    
    if (docRect.size.height < proposedBounds.size.height)
    {
        proposedBounds.origin.y = roundf(maxY / 2.0);
    } else
    {
        proposedBounds.origin.y = roundf(MAX(0, MIN(proposedBounds.origin.y, maxY)));
    }
  
    return proposedBounds;
}


@end
