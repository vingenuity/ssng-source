class SSG_Inventory_Objective extends SSG_Inventory_Base
	abstract;

var PrimitiveComponent AttachmentMesh;
var Rotator AttachmentMeshRotationOffset;
var Vector AttachmentMeshTranslationOffset;

function GiveObjectiveTo( Pawn Other )
{
	local SSG_Pawn SSGOther;

	SSGOther = SSG_Pawn( Other );
	if ( SSGOther != None )
	{
		GiveTo( Other );
		SSGOther.UpdateObjectiveMesh( self );
	}
}

DefaultProperties
{
	bDropOnDeath=true
	RespawnTime=9999

	DroppedPickupClass=class'SSG_DroppedPickup_Objective'

	PickupSound=SoundCue'MiscSounds.coins'

	Begin Object Class=StaticMeshComponent Name=TreasurePickupMesh
		StaticMesh=StaticMesh'AK_Pickups.StaticMeshes.AK_PickupBase_Mesh_Placeholder'
		BlockActors=false
		Scale=1.5
	End Object
	Components.Add( TreasurePickupMesh )
	AttachmentMesh=TreasurePickupMesh
	DroppedPickupMesh=TreasurePickupMesh
	PickupFactoryMesh=TreasurePickupMesh

	AttachmentMeshRotationOffset=(Pitch=0,Roll=0,Yaw=0)
	AttachmentMeshTranslationOffset=(X=-30.0,Y=0.0,Z=50.0)
}
