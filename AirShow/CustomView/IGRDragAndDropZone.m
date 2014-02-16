//
//  IGRDragAndDropZone.m
//  AirShow
//
//  Created by Vitalii Parovishnyk on 16/02/14.
//  Copyright (c) 2013 IGR Software. All rights reserved.
//

#import "IGRDragAndDropZone.h"

@implementation IGRDragAndDropZone

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
		CGPoint pos = CGPointMake(245.91, 169.66); //Center Position
		CGAffineTransform trans = CGAffineTransformMake(0.7561, 0, 0, 0.76136, pos.x, pos.y); //Transform of object
		{ //SubPath 0
			CGFloat d[] = {-326.79,-224.68,-326.79,-224.68,-220.64,-281.41,-204.74,-229.99, -204.74,-229.99,-95.586,123.1,75.908,96.809,314.76,165.51, 314.76,165.51,341.83,173.29,314.76,250.01,314.76,250.01, 314.76,250.01,314.76,250.01,-326.79,251.54,-326.79,251.54, -326.79,251.54,-326.79,251.54,-326.79,-224.68,-326.79,-224.68 };
			CGPathMoveToPoint(path, &trans, d[0], d[1]);
			for(int i=0; i<5; i++)
			{
				CGPathAddCurveToPoint(path, &trans, d[i*8+2], d[i*8+3], d[i*8+4], d[i*8+5], d[i*8+6], d[i*8+7]);
			}
			CGPathCloseSubpath(path);
		}
		
		//Gradient Fill
		CGFloat componentsFill[]={0.78824, 0.78824, 0.78824, 1,  0.88438, 0.88438, 0.88438, 0.85246,  1, 1, 1, 1};
		CGFloat locationsFill[]={0.10776, 0.3169, 0.94364};
		CGGradientRef gradientFill=CGGradientCreateWithColorComponents(colorSpace, componentsFill, locationsFill, 3);
		CGContextSaveGState(context);
		CGContextAddPath(context, path);
		CGContextEOClip(context);
		CGPoint startFill=CGPointApplyAffineTransform(CGPointMake(-176.02,251.43), trans);
		CGPoint endFill=CGPointApplyAffineTransform(CGPointMake(267.02,-251.43), trans);
		CGContextDrawLinearGradient(context, gradientFill, startFill, endFill, 0xff);
		CGContextRestoreGState(context);
		CGGradientRelease(gradientFill);
		
		//Release Path
		CGPathRelease(path);
	}
	
	//Clean up
	CGColorSpaceRelease(colorSpace);
}

@end
