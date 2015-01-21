package
{
	import flash.display.MovieClip;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.controls.OptionStepper;
	import scaleform.clik.events.FocusHandlerEvent;
	import scaleform.clik.events.IndexEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.gfx.Extensions;
	import PlayUDKSound;
	
	public class SSG_OptionStepper extends OptionStepper
	{
		// Constructor
		public function SSG_OptionStepper()
		{
			super();
			
			Extensions.enabled = true;
			
			addEventListener( FocusHandlerEvent.FOCUS_IN, PlayFocusSound );
			addEventListener( IndexEvent.INDEX_CHANGE, PlayIndexChangeSound );
			addEventListener( InputEvent.INPUT, HandleWASDSliding );
		}
		
		
		
		//Event Handlers
		function HandleWASDSliding( input_event:InputEvent )
		{
			if( input_event.details.value != InputValue.KEY_UP )
				return;
				
			switch( input_event.details.code )
			{
			case 65: //A
				--this.selectedIndex;
				break;
			case 68: //D
				++this.selectedIndex;
				break;
			default:
				break;
			}
        	input_event.stopImmediatePropagation();
		}
		
		function PlayFocusSound( focus_event:FocusHandlerEvent )
		{
			if( focus_event.type != FocusHandlerEvent.FOCUS_IN )
				return;
			
			PlayUDKSound( "MenuSounds", "ScaleformFocused" );
		}
		
		function PlayIndexChangeSound( index_event:IndexEvent )
		{
			if( index_event.type != IndexEvent.INDEX_CHANGE )
				return;

			PlayUDKSound( "MenuSounds", "OptionIndexChanged" );
		}
	}
}
