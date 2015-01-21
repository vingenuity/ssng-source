class SSG_IcePhysicsVolume extends PhysicsVolume;

//----------------------------------------------------------------------------------------------------------
var() float PlayerAccelRate;


//----------------------------------------------------------------------------------------------------------
simulated event Touch( Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal )
{
	local SSG_Pawn SSGP;

	Super.Touch( Other, OtherComp, HitLocation, HitNormal );

	SSGP = SSG_Pawn( Other );
	if( SSGP != None )
	{
		SSGP.NumIceVolumesCurrentlyTouching += 1;
		SSGP.UpdateAccelRate( PlayerAccelRate );
	}
}


//----------------------------------------------------------------------------------------------------------
event UnTouch( Actor Other )
{
	local SSG_Pawn SSGP;

	Super.UnTouch( Other );

	SSGP = SSG_Pawn( Other );
	if( SSGP != None )
	{
		SSGP.NumIceVolumesCurrentlyTouching -= 1;
		SSGP.UpdateAccelRate( PlayerAccelRate );
	}
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	GroundFriction=2.8
	PlayerAccelRate=200000.0
}
