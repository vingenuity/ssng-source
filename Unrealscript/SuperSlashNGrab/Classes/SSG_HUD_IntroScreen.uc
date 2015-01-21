class SSG_HUD_IntroScreen extends GFxMoviePlayer;

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
	AddFocusIgnoreKey( 'Escape' );
}

//----------------------------------------------------------------------------------------------------------
function CloseIntroMovie()
{
	Close( true );
}

//----------------------------------------------------------------------------------------------------------
function TickHUD()
{
}

DefaultProperties
{
	MovieInfo=SwfMovie'IntroScreen.IntroScreen'
	TimingMode=TM_Real
	Priority=5

	bBlurLesserMovies=true

	bDisplayWithHudOff=true
	bPauseGameWhileActive=true

	bAllowFocus=true
	bAllowInput=true
	bCaptureInput=true
	bCaptureMouseInput=true
}