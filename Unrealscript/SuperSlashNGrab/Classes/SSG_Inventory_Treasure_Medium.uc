class SSG_Inventory_Treasure_Medium extends SSG_Inventory_Treasure;

DefaultProperties
{
	MonetaryValue = 500

	PickupSound=SoundCue'MiscSounds.Coin2CUE'

	Begin Object Name=TreasurePickupMesh
		StaticMesh=StaticMesh'SSG_Pickups.Meshes.SSG_Loot_GoldBar'
	End Object
}
