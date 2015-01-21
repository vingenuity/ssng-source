class SSG_Menu_Pause extends GfxMoviePlayer
    config(SystemSettings);

var SSG_Menu_Pause_Object menuRoot;
var int PausingPlayerID;

var array< String > SupportedResolutions;
var globalconfig int ResX;
var globalconfig int ResY;
var globalconfig bool Fullscreen;

//Localization Files
var string LocalizationSection;
var string OptionsLocalizationSection;

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
	Start( false );
	Advance(0.f);

	SetViewScaleMode( SM_ExactFit );
	SetAlignment( Align_Center );
	SetExternalInterface( GetPC().myHUD );

	menuRoot = SSG_Menu_Pause_Object( GetVariableObject( "_root.mc_menu", class'SSG_Menu_Pause_Object' ) );

	LocalizePauseMenu();
}

//----------------------------------------------------------------------------------------------------------
function TickHUD()
{
}

//----------------------------------------------------------------------------------------------------------
function LocalizePauseMenu()
{
	local GFxObject Button;
	local string ButtonString;
	local string PlayerLocalized;
	local string PausedLocalized;

	PlayerLocalized = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "pauseTitlePlayer");
	PausedLocalized = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "pauseTitlePaused");

	menuRoot.SetTitleText( PlayerLocalized $ (PausingPlayerID + 1) $ PausedLocalized );
	menuRoot.SetTextColorFromLinearColor( class'SSG_PlayerController'.default.PlayerColors[ PausingPlayerID ] );

	Button = GetVariableObject("_root.mc_menu.mc_button_frame.mc_button_resume");
	ButtonString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "pauseButtonResume");
	Button.SetString("label", ButtonString);

	Button = GetVariableObject("_root.mc_menu.mc_button_frame.mc_button_map");
	ButtonString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "pauseButtonMap");
	Button.SetString("label", ButtonString);

	Button = GetVariableObject("_root.mc_menu.mc_button_frame.mc_button_main_menu");
	ButtonString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "pauseButtonMainMenu");
	Button.SetString("label", ButtonString);

	Button = GetVariableObject("_root.mc_menu.mc_button_frame.mc_button_quit");
	ButtonString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "pauseButtonQuit");
	Button.SetString("label", ButtonString);
}

//----------------------------------------------------------------------------------------------------------
function EnterOptionsMenu()
{
	SetExternalInterface( self );
}

//----------------------------------------------------------------------------------------------------------
function LeaveOptionsMenu()
{
	SetExternalInterface( GetPC().myHUD );
}

//----------------------------------------------------------------------------------------------------------
function SetPausingPlayer( int PlayerID )
{
	PausingPlayerID = PlayerID;
	menuRoot.SetPausingPlayerID( PlayerID );
	LocalizePauseMenu();
}

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

//+++++++++++++++++++++++++++++++++++++++++++ Helper Functions +++++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function GetCurrentResolutionAndFullscreenSettings()
{
	local PlayerController PC;
	local Vector2D CurrentScreenResolution;

	PC = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController();

	LocalPlayer( PC.Player ).ViewportClient.GetViewportSize( CurrentScreenResolution );
	ResX = CurrentScreenResolution.X;
	ResY = CurrentScreenResolution.Y;
	
	Fullscreen = LocalPlayer(PC.Player).ViewportClient.IsFullScreenViewport();
}

//----------------------------------------------------------------------------------------------------------
function string GetCurrentResolutionAsString()
{
	local String CurrentResolutionAsString;

	GetCurrentResolutionAndFullscreenSettings();
	CurrentResolutionAsString = ResX $ "x" $ ResY;
	//`log( "Current Resolution: " $ CurrentResolutionAsString );

	return CurrentResolutionAsString;
}

//----------------------------------------------------------------------------------------------------------
//This wondrous piece of code is from: https://forums.epicgames.com/threads/921361-How-to-get-available-display-resolutions-without-dllbind
function array<String> GetSupportedResolutions()
{
	//local int i;
	local string ResolutionsAsSingleString;
	local array<string> ResolutionStrings;

	ResolutionsAsSingleString = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().ConsoleCommand( "DUMPAVAILABLERESOLUTIONS", false );
	ParseStringIntoArray( ResolutionsAsSingleString, ResolutionStrings, "\n", true );
	// for( i = 0; i < ResolutionStrings.Length; ++i )
	// {
	// 	`log( "Found" @ ResolutionStrings[i] );
	// }
	return ResolutionStrings;
}

//----------------------------------------------------------------------------------------------------------
function SendConsoleCommand( string command ) 
{
	//`log( "CONSOLE COMMAND: " $ command );
	ConsoleCommand( command );
}

//----------------------------------------------------------------------------------------------------------
//This function thanks to: http://eliotvu.com/news/view/38/reading-and-writing-the-gamma-display-setting-in-udk
function SetGamma( float newGamma )
{
    // Change Run-Time Gamma
    ConsoleCommand( "Gamma" @ newGamma );
    
    // Change Save-Time Gamma
    class'Client'.default.DisplayGamma = newGamma;
    class'Client'.static.StaticSaveConfig();
}


//----------------------------------------------------------------------------------------------------------
function SetResolution( string resolution, bool isFullscreen )
{
    local string screenMode;

    if( isFullscreen )
        screenMode = "f";
    else
        screenMode = "w";

    //`log( "Setting Resolution to: " $ resolution );
    SendConsoleCommand( "setres " $ resolution $ screenMode );
}



//+++++++++++++++++++++++++++++++++ External Interfaces I: Unreal->Flash +++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function SetVideoSettingsFromUnrealSettings()
{
	local GFxObject ResolutionProvider;
	local GFxObject ResolutionStepper;
	local GFxObject GraphicsLevelStepper;
	local GFxObject FullscreenCheckbox;
	local GFxObject GammaSlider;

	//Get needed scaleform objects
	ResolutionStepper = GetVariableObject( "_root.mc_menu.options_popup.mc_options_video_frame.mc_resolution_stepper" );
	GraphicsLevelStepper = GetVariableObject( "_root.mc_menu.options_popup.mc_options_video_frame.mc_graphics_level_stepper" );
	FullscreenCheckbox = GetVariableObject( "_root.mc_menu.options_popup.mc_options_video_frame.mc_checkbox_fullscreen" );
	GammaSlider = GetVariableObject( "_root.mc_menu.options_popup.mc_options_video_frame.mc_slider_gamma" );

	//Set available resolutions
	SupportedResolutions = GetSupportedResolutions();
	ResolutionProvider = ConvertStringArrayIntoDataProvider( SupportedResolutions );
	ResolutionStepper.SetObject( "dataProvider", ResolutionProvider );

	//Set our current resolution
	ResolutionStepper.SetInt( "selectedIndex", FindIndexOfStringInArray( SupportedResolutions, GetCurrentResolutionAsString() ) );

	//Set our current graphics level
	GraphicsLevelStepper.SetInt( "selectedIndex", class'SSG_PlayerController'.default.GraphicsLevelIndex );

	//Set our fullscreen setting
	FullscreenCheckbox.SetBool( "selected", Fullscreen );

	//Set our gamma setting
    GammaSlider.SetFloat( "value", class'Client'.default.DisplayGamma );
}

//----------------------------------------------------------------------------------------------------------
function SetAudioSettingsFromUnrealSettings()
{
	local GFxObject MusicVolumeSlider;
	local GFxObject SoundVolumeSlider;
	local GFxObject VoiceVolumeSlider;

	//Get needed scaleform objects
	MusicVolumeSlider = GetVariableObject( "_root.mc_menu.options_popup.mc_options_audio_frame.mc_slider_volume_music" );
	SoundVolumeSlider = GetVariableObject( "_root.mc_menu.options_popup.mc_options_audio_frame.mc_slider_volume_sound" );
	VoiceVolumeSlider = GetVariableObject( "_root.mc_menu.options_popup.mc_options_audio_frame.mc_slider_volume_voice" );

	//Set volume sliders to our settings
	MusicVolumeSlider.SetFloat( "value", class'SSG_PlayerController'.default.MusicGroupVolume );
	SoundVolumeSlider.SetFloat( "value", class'SSG_PlayerController'.default.SoundGroupVolume );
	VoiceVolumeSlider.SetFloat( "value", class'SSG_PlayerController'.default.VoiceGroupVolume );
}

//----------------------------------------------------------------------------------------------------------
function SetGameplaySettingsFromUnrealSettings()
{
	local array< string > SupportedLanguages;
	local GFxObject LanguageProvider;
	local GFxObject LanguageStepper;
	local GFxObject RumbleCheckbox;

	//Get needed scaleform objects
	LanguageStepper = GetVariableObject( "_root.mc_menu.options_popup.mc_options_game_frame.mc_language_stepper" );
	RumbleCheckbox = GetVariableObject( "_root.mc_menu.options_popup.mc_options_game_frame.mc_checkbox_rumble" );

	//Set available resolutions
	SupportedLanguages = class'Text_Localizer'.static.GetSupportedLanguages();
	LanguageProvider = ConvertStringArrayIntoDataProvider( SupportedLanguages );
	LanguageStepper.SetObject( "dataProvider", LanguageProvider );

	//Set our current resolution
	LanguageStepper.SetInt( "selectedIndex", FindIndexOfStringInArray( SupportedLanguages, class'Text_Localizer'.static.GetCurrentLocalizationName() ) );

	//Set rumble checkbox state
	RumbleCheckbox.SetBool( "selected", class'SSG_PlayerController'.default.RumbleOn );
}



//++++++++++++++++++++++++++++++++ External Interfaces II: Flash->Unreal +++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function SetUnrealSettingsFromVideoSettings()
{
	local GFxObject ResolutionStepper;
	local GFxObject GraphicsLevelStepper;
	local GFxObject FullscreenCheckbox;
	local GFxObject GammaSlider;

	local string SelectedResolution;
	local int xLocation;
	local int SelectedXResolution, SelectedYResolution;
	local int SelectedGraphicsLevelIndex;
	local bool SelectedFullscreenSetting;
	local float SelectedGammaSetting;


	//Get needed scaleform objects
	ResolutionStepper = GetVariableObject( "_root.mc_menu.options_popup.mc_options_video_frame.mc_resolution_stepper" );
	GraphicsLevelStepper = GetVariableObject( "_root.mc_menu.options_popup.mc_options_video_frame.mc_graphics_level_stepper" );
	FullscreenCheckbox = GetVariableObject( "_root.mc_menu.options_popup.mc_options_video_frame.mc_checkbox_fullscreen" );
	GammaSlider = GetVariableObject( "_root.mc_menu.options_popup.mc_options_video_frame.mc_slider_gamma" );


	//Set selected resolution and fullscreen setting
	SelectedResolution = SupportedResolutions[ ResolutionStepper.GetInt( "selectedIndex" ) ];
    xLocation = InStr( SelectedResolution, "x" );
    SelectedXResolution = int( Mid( SelectedResolution, 0, xLocation ) );
    SelectedYResolution = int( Mid( SelectedResolution, xLocation + 1 ) );

	SelectedGraphicsLevelIndex = GraphicsLevelStepper.GetInt( "selectedIndex" );

	SelectedFullscreenSetting = FullscreenCheckbox.GetBool( "selected" );

	if( SelectedXResolution != ResX || SelectedYResolution != ResY || SelectedFullscreenSetting != Fullscreen )
    {
        //`log( SelectedXResolution @ SelectedYResolution );
        ResX = SelectedXResolution;
        ResY = SelectedYResolution;
        Fullscreen = SelectedFullscreenSetting;
        SaveConfig();

        SetResolution( SelectedResolution, SelectedFullscreenSetting );
    }

	if( SelectedGraphicsLevelIndex != class'SSG_PlayerController'.default.GraphicsLevelIndex )
	{
		class'SSG_PlayerController'.static.SetGraphicsLevel( SelectedGraphicsLevelIndex );
		SendConsoleCommand( "scale bucket bucket" $ ( SelectedGraphicsLevelIndex + 1 ) );
	}

	//Set our gamma setting
    SelectedGammaSetting = GammaSlider.GetFloat( "value" );
    SetGamma( SelectedGammaSetting );
}

//----------------------------------------------------------------------------------------------------------
function SetUnrealSettingsFromAudioSettings()
{
	local GFxObject MusicVolumeSlider;
	local GFxObject SoundVolumeSlider;
	local GFxObject VoiceVolumeSlider;
	local PlayerController PC;

	//Get needed scaleform objects
	MusicVolumeSlider = GetVariableObject( "_root.mc_menu.options_popup.mc_options_audio_frame.mc_slider_volume_music" );
	SoundVolumeSlider = GetVariableObject( "_root.mc_menu.options_popup.mc_options_audio_frame.mc_slider_volume_sound" );
	VoiceVolumeSlider = GetVariableObject( "_root.mc_menu.options_popup.mc_options_audio_frame.mc_slider_volume_voice" );

	//Set player controller's sound groups to the sliders
	class'SSG_PlayerController'.static.SetMusicGroupVolume( MusicVolumeSlider.GetFloat( "value" ) );
	class'SSG_PlayerController'.static.SetSoundGroupVolume( SoundVolumeSlider.GetFloat( "value" ) );
	class'SSG_PlayerController'.static.SetVoiceGroupVolume( VoiceVolumeSlider.GetFloat( "value" ) );

	PC = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController();
	PC.SetAudioGroupVolume( 'Music', MusicVolumeSlider.GetFloat( "value" ) * 0.01 );
	PC.SetAudioGroupVolume( 'SFX', SoundVolumeSlider.GetFloat( "value" ) * 0.01 );
	PC.SetAudioGroupVolume( 'Voice', VoiceVolumeSlider.GetFloat( "value" ) * 0.01 );
}

//----------------------------------------------------------------------------------------------------------
function SetUnrealSettingsFromGameplaySettings()
{
	local GFxObject LanguageStepper;
	local GFxObject RumbleCheckbox;
	local bool SelectedRumbleSettings;
	local SSG_Mesh_LocalizedText CurrentLocalizedText;

	//Get needed scaleform objects
	LanguageStepper = GetVariableObject( "_root.mc_menu.options_popup.mc_options_game_frame.mc_language_stepper" );
	RumbleCheckbox = GetVariableObject( "_root.mc_options_game_frame.mc_checkbox_rumble" );

	//Set our current language from the flash stepper
	class'Text_Localizer'.static.SetLocalizationLanguage( Language( LanguageStepper.GetInt( "selectedIndex" ) ) );

	//Set rumble to be on or off (for all controllers)
	SelectedRumbleSettings = RumbleCheckbox.GetBool( "selected" );
	if( SelectedRumbleSettings != class'SSG_PlayerController'.default.RumbleOn )
	{
		class'SSG_PlayerController'.static.SetRumble( SelectedRumbleSettings );
	}
	
	//Update all localized materials
	foreach class'WorldInfo'.static.GetWorldInfo().allActors(class'SSG_Mesh_LocalizedText', CurrentLocalizedText)
	{
		CurrentLocalizedText.UpdateLocalization();
	}

}

//----------------------------------------------------------------------------------------------------------
function SetMusicGroupVolume( float NewVolume )
{
	local PlayerController PC;
	PC = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController();
	//`log( "Setting Music Volume to: " $ NewVolume );
	class'SSG_PlayerController'.static.SetMusicGroupVolume( NewVolume );
	PC.SetAudioGroupVolume( 'Music', NewVolume * 0.01 );
}

//----------------------------------------------------------------------------------------------------------
function SetSoundGroupVolume( float NewVolume )
{
	local PlayerController PC;
	PC = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController();
	class'SSG_PlayerController'.static.SetSoundGroupVolume( NewVolume );
	PC.SetAudioGroupVolume( 'SFX', NewVolume * 0.01 );
}

//----------------------------------------------------------------------------------------------------------
function SetVoiceGroupVolume( float NewVolume )
{
	local PlayerController PC;
	PC = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController();
	class'SSG_PlayerController'.static.SetVoiceGroupVolume( NewVolume );
	PC.SetAudioGroupVolume( 'Voice', NewVolume * 0.01 );
}



//+++++++++++++++++++++++++++++++++++++++++++ Frame Localization +++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function LocalizeTopOptions()
{
	local GFxObject Title;
	local string TitleString;
	local GFxObject Button;
	local string ButtonString;

	Title = GetVariableObject("_root.mc_menu.options_popup.mc_options_frame.text_title");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuTitleOptions");
	Title.SetText(TitleString);

	Button = GetVariableObject("_root.mc_menu.options_popup.mc_options_frame.button_options_video");
	ButtonString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuButtonOptionsVideo");
	Button.SetString("label", ButtonString);

	Button = GetVariableObject("_root.mc_menu.options_popup.mc_options_frame.button_options_audio");
	ButtonString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuButtonOptionsAudio");
	Button.SetString("label", ButtonString);

	Button = GetVariableObject("_root.mc_menu.options_popup.mc_options_frame.button_options_gameplay");
	ButtonString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuButtonOptionsGameplay");
	Button.SetString("label", ButtonString);

	Button = GetVariableObject("_root.mc_menu.options_popup.mc_options_frame.button_back_main_menu");
	ButtonString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuButtonBackMainMenu");
	Button.SetString("label", ButtonString);
}

//----------------------------------------------------------------------------------------------------------
function LocalizeVideoOptions()
{
	local GFxObject Title;
	local string TitleString;
	local GFxObject Button;
	local string ButtonString;
	local GFxObject Stepper;
	local GFxObject StepperProvider;
	local array<string> StepperStringArray;

	Title = GetVariableObject("_root.mc_menu.options_popup.mc_options_video_frame.text_title");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuTitleVideoOptions");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_menu.options_popup.mc_options_video_frame.text_resolution");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuLabelVideoSettingResolution");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_menu.options_popup.mc_options_video_frame.text_graphics_level");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuLabelVideoSettingGraphicsLevel");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_menu.options_popup.mc_options_video_frame.text_fullscreen");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuLabelVideoSettingFullscreen");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_menu.options_popup.mc_options_video_frame.text_gamma");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuLabelVideoSettingGamma");
	Title.SetText(TitleString);

	Button = GetVariableObject("_root.mc_menu.options_popup.mc_options_video_frame.button_cancel");
	ButtonString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuButtonCancel");
	Button.SetString("label", ButtonString);

	Button = GetVariableObject("_root.mc_menu.options_popup.mc_options_video_frame.button_accept");
	ButtonString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuButtonAccept");
	Button.SetString("label", ButtonString);

	Stepper = GetVariableObject("_root.mc_menu.options_popup.mc_options_video_frame.mc_graphics_level_stepper");
	StepperStringArray.AddItem( class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuStepperGraphicsLevel0") );
	StepperStringArray.AddItem( class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuStepperGraphicsLevel1") );
	StepperStringArray.AddItem( class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuStepperGraphicsLevel2") );
	StepperStringArray.AddItem( class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuStepperGraphicsLevel3") );
	StepperStringArray.AddItem( class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuStepperGraphicsLevel4") );
	StepperProvider = ConvertStringArrayIntoDataProvider( StepperStringArray );
	Stepper.SetObject( "dataProvider", StepperProvider );
}

//----------------------------------------------------------------------------------------------------------
function LocalizeAudioOptions()
{
	local GFxObject Title;
	local string TitleString;
	local GFxObject Button;
	local string ButtonString;

	Title = GetVariableObject("_root.mc_menu.options_popup.mc_options_audio_frame.text_title");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuTitleAudioOptions");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_menu.options_popup.mc_options_audio_frame.text_volume_music");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuLabelAudioVolumeMusic");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_menu.options_popup.mc_options_audio_frame.text_volume_sound");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuLabelAudioVolumeSound");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_menu.options_popup.mc_options_audio_frame.text_volume_voice");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuLabelAudioVolumeVoice");
	Title.SetText(TitleString);

	Button = GetVariableObject("_root.mc_menu.options_popup.mc_options_audio_frame.button_cancel");
	ButtonString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuButtonCancel");
	Button.SetString("label", ButtonString);

	Button = GetVariableObject("_root.mc_menu.options_popup.mc_options_audio_frame.button_accept");
	ButtonString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuButtonAccept");
	Button.SetString("label", ButtonString);
}

//----------------------------------------------------------------------------------------------------------
function LocalizeGameplayOptions()
{
	local GFxObject Title;
	local string TitleString;
	local GFxObject Button;
	local string ButtonString;

	Title = GetVariableObject("_root.mc_menu.options_popup.mc_options_game_frame.text_title");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuTitleGameOptions");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_menu.options_popup.mc_options_game_frame.text_language");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuLabelGameLanguage");
	Title.SetText(TitleString);

	Title = GetVariableObject("_root.mc_menu.options_popup.mc_options_game_frame.text_rumble");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuLabelGameRumble");
	Title.SetText(TitleString);

	Button = GetVariableObject("_root.mc_menu.options_popup.mc_options_game_frame.button_cancel");
	ButtonString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuButtonCancel");
	Button.SetString("label", ButtonString);

	Button = GetVariableObject("_root.mc_menu.options_popup.mc_options_game_frame.button_accept");
	ButtonString = class'Text_Localizer'.static.GetLocalizedStringWithName(OptionsLocalizationSection, "menuButtonAccept");
	Button.SetString("label", ButtonString);
}



DefaultProperties
{
	MovieInfo=SwfMovie'PauseMenu.PauseMenu'
	TimingMode=TM_Real
	Priority=5

	bBlurLesserMovies=true
	PausingPlayerID=0

	bDisplayWithHudOff=true
	bPauseGameWhileActive=true

	bAllowFocus=true
	bAllowInput=true
	bCaptureInput=true
	bCaptureMouseInput=true

	LocalizationSection="SSG_Menu_Pause"
	OptionsLocalizationSection="SSG_Options_Menu"

	SoundThemes(0)=( ThemeName=MenuSounds, Theme=UISoundTheme'SSG_FlashAssets.Sound.SSG_SoundTheme' )
}
