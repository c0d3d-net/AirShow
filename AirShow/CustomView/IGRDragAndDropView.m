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
		CGPoint pos = CGPointMake(240.34, 180); //Center Position
		CGAffineTransform trans = CGAffineTransformMake(0.75078, 0, 0, 0.74843, pos.x, pos.y); //Transform of object
		{ //SubPath 0
			CGFloat d[] = {-320.78,-240.5,-320.78,-240.5,319.22,-240.5,319.22,-240.5, 319.22,-240.5,319.22,-240.5,320.78,240.5,320.78,240.5, 320.78,240.5,320.78,240.5,-320.11,240.5,-320.11,240.5, -320.11,240.5,-320.11,240.5,-320.78,-240.5,-320.78,-240.5 };
			CGPathMoveToPoint(path, &trans, d[0], d[1]);
			for(int i=0; i<4; i++)
			{
				CGPathAddCurveToPoint(path, &trans, d[i*8+2], d[i*8+3], d[i*8+4], d[i*8+5], d[i*8+6], d[i*8+7]);
			}
			CGPathCloseSubpath(path);
		}
		
		//Gradient Fill
		CGFloat componentsFill[]={0.40578, 0.55915, 0.74902, 0.47451,  0.88438, 0.88438, 0.88438, 0.85246,  0.59921, 0.85397, 1, 1};
		CGFloat locationsFill[]={0, 0.677, 0.94364};
		CGGradientRef gradientFill=CGGradientCreateWithColorComponents(colorSpace, componentsFill, locationsFill, 3);
		CGContextSaveGState(context);
		CGContextAddPath(context, path);
		CGContextEOClip(context);
		CGPoint startFill=CGPointApplyAffineTransform(CGPointMake(-53.015,19), trans);
		CGPoint endFill=CGPointApplyAffineTransform(CGPointMake(254.5,-320.5), trans);
		CGContextDrawRadialGradient(context, gradientFill, startFill, 0, endFill, 524.75, 0xff);
		CGContextRestoreGState(context);
		CGGradientRelease(gradientFill);
		
		//Release Path
		CGPathRelease(path);
	}
	
	//Clean up
	CGColorSpaceRelease(colorSpace);

}

@end
