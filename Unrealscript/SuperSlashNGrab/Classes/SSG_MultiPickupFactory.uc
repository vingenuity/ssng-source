class SSG_MultiPickupFactory extends UDKPickupFactory
	abstract;

var() int MaxNumberOfPickups;
var int NumberOfTimesPickedUp;

function PickedUpBy(Pawn P)
{
	++NumberOfTimesPickedUp;

	super.PickedUpBy(P);
	PlaySound( InventoryType.default.PickupSound );
}

function SetRespawn()
{
	if( MaxNumberOfPickups > 0 && numberOfTimesPickedUp >= MaxNumberOfPickups )
		GotoState('Disabled');

	StartSleeping();
}

DefaultProperties
{
	MaxNumberOfPickups=0
	NumberOfTimesPickedUp=0 //Counter -- do not change
}
