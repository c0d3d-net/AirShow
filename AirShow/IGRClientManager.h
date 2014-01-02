//
//  IGRClientManager.h
//  AirShow
//
//  Created by Vitalii Parovishnyk on 12/29/13.
//  Copyright (c) 2013 IGR Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AsyncSocket;

@interface IGRClientManager : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
{
    IBOutlet NSArrayController	*servicesController;
}

@property (readonly, strong) NSMutableArray *services;
@property (readonly, assign) BOOL isConnected;
@property (readonly, assign) BOOL isReady;
@property (readonly, strong) AsyncSocket *socket;

-(IBAction)search:(id)sender;
-(IBAction)connect:(id)sender;

- (void)sendRawData:(NSData *)data;

@end
