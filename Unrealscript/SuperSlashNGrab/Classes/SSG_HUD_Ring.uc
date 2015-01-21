class SSG_HUD_Ring extends GfxObject
	dependson( HSV_Color );


var float EmptyToFilledColorValueOffset;
var float BackgroundToFilledColorValueOffset;



//----------------------------------------------------------------------------------------------------------
function Hide()
{
	ActionScriptVoid( "Hide" );
}

//----------------------------------------------------------------------------------------------------------
function Show()
{
	ActionScriptVoid( "Show" );
}

//----------------------------------------------------------------------------------------------------------
function HideName()
{
	ActionScriptVoid( "HideNameDisplay" );
}

//----------------------------------------------------------------------------------------------------------
function ShowName()
{
	ActionScriptVoid( "ShowNameDisplay" );
}

//----------------------------------------------------------------------------------------------------------
function HideFacingArrow()
{
	ActionScriptVoid( "HideFacingArrow" );
}

//----------------------------------------------------------------------------------------------------------
function ShowFacingArrow()
{
	ActionScriptVoid( "ShowFacingArrow" );
}

//----------------------------------------------------------------------------------------------------------
function HideHealth()
{
	ActionScriptVoid( "HideRings" );
}

//----------------------------------------------------------------------------------------------------------
function ShowHealth()
{
	ActionScriptVoid( "ShowRings" );
}

//----------------------------------------------------------------------------------------------------------
function HideTreasure()
{
	ActionScriptVoid( "HideTreasureDisplay" );
}

//----------------------------------------------------------------------------------------------------------
function ShowTreasure()
{
	ActionScriptVoid( "ShowTreasureDisplay" );
}

//----------------------------------------------------------------------------------------------------------
function ReleaseCrossbowPopup( String TreasureText, int Red, int Green, int Blue )
{
	ActionScriptVoid( "ReleaseCrossbowPopup" );
}

//----------------------------------------------------------------------------------------------------------
function ReleaseHealthPopup( String Text, int Red, int Green, int Blue )
{
	ActionScriptVoid( "ReleaseHealthPopup" );
}

//----------------------------------------------------------------------------------------------------------
function ReleaseMedalPopup()
{
	ActionScriptVoid( "ReleaseMedalPopup" );
}

//----------------------------------------------------------------------------------------------------------
function ReleaseShieldPopup( String Text, int Red, int Green, int Blue )
{
	ActionScriptVoid( "ReleaseShieldPopup" );
}

//----------------------------------------------------------------------------------------------------------
function ReleaseTreasurePopup( String TreasureText, int Red, int Green, int Blue )
{
	ActionScriptVoid( "ReleaseTreasurePopup" );
}

//----------------------------------------------------------------------------------------------------------
function SetFacingArrowRotation( float RotationDegrees )
{
	ActionScriptVoid( "SetRingArrowRotation" );
}

//----------------------------------------------------------------------------------------------------------
function SetHealthLevel( int HealthLevel )
{
	ActionScriptVoid( "SetFillLevel" );
}

//----------------------------------------------------------------------------------------------------------
function SetName( String newName )
{
	ActionScriptVoid( "SetNameText" );
}

//----------------------------------------------------------------------------------------------------------
function SetTreasure( String newTreasure )
{
	ActionScriptVoid( "SetTreasureText" );
}

//----------------------------------------------------------------------------------------------------------
function SetEmptyColor( int Red, int Green, int Blue )
{
	ActionScriptVoid( "SetEmptyFillColor" );
}

//----------------------------------------------------------------------------------------------------------
function SetFilledColor( int Red, int Green, int Blue )
{
	ActionScriptVoid( "SetFullFillColor" );
}

//----------------------------------------------------------------------------------------------------------
function SetBackgroundColor( int Red, int Green, int Blue )
{
	ActionScriptVoid( "SetBackgroundColor" );
}

//----------------------------------------------------------------------------------------------------------
function SetTextColor( int Red, int Green, int Blue )
{
	ActionScriptVoid( "SetTextColor" );
}

//----------------------------------------------------------------------------------------------------------
function SetColorsFromLinearColor( LinearColor PlayerColor, optional float FilledValueBoost = 0.0 )
{
	local Color EmptyColor;
	local Color FillColor;
	local Color BackgroundColor;
	local HSVColor HSVEmptyColor;
	local HSVColor HSVFillColor;
	local HSVColor HSVBackgroundColor;
	local LinearColor LinearEmptyColor;
	local LinearColor LinearBackgroundColor;

	HSVFillColor = class'HSV_Color'.static.RGBToHSV( PlayerColor );
	HSVFillColor.V += FilledValueBoost;
	HSVFillColor.V = FMin( 1, HSVFillColor.V );

	FillColor.R = PlayerColor.R * 255;
	FillColor.G = PlayerColor.G * 255;
	FillColor.B = PlayerColor.B * 255;
	FillColor.A = 255;
	SetFilledColor( FillColor.R, FillColor.G, FillColor.B );
	//SetTextColor( FillColor.R, FillColor.G, FillColor.B );


	HSVEmptyColor = HSVFillColor;
	HSVEmptyColor.V -= EmptyToFilledColorValueOffset;
	HSVEmptyColor.V = FMax( 0, HSVEmptyColor.V );
	LinearEmptyColor = class'HSV_Color'.static.HSVToRGB( HSVEmptyColor );

	EmptyColor.R = LinearEmptyColor.R * 255;
	EmptyColor.G = LinearEmptyColor.G * 255;
	EmptyColor.B = LinearEmptyColor.B * 255;
	SetEmptyColor( EmptyColor.R, EmptyColor.G, EmptyColor.B );


	HSVBackgroundColor = HSVFillColor;
	HSVBackgroundColor.V -= BackgroundToFilledColorValueOffset;
	HSVBackgroundColor.V = FMax( 0, HSVBackgroundColor.V );
	LinearBackgroundColor = class'HSV_Color'.static.HSVToRGB( HSVBackgroundColor );

	BackgroundColor.R = LinearBackgroundColor.R * 255;
	BackgroundColor.G = LinearBackgroundColor.G * 255;
	BackgroundColor.B = LinearBackgroundColor.B * 255;
	SetBackgroundColor( BackgroundColor.R, BackgroundColor.G, BackgroundColor.B );
}



//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	EmptyToFilledColorValueOffset = 0.3
	BackgroundToFilledColorValueOffset = 0.4
}