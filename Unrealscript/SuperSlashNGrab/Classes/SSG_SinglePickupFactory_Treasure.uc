class SSG_SinglePickupFactory_Treasure extends SSG_SinglePickupFactory
	ClassGroup( Pickups, Treasure )
	placeable;

//----------------------------------------------------------------------------------------------------------
var() class<SSG_Inventory_Treasure> TreasurePickupClass;
var() ParticleSystemComponent       SparkleParticleSystem;


//----------------------------------------------------------------------------------------------------------
function bool CheckForErrors()
{
	if ( Super.CheckForErrors() )
		return true;

	if ( TreasurePickupClass == None )
	{
		`log(self$" no treasure pickup class");
		return true;
	}

	return false;
}


//----------------------------------------------------------------------------------------------------------
simulated function InitializePickup()
{
	InventoryType = TreasurePickupClass;
	if ( InventoryType == None )
	{
		GotoState('Disabled');
		return;
	}

	Super.InitializePickup();
}


//----------------------------------------------------------------------------------------------------------
function TakeDamage( int Damage, Controller InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser )
{
	Super.TakeDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser );

	if( InstigatedBy == None || InstigatedBy.Pawn == None )
		return;

	if( InstigatedBy.Pawn.Weapon.IsA( 'SSG_Weap_Bow' ) )
		return;

	GiveTo( InstigatedBy.Pawn );
}


//----------------------------------------------------------------------------------------------------------
function SpawnCopyFor( Pawn Recipient )
{
	local float LootMultiplyer;
	local SSG_Pawn GamePawn;
	local SSG_PlayerController SSG_PC;
	local class<SSG_Inventory_Treasure> TreasureType;

	GamePawn = SSG_Pawn( Recipient );
	TreasureType = class<SSG_Inventory_Treasure>( InventoryType );
	if( GamePawn != None && TreasureType != None )
	{
		SSG_PC = SSG_PlayerController( GamePawn.Controller );
		if( SSG_PC != None )
		{
			LootMultiplyer = 1.0;
			if( GamePawn.bDoubleLoot )
				LootMultiplyer = 2.0;

			SSG_PC.MoneyEarned += TreasureType.default.MonetaryValue * LootMultiplyer;
			SSG_PC.MoneyEarnedSinceLastUpdate += TreasureType.default.MonetaryValue * LootMultiplyer;
		}
	}

	SparkleParticleSystem.SetActive( false );

	//Recipient.MakeNoise(0.1);
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	bUpdatingPickup=true

	//Pickup Floating
	bFloatingPickup=true
	bRandomStart=false
	BobOffset=15
	BobSpeed=3

	//Pickup Rotation
	bRotatingPickup=true
	YawRotationRate=10000

	Begin Object Class=ParticleSystemComponent Name=SparkleParticleSystem
		Template=ParticleSystem'SSG_Environment_Particles.Loot.SSG_Particles_LootSparkles_PS_01'
        bAutoActivate=true
	End Object
	SparkleParticleSystem=SparkleParticleSystem
	Components.Add(SparkleParticleSystem)

	Begin Object Name=Sprite
		Sprite=Texture2D'EditorSprites.DollarSprite'
		Scale=0.25
	End Object
}
