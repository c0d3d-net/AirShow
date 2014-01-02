//
//  IGRURLPanel.m
//  AirShow
//
//  Created by Vitalii Parovishnyk on 1/2/14.
//  Copyright (c) 2014 IGR Software. All rights reserved.
//

#import "IGRURLPanel.h"
#import "IGRAppDelegate.h"

@interface IGRURLPanel ()

@property (strong) IBOutlet NSTextField *urlField;

@end

@implementation IGRURLPanel


- (IBAction)onOpenUrl:(id)sender
{
	if ([self.rollbackDelegate respondsToSelector:@selector(openUrl:)] && [self.urlField.stringValue length])
	{
		[self.rollbackDelegate openUrl:self.urlField.stringValue];
	}
	
	[[NSApplication sharedApplication] stopModal];
    [self orderOut: nil];
    [[NSApplication sharedApplication] endSheet: self
									 returnCode: NSOKButton];
}

- (IBAction)onCancel:(id)sender
{
	[[NSApplication sharedApplication] stopModal];
    [self orderOut: nil];
    [[NSApplication sharedApplication] endSheet: self
									 returnCode: NSCancelButton];
}

@end
