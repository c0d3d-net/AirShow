//
//  IGRURLPanel.h
//  AirShow
//
//  Created by Vitalii Parovishnyk on 1/2/14.
//  Copyright (c) 2014 IGR Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IGRAppDelegate;

@interface IGRURLPanel : NSPanel <NSTextFieldDelegate>

@property (nonatomic, weak) IBOutlet IGRAppDelegate *rollbackDelegate;

@end
