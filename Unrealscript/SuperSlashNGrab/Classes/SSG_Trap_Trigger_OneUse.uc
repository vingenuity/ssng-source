class SSG_Trap_Trigger_OneUse extends SSG_Trap_Trigger
	ClassGroup( Traps, Triggers )
	placeable;

//----------------------------------------------------------------------------------------------------------
var bool                        bTriggerUsed;
var Vector                      ParticleSystemOffset;
var() ParticleSystemComponent	BreakPSC;
var(Sounds) SoundCue            BreakSoundCue;


//----------------------------------------------------------------------------------------------------------
function PostBeginPlay()
{
	Super.PostBeginPlay();
	BreakPSC.SetTranslation( ParticleSystemOffset );
}


//----------------------------------------------------------------------------------------------------------
function SetTrapArrowColor()
{
	if( bTriggerUsed )
		return;

	Super.SetTrapArrowColor();
}


//----------------------------------------------------------------------------------------------------------
function TurnOffTrapArrows()
{
	local SSG_Trap_Base Trap;
	local LinearColor ArrowColor;
	local SSG_PlayerController PC;
	local int PlayerControllerID;

	ArrowColor.A = 0.0;
	foreach WorldInfo.AllControllers( class'SSG_PlayerController', PC )
    {
		PlayerControllerID = LocalPlayer( PC.Player ).ControllerId;
		ColorArrow.Colors[ PlayerControllerID ] = ArrowColor;
		foreach TrapsToTrigger( Trap )
		{
			Trap.ColorArrow.Colors[ PlayerControllerID ] = ArrowColor;
		}
    }

	ColorArrow.MIC.SetVectorParameterValue( 'Player_Color', ArrowColor );
	foreach TrapsToTrigger( Trap )
	{
		Trap.ColorArrow.MIC.SetVectorParameterValue( 'Player_Color', ArrowColor );
	}
}


//----------------------------------------------------------------------------------------------------------
function UpdateActivation()
{
	local SSG_Trap_Base Trap;

	if( SecondsSinceActive >= SecondsAfterActiveBeforeFire && !bActivatedTraps )
	{
		foreach TrapsToTrigger( Trap )
		{
			if( Trap == None )
				continue;

			Trap.bTrapActive = true;
			if( bResetLoopCount )
				Trap.CurrentLoopNum = Trap.NumLoopsActive;
		}
		
		ActivateTriggerEvent( class'SSG_SeqEvent_TriggerUsed' );
		BreakPSC.SetActive( true );
		SkelMesh.SetHidden( true );
		PlaySound( BreakSoundCue );
		TurnOffTrapArrows();
		CylinderComponent1.SetCylinderSize( CylinderComponent1.CollisionRadius, CylinderComponent1.CollisionHeight * 0.5 );
		CylinderComponent2.SetCylinderSize( CylinderComponent2.CollisionRadius, CylinderComponent2.CollisionHeight * 0.5 );
		CylinderComponent3.SetCylinderSize( CylinderComponent3.CollisionRadius, CylinderComponent3.CollisionHeight * 0.5 );
		bActivatedTraps = true;
		bTriggerUsed = true;
	}
}


//----------------------------------------------------------------------------------------------------------
event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if( bTriggerUsed || bTrapActive )
		return;

	if( EventInstigator == None || EventInstigator.Pawn == None )
		return;

	if( DamageType == class'SSG_DmgType_Projectile' )
		return;

	Super.TakeDamage( DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser );
	SkelMesh.PlayAnim( TriggerAnim, SecondsOfActivation, false );
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	bTriggerUsed=false
	SecondsOfActivation=0.667
	SecondsAfterActiveBeforeFire=0.333
	ParticleSystemOffset=(X=0.0,Y=0.0,Z=30.0)
	TriggerAnim=SSG_Trap_TriggerLever_OneWay_Return_01
	BreakSoundCue=SoundCue'SSG_TrapSounds.Triggers.HitWoodenTriggerCue'

	Begin Object Name=TriggerSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'SSG_Traps.TriggerLever.SSG_Trap_TriggerLever_02'
	End Object

	Begin Object Class=StaticMeshComponent Name=TriggerBaseMesh
		CollideActors=true
		BlockActors=true
		Rotation=(Yaw=16384)
		StaticMesh=StaticMesh'SSG_Traps.TriggerLever.SSG_Trap_Trgger_Base_Wood_01'
	End Object
	Components.Add(TriggerBaseMesh)

	Begin Object Class=ParticleSystemComponent Name=BreakParticleSystem
		Template=ParticleSystem'SSG_Environment_Particles.WoodDebris.SSG_Particles_WoodDebris_PS_01'
        bAutoActivate=false
	End Object
	BreakPSC=BreakParticleSystem
	Components.Add(BreakParticleSystem)
}
