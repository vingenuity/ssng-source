class SSG_Menu_Object_Scorecard extends GFxObject;


//----------------------------------------------------------------------------------------------------------
function SetBackgroundColor( int Red, int Green, int Blue )
{
	ActionScriptVoid( "SetBackgroundColor" );
}

//----------------------------------------------------------------------------------------------------------
function SetColorsFromLinearColor( LinearColor LinColor )
{
	local Color BackgroundColor;
	local LinearColor LinBackgroundColor;
	LinBackgroundColor = LinColor;

	BackgroundColor.R = LinBackgroundColor.R * 255;
	BackgroundColor.G = LinBackgroundColor.G * 255;
	BackgroundColor.B = LinBackgroundColor.B * 255;
	SetBackgroundColor( BackgroundColor.R, BackgroundColor.G, BackgroundColor.B );
}

//----------------------------------------------------------------------------------------------------------
function SetStatData( GFxObject StatDataArray )
{
	ActionScriptVoid( "SetStatData" );
}

//----------------------------------------------------------------------------------------------------------
function SetTitleData( GFxObject TitleDataArray )
{
	ActionScriptVoid( "SetTitleData" );
}

//----------------------------------------------------------------------------------------------------------
function SetDeathWinner( bool IsDeathWinner )
{
	ActionScriptVoid( "SetDeathWinner" );
}

//----------------------------------------------------------------------------------------------------------
function SetGoldWinner( bool IsGoldWinner )
{
	ActionScriptVoid( "SetGoldWinner" );
}

//----------------------------------------------------------------------------------------------------------
function SetKillWinner( bool IsKillWinner )
{
	ActionScriptVoid( "SetKillWinner" );
}

//----------------------------------------------------------------------------------------------------------
function SetPlayerName( String PlayerName )
{
	ActionScriptVoid( "SetPlayerName" );
}

//----------------------------------------------------------------------------------------------------------
function SetPlayerPlace( int PlayerPlace )
{
	ActionScriptVoid( "SetPlayerPlace" );
}



DefaultProperties
{
}
