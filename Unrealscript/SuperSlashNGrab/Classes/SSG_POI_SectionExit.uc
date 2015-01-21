class SSG_POI_SectionExit extends UDKGameObjective
	ClassGroup( Common, PlayerExit )
	placeable;

var StaticMeshComponent BaseMesh;
var MaterialInstanceConstant BaseMaterial;
var LinearColor BaseColor;

var bool IsEnabled;
var() bool DrawTriggerRadius;
var() float TriggerRadiusUnrealUnits;

var() int LevelSectionID;
var() int NextLevelSectionID;
var() bool NeedsObjectiveToTransition;
var() int SecondsAddedToTimerOnTransition;
var() int SecondsTakenToTransition;

//----------------------------------------------------------------------------------------------------------
simulated function PostBeginPlay()
{
	local vector TopOfCylinder, BottomOfCylinder;
	TopOfCylinder = self.location;
	TopOfCylinder.z += 60.0;
	BottomOfCylinder = self.location;
	BottomOfCylinder.z -= 60.0;

	BaseMaterial = new class'MaterialInstanceConstant';
	BaseMaterial.SetParent( BaseMesh.GetMaterial(0) );
	BaseMesh.SetMaterial( 0, BaseMaterial );
	BaseMesh.SetScale( BaseMesh.Scale * TriggerRadiusUnrealUnits * 0.01 );
	ResetColor();

	super.PostBeginPlay();
	
	if( DrawTriggerRadius )
		DrawDebugCylinder( BottomOfCylinder, TopOfCylinder, TriggerRadiusUnrealUnits, 40, 255, 255, 255, true );

	if ( Role < ROLE_Authority )
		return;

	SSG_GameInfo( WorldInfo.Game ).RegisterSectionExit( self );
}

//----------------------------------------------------------------------------------------------------------
function bool PawnIsInRadius( Pawn ChosenPawn )
{
	local Vector VectorToChosenPawn;

	VectorToChosenPawn = ChosenPawn.Location - Location;
	if( VSize( VectorToChosenPawn ) < TriggerRadiusUnrealUnits )
		return true;

	return false;
}

//----------------------------------------------------------------------------------------------------------
function AddColor( LinearColor ColorToAdd )
{
	BaseColor.R += ColorToAdd.R;
	BaseColor.G += ColorToAdd.G;
	BaseColor.B += ColorToAdd.B;

	BaseMaterial.SetVectorParameterValue( 'SwirlAColor', BaseColor );
	BaseMaterial.SetVectorParameterValue( 'SwirlBColor', BaseColor );
}

//----------------------------------------------------------------------------------------------------------
function ResetColor()
{
	BaseColor.R = 0.0;
	BaseColor.G = 0.0;
	BaseColor.B = 0.0;

	BaseMaterial.SetVectorParameterValue( 'SwirlAColor', BaseColor );
	BaseMaterial.SetVectorParameterValue( 'SwirlBColor', BaseColor );
}

//----------------------------------------------------------------------------------------------------------
function SetColor( float red, float green, float blue )
{
	BaseColor.R = red;
	BaseColor.G = green;
	BaseColor.B = blue;

	BaseMaterial.SetVectorParameterValue( 'SwirlAColor', BaseColor );
	BaseMaterial.SetVectorParameterValue( 'SwirlBColor', BaseColor );
}

//----------------------------------------------------------------------------------------------------------
function TriggerTransitionEvent()
{
	TriggerEventClass( class'SSG_SeqEvent_TransitionStart', self );
}

//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	IsEnabled=true
	
	DrawTriggerRadius=false
	TriggerRadiusUnrealUnits=100

	LevelSectionID=0
	NextLevelSectionID=0
	NeedsObjectiveToTransition=false;
	SecondsAddedToTimerOnTransition=30;
	SecondsTakenToTransition=7.0;

	Begin Object Name=Sprite
		Sprite=Texture2D'EditorSprites.NextArea'
		Scale=0.25
	End Object
	
	Begin Object Class=StaticMeshComponent Name=BaseMeshComponent
		StaticMesh=StaticMesh'AK_Decoration_Pieces.siphon_circle.AK_SiphonCircle_Mesh_Purple_01'
		Materials(0)=Material'AK_Decoration_Pieces.siphon_circle.AK_SiphonCircle'
		Scale=0.5
	End Object
	Components.Add( BaseMeshComponent )
	BaseMesh = BaseMeshComponent

	SupportedEvents.Add( class'SSG_SeqEvent_TransitionStart' )
}
