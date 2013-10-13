//
//  AppController.m
//  Fangraphs2
//
//  Created by Varun Sharma on 12/24/12.
//  Copyright (c) 2012 Varun Sharma. All rights reserved.
//

#import "AppController.h"
#import "MasterParser.h"
#import "Player.h"

@implementation AppController
@synthesize specialDuplicateURL = _specialDuplicateURL;

- (id)init{
    self = [super init];
    return self;
}

-(void)awakeFromNib{
    [NSApp setDelegate:self];
    [prog setHidden:YES];
    [pitcherScrollViewContainer setHidden:YES];
 

    
    if ([entry respondsToSelector: @selector(setRecentSearches:)])
        {
		NSMenu *searchMenu = [[NSMenu alloc] initWithTitle:@"Search Menu"];
		[searchMenu setAutoenablesItems:YES];
		
		// first add our custom menu item (Important note: "action" MUST be valid or the menu item is disabled)
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Custom" action:@selector(actionMenuItem:) keyEquivalent:@""];
		[item setTarget: self];
		[searchMenu insertItem:item atIndex:0];
		
		// add our own separator to keep our custom menu separate
		NSMenuItem *separator =  [NSMenuItem separatorItem];
		[searchMenu insertItem:separator atIndex:1];
        
		NSMenuItem *recentsTitleItem = [[NSMenuItem alloc] initWithTitle:@"Recent Searches" action:nil keyEquivalent:@""];
		// tag this menu item so NSSearchField can use it and respond to it appropriately
		[recentsTitleItem setTag:NSSearchFieldRecentsTitleMenuItemTag];
		[searchMenu insertItem:recentsTitleItem atIndex:2];
		
		NSMenuItem *norecentsTitleItem = [[NSMenuItem alloc] initWithTitle:@"No recent searches" action:nil keyEquivalent:@""];
		// tag this menu item so NSSearchField can use it and respond to it appropriately
		[norecentsTitleItem setTag:NSSearchFieldNoRecentsMenuItemTag];
		[searchMenu insertItem:norecentsTitleItem atIndex:3];
		
		NSMenuItem *recentsItem = [[NSMenuItem alloc] initWithTitle:@"Recents" action:nil keyEquivalent:@""];
		// tag this menu item so NSSearchField can use it and respond to it appropriately
		[recentsItem setTag:NSSearchFieldRecentsMenuItemTag];
		[searchMenu insertItem:recentsItem atIndex:4];
		
		NSMenuItem *separatorItem = (NSMenuItem*)[NSMenuItem separatorItem];
		// tag this menu item so NSSearchField can use it, by hiding/show it appropriately:
		[separatorItem setTag:NSSearchFieldRecentsTitleMenuItemTag];
		[searchMenu insertItem:separatorItem atIndex:5];
		
		NSMenuItem *clearItem = [[NSMenuItem alloc] initWithTitle:@"Clear" action:nil keyEquivalent:@""];
		[clearItem setTag:NSSearchFieldClearRecentsMenuItemTag];	// tag this menu item so NSSearchField can use it
		[searchMenu insertItem:clearItem atIndex:6];
		
		id searchCell = [entry cell];
		[searchCell setMaximumRecents:20];
		[searchCell setSearchMenuTemplate:searchMenu];
        }
	// Build the array from the plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Player-Names" ofType:@"plist"];
    builtInKeywords = [[NSMutableArray alloc] initWithContentsOfFile:path];
    
    [entry becomeFirstResponder];
    [entry setFocusRingType:YES];

      }
    
-(IBAction)searchPlayer:(id)sender{
    if([[entry stringValue] length] > 0){

    NSString *playerName = [entry stringValue];
    playerName = [playerName stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    MasterParser *parser = [[MasterParser alloc] init];
    [prog setHidden:NO];
    [prog startAnimation:(id)sender];
        if([_specialDuplicateURL length] > 0){
            playerArray = [parser loadPlayer:playerName BaseballProspectusDuplicateURL:_specialDuplicateURL appTroller:self];
            _specialDuplicateURL = @"";
        }
        else{
    playerArray = [parser loadPlayer:playerName BaseballProspectusDuplicateURL:nil appTroller:self];
        }
    
    NSImage *playerImage = [[playerArray objectAtIndex:0] photo];
    [imageView setImage:playerImage];
    
    //Set Position equal to the Position of the player in the array
    NSString *position = [[playerArray objectAtIndex:0] playPosition];
    //Set Label to position
    [positionLabel setHidden:YES];
    [positionLabel setStringValue:position];
    [positionLabel sizeToFit];
    [positionLabel setHidden:NO];

    
    if ([position isEqualToString:@"Pitcher"]){
        [pitcherScrollViewContainer setHidden:NO];
        [HitterScrollContainer setHidden:YES];
        [PitcherTableView reloadData];
    }
    else{
        [pitcherScrollViewContainer setHidden:YES];
        [HitterScrollContainer setHidden:NO];
        [HitterTableView reloadData];
    }
        [prog setHidden:YES];

    }
    [entry setFocusRingType:YES];

}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [playerArray count];
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    Player *player = [playerArray objectAtIndex:row];
    NSString *identifier = [tableColumn identifier];
    return [player valueForKey:identifier];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication{
    return YES;
}

- (NSArray *)allKeywords
{
    NSArray *array = [[NSArray alloc] init];
    NSInteger i,count;
    
    if (allKeywords == nil)
        {
        allKeywords = [builtInKeywords mutableCopy];
        
        if (array != nil)
            {
            count = [array count];
            for (i=0; i<count; i++)
                {
                if ([allKeywords indexOfObject:[array objectAtIndex:i]] == NSNotFound)
                    [allKeywords addObject:[array objectAtIndex:i]];
                }
            }
        [allKeywords sortUsingSelector:@selector(compare:)];
        }
    return allKeywords;
}

- (NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words
 forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(int*)index
{
    NSMutableArray*	matches = NULL;
    NSString*		partialString;
    NSArray*		keywords;
    NSInteger	i,count;
    NSString*		string;
    
    partialString = [[textView string] substringWithRange:charRange];
    keywords      = [self allKeywords];
    count         = [keywords count];
    matches       = [NSMutableArray array];
    
    // find any match in our keyword array against what was typed -
	for (i=0; i< count; i++)
        {
        string = [keywords objectAtIndex:i];
        if ([string rangeOfString:partialString
						  options:NSAnchoredSearch | NSCaseInsensitiveSearch
							range:NSMakeRange(0, [string length])].location != NSNotFound)
            {
            [matches addObject:string];
            }
        }
    [matches sortUsingSelector:@selector(compare:)];
	
	return matches;
}

- (void)controlTextDidChange:(NSNotification *)obj
{
	NSTextView* textView = [[obj userInfo] objectForKey:@"NSFieldEditor"];
    
    if (!completePosting && !commandHandling)	// prevent calling "complete" too often
        {
        completePosting = YES;
        [textView complete:nil];
        completePosting = NO;
        }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    BOOL result = NO;
	
	if ([textView respondsToSelector:commandSelector])
        {
        commandHandling = YES;
        [textView performSelector:commandSelector withObject:nil];
        commandHandling = NO;
		
		result = YES;
        }
	
    return result;
}



@end


