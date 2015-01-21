class SSG_Menu_Map extends GfxMoviePlayer
    dependson(Text_Localizer, SSG_Save_HighScore);

//Player Data

//Levels
var string MainMenuLevelName;
var string TutorialLevelName;
var string Level1Name;
var string Level2Name;
var string Level3Name;

var SSG_Save_HighScore HighScores;

//++++++++++++++++++++++++++++++++++++++++++ Lifecycle Functions +++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function bool Start( optional bool StartPaused = false )
{
	AddFocusIgnoreKey( 'Escape' );

	super.Start( StartPaused );

	SetViewScaleMode( SM_ExactFit );
	SetAlignment( Align_TopLeft );

	HighScores = new class'SSG_Save_HighScore';
	HighScores.LoadFromDisk();

	return true;
}

//+++++++++++++++++++++++++++++++++++++++++++ Helper Functions +++++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function SafelyQuitGame()
{
	ConsoleCommand( "Exit" );
}

//----------------------------------------------------------------------------------------------------------
function SendConsoleCommand( string command ) 
{
    `log( "CONSOLE COMMAND: " $ command );
     ConsoleCommand( command );
}



//+++++++++++++++++++++++++++++++++ External Interfaces I: Unreal->Flash +++++++++++++++++++++++++++++++++//



//++++++++++++++++++++++++++++++++ External Interfaces II: Flash->Unreal +++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function GoToMainMenu()
{
	SendConsoleCommand( "open " $ MainMenuLevelName );
}

//----------------------------------------------------------------------------------------------------------
function LoadTutorialLevel()
{
	SendConsoleCommand( "open " $ TutorialLevelName );
}

//----------------------------------------------------------------------------------------------------------
function LoadLevel1()
{
	SendConsoleCommand( "open " $ Level1Name );
}

//----------------------------------------------------------------------------------------------------------
function LoadLevel2()
{
	SendConsoleCommand( "open " $ Level2Name );
}

//----------------------------------------------------------------------------------------------------------
function LoadLevel3()
{
	SendConsoleCommand( "open " $ Level3Name );
}

//----------------------------------------------------------------------------------------------------------
function StopMusic()
{
	ConsoleCommand( "CE StopMusic" );
}

//----------------------------------------------------------------------------------------------------------
function bool CanMoveTo(int LevelID)
{
	local bool isOpen;
	local array<HighScoreEntry> Score;
	
	if(LevelID == 0)
	{
		isOpen = true;
	}
	else
	{
		Score = HighScores.AllHighScores[LevelID-1].HighScoreTable;
		if(Score.Length != 0)
		{
			isOpen = HighScores.AllHighScores[LevelID-1].HighScoreTable[0].LevelScore > 0;
		}
		else
		{
			isOpen = false;
		}
	}
	return isOpen;
}

//+++++++++++++++++++++++++++++++++++++++++++ Frame Localization +++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function LocalizeMap()
{
	//Don't forget to localize each and every text item on the map!
	local int i;
	local bool ShouldBeLocked;
	local GFxObject LockedSymbol;
	local SSG_Menu_Object_Label Label;
	local string LabelString;
	local SSG_Save_SessionObject CurrentSession;
	local string localizationSection;
	localizationSection = "SSG_Menu_Map";

	Label = SSG_Menu_Object_Label( GetVariableObject("_root.map_background.text_guildhall", class'SSG_Menu_Object_Label' ) );
	LabelString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "mapLabelPlaceGuildhall");
	Label.SetResizingText(LabelString);

	Label = SSG_Menu_Object_Label( GetVariableObject("_root.map_background.text_river", class'SSG_Menu_Object_Label' ) );
	LabelString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "mapLabelPlaceRiver");
	Label.SetResizingText(LabelString);

	Label = SSG_Menu_Object_Label( GetVariableObject("_root.map_background.text_kings_castle", class'SSG_Menu_Object_Label' ) );
	LabelString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "mapLabelPlaceCastle");
	Label.SetResizingText(LabelString);

	Label = SSG_Menu_Object_Label( GetVariableObject("_root.map_background.text_sewer_pipe", class'SSG_Menu_Object_Label' ) );
	LabelString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "mapLabelPlaceSewer");
	Label.SetResizingText(LabelString);

	Label = SSG_Menu_Object_Label( GetVariableObject("_root.map_background.text_servants_quarters", class'SSG_Menu_Object_Label' ) );
	LabelString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "mapLabelPlaceServants");
	Label.SetResizingText(LabelString);

	Label = SSG_Menu_Object_Label( GetVariableObject("_root.map_background.text_dining_hall", class'SSG_Menu_Object_Label' ) );
	LabelString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "mapLabelPlaceDining");
	Label.SetResizingText(LabelString);

	Label = SSG_Menu_Object_Label( GetVariableObject("_root.map_background.text_storage", class'SSG_Menu_Object_Label' ) );
	LabelString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "mapLabelPlaceStorage");
	Label.SetResizingText(LabelString);

	Label = SSG_Menu_Object_Label( GetVariableObject("_root.map_background.text_armory_barracks", class'SSG_Menu_Object_Label' ) );
	LabelString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "mapLabelPlaceArmory");
	Label.SetResizingText(LabelString);

	Label = SSG_Menu_Object_Label( GetVariableObject("_root.map_background.text_loading_docks", class'SSG_Menu_Object_Label' ) );
	LabelString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "mapLabelPlaceLoading");
	Label.SetResizingText(LabelString);

	Label = SSG_Menu_Object_Label( GetVariableObject("_root.map_background.text_cold_storage", class'SSG_Menu_Object_Label' ) );
	LabelString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "mapLabelPlaceCold");
	Label.SetResizingText(LabelString);

	Label = SSG_Menu_Object_Label( GetVariableObject("_root.map_background.text_vault", class'SSG_Menu_Object_Label' ) );
	LabelString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "mapLabelPlaceVault");
	Label.SetResizingText(LabelString);

	Label = SSG_Menu_Object_Label( GetVariableObject("_root.map_background.text_courtyard", class'SSG_Menu_Object_Label' ) );
	LabelString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "mapLabelPlaceCourtyard");
	Label.SetResizingText(LabelString);

	Label = SSG_Menu_Object_Label( GetVariableObject("_root.map_background.text_front_gate", class'SSG_Menu_Object_Label' ) );
	LabelString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "mapLabelPlaceGate");
	Label.SetResizingText(LabelString);

	Label = SSG_Menu_Object_Label( GetVariableObject("_root.map_background.text_lake", class'SSG_Menu_Object_Label' ) );
	LabelString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "mapLabelPlaceLake");
	Label.SetResizingText(LabelString);

	Label = SSG_Menu_Object_Label( GetVariableObject("_root.map_background.text_docks", class'SSG_Menu_Object_Label' ) );
	LabelString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "mapLabelPlaceDocks");
	Label.SetResizingText(LabelString);

	CurrentSession = new class'SSG_Save_SessionObject';
	CurrentSession.LoadFromDisk();
	`log( "Current Level: " $ CurrentSession.NextLevel );
	switch( CurrentSession.NextLevel )
	{
	case 3:
		ActionScriptVoid( "_root.StartPlayersAtLevel3" );
		break;
	case 2:
		ActionScriptVoid( "_root.StartPlayersAtLevel2" );
		break;
	case 1:
		ActionScriptVoid( "_root.StartPlayersAtLevel1" );
		break;
	case 0:
	default:
		ActionScriptVoid( "_root.StartPlayersAtTutorial" );
	}

	for(i = 1; i < 4; i++)
	{
		LockedSymbol = GetVariableObject("_root.mc_locked_"$i);
		ShouldBeLocked = !CanMoveTo(i);
		LockedSymbol.SetVisible(ShouldBeLocked);
	}
}

//----------------------------------------------------------------------------------------------------------
function LocalizeAndPopulateLevelDetailPopup( int levelID )
{
	// the level ID ranges from 0-3, and indicates which level this is for.
	// the popup text boxes should be at _root.level_detail_popup.gfxObjectName...
	local GFxObject Title;
	local string TitleString;
	local string localizationSection;
	localizationSection = "SSG_Menu_Map";
	
	Title = GetVariableObject("_root.level_detail_popup.text_high_scorer_name");
	TitleString = HighScores.LevelWinner[levelID];
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.level_detail_popup.text_high_scorer_amount");
	TitleString = string(HighScores.LevelScore[levelID]);
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.level_detail_popup.text_high_score");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "mapLabelPopupHighscore");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.level_detail_popup.text_level_number");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "mapLabelPopupLevel"$levelID);
	Title.SetText(TitleString);
}

//----------------------------------------------------------------------------------------------------------
function SetThiefVisibility()
{
	// Thieves are located at _root.mc_thieves_marker.mc_thief_[1-4]
	// Gets called at each tween.
	local SSG_Save_SessionObject CurrentSession;
	local GFxObject CurrentThief;
	local int i;

	CurrentSession = new class'SSG_Save_SessionObject';
	CurrentSession.LoadFromDisk();
	for(i = 0; i < 4; i++)
	{
		CurrentThief = GetVariableObject("_root.mc_thieves_marker.mc_thief_"$i+1);
		if(CurrentSession.PlayerNames[i] == "none")
		{
			CurrentThief.SetVisible(false);
		}
		else
		{
			CurrentThief.SetVisible(true);
		}
	}
}



//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	MovieInfo=SwfMovie'MapMenu.MapMenu'
	TimingMode=TM_Real
	Priority=5

	bDisplayWithHudOff=true
	//bPauseGameWhileActive=true

	bAllowFocus=true
	bAllowInput=true
	bCaptureInput=true
	bCaptureMouseInput=true

	MainMenuLevelName="SGS_MainMenu.udk";
	TutorialLevelName="SSG-RTMT_Persistent.udk";
	Level1Name="SSG-RTM1_Persistent.udk";
	Level2Name="SSG-RTM2_Persistent.udk";
	Level3Name="SSG-RTM3_Persistent.udk";

	SoundThemes(0)=( ThemeName=MenuSounds, Theme=UISoundTheme'SSG_FlashAssets.Sound.SSG_SoundTheme' )
}
