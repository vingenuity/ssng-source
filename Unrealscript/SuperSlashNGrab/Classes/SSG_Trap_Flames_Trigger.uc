class SSG_Trap_Flames_Trigger extends SSG_Trap_Flames
	placeable;

//----------------------------------------------------------------------------------------------------------
var bool            bIsShuttingDown;
var SoundCue        FlameOnLoopCue;
var AudioComponent  FlameOnLoopComponent;


//----------------------------------------------------------------------------------------------------------
function PostBeginPlay()
{
	Super.PostBeginPlay();

	if( FlameOnLoopCue != None )
	{
		FlameOnLoopComponent = CreateAudioComponent( FlameOnLoopCue, false, true );
		if( FlameOnLoopComponent != None )
		{
			FlameOnLoopComponent.bShouldRemainActiveIfDropped = true;
		}
	}
}


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	if( bTrapActive && !bIsShuttingDown )
	{
		SecondsSinceActive = 0.0;
	}
	else if( !bTrapActive && bHasStarted && TransitionSecondsLeft == 0.0 )
	{
		bIsShuttingDown = true;
		bTrapActive = true;
		Flames.SetActive( false );
		SecondsSinceActive = ( SecondsOfActivation - SecondsForGlowTransition );
		
		if( FlameOnLoopComponent != None )
		{
			FlameOnLoopComponent.FadeOut( 0.5, 0.0 );
		}
	}

	Super.Tick( DeltaTime );

	if( bTrapActive && FlameOnLoopComponent != None && !FlameOnLoopComponent.IsPlaying() )
	{
		FlameOnLoopComponent.FadeIn( 0.0, 1.0 );
	}

	if( bIsShuttingDown && !bTrapActive )
	{
		bIsShuttingDown = false;
	}
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	bIsShuttingDown=false
	SecondsOfActivation=1.0 // should be greater than 0

	FlameOnLoopCue=SoundCue'SSG_TrapSounds.ContinuousFlamesTrapCue'

	Begin Object Name=TrapFlameParticleSystem
        Template=ParticleSystem'SSG_Trap_Particles.Fire.SSG_Fire_PS_02'
	End Object
}
