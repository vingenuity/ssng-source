class SSG_HUD_Arrow extends GfxObject
	dependson( HSV_Color );


var float BackgroundToOutlineColorValueOffset;



//----------------------------------------------------------------------------------------------------------
function SetBackgroundColor( int Red, int Green, int Blue )
{
	ActionScriptVoid( "SetBackgroundColor" );
}

//----------------------------------------------------------------------------------------------------------
function SetOutlineColor( int Red, int Green, int Blue )
{
	ActionScriptVoid( "SetOutlineColor" );
}

//----------------------------------------------------------------------------------------------------------
function SetTextColor( int Red, int Green, int Blue )
{
	ActionScriptVoid( "SetTextColor" );
}

//----------------------------------------------------------------------------------------------------------
function SetToOffscreenMode()
{
	ActionScriptVoid( "SetOffscreenMode" );
}

//----------------------------------------------------------------------------------------------------------
function SetToRespawnMode()
{
	ActionScriptVoid( "SetRespawnMode" );
}

//----------------------------------------------------------------------------------------------------------
function SetColorsFromLinearColor( LinearColor LinColor, optional float OutlineValueBoost = 0.0 )
{
	local Color BackgroundColor;
	local Color OutlineColor;
	local HSVColor HSVOutlineColor;
	local HSVColor HSVBackgroundColor;
	local LinearColor LinBackgroundColor;

	HSVOutlineColor = class'HSV_Color'.static.RGBToHSV( LinColor );
	HSVOutlineColor.V += OutlineValueBoost;
	HSVOutlineColor.V = FMin( 1, HSVOutlineColor.V );

	OutlineColor.R = LinColor.R * 255;
	OutlineColor.G = LinColor.G * 255;
	OutlineColor.B = LinColor.B * 255;
	SetOutlineColor( OutlineColor.R, OutlineColor.G, OutlineColor.B );
	SetTextColor( OutlineColor.R, OutlineColor.G, OutlineColor.B );


	HSVBackgroundColor = HSVOutlineColor;
	HSVBackgroundColor.V -= BackgroundToOutlineColorValueOffset;
	HSVBackgroundColor.V = FMax( 0, HSVBackgroundColor.V );
	LinBackgroundColor = class'HSV_Color'.static.HSVToRGB( HSVBackgroundColor );

	BackgroundColor.R = LinBackgroundColor.R * 255;
	BackgroundColor.G = LinBackgroundColor.G * 255;
	BackgroundColor.B = LinBackgroundColor.B * 255;
	SetBackgroundColor( BackgroundColor.R, BackgroundColor.G, BackgroundColor.B );
}

//----------------------------------------------------------------------------------------------------------
function SetRotation( float RotationDegrees )
{
	ActionScriptVoid( "SetRotation" );
}

//----------------------------------------------------------------------------------------------------------
function SetTimeText( String NewText )
{
	ActionScriptVoid( "SetText" );
}

DefaultProperties
{
	BackgroundToOutlineColorValueOffset = 0.4
}
