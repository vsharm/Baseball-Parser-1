//
//  AppController.h
//  Fangraphs2
//
//  Created by Varun Sharma on 12/24/12.
//  Copyright (c) 2012 Varun Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppController : NSObject <NSTableViewDataSource>
{    
    IBOutlet NSSearchField *entry;
    IBOutlet NSTableView *HitterTableView;
    IBOutlet NSTableView *PitcherTableView;
    IBOutlet NSImageView *imageView;
    IBOutlet NSScrollView *HitterScrollContainer;
    IBOutlet NSScrollView *pitcherScrollViewContainer;
    IBOutlet NSProgressIndicator *prog;
    IBOutlet NSTextField *positionLabel;


    NSMutableArray *playerArray;
    


    
    NSMutableArray			*allKeywords;
	NSMutableArray			*builtInKeywords;
	
    
	
	BOOL					completePosting;
    BOOL					commandHandling;


}
- (id)init;
@property (nonatomic, copy) NSString *specialDuplicateURL;

-(void)awakeFromNib;
-(IBAction)searchPlayer:(id)sender;
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;



@end
