class SSG_Menu_Loading extends GfxMoviePlayer
    dependson(Text_Localizer);

//Localization
var string LocalizationSection;
const NUMBER_OF_THIEVES_CODE_RULES = 26;
var bool LocalizedRuleText;
var bool HasLoaded;

//Important Clips
var GFxObject LoadingTextClip;
var GFxObject PressAClip;


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
	Advance( 0.f );

	SetViewScaleMode( SM_ExactFit );
	SetAlignment( Align_Center );
	SetExternalInterface( GetPC().myHUD );
}

//----------------------------------------------------------------------------------------------------------
event bool WidgetInitialized( name WidgetName, name WidgetPath, GFxObject Widget )
{
	local string LocalizedString;
	local int RandomRuleNumber;

    switch( WidgetName )
    {
    case( 'mc_loading' ):
    	LoadingTextClip = Widget;
		LocalizedString = class'Text_Localizer'.static.GetLocalizedStringWithName( LocalizationSection, "loadingText" );
	    LoadingTextClip.GetObject( "text_loading" ).SetString( "text", LocalizedString );

	    if( HasLoaded )
			ActionScriptVoid( "_root.ListenForButtonPresses" );
    	break;
    case( 'mc_press_a_start' ):
    	PressAClip = Widget;
		LocalizedString = class'Text_Localizer'.static.GetLocalizedStringWithName( LocalizationSection, "pressText" );
	    PressAClip.GetObject( "text_press" ).SetString( "text", LocalizedString );
		LocalizedString = class'Text_Localizer'.static.GetLocalizedStringWithName( LocalizationSection, "toStartText" );
	    PressAClip.GetObject( "text_to_start" ).SetString( "text", LocalizedString );
    	break;
	case ( 'mc_text_code' ):
		if( LocalizedRuleText )
			break;
		RandomRuleNumber = Rand( NUMBER_OF_THIEVES_CODE_RULES );
		LocalizedString = class'Text_Localizer'.static.GetLocalizedStringWithName( LocalizationSection, "thievesCodeText" $ RandomRuleNumber );
	    Widget.GetObject( "text_thieves_code" ).SetString( "text", LocalizedString );
	    LocalizedRuleText = true;
	    break;
    default:
        break;
    }
	return true;
}


//----------------------------------------------------------------------------------------------------------
function TickHUD()
{
}


//----------------------------------------------------------------------------------------------------------
function CloseLoading()
{
	Close( true );
}

//----------------------------------------------------------------------------------------------------------
function ShowLoaded()
{
	LoadingTextClip.SetVisible( false );
	PressAClip.SetFloat( "alpha", 1.0 );
	HasLoaded = true;
}

//----------------------------------------------------------------------------------------------------------
function SetLoadingText( int TextNumber )
{
	local string LocalizedString;
	local GFxObject ThievesText;

	LocalizedString = class'Text_Localizer'.static.GetLocalizedStringWithName( LocalizationSection, "thievesCodeText" $ TextNumber );
	ThievesText = GetVariableObject( "_root.mc_text_code.text_thieves_code" );

	if( ThievesText == None )
		`log( "SHIIIIT" );
	ThievesText.SetString( "text", LocalizedString );
}

DefaultProperties
{
	MovieInfo=SwfMovie'LoadingScreen.LoadingScreen'
	TimingMode=TM_Real
	Priority=5

	bBlurLesserMovies=true

	bDisplayWithHudOff=true

	bAllowFocus=true
	bAllowInput=true
	bCaptureInput=true
	bCaptureMouseInput=true

	LocalizationSection="SSG_Menu_Loading"
	LocalizedRuleText=false
	HasLoaded=false

    WidgetBindings(0)={ ( WidgetName="mc_text_code", WidgetClass=class'GFxClikWidget' ) }
    WidgetBindings(1)={ ( WidgetName="mc_loading", WidgetClass=class'GFxClikWidget' ) }
    WidgetBindings(2)={ ( WidgetName="mc_press_a_start", WidgetClass=class'GFxClikWidget' ) }

	SoundThemes(0)=( ThemeName=MenuSounds, Theme=UISoundTheme'SSG_FlashAssets.Sound.SSG_SoundTheme' )
}
