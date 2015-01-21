class SSG_Menu_ThiefSelection extends GfxMoviePlayer
    dependson(Text_Localizer);

//Player Data
var array< string > CurrentThieves;
var array< bool > PlayerIsReady;
var string SelectedPlayerName[ 4 ];

//Levels
var string MainMenuLevelName;
var string OpeningCutsceneMovieName;
var SSG_Cutscene_Opening OpeningCutscene;

//Player stores
var SSG_Save_SessionObject LoadedReadyPlayers;

//Localization Files
var string localizationSection;


//++++++++++++++++++++++++++++++++++++++++++ Lifecycle Functions +++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function bool Start( optional bool StartPaused = false )
{
	super.Start( StartPaused );

	SetViewScaleMode( SM_ExactFit );
	SetAlignment( Align_TopLeft );
	AddFocusIgnoreKey( 'Escape' );

	LoadedReadyPlayers = new class'SSG_Save_SessionObject';

	return true;
}

//+++++++++++++++++++++++++++++++++++++++++++ Helper Functions +++++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function GFxObject CreateScaleformDataProviderFromArray( GFxObject array )
{
     return ActionScriptConstructor( "scaleform.clik.data.DataProvider" );
}

//----------------------------------------------------------------------------------------------------------
function GFxObject ConvertStringArrayIntoDataProvider( array<String> StringArray )
{
    local int i;
    local GFxObject DataProviderArray, DataProvider;

    DataProviderArray = CreateArray();

    for( i = 0; i < StringArray.Length; ++i ) 
    {
        DataProviderArray.SetElementString( i, StringArray[ i ] );
    }

    DataProvider = CreateScaleformDataProviderFromArray( DataProviderArray );
    return DataProvider;
}

//----------------------------------------------------------------------------------------------------------
function int FindIndexOfStringInArray( array< string > StringArray, string StringToFind )
{
    local int i;

    for( i = 0; i < StringArray.Length; ++i )
    {
        if( StringArray[ i ] == StringToFind )
            return i;
    }
    return 0;
}

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
//----------------------------------------------------------------------------------------------------------
function LoadThiefArrayFromUnreal()
{
	local int i;
	local GFxObject TempNameObject;
	local GFxObject ThiefNameArray;

	ThiefNameArray = CreateArray();
	for( i = 0; i < CurrentThieves.Length; ++i )
	{
		TempNameObject = CreateObject( "Object" );
		TempNameObject.SetString( "ThiefName", CurrentThieves[ i ] );
		ThiefNameArray.SetElementObject( i, TempNameObject );
	}

	GetVariableObject( "_root" ).SetObject( "current_thieves", ThiefNameArray );
	ActionscriptVoid( "_root.UpdateThiefLists" );

	SSG_Menu_Thief_Selection_Card( GetVariableObject( "_root.mc_player_1_selection", class'SSG_Menu_Thief_Selection_Card' ) ).SetColorsFromLinearColor( class'SSG_PlayerController'.default.PlayerColors[ 0 ] );
	SSG_Menu_Thief_Selection_Card( GetVariableObject( "_root.mc_player_2_selection", class'SSG_Menu_Thief_Selection_Card' ) ).SetColorsFromLinearColor( class'SSG_PlayerController'.default.PlayerColors[ 1 ] );
	SSG_Menu_Thief_Selection_Card( GetVariableObject( "_root.mc_player_3_selection", class'SSG_Menu_Thief_Selection_Card' ) ).SetColorsFromLinearColor( class'SSG_PlayerController'.default.PlayerColors[ 2 ] );
	SSG_Menu_Thief_Selection_Card( GetVariableObject( "_root.mc_player_4_selection", class'SSG_Menu_Thief_Selection_Card' ) ).SetColorsFromLinearColor( class'SSG_PlayerController'.default.PlayerColors[ 3 ] );
}



//++++++++++++++++++++++++++++++++ External Interfaces II: Flash->Unreal +++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function AddNewThiefPlayer1()
{
	local GFxObject ThiefNameInput;

	ThiefNameInput = GetVariableObject( "_root.mc_player_1_selection.mc_frame_name_entry.text_input_name" );

	CurrentThieves.AddItem( ThiefNameInput.GetString( "text" ) );
	`log( "Player 1 Added " $ ThiefNameInput.GetString( "text" ) );
}

//----------------------------------------------------------------------------------------------------------
function AddNewThiefPlayer2()
{
	local GFxObject ThiefNameInput;

	ThiefNameInput = GetVariableObject( "_root.mc_player_2_selection.mc_frame_name_entry.text_input_name" );

	CurrentThieves.AddItem( ThiefNameInput.GetString( "text" ) );
	`log( "Player 2 Added " $ ThiefNameInput.GetString( "text" ) );
}

//----------------------------------------------------------------------------------------------------------
function AddNewThiefPlayer3()
{
	local GFxObject ThiefNameInput;

	ThiefNameInput = GetVariableObject( "_root.mc_player_3_selection.mc_frame_name_entry.text_input_name" );

	CurrentThieves.AddItem( ThiefNameInput.GetString( "text" ) );
	`log( "Player 3 Added " $ ThiefNameInput.GetString( "text" ) );
}

//----------------------------------------------------------------------------------------------------------
function AddNewThiefPlayer4()
{
	local GFxObject ThiefNameInput;

	ThiefNameInput = GetVariableObject( "_root.mc_player_4_selection.mc_frame_name_entry.text_input_name" );

	CurrentThieves.AddItem( ThiefNameInput.GetString( "text" ) );
	`log( "Player 4 Added " $ ThiefNameInput.GetString( "text" ) );
}

//----------------------------------------------------------------------------------------------------------
function CheckIfAllPlayersAreReady()
{
	local int i;
	local bool TeamIsReady;
	TeamIsReady = true;

	for( i = 0; i < PlayerIsReady.Length; ++i )
	{
		if( PlayerIsReady[ i ] == false )
		{
			TeamIsReady = false;
			break;
		}
	}

	if( TeamIsReady )
		GoToMapMenu();
}

//----------------------------------------------------------------------------------------------------------
function GoToMainMenu()
{
	local int i;
	//SSG_GameInfo_Menu(class'WorldInfo'.static.GetWorldInfo().Game).SaveProfile();
	for(i = 0; i < 4; i++)
	{
		LoadedReadyPlayers.PlayerNames[i] = SelectedPlayerName[i];
	}
	LoadedReadyPlayers.SaveToDisk();
	SendConsoleCommand( "open " $ MainMenuLevelName );
}

//----------------------------------------------------------------------------------------------------------
function GoToMapMenu()
{
	local int i;
	//SSG_GameInfo_Menu(class'WorldInfo'.static.GetWorldInfo().Game).SaveProfile();
	for(i = 0; i < 4; i++)
	{
		LoadedReadyPlayers.PlayerNames[i] = SelectedPlayerName[i];
	}
	LoadedReadyPlayers.SaveToDisk();
	
	SetPause( true );
	ConsoleCommand( "CE PlayCutscene" );
	//SendConsoleCommand( "movietest " $ OpeningCutsceneMovieName );
	//SendConsoleCommand( "open " $ "SGS-MapMenu.udk" );
}

//----------------------------------------------------------------------------------------------------------
function ReadyPlayer1()
{
	local GFxObject Player1NameText;
	local int i;
	Player1NameText = GetVariableObject( "_root.mc_player_1_selection.mc_frame_ready.text_player_name" );

	PlayerIsReady[ 0 ] = true;
	SelectedPlayerName[ 0 ] = Player1NameText.GetString( "text" );
	for(i = 0; i < 4; i++)
	{
		LoadedReadyPlayers.PlayerNames[i] = SelectedPlayerName[i];
	}
	LoadedReadyPlayers.SaveToDisk();
	`log( "Player 1 selected " $ SelectedPlayerName[ 0 ] );
}

//----------------------------------------------------------------------------------------------------------
function ReadyPlayer2()
{
	local GFxObject Player2NameText;
	local int i;
	Player2NameText = GetVariableObject( "_root.mc_player_2_selection.mc_frame_ready.text_player_name" );

	PlayerIsReady[ 1 ] = true;
	SelectedPlayerName[ 1 ] = Player2NameText.GetString( "text" );
	for(i = 0; i < 4; i++)
	{
		LoadedReadyPlayers.PlayerNames[i] = SelectedPlayerName[i];
	}
	LoadedReadyPlayers.SaveToDisk();
	`log( "Player 2 selected " $ SelectedPlayerName[ 1 ] );
}

//----------------------------------------------------------------------------------------------------------
function ReadyPlayer3()
{
	local GFxObject Player3NameText;
	local int i;
	Player3NameText = GetVariableObject( "_root.mc_player_3_selection.mc_frame_ready.text_player_name" );

	PlayerIsReady[ 2 ] = true;
	SelectedPlayerName[ 2 ] = Player3NameText.GetString( "text" );
	for(i = 0; i < 4; i++)
	{
		LoadedReadyPlayers.PlayerNames[i] = SelectedPlayerName[i];
	}
	LoadedReadyPlayers.SaveToDisk();
	`log( "Player 3 selected " $ SelectedPlayerName[ 2 ] );
}

//----------------------------------------------------------------------------------------------------------
function ReadyPlayer4()
{
	local GFxObject Player4NameText;
	local int i;
	Player4NameText = GetVariableObject( "_root.mc_player_4_selection.mc_frame_ready.text_player_name" );

	PlayerIsReady[ 3 ] = true;
	SelectedPlayerName[ 3 ] = Player4NameText.GetString( "text" );
	for(i = 0; i < 4; i++)
	{
		LoadedReadyPlayers.PlayerNames[i] = SelectedPlayerName[i];
	}
	LoadedReadyPlayers.SaveToDisk();
	`log( "Player 4 selected " $ SelectedPlayerName[ 3 ] );
}

//----------------------------------------------------------------------------------------------------------
function StopMusic()
{
	ConsoleCommand( "CE StopMusic" );
}

//----------------------------------------------------------------------------------------------------------
function UnreadyPlayer1()
{
	PlayerIsReady[ 0 ] = false;
}

//----------------------------------------------------------------------------------------------------------
function UnreadyPlayer2()
{
	PlayerIsReady[ 1 ] = false;
}

//----------------------------------------------------------------------------------------------------------
function UnreadyPlayer3()
{
	PlayerIsReady[ 2 ] = false;
}

//----------------------------------------------------------------------------------------------------------
function UnreadyPlayer4()
{
	PlayerIsReady[ 3 ] = false;
}



//+++++++++++++++++++++++++++++++++++++++++++ Frame Localization +++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function LocalizePressAFrame()
{
	local GFxObject Title;
	local string TitleString;

	Title = GetVariableObject("_root.mc_player_1_selection.mc_frame_press_start.text_press");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelStartPress");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_1_selection.mc_frame_press_start.text_to_play");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelStartToPlay");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_2_selection.mc_frame_press_start.text_press");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelStartPress");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_2_selection.mc_frame_press_start.text_to_play");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelStartToPlay");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_3_selection.mc_frame_press_start.text_press");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelStartPress");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_3_selection.mc_frame_press_start.text_to_play");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelStartToPlay");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_4_selection.mc_frame_press_start.text_press");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelStartPress");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_4_selection.mc_frame_press_start.text_to_play");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelStartToPlay");
	Title.SetText(TitleString);


	//player titles initialized here, since this gets called first
	Title = GetVariableObject("_root.mc_player_1_selection.text_player_title");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuTitleSelectionPlayer1");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_2_selection.text_player_title");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuTitleSelectionPlayer2");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_3_selection.text_player_title");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuTitleSelectionPlayer3");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_4_selection.text_player_title");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuTitleSelectionPlayer4");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.text_title");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuTitleThiefSelection");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.text_waiting");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuSubtitleSelectionWaiting");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.text_press_start");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuSubtitleSelectionStart");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.text_heist_start");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuSubtitleSelectionHeist");
	Title.SetText(TitleString);
	
}

//----------------------------------------------------------------------------------------------------------
function LocalizeThiefSelectionFrame()
{
	local GFxObject Title;
	local string TitleString;

	Title = GetVariableObject("_root.mc_player_1_selection.mc_frame_thief_select.text_select_thief");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelSelectThief");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_2_selection.mc_frame_thief_select.text_select_thief");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelSelectThief");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_3_selection.mc_frame_thief_select.text_select_thief");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelSelectThief");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_4_selection.mc_frame_thief_select.text_select_thief");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelSelectThief");
	Title.SetText(TitleString);
}

//----------------------------------------------------------------------------------------------------------
function LocalizeNameEntryFrame()
{
	local GFxObject Title;
	local string TitleString;

	Title = GetVariableObject("_root.mc_player_1_selection.mc_frame_name_entry.text_enter_name");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelEnterName");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_2_selection.mc_frame_name_entry.text_enter_name");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelEnterName");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_3_selection.mc_frame_name_entry.text_enter_name");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelEnterName");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_4_selection.mc_frame_name_entry.text_enter_name");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelEnterName");
	Title.SetText(TitleString);
}

//----------------------------------------------------------------------------------------------------------
function LocalizePlayerReadyFrame()
{
	local GFxObject Title;
	local string TitleString;

	Title = GetVariableObject("_root.mc_player_1_selection.mc_frame_ready.text_player_ready");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelReady");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_2_selection.mc_frame_ready.text_player_ready");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelReady");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_3_selection.mc_frame_ready.text_player_ready");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelReady");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_player_4_selection.mc_frame_ready.text_player_ready");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "menuLabelReady");
	Title.SetText(TitleString);
}



//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	MovieInfo=SwfMovie'ThiefSelectionMenu.ThiefSelectionMenu'
	TimingMode=TM_Real
	Priority=5

	bDisplayWithHudOff=true
	//bPauseGameWhileActive=true

	bAllowFocus=true
	bAllowInput=true
	bCaptureInput=true
	bCaptureMouseInput=true

	PlayerIsReady(0)=false
	PlayerIsReady(1)=false
	PlayerIsReady(2)=false
	PlayerIsReady(3)=false

	SelectedPlayerName(0)="none"
	SelectedPlayerName(1)="none"
	SelectedPlayerName(2)="none"
	SelectedPlayerName(3)="none"

	MainMenuLevelName="SGS-MainMenu.udk";
	OpeningCutsceneMovieName="SSG_Opening_Cutscene";

	localizationSection="SSG_Menu_ThiefSelection"

	SoundThemes(0)=( ThemeName=MenuSounds, Theme=UISoundTheme'SSG_FlashAssets.Sound.SSG_SoundTheme' )
}
