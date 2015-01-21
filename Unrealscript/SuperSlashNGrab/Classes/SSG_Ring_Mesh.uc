class SSG_Ring_Mesh extends Actor;

const NUMBER_OF_MATERIALS = 4;
var StaticMeshComponent RingMesh;
var MaterialInstanceConstant RingMaterial[ NUMBER_OF_MATERIALS ];


//----------------------------------------------------------------------------------------------------------
function PostBeginPlay()
{
	local int i;

	for( i = 0; i < NUMBER_OF_MATERIALS; ++i )
	{
		RingMaterial[ i ] = new class'MaterialInstanceConstant';
		RingMaterial[ i ].SetParent( RingMesh.GetMaterial( i ) );
	}
	RingMesh.SetMaterial( 0, RingMaterial[ NUMBER_OF_MATERIALS - 1 ] );
}

function SetFillLevel( int FillLevel )
{
	if( FillLevel > NUMBER_OF_MATERIALS - 1 )
	{
		FillLevel = NUMBER_OF_MATERIALS - 1;
	}

	RingMesh.SetMaterial( 0, RingMaterial[ FillLevel ] );
}

DefaultProperties
{
	TickGroup=TG_DuringAsyncWork 
	bIgnoreBaseRotation=true

	Begin Object Class=StaticMeshComponent Name=RingStaticMesh
	  TickGroup=TG_DuringAsyncWork
	  Translation=(Z=-50)
	  Rotation=(Yaw=16384)
	  StaticMesh=StaticMesh'SSG_Character_Particles.HUD.SSG_HUD_Ring_01'
      Materials(0)=Material'SSG_Character_Particles.HUD.SSG_HUD_Ring_NoHealth_MAT_01'
      Materials(1)=Material'SSG_Character_Particles.HUD.SSG_HUD_Ring_LowHealth_MAT_01'
      Materials(2)=Material'SSG_Character_Particles.HUD.SSG_HUD_Ring_MediumHealth_MAT_01'
      Materials(3)=Material'SSG_Character_Particles.HUD.SSG_HUD_Ring_FullHealth_MAT_01'
	  Scale=0.75
	End Object
	RingMesh = RingStaticMesh;
	Components.Add( RingStaticMesh )
}