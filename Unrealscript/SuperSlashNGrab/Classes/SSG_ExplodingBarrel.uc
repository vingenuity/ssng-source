class SSG_ExplodingBarrel extends Actor
	ClassGroup( Traps )
	placeable;

//----------------------------------------------------------------------------------------------------------
var MaterialInstanceConstant        MIC;
var() float							FresnelGlowMinDistance;
var() float							FresnelGlowMaxDistance;
var() int                           DamageToGive;
var() float                         DamageRadius;
var Vector						    LocOffset;
var float                           ParticleScale;
var bool                            bIsParticlePlaying;
var ParticleSystemComponent			ExplosionPSC;
var() StaticMeshComponent			StaticMesh;
var const transient SpriteComponent GoodSprite;


//----------------------------------------------------------------------------------------------------------
event PostBeginPlay()
{
	Super.PostBeginPlay();

	ExplosionPSC.SetScale( ParticleScale );

	MIC = new class'MaterialInstanceConstant';
	MIC.SetParent( StaticMesh.GetMaterial(0) );
	StaticMesh.SetMaterial( 0, MIC );
}


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	Super.Tick( DeltaTime );
	//SetFresnelGlow();
	CheckIfReadyToDestroy();
}


//----------------------------------------------------------------------------------------------------------
function CheckIfReadyToDestroy()
{
	if( bIsParticlePlaying && !ExplosionPSC.bIsActive )
		Destroy();
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

	MIC.SetVectorParameterValue( 'Fresnel_Color', FresnelColor );
}


//----------------------------------------------------------------------------------------------------------
event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	StaticMesh.SetHidden( true );
	SetCollision(false, false, false);
	ExplosionPSC.SetActive( true );
	bIsParticlePlaying = true;
	HurtRadius( DamageToGive, DamageRadius, class'SSG_DmgType_Explosion', 1000, Location + LocOffset, , , true );

	//BCD: Play sound on hit
	PlaySound( SoundCue'SSG_TrapSounds.ExplodingBarrel.ExplosionBarrelCue' );
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	bCollideActors=true
    bBlockActors=true
	bCanBeDamaged=true

	DamageToGive=1
	DamageRadius=150.0
	ParticleScale=2.0
	bIsParticlePlaying=false

	FresnelGlowMinDistance=250
	FresnelGlowMaxDistance=350

	LocOffset=(X=0.0,Y=0.0,Z=50.0)

	Physics=PHYS_Interpolating

	Begin Object Class=StaticMeshComponent Name=TrapStaticMeshComponent
		CollideActors=true
		BlockActors=true
		StaticMesh=StaticMesh'SSG_Traps.Barrel_Explosive.SSG_Trap_Barrel_01'
	End Object
	StaticMesh=TrapStaticMeshComponent
	Components.Add(TrapStaticMeshComponent)

	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=40.0
		CollisionHeight=100.0
		BlockActors=false
		CollideActors=true
		Translation=(Z=70.0)
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add( CollisionCylinder )

	Begin Object Class=ParticleSystemComponent Name=ExplosionParticleSystem
		Template=ParticleSystem'SSG_Trap_Particles.ExplosiveBarrel.SSG_ExplosiveBarrel_PS_01'
        bAutoActivate=false
	End Object
	ExplosionPSC=ExplosionParticleSystem
	Components.Add(ExplosionParticleSystem)

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorSprites.SkullSprite'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Navigation"
		Scale=0.25
	End Object
	Components.Add(Sprite)
	GoodSprite=Sprite
}
