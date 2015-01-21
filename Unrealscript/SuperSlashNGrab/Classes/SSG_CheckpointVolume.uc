class SSG_CheckpointVolume extends TriggerVolume;

//----------------------------------------------------------------------------------------------------------
var bool                    bHasBeenTouched;
var() SSG_POI_PlayerStart   PlayerSpawner;
var() float                 LostTime;


//----------------------------------------------------------------------------------------------------------
event Touch( Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal )
{
	if( bHasBeenTouched )
		return;

	if( Other.IsA( 'SSG_Pawn' ) && SSG_Pawn( Other ).Controller.IsA( 'SSG_PlayerController' ) )
	{
		bHasBeenTouched = true;

		if( PlayerSpawner == None )
			return;

		SSG_GameInfo( WorldInfo.Game ).RegisterLastCheckpoint( PlayerSpawner );

		SSG_GameInfo( WorldInfo.Game ).RemoveLost();
		SSG_GameInfo( WorldInfo.Game ).SetTimer(LostTime, false, 'DelayedLost', WorldInfo.Game);
	}

	
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	bHasBeenTouched=false
	LostTime=15.0
}
