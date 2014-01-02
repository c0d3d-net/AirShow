//
//  IGRDragAndDropView.m
//  AirShow
//
//  Created by Vitalii Parovishnyk on 12/30/13.
//  Copyright (c) 2013 IGR Software. All rights reserved.
//

#import "IGRDragAndDropView.h"

@implementation IGRDragAndDropView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	CGContextRef context=[[NSGraphicsContext currentContext] graphicsPort];
	// We use Upper-left coordinate system.
	CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
	
	//Draw Object 1
	{
		//Create Path
		CGMutablePathRef path = CGPathCreateMutable();
		CGPoint pos = CGPointMake(240, 180); //Center Position
		CGAffineTransform trans = CGAffineTransformMake(0.96579, 0, 0, 0.93995, pos.x, pos.y); //Transform of object
		CGRect rect=CGRectMake(-248.5,-191.5,497,383);
		CGPathAddRect(path, &trans, rect);
		
		//Gradient Fill
		CGFloat componentsFill[]={0.5819, 0.55291, 0.58824, 0.78431,  1, 1, 1, 1};
		CGFloat locationsFill[]={0.0085889, 1};
		CGGradientRef gradientFill=CGGradientCreateWithColorComponents(colorSpace, componentsFill, locationsFill, 2);
		CGContextSaveGState(context);
		CGContextAddPath(context, path);
		CGContextEOClip(context);
		CGPoint startFill=CGPointApplyAffineTransform(CGPointMake(-233.11,-175.54), trans);
		CGPoint endFill=CGPointApplyAffineTransform(CGPointMake(-248.5,-191.5), trans);
		CGContextDrawRadialGradient(context, gradientFill, startFill, 0, endFill, 724.92, 0xff);
		CGContextRestoreGState(context);
		CGGradientRelease(gradientFill);
		
		//Release Path
		CGPathRelease(path);
	}
	
	//Clean up
	CGColorSpaceRelease(colorSpace);
}

@end
