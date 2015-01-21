class SSG_Trap_Trigger extends SSG_Trap_Base;

//----------------------------------------------------------------------------------------------------------
var name                                    TriggerAnim;
var bool                                    bActivatedTraps;
//var bool                                  bTriggerOn;
var float                                   SecondsAfterActiveBeforeFire; // seconds after the trigger is activated and before we want to activate set traps
var CylinderComponent                       CylinderComponent1;
var CylinderComponent                       CylinderComponent2;
var CylinderComponent                       CylinderComponent3;
var(SSG_Trap_Base) bool                     bResetLoopCount;
var(SSG_Trap_Base) float                    TriggerSpeedScale; // 2.0 is twice as fast, 0.5 is twice as slow
var(SSG_Trap_Base) float                    FresnelGlowMinDistance;
var(SSG_Trap_Base) float                    FresnelGlowMaxDistance;
var(SSG_Trap_Base) SkeletalMeshComponent	SkelMesh;
var(SSG_Trap_Base) Color                    GlowColor;
var(SSG_Trap_Base) array<SSG_Trap_Base>     TrapsToTrigger;
//var(SSG_Trap_Base) bool                   bToggleTrapActivation;


//----------------------------------------------------------------------------------------------------------
event PostBeginPlay()
{
	Super.PostBeginPlay();
	TrapMeshMIC = new class'MaterialInstanceConstant';
	TrapMeshMIC.SetParent( SkelMesh.GetMaterial(0) );
	SkelMesh.SetMaterial( 0, TrapMeshMIC );

	SecondsOfActivation *= ( 1.0 / TriggerSpeedScale );
	SecondsAfterActiveBeforeFire *= ( 1.0 / TriggerSpeedScale );
}


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	Super.Tick( DeltaTime );

	//SetFresnelGlow();
	SetTrapArrowColor();

	if( !bTrapActive )
	{
		bActivatedTraps = false;
		return;
	}

	if( bActivatedTraps )
		return;

	UpdateActivation();
}


//----------------------------------------------------------------------------------------------------------
function UpdateActivation();
//{
//	local SSG_Trap_Base Trap;

//	if( SecondsSinceActive >= SecondsAfterActiveBeforeFire && !bActivatedTraps )
//	{
//		foreach TrapsToTrigger( Trap )
//		{
//			if( Trap == None )
//				continue;

//			if( bToggleTrapActivation )
//			{
//				Trap.bTrapActive = !Trap.bTrapActive;
//			}
//			else
//			{
//				Trap.bTrapActive = true;
//			}
//		}

//		if( bToggleTrapActivation )
//		{
//			if( bTriggerOn )
//				ActivateTriggerEvent( class'SSG_SeqEvent_TriggerTurnedOn' );
//			else
//				ActivateTriggerEvent( class'SSG_SeqEvent_TriggerTurnedOff' );
//		}
//		else
//		{
//			ActivateTriggerEvent( class'SSG_SeqEvent_TriggerUsed' );
//		}
		
//		bActivatedTraps = true;
//	}
//}


//----------------------------------------------------------------------------------------------------------
function ActivateTriggerEvent( class<SequenceEvent> InClass )
{
	local Sequence GameSeq;
	local array<SequenceObject> AllSeqEvents;
	local SequenceObject SeqObj;
	local SequenceEvent SeqEvent;

	GameSeq = WorldInfo.GetGameSequence();
	if( GameSeq != None )
	{
		GameSeq.FindSeqObjectsByClass( InClass, true, AllSeqEvents );
		foreach AllSeqEvents( SeqObj )
		{
			SeqEvent = SequenceEvent( SeqObj );
			if( SeqEvent == None )
				continue;

			if( SeqEvent.Originator == self )
				SeqEvent.CheckActivate( self, self, false );
		}
	}
}


//----------------------------------------------------------------------------------------------------------
function SetTrapArrowColor()
{
	local int PlayerControllerID;
	local bool bFoundAlivePlayer;
	local float ArrowAlpha;
	local float DistanceBetweenPoints;
	local SSG_Trap_Base Trap;
	local SSG_PlayerController PC;
	local LinearColor ArrowColor;

	bFoundAlivePlayer = false;

	foreach WorldInfo.AllControllers( class'SSG_PlayerController', PC )
    {
		PlayerControllerID = LocalPlayer( PC.Player ).ControllerId;

		if( PC.Pawn == None )
		{
			ArrowColor.A = 0.0;
			ColorArrow.Colors[ PlayerControllerID ] = ArrowColor;
			foreach TrapsToTrigger( Trap )
			{
				Trap.ColorArrow.Colors[ PlayerControllerID ] = ArrowColor;
			}

			continue;
		}

		bFoundAlivePlayer = true;
		DistanceBetweenPoints = VSize( PC.Pawn.Location - self.Location );
		ArrowAlpha = 1.0 - ( ( DistanceBetweenPoints - FresnelGlowMinDistance ) / ( FresnelGlowMaxDistance - FresnelGlowMinDistance ) );
		ArrowAlpha = FClamp( ArrowAlpha, 0.0, 1.0 );

		if( ArrowAlpha > 0.0 )
		{
			ArrowColor = class'SSG_PlayerController'.default.PlayerColors[ PlayerControllerID ];
			ArrowColor.A = ArrowAlpha;
			ColorArrow.Colors[ PlayerControllerID ] = ArrowColor;

			foreach TrapsToTrigger( Trap )
			{
				Trap.ColorArrow.Colors[ PlayerControllerID ] = ArrowColor;
			}
		}
    }

	if( bFoundAlivePlayer )
		return;

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
function SetFresnelGlow()
{
	local float FresnelLevel;
	local float CheckFresnelLevel;
	local float DistanceBetweenPoints;
	local SSG_Trap_Base Trap;
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

	FresnelColor.R = ( GlowColor.R / 255.0 ) * FresnelLevel;
	FresnelColor.G = ( GlowColor.G / 255.0 ) * FresnelLevel;
	FresnelColor.B = ( GlowColor.B / 255.0 ) * FresnelLevel;

	TrapMeshMIC.SetVectorParameterValue( 'Fresnel_Color', FresnelColor );

	foreach TrapsToTrigger( Trap )
	{
		Trap.TrapMeshMIC.SetVectorParameterValue( 'Fresnel_Color', FresnelColor );
	}
}


//----------------------------------------------------------------------------------------------------------
event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if( bTrapActive )
		return;

	//SkelMesh.PlayAnim( TriggerAnim, 1.5, false );
	if( EventInstigator == None || EventInstigator.Pawn == None )
		return;

	if( DamageType == class'SSG_DmgType_Projectile' )
		return;

	bTrapActive = true;
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	TickGroup=TG_PreAsyncWork
	bEdShouldSnap=true
	bActivatedTraps=false
	bResetLoopCount=false
	//bTriggerOn=false
	TriggerSpeedScale=2.0
	SecondsOfActivation=1.5
	SecondsAfterActiveBeforeFire=0.3
	FresnelGlowMinDistance=250
	FresnelGlowMaxDistance=350
	//bToggleTrapActivation=false

	GlowColor=(R=255,G=255,B=255,A=255);

	SupportedEvents.Add(class'SSG_SeqEvent_TriggerTurnedOn')
	SupportedEvents.Add(class'SSG_SeqEvent_TriggerTurnedOff')
	SupportedEvents.Add(class'SSG_SeqEvent_TriggerUsed')

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Class=SkeletalMeshComponent Name=TriggerSkeletalMeshComponent
		bCacheAnimSequenceNodes=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		CastShadow=true
		BlockRigidBody=true
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=false
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		bChartDistanceFactor=true
		RBDominanceGroup=20
		Scale=1.f
		bAllowAmbientOcclusion=false
		bUseOnePassLightingOnTranslucency=true
		bPerBoneMotionBlur=true
		MinDistFactorForKinematicUpdate=0.0
		SkeletalMesh=SkeletalMesh'SSG_Traps.TriggerLever.SSG_Trap_TriggerLever_Metal_01'
		PhysicsAsset=PhysicsAsset'SSG_Traps.TriggerLever.SSG_Trap_TriggerLever_01_Physics'
		AnimSets(0)=AnimSet'SSG_Traps.TriggerLever.SSG_Trap_TriggerLever_AnimSet_01'
		Animations=MeshSequenceA
	End Object
	SkelMesh=TriggerSkeletalMeshComponent
	Components.Add(TriggerSkeletalMeshComponent)

	Begin Object Class=CylinderComponent Name=CollisionCylinder1
		CollisionRadius=50.0
		CollisionHeight=100.0
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
		Translation=(X=0.0,Y=-50.0,Z=0.0)
	End Object
	CollisionComponent=CollisionCylinder1
	CylinderComponent1=CollisionCylinder1
	Components.Add( CollisionCylinder1 )

	Begin Object Class=CylinderComponent Name=CollisionCylinder2
		CollisionRadius=50.0
		CollisionHeight=100.0
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
		Translation=(X=0.0,Y=0.0,Z=0.0)
	End Object
	CylinderComponent2=CollisionCylinder2
	Components.Add( CollisionCylinder2 )

	Begin Object Class=CylinderComponent Name=CollisionCylinder3
		CollisionRadius=50.0
		CollisionHeight=100.0
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
		Translation=(X=0.0,Y=50.0,Z=0.0)
	End Object
	CylinderComponent3=CollisionCylinder3
	Components.Add( CollisionCylinder3 )
}
