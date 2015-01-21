class SSG_Menu_Thief_Selection_Card extends GFxObject;

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



DefaultProperties
{
}
