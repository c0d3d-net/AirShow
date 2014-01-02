//
//  IGRAppDelegate.m
//  AirShow
//
//  Created by Vitalii Parovishnyk on 12/29/13.
//  Copyright (c) 2013 IGR Software. All rights reserved.
//

#import "IGRAppDelegate.h"
#import "IGRClientManager.h"
#import "AsyncSocket.h"
#import "IGRURLPanel.h"

@interface IGRAppDelegate ()

@end

@implementation IGRAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
}

- (void)openUrl:(NSString *)message
{
	while (!self.clientManager.isReady)
	{}
	
	NSString *body = [[NSString alloc] initWithFormat:@"Content-Location: %@\r\n"
					  "Start-Position: 0\r\n\r\n", message];
	NSUInteger length = [body length];
	
	NSString *_message = [[NSString alloc] initWithFormat:@"POST /play HTTP/1.1\r\n"
						 "Content-Length: %lu\r\n"
						 "User-Agent: MediaControl/1.0\r\n\r\n%@", (unsigned long)length, body];
	
	[self.clientManager sendRawData:[_message dataUsingEncoding:NSUTF8StringEncoding]];
}

- (IBAction)onOpenURL:(id)sender
{
	
	[[NSApplication sharedApplication] beginSheet: self.urlPanel
								   modalForWindow: _window
									modalDelegate: self
								   didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:)
									  contextInfo: nil];
	
	[[NSApplication sharedApplication] runModalForWindow: self.urlPanel];
	
	return;
	
	// Calculate the actual center
	CGFloat x = _window.frame.origin.x + (_window.frame.size.width - self.urlPanel.frame.size.width) / 2;
	CGFloat y = _window.frame.origin.y + _window.frame.size.height / 2;
	
	// Create a rect to send to the window
	NSRect newFrame = NSMakeRect(x, y, self.urlPanel.frame.size.width, self.urlPanel.frame.size.height);
	
	// Send message to the window to resize/relocate
	[self.urlPanel setFrame:newFrame display:YES animate:NO];
	
	[self.urlPanel makeKeyAndOrderFront:self];
}

- (void)sheetDidEnd:(NSWindow *)sheet
         returnCode:(int)returnCode
        contextInfo:(void  *)contextInfo
{
    
}

@end
