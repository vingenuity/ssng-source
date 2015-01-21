class SSG_CornerRug extends Actor
	placeable;

//----------------------------------------------------------------------------------------------------------
var() Color						RugColor;
var() StaticMeshComponent		StaticMesh;
var MaterialInstanceConstant    MIC;


//----------------------------------------------------------------------------------------------------------
function PostBeginPlay()
{
	local LinearColor LinearRugColor;

	Super.PostBeginPlay();
	MIC = new class'MaterialInstanceConstant';
	MIC.SetParent( StaticMesh.GetMaterial(0) );
	StaticMesh.SetMaterial( 0, MIC );

	LinearRugColor.R = RugColor.R / 255.0;
	LinearRugColor.G = RugColor.G / 255.0;
	LinearRugColor.B = RugColor.B / 255.0;
	LinearRugColor.A = RugColor.A / 255.0;
	MIC.SetVectorParameterValue( 'Carpet Color', LinearRugColor );
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	bCollideActors=true

	RugColor=(R=255,G=255,B=255,A=255)

	Begin Object Class=StaticMeshComponent Name=RugStaticMeshComponent
		CollideActors=true
		BlockActors=true
		StaticMesh=StaticMesh'SSG_Architecture_01.Meshes.SSG_Environment_Carpet_TransitionRoom_01'
	End Object
	StaticMesh=RugStaticMeshComponent
	Components.Add(RugStaticMeshComponent)
}
