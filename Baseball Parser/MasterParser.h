//
//  MasterParser.h
//  Fangraphs
//
//  Created by Varun Sharma on 12/23/12.
//  Copyright (c) 2012 Varun Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WebWindowController;
@class AppController;

@interface MasterParser : NSObject <NSApplicationDelegate>{
    NSOperationQueue *queue;
    WebWindowController *webWindowController;


}
@property (nonatomic, copy) NSMutableArray *playerArray;
@property (assign) IBOutlet NSWindow *jwindow;

-(NSMutableArray *)loadPlayer:(NSString *)name BaseballProspectusDuplicateURL:(NSString *)BPDuplicateURL appTroller:(AppController *)TrollApper;


@end

