class SSG_Menu_Pause_Object extends GfxObject;


//----------------------------------------------------------------------------------------------------------
function SetTitleText( String title )
{
	ActionScriptVoid( "SetTitleText" );
}

//----------------------------------------------------------------------------------------------------------
function SetResumeText( String title )
{
	ActionScriptVoid( "SetResumeText" );
}

//----------------------------------------------------------------------------------------------------------
function SetReturnText( String title )
{
	ActionScriptVoid( "SetReturnText" );
}

//----------------------------------------------------------------------------------------------------------
function SetQuitText( String title )
{
	ActionScriptVoid( "SetQuitText" );
}

//----------------------------------------------------------------------------------------------------------
function SetPausingPlayerID( int PlayerID )
{
	ActionScriptVoid( "SetPausingPlayerID" );
}

//----------------------------------------------------------------------------------------------------------
function SetTitleTextColor( int red, int green, int blue )
{
	ActionScriptVoid( "SetTextColor" );
}

//----------------------------------------------------------------------------------------------------------
function SetTextColorFromLinearColor( LinearColor LinColor )
{
	local Color TextColor;

	TextColor.R = LinColor.R * 255;
	TextColor.G = LinColor.G * 255;
	TextColor.B = LinColor.B * 255;
	SetTitleTextColor( TextColor.R, TextColor.G, TextColor.B );
}


DefaultProperties
{
}
