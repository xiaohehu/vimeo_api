//
//  galleryCell.m
//  vimeo_test
//
//  Created by Xiaohe Hu on 1/29/15.
//  Copyright (c) 2015 Neoscape. All rights reserved.
//

#import "galleryCell.h"

@implementation galleryCell
@synthesize cellThumb = _cellThumb;
@synthesize cellCaption = _cellCaption;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)prepareForReuse
{
//    [cellThumb removeFromSuperview];
//    cellThumb = nil;
}

@end
