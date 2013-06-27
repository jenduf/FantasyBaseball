//
//  Constants.h
//  Fantasy
//
//  Created by Jennifer Duffey on 4/24/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#define YAHOO_API_KEY	@"dj0yJmk9R1lOUE5yRk1LUHZrJmQ9WVdrOU9FSmliREIyTkRJbWNHbzlNakEzTXpFek5UVTJNZy0tJnM9Y29uc3VtZXJzZWNyZXQmeD1iMg--"

#define YAHOO_API_SECRET	@"a5eab504270b60d264bdb0396389ab0b4665fcef%26"

#define PRE_APPROVED_TOKEN_STRING	@"PreApprovedRequestToken"

#define KEY_ACCESS_TOKEN		@"access_token"

#define QUERY_URL	@"http://query.yahooapis.com/v1/yql/duffey/"

#define PADDING_TOP		5

typedef enum
{
	REQUEST_NONE = 0,
	REQUEST_AUTH = 1,
     REQUEST_TOKEN = 2,
     REQUEST_TOKEN_REFRESH = 3,
	REQUEST_GAME = 4,
	REQUEST_LEAGUE = 5,
	REQUEST_SCOREBOARD = 6,
	REQUEST_STANDINGS = 7,
	REQUEST_PLAYERS = 8,
	REQUEST_MY_TEAM = 9,
	REQUEST_MY_ROSTER = 10,
	REQUEST_STATS = 11,
	REQUEST_TEAMS = 12
} RequestType;


typedef enum
{
	NEWS_MODE_NONE = 0,
	NEWS_MODE_WARM = 1,
	NEWS_MODE_HOT = 2
} NewsMode;

typedef enum
{
	STATUS_MODE_PLAYING = 0,
	STATUS_MODE_BENCHED = 1,
	STATUS_MODE_DISABLED = 2
} StatusMode;

typedef enum
{
	STATS_ID_ATBATS = 60,
	STATS_ID_RUNS = 7,
	STATS_ID_HOMERUNS = 12,
	STATS_ID_RBI = 13,
	STATS_ID_STOLEN_BASES = 16,
	STATS_ID_BATTING_AVERAGE = 3,
	STATS_ID_INNINGS_PITCHED = 50,
	STATS_ID_WINS	= 28,
	STATS_ID_SAVES	= 32,
	STATS_ID_STRIKEOUTS = 42,
	STATS_ID_ERA = 26,
	STATS_ID_WHIP = 27
} StatID;

typedef enum
{
	OWNERSHIP_TYPE_FREE_AGENT = 0,
	OWNERSHIP_TYPE_TEAM = 1
} OwnershipType;
