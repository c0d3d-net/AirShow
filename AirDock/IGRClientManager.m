//
//  IGRClientManager.m
//  AirDock
//
//  Created by Vitalii Parovishnyk on 12/29/13.
//  Copyright (c) 2013 IGR Software. All rights reserved.
//

#import "IGRClientManager.h"

@interface IGRClientManager ()

@property (readwrite, strong) NSNetServiceBrowser *browser;
@property (readwrite, strong) NSMutableArray *services;
@property (readwrite, assign) BOOL isConnected;
@property (readwrite, strong) NSNetService *connectedService;

@end

@implementation IGRClientManager

- (void)awakeFromNib
{
    _services = [NSMutableArray new];
    _browser = [NSNetServiceBrowser new];
    _browser.delegate = self;
    _isConnected = NO;
	
	[self search:nil];
	
	[servicesController addObserver:self forKeyPath:@"selectionIndexes" options:NSKeyValueObservingOptionNew context:nil];
}

- (IBAction)search:(id)sender
{
    [self.browser searchForServicesOfType:@"_airplay._tcp" inDomain:@"local."];
}

- (IBAction)connect:(id)sender
{
	[self disconnectFromDevice];
	
    NSNetService *remoteService = servicesController.selectedObjects.lastObject;
	
	if (!remoteService && [servicesController.arrangedObjects count])
	{
		servicesController.selectionIndex = 0;
	}
	
	if (remoteService && remoteService != self.connectedService)
	{
		remoteService.delegate = self;
		[remoteService resolveWithTimeout:0];
	}
	
}

- (void)disconnectFromDevice
{
    if (self.connectedService)
	{
        NSLog(@"%s There are no connected devices", __func__);
        return;
    }
	
    self.connectedService = nil;
    
}

#pragma mark - Net Service Browser Delegate Methods
- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didFindService:(NSNetService *)aService moreComing:(BOOL)more
{
	NSLog(@"%s: Added service: %@", __func__, aService);
	
    [servicesController addObject:aService];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didRemoveService:(NSNetService *)aService moreComing:(BOOL)more
{
    [servicesController removeObject:aService];
	
    if ( aService == self.connectedService )
	{
		self.isConnected = NO;
	}
}

#pragma mark - Net Service Delegate Methods

- (void)netServiceDidResolveAddress:(NSNetService *)aService
{
	NSLog(@"%s: Connected to service: %@", __func__, aService);
	
    self.isConnected = YES;
    self.connectedService = aService;
}

- (void)netService:(NSNetService *)aService didNotResolve:(NSDictionary *)errorDict
{
	NSLog(@"%s: Could not resolve: %@",__func__, errorDict);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualTo:@"selectionIndexes"])
    {
		[self connect:nil];
    }
}

@end
