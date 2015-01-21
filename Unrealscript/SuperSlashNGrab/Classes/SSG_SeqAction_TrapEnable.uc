class SSG_SeqAction_TrapEnable extends SequenceAction;

//----------------------------------------------------------------------------------------------------------
var SSG_Trap_Base Trap;


//----------------------------------------------------------------------------------------------------------
event Activated()
{
	if( Trap != None )
		Trap.Enable( 'Tick' );
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	ObjName="Enable Trap"
	ObjCategory="SSG Actions"

	VariableLinks(0)=( ExpectedType=class'SeqVar_Object', LinkDesc="SSG Trap", bWriteable=false, PropertyName=trap )
}
