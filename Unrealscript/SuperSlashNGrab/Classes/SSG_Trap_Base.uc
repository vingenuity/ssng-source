class SSG_Trap_Base extends Actor
	ClassGroup( Traps );

//----------------------------------------------------------------------------------------------------------
var bool							bTrapActive;
var() bool                          bActiveAtStart;
var() int							DamageToGivePawn;
var() int                           NumLoopsActive; // 0 = infinite
var int                             CurrentLoopNum;
var float							SecondsSinceActive;
var() float							SecondsOfActivation;
var Vector							PawnHitLocation;
var Vector							PawnHitNormal;
var MaterialInstanceConstant        TrapMeshMIC;
var() StaticMeshComponent			StaticMesh;
var SSG_ColorArrow                  ColorArrow;
var const transient SpriteComponent GoodSprite;
var class<SSG_DamageType>           DamageTypeToApply;


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	Super.Tick( DeltaTime );

	if( NumLoopsActive != 0 && CurrentLoopNum <= 0 )
		return;

	if( !bTrapActive )
		return;

	if( SecondsSinceActive >= SecondsOfActivation )
	{
		bTrapActive = false;
		SecondsSinceActive = 0.0;
		if( NumLoopsActive != 0 )
			--CurrentLoopNum;
	}
	else
	{
		SecondsSinceActive += DeltaTime;
	}
}


//----------------------------------------------------------------------------------------------------------
function PostBeginPlay()
{
	Super.PostBeginPlay();

	bTrapActive = bActiveAtStart;
	CurrentLoopNum = NumLoopsActive;
	
	ColorArrow = Spawn( class'SSG_ColorArrow',,, Location + Vect( 120.0, 0.0, 0.0 ), Rot( 0, 16384, 0 ) );
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	bCollideActors=true    
    bBlockActors=true
	TickGroup=TG_DuringAsyncWork

	Physics=PHYS_Interpolating

	bTrapActive=false
	bActiveAtStart=false
	DamageToGivePawn=0
	NumLoopsActive=0
	CurrentLoopNum=0
	SecondsSinceActive=0
	SecondsOfActivation=0

	Begin Object Class=StaticMeshComponent Name=TrapStaticMeshComponent
		CollideActors=true
		BlockActors=true
		TickGroup=TG_DuringAsyncWork
	End Object
	StaticMesh=TrapStaticMeshComponent
	Components.Add(TrapStaticMeshComponent)

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

	DamageTypeToApply=class'SSG_DmgType_Spikes'
}
