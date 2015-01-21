class SSG_Pawn_BowBot extends SSG_Pawn_Bot;

//----------------------------------------------------------------------------------------------------------
function AddDefaultInventory()
{
	InvManager.CreateInventory( class'SuperSlashNGrab.SSG_Weap_Bow' );
}

//----------------------------------------------------------------------------------------------------------
function bool BotFire(bool bFinished)
{
	SSG_Weap_Bow(Weapon).FireInterval[0] = 0.8;
	SSG_Weap_Bow(Weapon).FireInterval[1] = 0.8;
	StartFire(1);
	return true;
}

//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	Begin Object Name=PawnSkeletalMesh
	  	SkeletalMesh=SkeletalMesh'SSG_Characters.Guard.SSG_Character_CrossbowGuard_01'
    	Materials(0)=Material'SSG_Characters.Guard.SSG_Character_CrossbowGuard_MAT_01'
		PhysicsAsset=PhysicsAsset'SSG_Characters.guard.SSG_Character_Guard_Crossbow_PHS_01'
	End Object
	
	Health=1
	RangeToBeginAttacking = 768
	bHasSecondaryWeapon=true
}
