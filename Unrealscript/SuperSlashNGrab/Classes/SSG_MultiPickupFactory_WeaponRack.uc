class SSG_MultiPickupFactory_WeaponRack extends SSG_MultiPickupFactory
	ClassGroup( Pickups, Weapon )
	placeable;

//----------------------------------------------------------------------------------------------------------
var() class<SSG_Weap_Base>      WeaponPickupClass;
var MaterialInstanceConstant    MIC;
var() float						FresnelGlowMinDistance;
var() float						FresnelGlowMaxDistance;


//----------------------------------------------------------------------------------------------------------
event PostBeginPlay()
{
	Super.PostBeginPlay();
}


//----------------------------------------------------------------------------------------------------------
function SetFresnelGlow()
{
	local float FresnelLevel;
	local float CheckFresnelLevel;
	local float DistanceBetweenPoints;
	local SSG_PlayerController PC;
	local LinearColor FresnelColor;

	FresnelLevel = 0.0;

	foreach WorldInfo.AllControllers( class'SSG_PlayerController', PC )
    {
		if( PC.Pawn == None )
			continue;

		DistanceBetweenPoints = VSize( PC.Pawn.Location - self.Location );
		CheckFresnelLevel = 1.0 - ( ( DistanceBetweenPoints - FresnelGlowMinDistance ) / ( FresnelGlowMaxDistance - FresnelGlowMinDistance ) );
		CheckFresnelLevel = FClamp( CheckFresnelLevel, 0.0, 1.0 );
		if( CheckFresnelLevel > FresnelLevel )
			FresnelLevel = CheckFresnelLevel;
    }

	FresnelColor.R = FresnelLevel;
	FresnelColor.G = FresnelLevel;
	FresnelColor.B = FresnelLevel;

	if( MIC != None )
		MIC.SetVectorParameterValue( 'Fresnel_Color', FresnelColor );
}


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	Super.Tick( DeltaTime );
	//SetFresnelGlow();
}


//----------------------------------------------------------------------------------------------------------
function bool CheckForErrors()
{
	if ( Super.CheckForErrors() )
		return true;

	if ( WeaponPickupClass == None )
	{
		`log(self$" no weapon pickup class");
		return true;
	}

	return false;
}


//----------------------------------------------------------------------------------------------------------
simulated function InitializePickup()
{
	InventoryType = WeaponPickupClass;
	if ( InventoryType == None )
	{
		GotoState('Disabled');
		return;
	}
	
	Super.InitializePickup();
}


//----------------------------------------------------------------------------------------------------------
simulated function SetPickupMesh()
{
	local SkeletalMeshComponent SMC;

	Super.SetPickupMesh();

	PickupMesh.SetTranslation(WeaponPickupClass.default.LockerOffset);
	PickupMesh.SetRotation(WeaponPickupClass.default.LockerRotation);

	SMC = SkeletalMeshComponent( PickupMesh );
	if( SMC != None )
	{
		if( MIC == None )
		{
			MIC = new class'MaterialInstanceConstant';
		}

		MIC.SetParent( SMC.GetMaterial(0) );
		SMC.SetMaterial( 0, MIC );
	}
}


//----------------------------------------------------------------------------------------------------------
function SpawnCopyFor( Pawn Recipient )
{
	local SSG_Pawn GamePawn;
	local SSG_Weap_Base WeaponObject;

	GamePawn = SSG_Pawn( Recipient );
	if( GamePawn != None )
	{
		GamePawn.bHasSecondaryWeapon = true;

		foreach Recipient.InvManager.InventoryActors( class'SSG_Weap_Base', WeaponObject )
		{
			if( WeaponObject.IsSecondaryWeapon() )
			{
				WeaponObject.GotoState( 'EndState' );
				Recipient.InvManager.RemoveFromInventory( WeaponObject );
			}
		}
		super.SpawnCopyFor( Recipient );

		if( GamePawn.Controller.IsA( 'SSG_PlayerController' ) )
		{
			SSG_PlayerController( GamePawn.Controller ).IDOfCurrentWeapon = WeaponPickupClass.default.WeaponID;
			SSG_PlayerController( GamePawn.Controller ).IDOfWeaponPickedUpLastUpdate = WeaponPickupClass.default.WeaponID;
		}
	}
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	FresnelGlowMinDistance=250
	FresnelGlowMaxDistance=350

	Begin Object Class=StaticMeshComponent Name=RackMeshComponent
		StaticMesh=StaticMesh'SSG_Props_01.Meshes.SSG_Environment_Props_WeaponRack_01'
		Translation=(X=0.0,Y=0.0,Z=-80.0)
		//Scale3D=(X=2.0,Y=2.0,Z=2.0)
		CastShadow=FALSE
		bCastDynamicShadow=FALSE
		bAcceptsLights=TRUE
		bBlockFootPlacement=TRUE
		CollideActors=false
		BlockActors=True
		BlockZeroExtent=True
		BlockNonZeroExtent=True
		BlockRigidBody=True
		MaxDrawDistance=7000
	End Object
	BaseMesh=RackMeshComponent
	Components.Add(RackMeshComponent)
	//PivotTranslation=(X=-100, Y=0, Z=0)

	Begin Object Name=CollisionCylinder
		Translation=(X=60.0,Y=15.0,Z=0.0)
	End Object

	Begin Object Name=Sprite
		Sprite=Texture2D'EditorSprites.CrownSprite'
		Scale=0.25
	End Object
}
