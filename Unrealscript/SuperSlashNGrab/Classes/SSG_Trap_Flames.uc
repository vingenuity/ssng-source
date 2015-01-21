class SSG_Trap_Flames extends SSG_Trap_Base;

//----------------------------------------------------------------------------------------------------------
var ParticleSystemComponent Flames;
var SoundCue                FlameUpCue;
var bool					bHasStarted;
var bool					bIsCooldown;
var float                   SecondsForGlowTransition;
var float                   TransitionSecondsLeft;
var LinearColor             GlowColor;


//----------------------------------------------------------------------------------------------------------
event PostBeginPlay()
{
	TrapMeshMIC = StaticMesh.CreateAndSetMaterialInstanceConstant(0);
	Super.PostBeginPlay();
	TrapMeshMIC.SetVectorParameterValue( 'glowColor', GlowColor );
}


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	local float glowValue;

	Super.Tick( DeltaTime );

	if( bTrapActive && !bHasStarted )
	{
		bTrapActive = false;
		bHasStarted = true;
		TransitionSecondsLeft = SecondsForGlowTransition;
		TrapMeshMIC.SetScalarParameterValue( 'isGlowing', 1.0 );
	}

	if( SecondsSinceActive >= ( SecondsOfActivation - SecondsForGlowTransition ) && TransitionSecondsLeft == 0.0 )
	{
		TransitionSecondsLeft = SecondsForGlowTransition;
		bIsCooldown = true;
	}

	if( TransitionSecondsLeft > 0.0 )
	{
		if( bIsCooldown )
		{
			glowValue = TransitionSecondsLeft / SecondsForGlowTransition;
		}
		else
		{
			glowValue = ( SecondsForGlowTransition - TransitionSecondsLeft ) / SecondsForGlowTransition;
		}

		TrapMeshMIC.SetScalarParameterValue( 'glowValue', glowValue );
		TransitionSecondsLeft -= DeltaTime;
	}
	else if( TransitionSecondsLeft < 0.0 )
	{
		TransitionSecondsLeft = 0.0;

		if( bIsCooldown )
		{
			TrapMeshMIC.SetScalarParameterValue( 'glowValue', 0.0 );
			TrapMeshMIC.SetScalarParameterValue( 'isGlowing', 0.0 );
			Flames.SetActive( false );
			bHasStarted = false;
			bIsCooldown = false;
		}
		else
		{
			TrapMeshMIC.SetScalarParameterValue( 'glowValue', 1.0 );
			Flames.SetActive( true );
			PlaySound( FlameUpCue );
			bTrapActive = true;
		}
	}
}


//----------------------------------------------------------------------------------------------------------
event Touch( Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal )
{
	local SSG_Pawn SSGP;

	SSGP = SSG_Pawn( Other );
	if( SSGP != None )
	{
		SSGP.TrapsCurrentlyTouching.AddItem( self );
		SSGP.NumHarmfulTrapsTouching += 1;
		SSGP.bIsTouchingHarmfulTrap = true;
		PawnHitLocation = HitLocation;
		PawnHitNormal = HitNormal;
	}
}


//----------------------------------------------------------------------------------------------------------
event UnTouch( Actor Other )
{
	local SSG_Pawn SSGP;

	SSGP = SSG_Pawn( Other );
	if( SSGP != None )
	{
		SSGP.TrapsCurrentlyTouching.RemoveItem( self );
		SSGP.NumHarmfulTrapsTouching -= 1;
		if( SSGP.NumHarmfulTrapsTouching == 0 )
			SSGP.bIsTouchingHarmfulTrap = false;
	}
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	bBlockActors=false
	bHasStarted=false
	bIsCooldown=false

	SecondsForGlowTransition=0.5
	TransitionSecondsLeft=0.0
	DamageToGivePawn=1

	GlowColor=(R=0.8,G=0.0,B=0.0,A=1.0)

	FlameUpCue=SoundCue'SSG_TrapSounds.FlameTrap.FlameUpCue'

	Begin Object Class=ParticleSystemComponent Name=TrapFlameParticleSystem
        bAutoActivate=false
	End Object
	Flames=TrapFlameParticleSystem
	Components.Add(TrapFlameParticleSystem)

	Begin Object Name=TrapStaticMeshComponent
		StaticMesh=StaticMesh'SSG_Traps.Fire_Trap.SSG_Trap_Fire_Grate_01'
		Scale=1.5
	End Object

	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=70.0
		CollisionHeight=100.0
		BlockActors=false
		CollideActors=true
		Translation=(Z=70.0)
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add( CollisionCylinder )

	DamageTypeToApply=class'SSG_DmgType_Burn'
}
