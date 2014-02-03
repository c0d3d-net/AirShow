//
//  IGRContentHelper.m
//  AirShow
//
//  Created by Vitalii Parovishnyk on 1/3/14.
//  Copyright (c) 2014 IGR Software. All rights reserved.
//

#import "IGRContentHelper.h"

@implementation IGRContentHelper

#define COMMAND_REVERSE						@"POST /reverse\r\n"
#define COMMAND_SEVER_INFO					@"GET /server-info HTTP/1.1\r\n"
#define COMMAND_PLAY						@"POST /play HTTP/1.1\r\n"
#define COMMAND_SEAK_ARBITRAYRY				@"POST /scrub HTTP/1.1\r\n"
#define COMMAND_CHANGE_RATE					@"POST /rate HTTP/1.1\r\n"
#define COMMAND_STOP						@"POST /stop HTTP/1.1\r\n"
#define COMMAND_CURRENT_PLAYBACK_POSITION	@"GET /scrub HTTP/1.1\r\n"
#define COMMAND_PLAYBACK_INFO				@"GET /playback-info HTTP/1.1\r\n"
#define COMMAND_SET_PROPERTY				@"PUT /setProperty HTTP/1.1\r\n"
#define COMMAND_GET_PROPERTY				@"GET /getProperty HTTP/1.1\r\n"

+ (NSString*)contentForURL:(NSString*)anUrl
{
	NSString *body = [[NSString alloc] initWithFormat:@"Content-Location: %@\r\n"
													   "Start-Position: 0\r\n\r\n", anUrl];
	
	NSString *content = [IGRContentHelper prepareCommand:COMMAND_PLAY body:body];
	
	return content;
}

+ (NSString*)contentForReverse
{
	NSString *content = [NSString stringWithFormat: @"%@"
			   "Upgrade: PTTH/1.0\r\n"
			   "Connection: Upgrade\r\n"
			   "X-Apple-Purpose: event\r\n"
			   "Content-Length: 0\r\n"
			   "User-Agent: AirShow/1.0\r\n"
			   "X-Apple-Session-ID: %@\r\n", COMMAND_REVERSE, [IGRContentHelper sessionID]];
	
	return content;
}

#pragma mark - Private Methods

+ (NSString*)prepareCommand:(NSString*)aCommand body:(NSString*)aBody
{
	NSUInteger length = [aBody length];
	
	NSString* message = [[NSString alloc] initWithFormat:@"%@"
						 "Content-Length: %lu\r\n"
						 "User-Agent: AirShow/1.0\r\n\r\n"
						 "%@", aCommand, (unsigned long)length, aBody];
	
	return message;
}

+ (NSString*)sessionID
{
	static NSString *__UID = @"";
	
	// generate a UUID for the session
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		CFUUIDRef UUID = CFUUIDCreate(kCFAllocatorDefault);
		CFStringRef UUIDString = CFUUIDCreateString(kCFAllocatorDefault,UUID);
		__UID = (__bridge NSString *)UUIDString;
	});
	
	return __UID;
}

@end
