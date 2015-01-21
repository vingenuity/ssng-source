package
{
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.gfx.Extensions;
	import scaleform.gfx.FocusEventEx;
	import scaleform.gfx.FocusManager;
	import PlayUDKSound;
	
	public class NameEntryFrame extends MovieClip
	{
		public var text_enter_name:TextField;
		public var text_input_name:NameInput;
		public var mc_keyboard:OSKButtonFrame;
		public var last_focus_change_time:int;
		
		public var last_focus:InteractiveObject;
		
		// Constructor
		public function NameEntryFrame()
		{
			Extensions.enabled = true;
			
			last_focus = mc_keyboard.mc_a_button;
			last_focus_change_time = getTimer();
			mc_keyboard.addEventListener( ButtonEvent.CLICK, AddPressedKeyToName );
			mc_keyboard.addEventListener( InputEvent.INPUT, HandleButtonPresses );
			addEventListener( FocusEvent.FOCUS_IN, OnFocusChange );
		}
		
		
		
		//---------------------------------------------------------------------------------------------------
		private function OnFocusChange( focus_event:FocusEvent )
		{
			if( FocusEventEx( focus_event ).controllerIdx != ThiefSelectionArea( this.parent ).controller_id )
				return;
			last_focus_change_time = getTimer();
			last_focus = focus_event.target as InteractiveObject;
		}
		
		//---------------------------------------------------------------------------------------------------
		private function AddPressedKeyToName( button_event:ButtonEvent )
		{
			if( button_event.target.data == "<" )
				HandleBackPress();
			else if( button_event.target.data == "/" )
				HandleGoPress();
			else if( text_input_name.text.length < text_input_name.maxChars )
				text_input_name.text += button_event.target.data;
		}
		
		//Wrapping has been disabled because UDK's implementation of FocusManager.getFocus() isn't working for players 2-4.
		//---------------------------------------------------------------------------------------------------
		private function HandleButtonPresses( input_event:InputEvent )
		{
			if( input_event.details.value != InputValue.KEY_UP )
				return;
			
			const MIN_MS_BETWEEN_FOCUS_CHANGES:int = 200;
			var msSinceLastFocusChange:int = getTimer() - last_focus_change_time;
			var curFocus:InteractiveObject = FocusManager.getFocus( ThiefSelectionArea( this.parent ).controller_id );
			
			input_event.stopPropagation(); //this prevents double frame changes when we return to the previous frame
			
			switch( input_event.details.navEquivalent )
			{
			case NavigationCode.UP:
				//if( msSinceLastFocusChange > MIN_MS_BETWEEN_FOCUS_CHANGES )
					//WrapUpperEdge( curFocus );
				return;
			case NavigationCode.DOWN:
				//if( msSinceLastFocusChange > MIN_MS_BETWEEN_FOCUS_CHANGES )
					//WrapLowerEdge( curFocus );
				return;
			case NavigationCode.LEFT:
				//if( msSinceLastFocusChange > MIN_MS_BETWEEN_FOCUS_CHANGES )
					//WrapLeftEdge( curFocus );
				return;
			case NavigationCode.RIGHT:
				//if( msSinceLastFocusChange > MIN_MS_BETWEEN_FOCUS_CHANGES )
					//WrapRightEdge( curFocus );
				return;
			case NavigationCode.GAMEPAD_B:
				HandleBackPress();
				return;
			case NavigationCode.GAMEPAD_START:
				HandleGoPress();
				return;
			default:
				break;
			}
			
			if( curFocus == null )
			{
				FocusManager.setFocus( last_focus, input_event.details.controllerIndex );
				curFocus = last_focus;
			}

			if( curFocus != null )
			{
				switch( input_event.details.code )
				{
				case 87: //W
					//if( !WrapUpperEdge( curFocus ) )
						FocusManager.moveFocus( "up" );
					break;
					
				case 83: //S
					//if( !WrapLowerEdge( curFocus ) )
						FocusManager.moveFocus( "down" );
					break;
					
				case 65: //A
					//if( !WrapLeftEdge( curFocus ) )
						FocusManager.moveFocus( "left" );
					break;
					
				case 68: //D
					//if( !WrapRightEdge( curFocus ) )
						FocusManager.moveFocus( "right" );
					break;
					
				default:
					break;
				}
			}
		}
		
		//---------------------------------------------------------------------------------------------------
		private function HandleBackPress()
		{
			if( text_input_name.text.length == 0 )
			{
				//trace( "Dispatching rejection event" );
				dispatchEvent( new NameEntryEvent( NameEntryEvent.ENTRY_REJECTED, "", true ) );
			}
			else
			{
				PlayUDKSound( "MenuSounds", "ThiefCardTransition" );
				RemoveLastLetterInName()
			}
		}
		
		//---------------------------------------------------------------------------------------------------
		private function HandleGoPress()
		{
			if( text_input_name.text.length == 0 )
				return; //You can't enter a blank name, silly!
			else
			{
				trace( "Dispatching accept event" );
				dispatchEvent( new NameEntryEvent( NameEntryEvent.ENTRY_ACCEPTED, text_input_name.text, true ) );
			}
		}
		
		//---------------------------------------------------------------------------------------------------
		private function RemoveLastLetterInName()
		{
			text_input_name.text = text_input_name.text.slice( 0, -1 );
		}
		
		
		
		//++++++++++++++++++++++++++++++++++++++++ Edge Wrapping ++++++++++++++++++++++++++++++++++++++++++++
		//---------------------------------------------------------------------------------------------------
		private function WrapUpperEdge( curFocus:InteractiveObject ):Boolean
		{
			if( curFocus == mc_keyboard.mc_a_button || curFocus == mc_keyboard.mc_b_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_back_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			else if( curFocus == mc_keyboard.mc_c_button || curFocus == mc_keyboard.mc_d_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_done_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
				
			return false;
		}
		
		//---------------------------------------------------------------------------------------------------
		private function WrapLowerEdge( curFocus:InteractiveObject ):Boolean
		{
			if( curFocus == mc_keyboard.mc_back_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_a_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			else if( curFocus == mc_keyboard.mc_done_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_c_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			return false;
		}
		
		//---------------------------------------------------------------------------------------------------
		private function WrapLeftEdge( curFocus:InteractiveObject ):Boolean
		{
			if( curFocus == mc_keyboard.mc_a_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_d_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			else if( curFocus == mc_keyboard.mc_e_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_h_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			else if( curFocus == mc_keyboard.mc_i_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_l_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			else if( curFocus == mc_keyboard.mc_m_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_p_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			else if( curFocus == mc_keyboard.mc_q_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_t_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			else if( curFocus == mc_keyboard.mc_u_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_x_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			else if( curFocus == mc_keyboard.mc_y_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_z_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			else if( curFocus == mc_keyboard.mc_back_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_done_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			return false;
		}
		
		//---------------------------------------------------------------------------------------------------
		private function WrapRightEdge( curFocus:InteractiveObject ):Boolean
		{
			if( curFocus == mc_keyboard.mc_d_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_a_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			else if( curFocus == mc_keyboard.mc_h_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_e_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			else if( curFocus == mc_keyboard.mc_l_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_i_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			else if( curFocus == mc_keyboard.mc_p_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_m_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			else if( curFocus == mc_keyboard.mc_t_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_q_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			else if( curFocus == mc_keyboard.mc_x_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_u_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			else if( curFocus == mc_keyboard.mc_z_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_y_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			else if( curFocus == mc_keyboard.mc_done_button )
			{
				FocusManager.setFocus( mc_keyboard.mc_back_button, ThiefSelectionArea( this.parent ).controller_id );
				return true;
			}
			return false;
		}
	}
}
