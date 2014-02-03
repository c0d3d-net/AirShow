//
//  IGRAppDelegate.h
//  AirShow
//
//  Created by Vitalii Parovishnyk on 12/29/13.
//  Copyright (c) 2013 IGR Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IGRClientManager;
@class IGRURLPanel;

@interface IGRAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet IGRClientManager *clientManager;
@property (assign) IBOutlet IGRURLPanel *urlPanel;

- (void)openUrl:(NSString *)anURL;

@end
