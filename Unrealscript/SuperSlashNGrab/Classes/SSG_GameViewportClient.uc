class SSG_GameViewportClient extends GameViewportClient;

function bool CreateInitialPlayer( out string OutError )
{
	//return Super.CreateInitialPlayer( OutError );

	local bool bResult;

	bResult = CreatePlayer( 0, OutError, false ) != none;
	//bResult = bResult && ( CreatePlayer( 1, OutError, false ) != none );
	//bResult = bResult && ( CreatePlayer( 2, OutError, false ) != none );
	//bResult = bResult && ( CreatePlayer( 3, OutError, false ) != none );

	return bResult;
}


//----------------------------------------------------------------------------------------------------------
exec function DebugCreatePlayer( int ControllerId )
{
	local string Error;
	local SSG_GameInfo GIasSSGGI;

	if( GamePlayers.Length < 4 )
	{
		CreatePlayer( ControllerId, Error, TRUE );
	}

	GIasSSGGI = SSG_GameInfo(class'WorldInfo'.static.GetWorldInfo().Game);
	if(GIasSSGGI != none)
	{
		//GIasSSGGI.LoadAllProfiles();
		//TODO this assumes they've been through the menu
	}
}


//----------------------------------------------------------------------------------------------------------
function UpdateActiveSplitscreenType()
{
	ActiveSplitscreenType = eSST_NONE;
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
}
