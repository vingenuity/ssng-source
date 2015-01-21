class SSG_Cutscene_Opening extends GfxMoviePlayer;

var class<SSG_Message_Cutscene_Opening> MessageClass;
var string NextLevelName;
var SSG_Cutscene_Subtitle_Object Subtitle;
var string LocalizationSection;


//++++++++++++++++++++++++++++++++++++++++++ Lifecycle Functions +++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function bool Start( optional bool StartPaused = false )
{
	super.Start();

	SetViewScaleMode(SM_ExactFit);
	SetAlignment(Align_TopLeft);
	
	return true;
}

//----------------------------------------------------------------------------------------------------------
function Init( optional LocalPlayer playerController )
{
	Start();
	Advance(0.f);

	SetViewScaleMode(SM_ExactFit);
	SetAlignment(Align_TopLeft);

	Subtitle = SSG_Cutscene_Subtitle_Object( GetVariableObject( "_root.mc_subtitle", class'SSG_Cutscene_Subtitle_Object' ) );
}

//----------------------------------------------------------------------------------------------------------
function LocalizeSkipFrame()
{
	local GFxObject SkipFrameText;
	local string SkipFrameTextString;

	SkipFrameText = GetVariableObject("_root.mc_skip_clip.text_press");
	SkipFrameTextString = class'Text_Localizer'.static.GetLocalizedStringWithName(LocalizationSection, "cutsceneClipPress");
	SkipFrameText.SetText(SkipFrameTextString);

	SkipFrameText = GetVariableObject("_root.mc_skip_clip.text_to_skip");
	SkipFrameTextString = class'Text_Localizer'.static.GetLocalizedStringWithName(LocalizationSection, "cutsceneClipToSkip");
	SkipFrameText.SetText(SkipFrameTextString);
}

//----------------------------------------------------------------------------------------------------------
function PlayCutsceneMessage( int MessageNumber )
{
	SSG_PlayerController( GetPC() ).Announcer.PlayAnnouncement( MessageClass, MessageNumber );
	Subtitle = SSG_Cutscene_Subtitle_Object( GetVariableObject( "_root.mc_subtitle", class'SSG_Cutscene_Subtitle_Object' ) );
	Subtitle.Show( MessageClass.static.GetString( MessageNumber ), MessageClass.static.GetSubtitleLengthSeconds( MessageNumber ) );
}


//----------------------------------------------------------------------------------------------------------
function EndCutscene()
{
	SetPause( true );
	ConsoleCommand( "open " $ NextLevelName );
}



//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	MovieInfo=SwfMovie'SSG_Opening_Cutscene.SSG_Opening_Cutscene'
	TimingMode=TM_Real
	Priority=10

	bBlurLesserMovies=true

	bDisplayWithHudOff=true
	bPauseGameWhileActive=false

	bAllowFocus=true
	bAllowInput=true
	bCaptureInput=true
	bCaptureMouseInput=true

	LocalizationSection="SSG_Cutscene"
	MessageClass=class'SSG_Message_Cutscene_Opening'
	NextLevelName="SGS-MapMenu.udk";

	//SoundThemes(0)=( ThemeName=MenuSounds, Theme=UISoundTheme'SSG_FlashAssets.Sound.SSG_SoundTheme' )
}