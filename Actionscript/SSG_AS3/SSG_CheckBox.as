package
{
	import flash.display.MovieClip;
	import scaleform.clik.controls.CheckBox;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.FocusHandlerEvent;
	import scaleform.gfx.Extensions;
	import PlayUDKSound;
	
	public class SSG_CheckBox extends CheckBox
	{
		// Constructor
		public function SSG_CheckBox()
		{
			super();
			
			Extensions.enabled = true;
			
			addEventListener( ButtonEvent.CLICK, PlayClickSound );
			addEventListener( FocusHandlerEvent.FOCUS_IN, PlayFocusSound );
		}
		
		
		
		//Event Handlers
		function PlayClickSound( button_event:ButtonEvent )
		{
			if( button_event.type != ButtonEvent.CLICK )
				return;

			PlayUDKSound( "MenuSounds", "ButtonClicked" );
		}
		
		function PlayFocusSound( focus_event:FocusHandlerEvent )
		{
			if( focus_event.type != FocusHandlerEvent.FOCUS_IN )
				return;
			
			PlayUDKSound( "MenuSounds", "ScaleformFocused" );
		}
	}
	
}
