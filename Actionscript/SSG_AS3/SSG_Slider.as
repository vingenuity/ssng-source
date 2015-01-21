package
{
	import flash.display.MovieClip;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.controls.Slider;
	import scaleform.clik.events.FocusHandlerEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.SliderEvent;
	import scaleform.gfx.Extensions;
	import PlayUDKSound;
	
	public class SSG_Slider extends Slider
	{
		// Constructor
		public function SSG_Slider()
		{
			super();
			
			Extensions.enabled = true;
			
			addEventListener( FocusHandlerEvent.FOCUS_IN, PlayFocusSound );
			addEventListener( SliderEvent.VALUE_CHANGE, PlayValueChangeSound );
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
				this.value -= this.snapInterval;
				break;
			case 68: //D
				this.value += this.snapInterval;
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
		
		function PlayValueChangeSound( slider_event:SliderEvent )
		{
			if( slider_event.type != SliderEvent.VALUE_CHANGE )
				return;
			
			PlayUDKSound( "MenuSounds", "SliderValueChanged" );
		}
	}
}
