class SSG_SinglePickupFactory_PowerUp extends SSG_SinglePickupFactory
	ClassGroup( Pickups, PowerUps )
	placeable;

//----------------------------------------------------------------------------------------------------------
var() class<SSG_Inventory_PowerUp>  PowerUpPickupClass;
var ParticleSystemComponent         PowerUpParticleSystem;
var() PointLightComponent           FactoryPointLight;


//----------------------------------------------------------------------------------------------------------
function bool CheckForErrors()
{
	if ( Super.CheckForErrors() )
		return true;

	if ( PowerUpPickupClass == None )
	{
		`log(self$" no power up pickup class");
		return true;
	}

	return false;
}


//----------------------------------------------------------------------------------------------------------
simulated function InitializePickup()
{
	InventoryType = PowerUpPickupClass;
	if ( InventoryType == None )
	{
		GotoState('Disabled');
		return;
	}

	SetParticleSystem();

	Super.InitializePickup();
}


//----------------------------------------------------------------------------------------------------------
function SetParticleSystem()
{
	if( PowerUpPickupClass == class'SSG_Inventory_PowerUp_DoubleLoot' )
	{
		PowerUpParticleSystem.SetTemplate( class'SSG_Inventory_PowerUp_DoubleLoot'.default.PickupParticleSystem );
	}
	else if( PowerUpPickupClass == class'SSG_Inventory_PowerUp_ArrowCircle' )
	{
		PowerUpParticleSystem.SetTemplate( class'SSG_Inventory_PowerUp_ArrowCircle'.default.PickupParticleSystem );
	}
	else if( PowerUpPickupClass == class'SSG_Inventory_PowerUp_BubbleShield' )
	{
		PowerUpParticleSystem.SetTemplate( class'SSG_Inventory_PowerUp_BubbleShield'.default.PickupParticleSystem );
	}
}


//----------------------------------------------------------------------------------------------------------
function GiveTo( Pawn P )
{
	local SSG_Pawn SSGP;

	SSGP = SSG_Pawn( P );
	if( SSGP == None || SSGP.Controller == None || !SSGP.Controller.IsA( 'SSG_PlayerController' ) )
		return;

	if( PowerUpPickupClass == class'SSG_Inventory_PowerUp_DoubleLoot' && SSGP.bDoubleLoot )
		return;

	if( PowerUpPickupClass == class'SSG_Inventory_PowerUp_ArrowCircle' && SSGP.bArrowCircle )
		return;

	if( PowerUpPickupClass == class'SSG_Inventory_PowerUp_BubbleShield' && SSGP.bBubbleShield )
		return;

	Super.GiveTo( P );
}


//----------------------------------------------------------------------------------------------------------
function SpawnCopyFor( Pawn Recipient )
{
	local SSG_Pawn SSGP;

	SSGP = SSG_Pawn( Recipient );
	if( SSGP != None && SSGP.Controller.IsA( 'SSG_PlayerController' ) )
	{
		if( PowerUpPickupClass == class'SSG_Inventory_PowerUp_DoubleLoot' )
		{
			SSGP.EnableDoubleLootPowerUp();
		}
		else if( PowerUpPickupClass == class'SSG_Inventory_PowerUp_ArrowCircle' )
		{
			SSGP.EnableArrowCirclePowerUp();
		}
		else if( PowerUpPickupClass == class'SSG_Inventory_PowerUp_BubbleShield' )
		{
			SSGP.EnableBubbleShieldPowerUp();
		}
	}

	PowerUpParticleSystem.SetActive( false );
	FactoryPointLight.SetEnabled( false ); 
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

	Begin Object Class=ParticleSystemComponent Name=PowerUpSystem
	    bAutoActivate=true
	End Object
	PowerUpParticleSystem=PowerUpSystem
	Components.Add(PowerUpSystem)

	Begin Object Class=PointLightComponent Name=FactoryLightComponent
		bEnabled=true
		CastDynamicShadows=false
		Brightness=0.5
		FalloffExponent=10.0
	End Object
	FactoryPointLight=FactoryLightComponent;
	Components.Add(FactoryLightComponent);

	Begin Object Name=Sprite
		Sprite=Texture2D'EditorSprites.powerup'
		Scale=0.25
	End Object
}
