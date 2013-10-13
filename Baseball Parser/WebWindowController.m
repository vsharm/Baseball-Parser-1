//
//  WebWindowController.m
//  RanchForecast
//
//  Created by Adam Preble on 12/9/11.
//  Copyright (c) 2011 Big Nerd Ranch. All rights reserved.
//

#import "WebWindowController.h"
#import <WebKit/WebKit.h>
#import "AppController.h"

@implementation WebWindowController
- (id)init:(AppController *) Acontroller
{
    controller = Acontroller;
    self = [super initWithWindowNibName:@"WebWindowController"];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	[webView setFrameLoadDelegate:self];
}

- (void)openURL:(NSURL *)url
{
	[webView setMainFrameURL:[url absoluteString]];
}

- (void)openData:(NSData *)data
{
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [[webView mainFrame] loadHTMLString:htmlString baseURL:nil];

}
- (IBAction)close:(id)sender
{
	[NSApp endSheet:[self window]];
	[[self window] orderOut:nil];
}

- (IBAction)select:(id)sender{
    duplicateSelectedURL = [webView stringByEvaluatingJavaScriptFromString:@"window.location.href"];
    [controller setSpecialDuplicateURL:duplicateSelectedURL];

    [controller searchPlayer:nil];
    NSLog(@"%@", duplicateSelectedURL);
	[NSApp endSheet:[self window]];
	[[self window] orderOut:nil];
    
}

#pragma mark - WebFrameLoadDelegate

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
	[progress startAnimation:nil];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    NSInteger height = 1017; 
    NSString* javascript = [NSString stringWithFormat:@"window.scrollBy(0, %ld);", height];
    [webView stringByEvaluatingJavaScriptFromString:javascript];
	[progress stopAnimation:nil];
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	[progress stopAnimation:nil];
}

@end
