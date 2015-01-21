class SSG_SeqAction_TrapDisable extends SequenceAction;

//----------------------------------------------------------------------------------------------------------
var SSG_Trap_Base Trap;


//----------------------------------------------------------------------------------------------------------
event Activated()
{
	if( Trap != None )
		Trap.Disable( 'Tick' );
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	ObjName="Disable Trap"
	ObjCategory="SSG Actions"

	VariableLinks(0)=( ExpectedType=class'SeqVar_Object', LinkDesc="SSG Trap", bWriteable=false, PropertyName=trap )
}
