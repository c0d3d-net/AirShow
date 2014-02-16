//
//  IGRClientManager.m
//  AirShow
//
//  Created by Vitalii Parovishnyk on 12/29/13.
//  Copyright (c) 2013 IGR Software. All rights reserved.
//

#import "IGRClientManager.h"
#import "AsyncSocket.h"
#import "IGRContentHelper.h"

@interface IGRClientManager ()

@property (readwrite, strong) NSNetServiceBrowser *browser;
@property (readwrite, strong) NSMutableArray *services;
@property (readwrite, assign) BOOL isConnected;
@property (readwrite, assign) BOOL isReady;
@property (readwrite, strong) NSNetService *connectedService;
@property (readwrite, strong) AsyncSocket *socket;

@end

@implementation IGRClientManager

- (void)awakeFromNib
{
    _services = [NSMutableArray new];
    _browser = [NSNetServiceBrowser new];
    _browser.delegate = self;
    _isConnected = NO;
	_isReady = NO;
	_socket = nil;
	
	[self search:nil];
}

- (IBAction)search:(id)sender
{
    [self.browser searchForServicesOfType:@"_airplay._tcp" inDomain:@"local."];
}

- (IBAction)connect:(id)sender
{
	[self disconnectFromDevice];
	
    NSNetService *remoteService = servicesController.selectedObjects.lastObject;
	
	if (remoteService && remoteService != self.connectedService)
	{
		remoteService.delegate = self;
		[remoteService resolveWithTimeout:0];
	}
}

- (void)sendRawData:(NSData *)data
{
	self.isReady = NO;
	
	self.socket.delegate = self;
	[self.socket writeData:data withTimeout:20 tag:1];
	[self.socket readDataWithTimeout:20.0 tag:1];
}

- (void)disconnectFromDevice
{
    if (self.connectedService)
	{
        NSLog(@"%s There are no connected devices", __func__);
        return;
    }
	
    self.connectedService = nil;
	self.socket = nil;
	self.isConnected = NO;
	self.isReady = NO;
}

#pragma mark - Net Service Browser Delegate Methods
- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didFindService:(NSNetService *)aService moreComing:(BOOL)more
{
	NSLog(@"%s: Added service: %@", __func__, aService);
	
    [servicesController addObject:aService];
	
	if (!more && !self.connectedService)
	{
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^
		{
			[servicesController addObserver:self forKeyPath:@"selectionIndexes" options:NSKeyValueObservingOptionNew context:nil];
		});
		
		servicesController.selectionIndex = 0;
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didRemoveService:(NSNetService *)aService moreComing:(BOOL)more
{
    [servicesController removeObject:aService];
	
    if ( aService == self.connectedService )
	{
		self.isConnected = NO;
		self.isReady = NO;
	}
}

#pragma mark - Net Service Delegate Methods

- (void)netServiceDidResolveAddress:(NSNetService *)aService
{
	NSLog(@"%s: Connected to service: %@", __func__, aService);
	
    self.isConnected = YES;
    self.connectedService = aService;
	
	self.isReady = NO;
	
	self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    [self.socket connectToHost:self.connectedService.hostName onPort:self.connectedService.port error:NULL];
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

#pragma mark - AsyncSocketDelegate

- (void)onSocket:(AsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port
{
    if (![self.socket isEqual:socket])
	{
        NSLog(@"Ignoring %s from socket %@; socket does not match _connecting device %@", __func__, socket,
              self.connectedService);
		
        return;
    }
	
	if (self.isConnected && !self.isReady)
	{
		//[self sendRawData:[[IGRContentHelper contentForReverse] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	self.isReady = YES;
	NSLog(@"%s: Socket opened successful",__func__);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"Test" object:nil userInfo:nil];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	self.isReady = YES;
	
	NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSLog(@"Message: %@", message);
}

@end
