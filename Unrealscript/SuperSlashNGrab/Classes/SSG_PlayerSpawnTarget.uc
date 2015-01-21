class SSG_PlayerSpawnTarget extends Actor
	placeable;

//----------------------------------------------------------------------------------------------------------
var() StaticMeshComponent		TargetMesh;
var() PointLightComponent		TargetLight;
var MaterialInstanceConstant    TargetMIC;

//----------------------------------------------------------------------------------------------------------
function SetColor( int PlayerNum )
{
	local float LightBrightness;
	local Color PlayerColor;
	local LinearColor LinearPlayerColor;

	TargetMIC = new class'MaterialInstanceConstant';
	TargetMIC.SetParent( TargetMesh.GetMaterial(0) );
	TargetMesh.SetMaterial( 0, TargetMIC );
	LinearPlayerColor = class'SSG_PlayerController'.default.PlayerColors[PlayerNum];
	TargetMIC.SetVectorParameterValue( 'Player_Color', LinearPlayerColor);
	
	PlayerColor.R = LinearPlayerColor.R * 255;
	PlayerColor.G = LinearPlayerColor.G * 255;
	PlayerColor.B = LinearPlayerColor.B * 255;
	PlayerColor.A = LinearPlayerColor.A * 255;

	if( PlayerNum == 0 )
		LightBrightness = 2.2;
	else if( PlayerNum == 1 )
		LightBrightness = 1.5;
	else if( PlayerNum == 2 )
		LightBrightness = 2.0;
	else
		LightBrightness = 1.0;

	TargetLight.SetLightProperties( LightBrightness, PlayerColor );
}


//----------------------------------------------------------------------------------------------------------
event Touch( Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal )
{
	Super.Touch( Other, OtherComp, HitLocation, HitNormal );

	if( Other.IsA( 'SSG_Proj_Barrel' ) )
	{
		if( Owner.IsA( 'SSG_POI_PlayerStart' ) )
		{
			SSG_POI_PlayerStart( Owner ).Target = None;
		}
		Destroy();
	}
}


//----------------------------------------------------------------------------------------------------------
function SetLight( bool bLightOn )
{
	TargetLight.SetEnabled( bLightOn );
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	bBlockActors=true
	bCollideActors=true

	Begin Object Class=StaticMeshComponent Name=TargetMeshComponent
		BlockActors=true
		CollideActors=true
		StaticMesh=StaticMesh'SSG_Character_Particles.RespawnBarrels.SSG_Props_RespawnBarrel_01'
	End Object
	TargetMesh=TargetMeshComponent
	Components.Add(TargetMeshComponent)

	Begin Object Class=PointLightComponent Name=TargetLightComponent
		bEnabled=false
		CastDynamicShadows=false
		FalloffExponent=10.0
		Translation=(X=0.0,Y=0.0,Z=120.0)
	End Object
	TargetLight=TargetLightComponent;
	Components.Add(TargetLightComponent);
}
