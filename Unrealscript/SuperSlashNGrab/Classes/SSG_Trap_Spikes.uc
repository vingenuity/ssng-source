class SSG_Trap_Spikes extends SSG_Trap_Base
	placeable;

//----------------------------------------------------------------------------------------------------------
event Touch( Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal )
{
	local SSG_Pawn SSGP;
	//local Vector Momentum;
	//local Rotator FaceDirection;

	SSGP = SSG_Pawn( Other );
	if( SSGP != None )
	{
		SSGP.TrapsCurrentlyTouching.AddItem( self );
		SSGP.NumHarmfulTrapsTouching += 1;
		SSGP.bIsTouchingHarmfulTrap = true;
		PawnHitLocation = HitLocation;
		PawnHitNormal = HitNormal;

		//if( !bTrapActive || SSGP.bIsInDamageCooldown )
			//return;

		// momentum needs to be improved
		//FaceDirection = SSGP.Rotation;
		//Momentum.X = -cos( FaceDirection.Yaw * UnrRotToRad );
		//Momentum.Y = -sin( FaceDirection.Yaw * UnrRotToRad );
		//Momentum.Z = 0.0;
		//SSGP.TakeDamage( 0, none, HitLocation, HitNormal * 5000, none );
	}
}


//----------------------------------------------------------------------------------------------------------
event UnTouch( Actor Other )
{
	local SSG_Pawn SSGP;

	SSGP = SSG_Pawn( Other );
	if( SSGP != None )
	{
		SSGP.TrapsCurrentlyTouching.RemoveItem( none );
		SSGP.NumHarmfulTrapsTouching -= 1;
		if( SSGP.NumHarmfulTrapsTouching == 0 )
			SSGP.bIsTouchingHarmfulTrap = false;
	}
}


//----------------------------------------------------------------------------------------------------------
event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal )
{
	//local SSG_Pawn SSGP;
	//local Vector Momentum;
	//local Rotator FaceDirection;

	//if( !bTrapActive )
	//	return;

	//SSGP = SSG_Pawn( Other );
	//if( SSGP != None )
	//{
	//	// momentum needs to be improved
	//	FaceDirection = SSGP.Rotation;
	//	Momentum.X = -cos( FaceDirection.Yaw * UnrRotToRad );
	//	Momentum.Y = -sin( FaceDirection.Yaw * UnrRotToRad );
	//	Momentum.Z = 0.0;
	//	SSGP.TakeDamage( 0, none, HitNormal, Momentum * 50000, none );
	//}
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	bBlockActors=false

	DamageToGivePawn=1
	SecondsOfActivation=2.5

	Begin Object Name=TrapStaticMeshComponent
		StaticMesh=StaticMesh'SSG_Traps.Spikes.SSG_Trap_Spikes_Bottom_01'
	End Object
}
