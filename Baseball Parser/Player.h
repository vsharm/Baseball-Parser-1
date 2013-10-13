//
//  Player.h
//  Fangraphs2
//
//  Created by Varun Sharma on 12/24/12.
//  Copyright (c) 2012 Varun Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *team;
@property (nonatomic, copy) NSString *playPosition;

@property (nonatomic, copy) NSNumber *year;
@property (nonatomic, copy) NSNumber *age;
@property (nonatomic, copy) NSNumber *games;

@property (nonatomic, copy) NSNumber *gamesStarted;
@property (nonatomic, copy) NSNumber *ip;
@property (nonatomic, copy) NSNumber *ipStarting;
@property (nonatomic, copy) NSNumber *ipReleieving;
@property (nonatomic, copy) NSNumber *wins;
@property (nonatomic, copy) NSNumber *losses;
@property (nonatomic, copy) NSNumber *saves;
@property (nonatomic, copy) NSNumber *bs;
@property (nonatomic, copy) NSNumber *qs;
@property (nonatomic, copy) NSNumber *bqs;
@property (nonatomic, copy) NSNumber *er;
@property (nonatomic, copy) NSNumber *hr;
@property (nonatomic, copy) NSNumber *tb;
@property (nonatomic, copy) NSNumber *ubb;
@property (nonatomic, copy) NSNumber *so;
@property (nonatomic, copy) NSNumber *era;
@property (nonatomic, copy) NSNumber *fip;
@property (nonatomic, copy) NSNumber *fra;




@property (nonatomic, copy) NSNumber *plateAppearences;
@property (nonatomic, copy) NSNumber *atBats;
@property (nonatomic, copy) NSNumber *runs;
@property (nonatomic, copy) NSNumber *hits;
@property (nonatomic, copy) NSNumber *doubles;
@property (nonatomic, copy) NSNumber *triples;
@property (nonatomic, copy) NSNumber *homeruns;
@property (nonatomic, copy) NSNumber *totalBases;
@property (nonatomic, copy) NSNumber *baseOnBalls;
@property (nonatomic, copy) NSNumber *strikeout;
@property (nonatomic, copy) NSNumber *hbp;
@property (nonatomic, copy) NSNumber *sackFly;
@property (nonatomic, copy) NSNumber *sh;
@property (nonatomic, copy) NSNumber *rbi;
@property (nonatomic, copy) NSNumber *sb;
@property (nonatomic, copy) NSNumber *cs;
@property (nonatomic, copy) NSNumber *avg;
@property (nonatomic, copy) NSNumber *obp;
@property (nonatomic, copy) NSNumber *slg;
@property (nonatomic, copy) NSNumber *tav;
@property (nonatomic, copy) NSNumber *vorp;
@property (nonatomic, copy) NSNumber *fraa;
@property (nonatomic, copy) NSNumber *warp;

@property (nonatomic, copy) NSNumber *bwar;
@property (nonatomic, copy) NSImage *photo;

//Fangraphs Batter Stats
@property (nonatomic, copy) NSNumber *wrc;
@property (nonatomic, copy) NSNumber *bsr;
@property (nonatomic, copy) NSNumber *fld;
//FG Pitchers Stats
@property (nonatomic, copy) NSNumber *gbRate;
@property (nonatomic, copy) NSNumber *xfip;
@property (nonatomic, copy) NSNumber *k9;
@property (nonatomic, copy) NSNumber *bb9;
@property (nonatomic, copy) NSNumber *lob;
@property (nonatomic, copy) NSNumber *hr9;
@property (nonatomic, copy) NSNumber *ra9Wins;

//FG for both
@property (nonatomic, copy) NSNumber *fwar;
@property (nonatomic, copy) NSNumber *babip;




@end
