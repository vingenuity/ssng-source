class SSG_SeqAction_ActivateTrap extends SequenceAction;

//----------------------------------------------------------------------------------------------------------
var SSG_Trap_Base Trap;


//----------------------------------------------------------------------------------------------------------
event Activated()
{
	if( Trap != None )
		Trap.bTrapActive = true;
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	ObjName="Activate Trap"
	ObjCategory="SSG Actions"

	VariableLinks(0)=( ExpectedType=class'SeqVar_Object', LinkDesc="SSG Trap", bWriteable=false, PropertyName=trap )
}
