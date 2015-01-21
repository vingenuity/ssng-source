class SSG_CheatManager extends CheatManager;



//----------------------------------------------------------------------------------------------------------
exec function DelayEnrageBy( int timeSeconds )
{
	if( SSG_GameInfo( WorldInfo.Game ) != None )
	{
		SSG_GameInfo( WorldInfo.Game ).SecondsLeftUntilSuddenDeath += timeSeconds;
		ClientMessage( "Guard Enrage delayed by " $ timeSeconds $ " seconds." );
	}
}

//----------------------------------------------------------------------------------------------------------
exec function Buddha()
{
	local SSG_Pawn SSGPawn;

	SSGPawn = SSG_Pawn( Pawn );
	if( SSGPawn == None )
		return;

	if ( SSGPawn.bInBuddhaMode )
	{
		SSGPawn.bInBuddhaMode = false;
		ClientMessage("Buddha mode off");
	}
	else
	{
		SSGPawn.bInBuddhaMode = true;
		ClientMessage("Buddha Mode on");
		SSGPawn.DamageTakenDuringBuddhaMode = 0;
	}
}

defaultproperties
{
}
