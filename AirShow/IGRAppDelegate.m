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
#import "IGRContentHelper.h"
#import "HTTPServer.h"
#import "GCDAsyncSocket.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

#import <AVFoundation/AVFoundation.h>

// Log levels: off, error, warn, info, verbose

@interface IGRAppDelegate ()
{
	HTTPServer *_httpServer;
}

@property (nonatomic, assign) IBOutlet NSButton	*popoverButton;
@property (nonatomic, assign) IBOutlet NSImageView	*imgThumbnail;

@property (nonatomic, assign) BOOL popoverButtonIsPressed;
@property (nonatomic, strong) HTTPServer *httpServer;
@end

@implementation IGRAppDelegate

@synthesize httpServer;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	
	_popoverButtonIsPressed = NO;
	
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(startLocalServer)
												 name:@"Test"
											   object:nil];
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
	if ([[filename lowercaseString] hasPrefix:@"http://"])
	{
		[self openUrl:[NSURL URLWithString:filename]];
	}
	else
	{
		[self openLocalMedia:filename];
	}
	
	return YES;
}

- (void)openUrl:(NSString *)anURL
{
	NSURL *webURL = [NSURL URLWithString:anURL];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self createThumbnailForURL:webURL];
	});
	
	while (!self.clientManager.isReady)
	{}
	
	NSString *message = [IGRContentHelper contentForURL:anURL];
	
	[self.clientManager sendRawData:[message dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)openLocalMedia:(NSString *)anURL
{
	[[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL URLWithString:anURL]];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self createThumbnailForURL:[NSURL URLWithString:anURL]];
	});
	
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(queue, ^{
		while (!self.clientManager.isReady)
		{}
		
		NSString *message = @"";
		if ([[anURL lowercaseString] hasSuffix:@"mp4"])
		{
			message = [IGRContentHelper contentForLocalFile:anURL address:[self getIPAddress] port:httpServer.listeningPort];
		}
		else
		{
			
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.clientManager sendRawData:[message dataUsingEncoding:NSUTF8StringEncoding]];
		});
	});
}

#pragma mark - Actions

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

- (IBAction)onOpenMediaFile:(id)sender
{
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:YES];
	[openDlg setFloatingPanel:YES];
	[openDlg setAllowedFileTypes:@[@"mp4"]];
    
    if ( [openDlg runModal] == NSOKButton )
    {
        NSURL* files = [openDlg URL];
		
		[self openLocalMedia:files.absoluteString];
    }
	
}

- (void)sheetDidEnd:(NSWindow *)sheet
         returnCode:(int)returnCode
        contextInfo:(void  *)contextInfo
{
    
}

- (IBAction) togglePopover:(id)sender
{
	if (!self.popoverButtonIsPressed)
	{
        [self.popover showRelativeToRect:[self.popoverButton bounds] ofView:self.popoverButton preferredEdge:NSMinXEdge | NSMaxYEdge];
    }
	else
	{
        [self.popover close];
    }
	
	self.popoverButtonIsPressed = !self.popoverButtonIsPressed;
}

- (void) createThumbnailForURL:(NSURL*)assetURL
{

    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:assetURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0, 30);
	
    //NSLog(@"Starting Async Queue");
	
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"couldn't generate thumbnail, error:%@", error);
        }

        //Convert CGImage thumbnail to UIImage.
		CGFloat sizeW = CGImageGetWidth(im);
        CGFloat sizeH = CGImageGetHeight(im);
        NSImage * thumbnail = [[NSImage alloc] initWithCGImage:im size:NSMakeSize(sizeW, sizeH)];
		
        NSLog(@"Image width is %f", sizeH);
        NSLog(@"Image height is %f", sizeH);
		
        //Set the image once resized.
        self.imgThumbnail.image = thumbnail;
		
    };
	
    CGSize maxSize = CGSizeMake(240, 180);
    generator.maximumSize = maxSize;
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];

}

#pragma mark - Server

- (void)startLocalServer
{
	// Initalize our http server
	self.httpServer = [[HTTPServer alloc] init];
	
	// Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
	[httpServer setType:@"_http._tcp."];
	
	// Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
	//	[httpServer setPort:12345];
	
	// Serve files from the standard Sites folder
	NSString *docRoot = [@"~" stringByExpandingTildeInPath];
	
	[httpServer setDocumentRoot:docRoot];
	
	NSError *error = nil;
	if(![httpServer start:&error])
	{
		DDLogError(@"Error starting HTTP Server: %@", error);
	}
}

- (NSString *)getIPAddress
{
	
    NSHost *host = [NSHost currentHost];
	
	return host.addresses[1];
}

@end
