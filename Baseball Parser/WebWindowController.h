//
//  WebWindowController.h
//  RanchForecast
//
//  Created by Adam Preble on 12/9/11.
//  Copyright (c) 2011 Big Nerd Ranch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WebView;
@class AppController;

@interface WebWindowController : NSWindowController {
	IBOutlet WebView *webView;
	IBOutlet NSProgressIndicator *progress;
    NSString *duplicateSelectedURL;
    IBOutlet NSTextField *dumpURl;
    AppController *controller;
}

- (IBAction)close:(id)sender;

- (IBAction)select:(id)sender;

- (id)init:(AppController *) Acontroller;

- (void)openURL:(NSURL *)url;
- (void)openData:(NSData *)data;

@end
