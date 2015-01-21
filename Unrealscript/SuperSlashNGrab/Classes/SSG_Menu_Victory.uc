class SSG_Menu_Victory extends GfxMoviePlayer;

const MAX_NUMBER_OF_PLAYERS = 4;
var SSG_Menu_Object_Scorecard PlayerScorecards[ MAX_NUMBER_OF_PLAYERS ];
var string ScaleformScorecardNames[ MAX_NUMBER_OF_PLAYERS ];
var SoundCue WinningSounds [ MAX_NUMBER_OF_PLAYERS ];

//Score->Gold Values
var int GoldValuePerBetrayal;
var int GoldValuePerDeath;
var int GoldValuePerKill;

//Localization Files
var string LocalizationSection;


//++++++++++++++++++++++++++++++++++++++++++ Lifecycle Functions +++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function bool Start( optional bool StartPaused = false )
{
	super.Start( StartPaused );
	return true;
}

//----------------------------------------------------------------------------------------------------------
function Init( optional LocalPlayer playerController )
{
	local int i;
	local int PlayerID;
	local SSG_PlayerController PC;
	local LinearColor PlayerBaseColor;
	local int TotalBetrayals;
	local int NumPlayers;
	NumPlayers = 0;
	TotalBetrayals = 0;

	Start( false );
	Advance(0.f);

	SetViewScaleMode( SM_ExactFit );
	SetAlignment( Align_Center );
	//AddFocusIgnoreKey( 'Escape' ); //No pausing allowed here.


	for( i = 0; i < MAX_NUMBER_OF_PLAYERS; ++i )
	{
		PlayerBaseColor = SSG_PlayerController( GetPC() ).PlayerColors[ i ];

		PlayerScorecards[ i ] = SSG_Menu_Object_Scorecard( GetVariableObject( ScaleformScorecardNames[ i ], class'SSG_Menu_Object_Scorecard' ) );
		PlayerScorecards[ i ].SetColorsFromLinearColor( PlayerBaseColor );
		PlayerScorecards[ i ].SetVisible( false );
	}

	ForEach GetPC().WorldInfo.AllControllers( class'SSG_PlayerController', PC )
	{
		++NumPlayers;
	}

	foreach GetPC().WorldInfo.AllControllers( class'SSG_PlayerController', PC )
	{
		//Set our player's score data with the final score
		PC.RawMoneyEarned = PC.MoneyEarned;
		TotalBetrayals = PC.NumTimesBetrayedPlayer[0] + PC.NumTimesBetrayedPlayer[1] + PC.NumTimesBetrayedPlayer[2] + PC.NumTimesBetrayedPlayer[3];
		PC.MoneyEarned = PC.MoneyEarned + ( PC.NumKills * GoldValuePerKill ) + ( ( PC.LivesLived - 1 ) * GoldValuePerDeath) + ( TotalBetrayals * GoldValuePerBetrayal );
		PC.MoneyEarned *= NumPlayers;
	}

	foreach GetPC().WorldInfo.AllControllers( class'SSG_PlayerController', PC )
	{

		PlayerID = LocalPlayer( PC.Player ).ControllerID;

		PlayerScorecards[ PlayerID ].SetVisible( true );
		PlayerScorecards[ PlayerID ].SetPlayerName( PC.ThiefName );
		PlayerScorecards[ PlayerID ].SetGoldWinner( false );
		PlayerScorecards[ PlayerID ].SetDeathWinner( false );
		PlayerScorecards[ PlayerID ].SetKillWinner( false );
		FillScorecardWithPlayerData( PlayerScorecards[ PlayerID ], PC );
		LocalizeAndPopulateTitlesFrame( PlayerID );
		//UpdatePlayerIndicator( PC );
		//SetPlayerName( LocalPlayer( PC.Player ).ControllerID, PC.PlayerReplicationInfo.PlayerName, SSG_PlayerController( PC ).LivesLived );
		//SetTreasureAmount( LocalPlayer( PC.Player ).ControllerID, SSG_PlayerController( PC ).MoneyEarned );
	}

	LocalizeVictoryScreen();

	SetExternalInterface( GetPC().myHUD );
}

//----------------------------------------------------------------------------------------------------------
function LocalizeVictoryScreen()
{
	local GFxObject Title;
	local string TitleString;

	Title = GetVariableObject("_root.text_title");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "victoryTitleVictory");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.text_subtitle");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "victoryTitleSubtitle");
	Title.SetText(TitleString);
}

//----------------------------------------------------------------------------------------------------------
function TickHUD()
{
}


//++++++++++++++++++++++++++++++++++++++++++++ Helper Functions ++++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function FillScorecardWithPlayerData( SSG_Menu_Object_Scorecard Scorecard, SSG_PlayerController SSG_PC )
{
    local GFxObject ScoreDataArray;
    local GFxObject ScoreData;
	local string LocalizedString;
	local GFxObject Title;
	local string TitleString;
	local SSG_PlayerController PC;
	local int TotalBetrayals;
	local int NumPlayers;
	NumPlayers = 0;
	TotalBetrayals = 0;

	Title = GetVariableObject("_root.mc_player_"$LocalPlayer( SSG_PC.Player ).ControllerID+1$"_score.mc_stats_frame.text_title");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "victoryTitleStats");
	Title.SetText(TitleString);

	ForEach GetPC().WorldInfo.AllControllers( class'SSG_PlayerController', PC )
	{
		++NumPlayers;
	}

    ScoreDataArray = CreateArray();

	ScoreData = CreateObject( "Object" );
	LocalizedString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "victoryLabelScoreGold");
	ScoreData.SetString( "label", LocalizedString );
	ScoreData.SetString( "score", "" );
	ScoreData.SetString( "gold", String( SSG_PC.RawMoneyEarned ) );
	ScoreDataArray.SetElementObject( 0, ScoreData );

	ScoreData = CreateObject( "Object" );
	LocalizedString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "victoryLabelScoreKills");
	ScoreData.SetString( "label", LocalizedString );
	ScoreData.SetString( "score", String( SSG_PC.NumKills ) );
	ScoreData.SetString( "gold", "+" $ String( SSG_PC.NumKills * GoldValuePerKill ) );
	ScoreDataArray.SetElementObject( 1, ScoreData );

	ScoreData = CreateObject( "Object" );
	LocalizedString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "victoryLabelScoreDeaths");
	ScoreData.SetString( "label", LocalizedString );
	ScoreData.SetString( "score", String( SSG_PC.LivesLived - 1 ) );
	ScoreData.SetString( "gold", String( ( SSG_PC.LivesLived - 1 ) * GoldValuePerDeath)  );
	ScoreDataArray.SetElementObject( 2, ScoreData );

	TotalBetrayals = SSG_PC.NumTimesBetrayedPlayer[0] + SSG_PC.NumTimesBetrayedPlayer[1] + SSG_PC.NumTimesBetrayedPlayer[2] + SSG_PC.NumTimesBetrayedPlayer[3];
	ScoreData = CreateObject( "Object" );
	LocalizedString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "victoryLabelScoreBetrayals");
	ScoreData.SetString( "label", LocalizedString );
	ScoreData.SetString( "score", String( TotalBetrayals ) );
	ScoreData.SetString( "gold", "+" $ String( TotalBetrayals * GoldValuePerBetrayal ) );
	ScoreDataArray.SetElementObject( 3, ScoreData );

	ScoreData = CreateObject( "Object" );
	LocalizedString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "victoryLabelScoreMultiplier");
	ScoreData.SetString( "label", LocalizedString );
	ScoreData.SetString( "score", "" );
	ScoreData.SetString( "gold", 'x' $ String( NumPlayers ) );
	ScoreDataArray.SetElementObject( 4, ScoreData );


	Scorecard.SetPlayerPlace( GetRank( SSG_PC ) + 1 );

	ScoreData = CreateObject( "Object" );
	LocalizedString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "victoryLabelScoreTotal");
	ScoreData.SetString( "label", LocalizedString );
	ScoreData.SetString( "score", "" );
	ScoreData.SetString( "gold", String( SSG_PC.MoneyEarned ) );
	ScoreDataArray.SetElementObject( 5, ScoreData );

	Scorecard.SetFloat( "rowCount", 6 );   // you must specify the row count of scrolling lists manually 
	Scorecard.SetStatData( ScoreDataArray );
}

//----------------------------------------------------------------------------------------------------------
delegate int SortByGold(SSG_PlayerController A, SSG_PlayerController B) 
{ 
	return A.MoneyEarned < B.MoneyEarned ? -1 : 0; 
}

//----------------------------------------------------------------------------------------------------------
function int GetRank(SSG_PlayerController OfPlayer)
{
	local int PlaceInGoldStandings;
	local array< SSG_PlayerController > PlayerRanks;
	local SSG_PlayerController SSG_PC;

	foreach OfPlayer.LocalPlayerControllers( class'SSG_PlayerController', SSG_PC )
	{
		PlayerRanks.AddItem( SSG_PC );
	}

	PlayerRanks.Sort(SortByGold);
	PlaceInGoldStandings = PlayerRanks.Find(OfPlayer);
	while(PlaceInGoldStandings != 0)
	{
		if(PlayerRanks[PlaceInGoldStandings].MoneyEarned == PlayerRanks[PlaceInGoldStandings - 1].MoneyEarned)
		{
			PlaceInGoldStandings--;
		}
		else
		{
			break;
		}
	}

	return PlaceInGoldStandings;
}

//----------------------------------------------------------------------------------------------------------
function LocalizeAndPopulateTitlesFrame( int controllerID )
{
	//switch on controller id for identification of which card it is
	//Check FillScorecardWithPlayerData in SSG_Menu_Victory for details of how to properly populate
	local SSG_PlayerController currentController;
	local SSG_GameInfo SSG_GI;
	local string currentSuperlativeLocalizeID;
	local int TitleIndex;
	local GFxObject TitleDataArray;
	local GFxObject TitleData;
	local string LocalizedString;
	local GFxObject Title;
	local string TitleString;

	SSG_GI = SSG_GameInfo(class'WorldInfo'.static.GetWorldInfo().Game);
	SSG_GI.GenerateSuperlatives();
	
	foreach class'WorldInfo'.static.GetWorldInfo().AllControllers(class'SSG_PlayerController', currentController)
	{
		if(LocalPlayer(currentController.Player).ControllerId == controllerID)
		{
			Title = GetVariableObject("_root.mc_player_"$controllerID+1$"_score.mc_titles_frame.text_title");
			TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "victoryTitleTitles");
			Title.SetText(TitleString);

			TitleDataArray = CreateArray();
			TitleIndex = 0;

			foreach currentController.Superlatives(currentSuperlativeLocalizeID)
			{
				TitleData = CreateObject( "Object" );
				LocalizedString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, currentSuperlativeLocalizeID);
				TitleData.SetString( "label", LocalizedString );
				TitleData.SetString( "score", "");
				TitleDataArray.SetElementObject( TitleIndex, TitleData );

				TitleIndex++;
			}

			PlayerScorecards[controllerID].SetFloat( "rowCount", TitleIndex );
			PlayerScorecards[controllerID].SetTitleData(TitleDataArray);
		}
	}
}



DefaultProperties
{
	MovieInfo=SwfMovie'VictoryScoreboard.VictoryScoreboard'
	TimingMode=TM_Real
	Priority=5

	bBlurLesserMovies=true

	bDisplayWithHudOff=true
	bPauseGameWhileActive=false

	bAllowFocus=true
	bAllowInput=true
	bCaptureInput=true
	bCaptureMouseInput=true

	ScaleformScorecardNames(0)="_root.mc_player_1_score"
	ScaleformScorecardNames(1)="_root.mc_player_2_score"
	ScaleformScorecardNames(2)="_root.mc_player_3_score"
	ScaleformScorecardNames(3)="_root.mc_player_4_score"

	WinningSounds(0)=SoundCue'SSG_AnnouncerSounds.Winning.SSG_Announcer_Win_Blue_Cue_01'
	WinningSounds(1)=SoundCue'SSG_AnnouncerSounds.Winning.SSG_Announcer_Win_Pink_Cue_01'
	WinningSounds(2)=SoundCue'SSG_AnnouncerSounds.Winning.SSG_Announcer_Win_Orange_Cue_01'
	WinningSounds(3)=SoundCue'SSG_AnnouncerSounds.Winning.SSG_Announcer_Win_Green_Cue_01'

	GoldValuePerBetrayal=200
	GoldValuePerDeath=-25
	GoldValuePerKill=50

	LocalizationSection="SSG_Menu_Victory"

	SoundThemes(0)=( ThemeName=MenuSounds, Theme=UISoundTheme'SSG_FlashAssets.Sound.SSG_SoundTheme' )
}
