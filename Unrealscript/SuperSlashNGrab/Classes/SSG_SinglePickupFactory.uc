class SSG_SinglePickupFactory extends UDKPickupFactory
	abstract;

var int NumberOfTimesPickedUp;

function PickedUpBy(Pawn P)
{
	++numberOfTimesPickedUp;

	super.PickedUpBy(P);
	PlaySound( InventoryType.default.PickupSound );
}

function SetRespawn()
{
	if( numberOfTimesPickedUp > 0 )
		GotoState('Disabled');
	else if( WorldInfo.Game.ShouldRespawn(self) )
		StartSleeping();
	else
		GotoState('Disabled');
}

DefaultProperties
{
	NumberOfTimesPickedUp = 0 //Counter -- do not change
}
