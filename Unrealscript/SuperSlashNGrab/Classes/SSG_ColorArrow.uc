class SSG_ColorArrow extends Actor;

//----------------------------------------------------------------------------------------------------------
var MaterialInstanceConstant    MIC;
var StaticMeshComponent         StaticMesh;
var LinearColor                 Colors[4];
var int                         CurrentColorIndex;
var float                       SecondsSinceColorTransition;

const NUM_ARROW_COLORS = 4;
const COLOR_TIME_SECONDS = 1.0;
const COLOR_TRANSITION_TIME_SECONDS = 0.25;


//----------------------------------------------------------------------------------------------------------
function PostBeginPlay()
{
	local LinearColor InitArrowColor;

	MIC = new class'MaterialInstanceConstant';
	MIC.SetParent( StaticMesh.GetMaterial(0) );
	StaticMesh.SetMaterial( 0, MIC );
	StaticMesh.SetDepthPriorityGroup( SDPG_Foreground );

	InitArrowColor.A = 0.0;
	MIC.SetVectorParameterValue( 'Player_Color', InitArrowColor );
}


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	Super.Tick( DeltaTime );
	UpdateArrowColor( DeltaTime );
}


//----------------------------------------------------------------------------------------------------------
function UpdateArrowColor( float DeltaTime )
{
	local int i;
	local LinearColor ArrowColor, NextArrowColor;

	SecondsSinceColorTransition += DeltaTime;
	if( SecondsSinceColorTransition > COLOR_TIME_SECONDS + COLOR_TRANSITION_TIME_SECONDS )
	{
		SecondsSinceColorTransition -= COLOR_TIME_SECONDS + COLOR_TRANSITION_TIME_SECONDS;
		++CurrentColorIndex;
		if( CurrentColorIndex == NUM_ARROW_COLORS )
		{
			CurrentColorIndex = 0;
		}
	}

	ArrowColor = Colors[ CurrentColorIndex ];
	i = CurrentColorIndex;

	while( true )
	{
		if( Colors[i].A > 0.0 )
		{
			if( Colors[i].A < 0.15 )
			{
				Colors[i].A = 0.0;
				continue;
			}

			ArrowColor = Colors[i];
			CurrentColorIndex = i;
			break;
		}

		++i;
		if( i == NUM_ARROW_COLORS )
		{
			i = 0;
		}

		if( i == CurrentColorIndex )
			return;
	}

	if( SecondsSinceColorTransition > COLOR_TIME_SECONDS )
	{
		NextArrowColor = Colors[ CurrentColorIndex + 1 ];
		i = CurrentColorIndex + 1;

		while( true )
		{
			if( Colors[i].A > 0.0 )
			{
				if( Colors[i].A < 0.15 )
				{
					Colors[i].A = 0.0;
					continue;
				}

				NextArrowColor = Colors[i];
				break;
			}

			++i;
			if( i == NUM_ARROW_COLORS )
			{
				i = 0;
			}

			if( i == CurrentColorIndex + 1 )
				return;
		}

		ArrowColor = TransitionColors( ArrowColor, NextArrowColor, ( SecondsSinceColorTransition - COLOR_TIME_SECONDS ) / COLOR_TRANSITION_TIME_SECONDS );
	}

	MIC.SetVectorParameterValue( 'Player_Color', ArrowColor );
}


//----------------------------------------------------------------------------------------------------------
function LinearColor TransitionColors( LinearColor ColorA, LinearColor ColorB, float ColorScale )
{
	local LinearColor ReturnColor;
	ReturnColor.R = ( ColorB.R * ColorScale ) + ( ColorA.R * ( 1.0 - ColorScale ) );
	ReturnColor.G = ( ColorB.G * ColorScale ) + ( ColorA.G * ( 1.0 - ColorScale ) );
	ReturnColor.B = ( ColorB.B * ColorScale ) + ( ColorA.B * ( 1.0 - ColorScale ) );
	ReturnColor.A = ( ColorB.A * ColorScale ) + ( ColorA.A * ( 1.0 - ColorScale ) );

	return ReturnColor;
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	TickGroup=TG_DuringAsyncWork 

	bIgnoreBaseRotation=true

	Colors(0)=(A=0.0)
	Colors(1)=(A=0.0)
	Colors(2)=(A=0.0)
	Colors(3)=(A=0.0)

	CurrentColorIndex=0
	SecondsSinceColorTransition=0.0

	Begin Object Class=StaticMeshComponent Name=ArrowMeshComponent
		TickGroup=TG_DuringAsyncWork
		CollideActors=false
		BlockActors=false
		StaticMesh=StaticMesh'SSG_Trap_Particles.TriggerIndicator.SSG_HUD_TriggerIndicator_Plane_01'
	End Object
	StaticMesh=ArrowMeshComponent
	Components.Add(ArrowMeshComponent)
}
