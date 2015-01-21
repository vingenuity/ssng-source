class SSG_HUD_Edge extends GfxObject;



//----------------------------------------------------------------------------------------------------------
function SetBackgroundColor( int Red, int Green, int Blue )
{
	ActionScriptVoid( "SetBackgroundColor" );
}

//----------------------------------------------------------------------------------------------------------
function SetNameTextColor( int Red, int Green, int Blue )
{
	ActionScriptVoid( "SetNameTextColor" );
}

//----------------------------------------------------------------------------------------------------------
function SetOutlineColor( int Red, int Green, int Blue )
{
	ActionScriptVoid( "SetOutlineColor" );
}

//----------------------------------------------------------------------------------------------------------
function SetHealthLevel( int HealthLevel )
{
	ActionScriptVoid( "SetHealthLevel" );
}

//----------------------------------------------------------------------------------------------------------
function SetIconToAButton()
{
	ActionScriptVoid( "SetIconToAButton" );
}

//----------------------------------------------------------------------------------------------------------
function SetIconToCrossbow()
{
	ActionScriptVoid( "SetIconToCrossbow" );
}

//----------------------------------------------------------------------------------------------------------
function SetIconToNone()
{
	ActionScriptVoid( "SetIconToNone" );
}

//----------------------------------------------------------------------------------------------------------
function SetIconToShield()
{
	ActionScriptVoid( "SetIconToShield" );
}

//----------------------------------------------------------------------------------------------------------
function SetIconToSpear()
{
	ActionScriptVoid( "SetIconToSpear" );
}

//----------------------------------------------------------------------------------------------------------
function SetIconToSword()
{
	ActionScriptVoid( "SetIconToSword" );
}

//----------------------------------------------------------------------------------------------------------
function SetName( String newName )
{
	ActionScriptVoid( "SetNameText" );
}

//----------------------------------------------------------------------------------------------------------
function SetPlace( int Place )
{
	ActionScriptVoid( "SetPlace" );
}

//----------------------------------------------------------------------------------------------------------
function SetTreasure( String newTreasure )
{
	ActionScriptVoid( "SetTreasureText" );
}

//----------------------------------------------------------------------------------------------------------
function SetColorsFromLinearColor( LinearColor LinColor, optional float OutlineValueBoost = 0.0 )
{
	local Color BackgroundColor;
	//local Color OutlineColor;
	//local HSVColor HSVOutlineColor;
	//local HSVColor HSVBackgroundColor;
	local LinearColor LinBackgroundColor;

	//HSVOutlineColor = class'HSV_Color'.static.RGBToHSV( LinColor );
	//HSVOutlineColor.V += OutlineValueBoost;
	//HSVOutlineColor.V = FMin( 1, HSVOutlineColor.V );

	//OutlineColor.R = LinColor.R * 255;
	//OutlineColor.G = LinColor.G * 255;
	//OutlineColor.B = LinColor.B * 255;
	//SetOutlineColor( OutlineColor.R, OutlineColor.G, OutlineColor.B );
	//SetTextColor( OutlineColor.R, OutlineColor.G, OutlineColor.B );


	//HSVBackgroundColor = HSVOutlineColor;
	//HSVBackgroundColor.V -= BackgroundToOutlineColorValueOffset;
	//HSVBackgroundColor.V = FMax( 0, HSVBackgroundColor.V );
	LinBackgroundColor = LinColor;

	BackgroundColor.R = LinBackgroundColor.R * 255;
	BackgroundColor.G = LinBackgroundColor.G * 255;
	BackgroundColor.B = LinBackgroundColor.B * 255;
	SetBackgroundColor( BackgroundColor.R, BackgroundColor.G, BackgroundColor.B );
}



//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
}
