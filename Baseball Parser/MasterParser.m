//
//  MasterParser.m
//  Fangraphs
//
//  Created by Varun Sharma on 12/23/12.
//  Copyright (c) 2012 Varun Sharma. All rights reserved.
//
#import "MasterParser.h"
#import "TFHpple.h"
#import "Player.h"
#import "LoadPage.h"
#import "WebWindowController.h"
#import "AppController.h"


@implementation MasterParser

@synthesize jwindow = _jwindow;


-(NSMutableArray *)loadPlayer:(NSString *)name BaseballProspectusDuplicateURL:(NSString *)BPDuplicateURL appTroller:(AppController *)TrollApper{

    //Fangraphs Load
    NSString *FGstarter = @"http://www.fangraphs.com/players.aspx?lastname=";
    NSString *FGquery =  [FGstarter stringByAppendingString:name];
    NSLog(@"%@",FGquery);
    NSURL *FGplayerUrl = [NSURL URLWithString:FGquery];

    
    //Baseball Reference Load
    
        NSString *BRstarter = @"http://baseball-reference.com/pl/player_search.cgi?search=";
        NSString *BRquery =  [BRstarter stringByAppendingString:name];
        NSLog(@"%@",BRquery);
        NSURL *BRplayerUrl = [NSURL URLWithString:BRquery];
    

    NSURL *BPplayerUrl;
if (BPDuplicateURL == nil) {

    //BP Load
    NSString *starter = @"http://www.baseballprospectus.com/player_search.php?search_name=";
    NSString *query =  [starter stringByAppendingString:name];
    NSLog(@"%@",query);    
    BPplayerUrl = [NSURL URLWithString:query];
}
    else{
        NSLog(@"%@",BPDuplicateURL);
        BPplayerUrl = [NSURL URLWithString:BPDuplicateURL];
    }
    
    
    LoadPage *FGpage = [[LoadPage alloc] initWithURL:FGplayerUrl];
    LoadPage *BPpage = [[LoadPage alloc] initWithURL:BPplayerUrl];
    LoadPage *BRpage = [[LoadPage alloc] initWithURL:BRplayerUrl];

    queue = [[NSOperationQueue alloc] init];
    [queue addOperation:FGpage];
    [queue addOperation:BPpage];
    [queue addOperation:BRpage];
    [queue waitUntilAllOperationsAreFinished];
    
    NSData *FGplayerPage = [FGpage webpage];
    NSData *BPplayerPage = [BPpage webpage];
    NSData *BRplayerPage = [BRpage webpage];


    
    //Baseball Prospectus

    

    //Fangraphs
    TFHpple *FGplayerParser = [TFHpple hppleWithHTMLData:FGplayerPage];
    
    TFHpple *playerParser = [TFHpple hppleWithHTMLData:BPplayerPage];
    

    

    // BaseballRefrence
    TFHpple *BRplayerParser = [TFHpple hppleWithHTMLData:BRplayerPage];
    
    //Baseball Prospectus Checking Year
    NSArray *yearNodes;
    @try {
        //Xpath Query for the Year
        NSString *yearXpath = @"//*[@id='stats_card_standard_datagrid']/tbody/tr/td[1]/a[1]";
        yearNodes = [playerParser searchWithXPathQuery:yearXpath];
        if( yearNodes[0] == nil)
            NSLog(@"stuff");

    }
    @catch (NSException *exception) {
  
        NSString *duplicateXpath = @"//*[@id='content']";
        NSArray *duplicateNodes = [playerParser searchWithXPathQuery:duplicateXpath];
        TFHppleElement *duplicateNode = duplicateNodes[0];
        NSString *duplicateString = [duplicateNode objectForKey:@"cellpadding"];
        NSLog(@"%@", duplicateString);
        if([duplicateString isEqualToString:@"5"]){
            webWindowController = [[WebWindowController alloc] init:TrollApper];
            [self setJwindow:[[NSApplication sharedApplication] mainWindow]];
            [NSApp beginSheet:[webWindowController window] modalForWindow:[self jwindow] modalDelegate:nil didEndSelector:nil contextInfo:NULL];
            [webWindowController openData:BPplayerPage];
        }

    
    }
    
    //Determine Exact Position
    NSString *BRpositionXpath = @"//*[@id='info_box']/p[2]/text()[1]";

    NSString *playerPosition;    
    NSArray *BRpositionNodes = [BRplayerParser searchWithXPathQuery:BRpositionXpath];
    @try {
    TFHppleElement *BRpositionElement = [BRpositionNodes objectAtIndex:0];
    NSString *BRposition = [BRpositionElement content];
    //Takes Line off the first two characters in String
    NSString *tempPosition = [BRposition substringWithRange:NSMakeRange(2, [BRposition length]-2)];
    //Takes Line off the last character in String
    playerPosition = [tempPosition substringToIndex:[tempPosition length]-1];
    NSLog(@"%@",playerPosition);
    }    
    @catch (id theException){
        NSString *FGpositionXpath = @"//*[@id='SeasonStats1_dgSeason8_ctl00__0']/td[3]/a";
        NSArray *FGpositionNodes = [FGplayerParser searchWithXPathQuery:FGpositionXpath];
        TFHppleElement *FGpositionElement = [FGpositionNodes objectAtIndex:0];
        NSString *FGposition = [[FGpositionElement firstChild] content];
        NSLog(@"%@",FGposition);
        playerPosition = FGposition;
    }






    
    //Xpath query for the team
    NSString *teamXpath = @"//*[@id='stats_card_standard_datagrid']/tbody/tr/td[2]/a";
    NSArray *teamNodes = [playerParser searchWithXPathQuery:teamXpath];
    
    //Xpath query for the stats
    NSString *statsXpath = @"//*[@id='stats_card_standard_datagrid']/tbody/tr/td";
    NSArray *statsNodes = [playerParser searchWithXPathQuery:statsXpath];
    
    
    //Grab Photo
    NSString *photoXpath = @"//*[@id='player']/img";
    NSArray *photoNodes = [playerParser searchWithXPathQuery:photoXpath];
    TFHppleElement *element = [photoNodes objectAtIndex:0];
    NSString *photoLink = [element objectForKey:@"src"];
    NSLog(@"%@",photoLink);
    NSImage *image = [[NSImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoLink]]];
    
        
    //Decide if pitcher or hitter
    BOOL typePlayer = YES;
    if (([playerPosition isEqualToString:@"Pitcher"]) ||([playerPosition isEqualToString:@"P"]))
        typePlayer = NO;
        
    if ([name isEqualToString:@"Babe+Ruth"] || [name isEqualToString:@"Rick+Ankiel"] || [name isEqualToString:@"Ty+Cobb"])
        typePlayer = YES;
    
    NSLog(@"%i",typePlayer);   
    
    NSMutableArray *playerArray = [[NSMutableArray alloc] initWithCapacity:0];
    int i = 0;
    int statsCount = 2;
    int FGMultiCount = 0;
    for (TFHppleElement *yearElement in yearNodes) {
        
        
        
        //FOR HITTERS
        if (typePlayer == YES){
            
            //FOR GRABBING SPECIFIC STATS
            
            //BR WAR
            NSString *BRwarXpath = @"//*[@id='batting_value']/tbody/tr/td[16]";
            NSArray *BRwarNodes = [BRplayerParser searchWithXPathQuery:BRwarXpath];
            
            //FANGRAPHS STATS
            //Get FGTeamName

                
            NSString *FGCheckMultiTeamXpath = @"//*[@id='SeasonStats1_dgSeason11_ctl00']/tbody/tr[@class='rgRow' or @class='rgAltRow' or @class='rgRow grid_multi']/td[2]";
            NSArray *FGCheckMultiTeamNodes = [FGplayerParser searchWithXPathQuery:FGCheckMultiTeamXpath];
            TFHppleElement *FGCheckMultiTeamNode = FGCheckMultiTeamNodes[FGMultiCount];
            NSLog(@"%@", [[FGCheckMultiTeamNode firstChild] content]);
            if([[[FGCheckMultiTeamNode firstChild] content] isEqualToString:@"2 Teams"])
               FGMultiCount++;

            
            //Get Nodes for WRC+
            NSString *FGWRCXpath = @"//*[@id='SeasonStats1_dgSeason11_ctl00']/tbody/tr[@class='rgRow' or @class='rgAltRow' or @class='rgRow grid_multi']/td[17]";
            NSArray *FGwrcNodes = [FGplayerParser searchWithXPathQuery:FGWRCXpath];
            
            
            //Get Nodes for FLD
            NSString *FGFldXpath = @"//*[@id='SeasonStats1_dgSeason11_ctl00']/tbody/tr[@class='rgRow' or @class='rgAltRow' or @class='rgRow grid_multi']/td[18]";
            NSArray *FGFldNodes = [FGplayerParser searchWithXPathQuery:FGFldXpath];
            
            //Get Nodes for BSR
            NSString *FGBsrXpath = @"//*[@id='SeasonStats1_dgSeason11_ctl00']/tbody/tr[@class='rgRow' or @class='rgAltRow' or @class='rgRow grid_multi']/td[19]";
            NSArray *FGBSRNodes = [FGplayerParser searchWithXPathQuery:FGBsrXpath];
            
            //Get Nodes Hitting for BABIP
            NSString *FGHittingBabipXpath = @"//*[@id='SeasonStats1_dgSeason11_ctl00']/tbody/tr[@class='rgRow' or @class='rgAltRow' or @class='rgRow grid_multi']/td[11]";
            NSArray *FGHittingBabipNodes = [FGplayerParser searchWithXPathQuery:FGHittingBabipXpath];
            
            //Get Nodes for hitting player fWAR
            NSString *FGfWARXpath = @"//*[@id='SeasonStats1_dgSeason11_ctl00']/tbody/tr[@class='rgRow' or @class='rgAltRow' or @class='rgRow grid_multi']/td[20]";
            NSArray *FGfWARNodes = [FGplayerParser searchWithXPathQuery:FGfWARXpath];
            

            //END FANGRAPHS STATS
            
            //END OF GRABBING SPECIFIC STATS
            
            Player *player = [[Player alloc] init];
            [playerArray addObject:player];
            
            //Adds image to every player object
            player.photo = image;
            
            //Add position to Player Object
            player.playPosition = playerPosition;
            //Add team to Player Object
            TFHppleElement *teamNode = [teamNodes objectAtIndex:i];
            player.team = [[teamNode firstChild] content];
            
            
            
            //Temp Vars for changing NSString to NSNumber
            NSNumberFormatter *temp = [[NSNumberFormatter alloc] init];
            [temp setNumberStyle:NSNumberFormatterDecimalStyle];
            
            //Set the Player object IV to a year
            NSNumber * year = [temp numberFromString:[[yearElement firstChild] content]];
            player.year = year;            
            
            //add Standard Stats to Player OBJ         
                     
            
            //Add WRC+
            
            TFHppleElement *wrcElement = [FGwrcNodes objectAtIndex:FGMultiCount];
            NSNumber *wrc = [temp numberFromString:[[wrcElement firstChild] content]];
            player.wrc = wrc;
            
            //Add FLD
            
            TFHppleElement *fldElement = [FGFldNodes objectAtIndex:FGMultiCount];
            NSNumber *fld = [temp numberFromString:[[fldElement firstChild] content]];
            player.fld = fld;
            
            
            //Add BSR
            TFHppleElement *BsrElement = [FGBSRNodes objectAtIndex:FGMultiCount];
            NSNumber *bsr = [temp numberFromString:[[BsrElement firstChild] content]];
            player.bsr = bsr;
            
            //Add babip
            TFHppleElement *babipElement = [FGHittingBabipNodes objectAtIndex:FGMultiCount];
            NSNumber *babip = [temp numberFromString:[[babipElement firstChild] content]];
            player.babip = babip;
            
            //Add fWAR
            TFHppleElement *FWarElement = [FGfWARNodes objectAtIndex:FGMultiCount];
            NSNumber *fwar = [temp numberFromString:[[FWarElement firstChild] content]];
            player.fwar = fwar;
            
            
            //Add Bwar
            TFHppleElement *bwarElement = [BRwarNodes objectAtIndex:i];
            NSNumber *bwar = [temp numberFromString:[[bwarElement firstChild] content]];
            player.bwar = bwar;
            
            //add Age
            TFHppleElement *ageElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * age = [temp numberFromString:[[ageElement firstChild] content]];
            player.age = age;
            statsCount++;
            
            //add Games
            TFHppleElement *gamesElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * games = [temp numberFromString:[[gamesElement firstChild] content]];
            player.games = games;
            statsCount++;
            
            //add PA
            TFHppleElement *paElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * pa = [temp numberFromString:[[paElement firstChild] content]];
            player.plateAppearences = pa;
            statsCount++;
            
            //add AB's
            TFHppleElement *abElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * ab = [temp numberFromString:[[abElement firstChild] content]];
            player.atBats = ab;
            statsCount++;
            
            //add Runs
            TFHppleElement *rElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * runs = [temp numberFromString:[[rElement firstChild] content]];
            player.runs = runs;
            statsCount++;
            
            //add Hits
            TFHppleElement *hElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * hits = [temp numberFromString:[[hElement firstChild] content]];
            player.hits = hits;
            statsCount++;
            
            //add doubles
            TFHppleElement *doubleElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * doubles = [temp numberFromString:[[doubleElement firstChild] content]];
            player.doubles = doubles;
            statsCount++;
            
            //add triples
            TFHppleElement *tripElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * triple = [temp numberFromString:[[tripElement firstChild] content]];
            player.triples = triple;
            statsCount++;
            
            //add homeruns
            TFHppleElement *hrElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * hr = [temp numberFromString:[[hrElement firstChild] content]];
            player.homeruns = hr;
            statsCount++;
            
            //add TotalBases
            TFHppleElement *tbElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * tb = [temp numberFromString:[[tbElement firstChild] content]];
            player.totalBases = tb;
            statsCount++;
            
            //add Walks
            TFHppleElement *bbElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * bb = [temp numberFromString:[[bbElement firstChild] content]];
            player.baseOnBalls = bb;
            statsCount++;
            
            //add Strikouts
            TFHppleElement *kElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * k = [temp numberFromString:[[kElement firstChild] content]];
            player.strikeout = k;
            statsCount++;
            
            //add HBP
            TFHppleElement *hbpElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * hbp = [temp numberFromString:[[hbpElement firstChild] content]];
            player.hbp = hbp;
            statsCount++;
            
            //add Sack Fly
            TFHppleElement *sfElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * sf = [temp numberFromString:[[sfElement firstChild] content]];
            player.sackFly = sf;
            statsCount++;
            
            //add SH
            TFHppleElement *shElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * sh = [temp numberFromString:[[shElement firstChild] content]];
            player.sh = sh;
            statsCount++;
            
            //add RBI
            TFHppleElement *rbiElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * rbi = [temp numberFromString:[[rbiElement firstChild] content]];
            player.rbi = rbi;
            statsCount++;
            
            //add SB
            TFHppleElement *sbElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * sb = [temp numberFromString:[[sbElement firstChild] content]];
            player.sb = sb;
            statsCount++;
            
            //add CS
            TFHppleElement *csElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * cs = [temp numberFromString:[[csElement firstChild] content]];
            player.cs = cs;
            statsCount++;
            
            //add AVG
            TFHppleElement *avgElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * avg = [temp numberFromString:[[avgElement firstChild] content]];
            player.avg = avg;
            statsCount++;
            
            //add OBP
            TFHppleElement *obpElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * obp = [temp numberFromString:[[obpElement firstChild] content]];
            player.obp = obp;
            statsCount++;
            
            //add SLG
            TFHppleElement *slgElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * slg = [temp numberFromString:[[slgElement firstChild] content]];
            player.slg = slg;
            statsCount++;
            
            //add TrueAvg
            TFHppleElement *tavElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * tav = [temp numberFromString:[[tavElement firstChild] content]];
            player.tav = tav;
            statsCount++;
            
            //add Vorp
            TFHppleElement *vorpElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * vorp = [temp numberFromString:[[vorpElement firstChild] content]];
            player.vorp = vorp;
            statsCount++;
            
            //add FRAA
            TFHppleElement *fraaElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * fraa = [temp numberFromString:[[fraaElement firstChild] content]];
            player.fraa = fraa;
            statsCount++;
            
            //add WARP
            TFHppleElement *warpElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * warp = [temp numberFromString:[[warpElement firstChild] content]];
            player.warp = warp;
            statsCount++;
                     
            NSLog(@"************************************************************Year %@",[player year]);
            NSLog(@"Team %@",[player team]);
            NSLog(@"games %@",[player games]);
            NSLog(@"age %@",[player age]);
            NSLog(@"PA %@",[player plateAppearences]);
            NSLog(@"ABs %@",[player atBats]);
            NSLog(@"runs %@",[player runs]);
            NSLog(@"hits %@",[player hits]);
            NSLog(@"doubles %@",[player doubles]);
            NSLog(@"triples %@",[player triples]);
            NSLog(@"HR %@",[player homeruns]);
            NSLog(@"TB %@",[player totalBases]);
            NSLog(@"walks %@",[player baseOnBalls]);
            NSLog(@"strikeoutes %@",[player strikeout]);
            NSLog(@"HBP %@",[player hbp]);
            NSLog(@"SF %@",[player sackFly]);
            NSLog(@"SH %@",[player sh]);
            NSLog(@"RBI %@",[player rbi]);
            NSLog(@"SB %@",[player sb]);
            NSLog(@"CS %@",[player cs]);
            NSLog(@"AVG %@",[player avg]);
            NSLog(@"OBP %@",[player obp]);
            NSLog(@"SLG %@",[player slg]);
            NSLog(@"TAv %@",[player tav]);
            NSLog(@"VORP %@",[player vorp]);
            NSLog(@"FRAA %@",[player fraa]);
            NSLog(@"WARP %@",[player warp]);
            NSLog(@"Player Position %@",[player playPosition]);
            NSLog(@"BWAR %@",[player bwar]);
            NSLog(@"WRC+ %@",[player wrc]);
            NSLog(@"FLD %@",[player fld]);
            NSLog(@"fWAR %@",[player fwar]);
            NSLog(@"BSR %@",[player bsr]);
            
            statsCount += 2;
            i++;
            FGMultiCount++;

        }
        else {
            
            NSString *FGCheckMultiTeamXpath = @"//*[@id='SeasonStats1_dgSeason11_ctl00']/tbody/tr[@class='rgRow' or @class='rgAltRow' or @class='rgRow grid_multi']/td[2]";
            NSArray *FGCheckMultiTeamNodes = [FGplayerParser searchWithXPathQuery:FGCheckMultiTeamXpath];
            TFHppleElement *FGCheckMultiTeamNode = FGCheckMultiTeamNodes[FGMultiCount];
            NSLog(@"%@", [[FGCheckMultiTeamNode firstChild] content]);
            if([[[FGCheckMultiTeamNode firstChild] content] isEqualToString:@"2 Teams"])
                FGMultiCount++;
            
            //FOR GRABBING SPECIFIC STATS
            
            //BR WAR
            NSString *BRwarXpath = @"//*[@id='pitching_value']/tbody/tr/td[16]";
            NSArray *BRwarNodes = [BRplayerParser searchWithXPathQuery:BRwarXpath];
            
            //FANGRAPHS STATS
            //Get Nodes for pitching player fWAR
            NSString *FGPitchingfWARXpath = @"//*[@id='SeasonStats1_dgSeason11_ctl00']/tbody/tr[@class='rgRow' or @class='rgAltRow' or @class='rgRow grid_multi']/td[19]";
            NSArray *FGPitchingfWARNodes = [FGplayerParser searchWithXPathQuery:FGPitchingfWARXpath];
            
            //Get Nodes for  player xFIP
            NSString *FGxFipXpath = @"//*[@id='SeasonStats1_dgSeason11_ctl00']/tbody/tr[@class='rgRow' or @class='rgAltRow' or @class='rgRow grid_multi']/td[18]";
            NSArray *FGxFipNodes = [FGplayerParser searchWithXPathQuery:FGxFipXpath];
            
            //Get Nodes for  player k/9
            NSString *FGK9Xpath = @"//*[@id='SeasonStats1_dgSeason11_ctl00']/tbody/tr[@class='rgRow' or @class='rgAltRow' or @class='rgRow grid_multi']/td[9]";
            NSArray *FGxK9Nodes = [FGplayerParser searchWithXPathQuery:FGK9Xpath];
            
            //Get Nodes for  player BB/9
            NSString *FGBb9Xpath = @"//*[@id='SeasonStats1_dgSeason11_ctl00']/tbody/tr[@class='rgRow' or @class='rgAltRow' or @class='rgRow grid_multi']/td[10]";
            NSArray *FGBb9Nodes = [FGplayerParser searchWithXPathQuery:FGBb9Xpath];
            
            //Get Nodes for  player GB%
            NSString *FGGbXpath = @"//*[@id='SeasonStats1_dgSeason11_ctl00']/tbody/tr[@class='rgRow' or @class='rgAltRow' or @class='rgRow grid_multi']/td[14]";
            NSArray *FGGbNodes = [FGplayerParser searchWithXPathQuery:FGGbXpath];
            
            //Get Nodes for  player LOB%
            NSString *FGLobXpath = @"//*[@id='SeasonStats1_dgSeason11_ctl00']/tbody/tr[@class='rgRow' or @class='rgAltRow' or @class='rgRow grid_multi']/td[13]";
            NSArray *FGLobNodes = [FGplayerParser searchWithXPathQuery:FGLobXpath];
            
            //Get Nodes for Pitching player BABIP
            NSString *FGPitchingBabipXpath = @"//*[@id='SeasonStats1_dgSeason11_ctl00']/tbody/tr[@class='rgRow' or @class='rgAltRow' or @class='rgRow grid_multi']/td[12]";
            NSArray *FGPitchingBabipNodes = [FGplayerParser searchWithXPathQuery:FGPitchingBabipXpath];
            
            //Get Nodes for HR/9
            NSString *FGHr9Xpath = @"//*[@id='SeasonStats1_dgSeason11_ctl00']/tbody/tr[@class='rgRow' or @class='rgAltRow' or @class='rgRow grid_multi']/td[11]";
            NSArray *FGHr9Nodes = [FGplayerParser searchWithXPathQuery:FGHr9Xpath];
            
            //Get Nodes for RA/9 wins
            NSString *ra9WinsXpath = @"//*[@id='SeasonStats1_dgSeason9_ctl00']/tbody/tr[@class='rgRow' or @class='rgAltRow' or @class='rgRow grid_multi']/td[3]";
            NSArray *ra9WinsNodes = [FGplayerParser searchWithXPathQuery:ra9WinsXpath];
            //END OF FANGRAPH STATS
            
            //END OF GRABBING SPECIFIC STATS
            
            Player *player = [[Player alloc] init];
            [playerArray addObject:player];
            
            //Adds image to every player object
            player.photo = image;
            
            //Add position to Player Object
            player.playPosition = @"Pitcher";
            
            //Add team to Player Object
            TFHppleElement *teamNode = [teamNodes objectAtIndex:i];
            player.team = [[teamNode firstChild] content];
            
            
            //Temp Vars for changing NSString to NSNumber
            NSNumberFormatter *temp = [[NSNumberFormatter alloc] init];
            NSString *temp2;
            
            [temp setNumberStyle:NSNumberFormatterDecimalStyle];
            
            //Set the Player object IV to a year
            NSNumber * year = [temp numberFromString:[[yearElement firstChild] content]];
            player.year = year;
            
            
            //add Standard Stats to Player OBJ
            
            //Add fWAR
            TFHppleElement *FWarElement = [FGPitchingfWARNodes objectAtIndex:FGMultiCount];
            NSNumber *fwar = [temp numberFromString:[[FWarElement firstChild] content]];
            player.fwar = fwar;
            
            //Add gbRate
            TFHppleElement *gbRateElement = [FGGbNodes objectAtIndex:FGMultiCount];
            temp2 = [[[gbRateElement firstChild] content] substringToIndex:[[[gbRateElement firstChild] content] length]-1];
            NSNumber *gbRate = [temp numberFromString:temp2];
            player.gbRate = gbRate;
            
            //Add babip
            TFHppleElement *babipElement = [FGPitchingBabipNodes objectAtIndex:FGMultiCount];
            NSNumber *babip = [temp numberFromString:[[babipElement firstChild] content]];
            player.babip = babip;
            
            //Add xfip
            TFHppleElement *xfipElement = [FGxFipNodes objectAtIndex:FGMultiCount];
            NSNumber *xfip = [temp numberFromString:[[xfipElement firstChild] content]];
            player.xfip = xfip;
            
            //Add RA9 Wins
            TFHppleElement *ra9Element = [ra9WinsNodes objectAtIndex:FGMultiCount];
            NSNumber *ra9 = [temp numberFromString:[[ra9Element firstChild] content]];
            player.ra9Wins = ra9;
            
            
            //Add k/9
            TFHppleElement *k9Element = [FGxK9Nodes objectAtIndex:FGMultiCount];
            NSNumber *k9 = [temp numberFromString:[[k9Element firstChild] content]];
            player.k9 = k9;
            
            //Add bb/9
            TFHppleElement *bb9Element = [FGBb9Nodes objectAtIndex:FGMultiCount];
            NSNumber *bb9 = [temp numberFromString:[[bb9Element firstChild] content]];
            player.bb9 = bb9;
            
            //Add lob%
            TFHppleElement *lobElement = [FGLobNodes objectAtIndex:FGMultiCount];
            temp2 = [[[lobElement firstChild] content] substringToIndex:[[[lobElement firstChild] content] length]-2];
            NSNumber *lob = [temp numberFromString:temp2];
            player.lob = lob;
            
            //Add hr/9
            TFHppleElement *hr9Element = [FGHr9Nodes objectAtIndex:FGMultiCount];
            NSNumber *hr9 = [temp numberFromString:[[hr9Element firstChild] content]];
            player.hr9 = hr9;
            
            //Add Bwar
            TFHppleElement *bwarElement = [BRwarNodes objectAtIndex:i];
            NSNumber *bwar = [temp numberFromString:[[bwarElement firstChild] content]];
            player.bwar = bwar;
            
            //add Age
            TFHppleElement *ageElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * age = [temp numberFromString:[[ageElement firstChild] content]];
            player.age = age;
            statsCount++;
            
            //add Games
            TFHppleElement *gamesElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * games = [temp numberFromString:[[gamesElement firstChild] content]];
            player.games = games;
            statsCount++;
            
            //add GS
            TFHppleElement *gsElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * gamesStarted = [temp numberFromString:[[gsElement firstChild] content]];
            player.gamesStarted = gamesStarted;
            statsCount++;
            
            //add IP
            TFHppleElement *ipElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * ip = [temp numberFromString:[[ipElement firstChild] content]];
            player.ip = ip;
            statsCount++;
            
            //add IP-SP
            TFHppleElement *ipspElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * ipStarting = [temp numberFromString:[[ipspElement firstChild] content]];
            player.ipStarting = ipStarting;
            statsCount++;
            
            //add IP-RP
            TFHppleElement *iprpElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * ipReleieving = [temp numberFromString:[[iprpElement firstChild] content]];
            player.ipReleieving = ipReleieving;
            statsCount++;
            
            //add Wins
            TFHppleElement *winsElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * wins = [temp numberFromString:[[winsElement firstChild] content]];
            player.wins = wins;
            statsCount++;
            
            //add losses
            TFHppleElement *lossesElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * losses = [temp numberFromString:[[lossesElement firstChild] content]];
            player.losses = losses;
            statsCount++;
            
            //add svs
            TFHppleElement *svsElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * saves = [temp numberFromString:[[svsElement firstChild] content]];
            player.saves= saves;
            statsCount++;
            
            //add bs
            TFHppleElement *bsElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * bs = [temp numberFromString:[[bsElement firstChild] content]];
            player.bs = bs;
            statsCount++;
            
            //add qs
            TFHppleElement *qsElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * qs = [temp numberFromString:[[qsElement firstChild] content]];
            player.qs = qs;
            statsCount++;
            
            //add bqs
            TFHppleElement *bqsElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * bqs = [temp numberFromString:[[bqsElement firstChild] content]];
            player.bqs = bqs;
            statsCount++;
            
            //add pa
            TFHppleElement *paElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * plateAppearences = [temp numberFromString:[[paElement firstChild] content]];
            player.plateAppearences = plateAppearences;
            statsCount++;
            
            //add Hits
            TFHppleElement *hitsElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * hits = [temp numberFromString:[[hitsElement firstChild] content]];
            player.hits = hits;
            statsCount++;
            
            //add Runs
            TFHppleElement *runsElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * runs = [temp numberFromString:[[runsElement firstChild] content]];
            player.runs = runs;
            statsCount++;
            
            //add ER
            TFHppleElement *erElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * er = [temp numberFromString:[[erElement firstChild] content]];
            player.er = er;
            statsCount++;
            
            //add HR
            TFHppleElement *hrElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * hr = [temp numberFromString:[[hrElement firstChild] content]];
            player.hr = hr;
            statsCount++;
            
            //add TB
            TFHppleElement *tbElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * tb = [temp numberFromString:[[tbElement firstChild] content]];
            player.tb = tb;
            statsCount++;
            
            //add BB
            TFHppleElement *bbElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * bb = [temp numberFromString:[[bbElement firstChild] content]];
            player.baseOnBalls = bb;
            statsCount++;
            
            //add UBB
            TFHppleElement *ubbElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * ubb = [temp numberFromString:[[ubbElement firstChild] content]];
            player.ubb = ubb;
            statsCount++;
            
            //add HBP
            TFHppleElement *hbpElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * hbp = [temp numberFromString:[[hbpElement firstChild] content]];
            player.hbp = hbp;
            statsCount++;
            
            //add SO
            TFHppleElement *soElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * so = [temp numberFromString:[[soElement firstChild] content]];
            player.strikeout = so;
            statsCount++;
            
            //add ERA
            TFHppleElement *eraElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * era = [temp numberFromString:[[eraElement firstChild] content]];
            player.era = era;
            statsCount++;
            
            //add FIP
            TFHppleElement *fipElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * fip = [temp numberFromString:[[fipElement firstChild] content]];
            player.fip = fip;
            statsCount++;
            
            //add FRA
            TFHppleElement *fraElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * fra = [temp numberFromString:[[fraElement firstChild] content]];
            player.fra = fra;
            statsCount++;
            
            //add VORP
            TFHppleElement *vorpElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * vorp = [temp numberFromString:[[vorpElement firstChild] content]];
            player.vorp = vorp;
            statsCount++;
            
            //add WARP
            TFHppleElement *warpElement = [statsNodes objectAtIndex:statsCount];
            NSNumber * warp = [temp numberFromString:[[warpElement firstChild] content]];
            player.warp = warp;
            statsCount++;
            
            NSLog(@"************************************************************Year %@",[player year]);
            NSLog(@"Team %@",[player team]);
            NSLog(@"games %@",[player games]);
            NSLog(@"age %@",[player age]);
            NSLog(@"GS %@",[player gamesStarted]);
            NSLog(@"IP %@",[player ip]);
            NSLog(@"IP-SP %@",[player ipStarting]);
            NSLog(@"IP-RP %@",[player ipReleieving]);
            NSLog(@"W %@",[player wins]);
            NSLog(@"L %@",[player losses]);
            NSLog(@"SV %@",[player saves]);
            NSLog(@"BS %@",[player bs]);
            NSLog(@"QS %@",[player qs]);
            NSLog(@"BQS %@",[player bqs]);
            NSLog(@"PA %@",[player plateAppearences]);
            NSLog(@"H %@",[player hits]);
            NSLog(@"R %@",[player runs]);
            NSLog(@"ER %@",[player er]);
            NSLog(@"HR %@",[player hr]);
            NSLog(@"TB %@",[player tb]);
            NSLog(@"BB %@",[player baseOnBalls]);
            NSLog(@"UBB %@",[player ubb]);
            NSLog(@"HBP %@",[player hbp]);
            NSLog(@"SO %@",[player strikeout]);
            NSLog(@"ERA %@",[player era]);
            NSLog(@"FIP %@",[player fip]);
            NSLog(@"FRA %@",[player fra]);
            NSLog(@"VORP %@",[player vorp]);
            NSLog(@"WARP %@",[player warp]);
            NSLog(@"Player Position %@",[player playPosition]);
            NSLog(@"fwar %@",[player fwar]);
            NSLog(@"GB Rate %@",[player gbRate]);
            NSLog(@"LOB %@",[player lob]);
            NSLog(@"xFIP %@",[player xfip]);
            NSLog(@"BB/9 %@",[player bb9]);
            NSLog(@"HR/9 %@",[player hr9]);
            NSLog(@"K/9 %@",[player k9]);
            NSLog(@"RA/9 Wins %@",[player ra9Wins]);
            
            statsCount += 2;
            i++;
            FGMultiCount++;

        }
        
    }
    return playerArray;


}


@end
