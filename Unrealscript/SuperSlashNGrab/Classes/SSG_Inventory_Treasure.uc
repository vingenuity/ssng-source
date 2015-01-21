class SSG_Inventory_Treasure extends SSG_Inventory_Base
	abstract;

var int MonetaryValue;

DefaultProperties
{
	bDropOnDeath = true
	RespawnTime = 9999

	MonetaryValue = 1

	DroppedPickupClass = class'SSG_DroppedPickup_Treasure'

	PickupSound=SoundCue'MiscSounds.coins'

	Begin Object Class=StaticMeshComponent Name=TreasurePickupMesh
		StaticMesh=StaticMesh'SSG_Pickups.Meshes.SSG_Loot_Coin_01'
	End Object
	Components.Add( TreasurePickupMesh )
	DroppedPickupMesh = TreasurePickupMesh
	PickupFactoryMesh = TreasurePickupMesh
	bBlockActors = false
	bNoEncroachCheck = true
}
