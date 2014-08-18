//
//  Constants.h
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#ifndef FantasySports_Constants_h
#define FantasySports_Constants_h

#define YAHOO_API_KEY	@"dj0yJmk9R1lOUE5yRk1LUHZrJmQ9WVdrOU9FSmliREIyTkRJbWNHbzlNakEzTXpFek5UVTJNZy0tJnM9Y29uc3VtZXJzZWNyZXQmeD1iMg--"

#define YAHOO_API_SECRET	@"a5eab504270b60d264bdb0396389ab0b4665fcef%26"

#define PRE_APPROVED_TOKEN_STRING	@"PreApprovedRequestToken"

#define KEY_ACCESS_TOKEN		@"access_token"

#define QUERY_URL	@"http://query.yahooapis.com/v1/yql/duffey/"
#define SPECIFIC_QUERY_URL    @"https://query.yahooapis.com/v1/yql?q="

#define HTTP_CODE_SUCCESS   200

#define TOTAL_STAT_LABELS       6

// Layout
#define PADDING_TOP                 5
#define CELL_PADDING                4
#define STAT_PADDING                22
#define CELL_ITEM_PADDING           10
#define STAT_CELL_NARROW_WIDTH      24
#define STAT_CELL_WIDE_WIDTH        100
#define STAT_CELL_HEIGHT            24
#define STAT_FIRST_CELL_WIDTH       34

// controllers
#define AUTH_VIEW_CONTROLLER        @"AuthViewController"
#define ROSTER_VIEW_CONTROLLER      @"RosterViewController"
#define PLAYER_VIEW_CONTROLLER      @"PlayerViewController"


// identifiers
#define PLAYER_CELL_IDENTIFIER              @"PlayerCellIdentifier"
#define LEAGUE_CELL_IDENTIFIER              @"LeagueCellIdentifier"
#define STATS_CELL_IDENTIFIER               @"StatsCellIdentifier"
#define SCOREBOARD_CELL_IDENTIFIER          @"ScoreboardCellIdentifier"
#define SCORE_DETAIL_CELL_IDENTIFIER        @"ScoreDetailCellIdentifier"
#define STANDINGS_CELL_IDENTIFIER           @"StandingsCellIdentifier"
#define PLAYER_LIST_CELL_IDENTIFIER         @"PlayerListCellIdentifier"

// fonts
#define FONT_DIN_CONDENSED_BOLD      @"DINCondensed-Bold"
#define FONT_SIZE_HEADER            18
#define FONT_SIZE_TITLE             14

#define DATE_FORMAT_STRING          @"yyyy-MM-dd"

#define OWNERSHIP_TYPE_FREEAGENTS   @"freeagents"

typedef int RequestType;
enum
{
    RequestTypeNone = 0,
    RequestTypeGame = 1,
    RequestTypeLeague = 2,
    RequestTypeMyRoster = 3,
    RequestTypeStats = 4,
    RequestTypePlayer = 5,
    RequestTypeScoreboard = 6,
    RequestTypeTeam = 7,
    RequestTypeStandings = 8,
    RequestTypePlayers = 9,
    RequestTypeOwnership = 10
};

typedef int HttpType;
enum
{
    HttpTypeGet = 0,
    HttpTypePost = 1
};

typedef int NewsMode;
enum
{
    NewsModeNone = 0,
    NewsModeWarm = 1,
    NewsModeHot = 2
};

typedef int StatusMode;
enum
{
    StatusModePlaying = 0,
    StatusModeBenched = 1,
    StatusModeDisabled = 2
};

typedef int StatID;
enum
{
    StatIDAB = 60,
    StatIDRuns = 7,
    StatIDHR = 12,
    StatIDRBI = 13,
    StatIDSB = 16,
    StatIDBA = 3,
    StatIDIP = 50,
    StatIDWins = 28,
    StatIDSaves = 32,
    StatIDK = 42,
    StatIDERA = 26,
    StatIDWhip = 27
};

typedef int TabState;
enum
{
    TabStateHome = 0,
    TabStateRoster = 1,
    TabStateStats = 2
};

typedef int OwnershipType;
enum
{
    OwnershipTypeFreeAgent = 0,
    OwnershipTypeTeam = 1
};

typedef int CollectionViewLayoutMode;
enum
{
    CollectionViewLayoutModeWide = 0,
    CollectionViewLayoutModeNarrow = 1
};

typedef int PlayerType;
enum
{
    PlayerTypeBatter = 0,
    PlayerTypePitcher = 1
};

typedef int BatterStatIndex;
enum
{
    BatterStatIndexAB = 0,
    BatterStatIndexR = 1,
    BatterStatIndexHR = 2,
    BatterStatIndexRBI = 3,
    BatterStatIndexSB = 4,
    BatterStatIndexAVG = 5
};

typedef int PitcherStatIndex;
enum
{
    PitcherStatIndexIP = 0,
    PitcherStatIndexW = 1,
    PitcherStatIndexSV = 2,
    PitcherStatIndexK = 3,
    PitcherStatIndexERA = 4,
    PitcherStatIndexWHIP = 5
};

#endif
