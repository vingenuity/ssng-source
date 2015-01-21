class SSG_InventoryManager extends InventoryManager;

//----------------------------------------------------------------------------------------------------------
function Inventory CreateInventoryArchetype( Inventory NewInventoryItemArchetype, optional bool bDoNotActivate )
{
    local Inventory Inv;

    if( NewInventoryItemArchetype != none )
    {
        Inv = Spawn( NewInventoryItemArchetype.Class, Owner,,,, NewInventoryItemArchetype );

        if( Inv != none )
        {
            if( !AddInventory( Inv, bDoNotActivate ) )
            {
                Inv.Destroy();
                Inv = none;
            }
        }
    }

    return Inv;
}


reliable client function SetCurrentWeapon(Weapon DesiredWeapon)
{
	// Switch to this weapon
	InternalSetCurrentWeapon(DesiredWeapon);

	// Tell the server we have changed the pending weapon
	if( Role < Role_Authority )
	{
		ServerSetCurrentWeapon(DesiredWeapon);
	}
}


simulated private function InternalSetCurrentWeapon(Weapon DesiredWeapon)
{
	local Weapon PrevWeapon;

	PrevWeapon = Instigator.Weapon;

	`LogInv("PrevWeapon:" @ PrevWeapon @ "DesiredWeapon:" @ DesiredWeapon);

	// Make sure we are switching to a new weapon
	// Handle the case where we're selecting again a weapon we've just deselected
	if( PrevWeapon != None && DesiredWeapon == PrevWeapon && !PrevWeapon.IsInState('WeaponPuttingDown') )
	{
		if(!DesiredWeapon.IsInState('Inactive') && !DesiredWeapon.IsInState('PendingClientWeaponSet'))
		{
			`LogInv("DesiredWeapon == PrevWeapon - abort"@DesiredWeapon.GetStateName());
			return;
		}
	}

	// Set the new weapon as pending
	SetPendingWeapon(DesiredWeapon);

	// if there is an old weapon handle it first.
	if( PrevWeapon != None && PrevWeapon != DesiredWeapon && !PrevWeapon.bDeleteMe && !PrevWeapon.IsInState('Inactive') )
	{
		// Try to put the weapon down.
		`LogInv("Try to put down previous weapon first.");
		PrevWeapon.TryPutdown();
	}
	//else
	//{
	//	// We don't have a weapon, force the call to ChangedWeapon
	//	ChangedWeapon();
	//}

	ChangedWeapon();
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	PendingFire(0) = 0

	bMustHoldWeapon=true
}
