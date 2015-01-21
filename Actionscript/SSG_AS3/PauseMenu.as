package
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.gfx.Extensions;
	import scaleform.gfx.FocusManager;

	public class PauseMenu extends MovieClip
	{
		public var text_title:TextField;
		public var mc_button_frame:MovieClip;
		public var mc_image_background:MovieClip;
		public var options_popup:OptionDialog;
		
		public var confirmation_popup:ConfirmationDialog;
		
		private var pausing_player_controller_id;


		//Constructor
		//---------------------------------------------------------------------------------------------------
		public function PauseMenu()
		{
			options_popup.pausing_player_controller_id = pausing_player_controller_id;
			addEventListener( ButtonEvent.CLICK, HandleButtonPress );
			options_popup.addEventListener( ButtonEvent.CLICK, HandleOptionsButtonPress );
			InputDelegate.getInstance().addEventListener( InputEvent.INPUT, HandleInput );
			
			options_popup.addEventListener( "OptionMenuClose", CleanupOptionsDialog );
			
			options_popup.visible = false;
			if( Extensions.isGFxPlayer )
			{
				SetPausingPlayerID( 0 );
			}
		}
		
		//---------------------------------------------------------------------------------------------------
		public function CleanupConfirmationDialog()
		{
			confirmation_popup.removeEventListener( ButtonEvent.CLICK, HandleConfirmationButtonPress );
			removeChild( confirmation_popup );
			confirmation_popup = null;
			addEventListener( ButtonEvent.CLICK, HandleButtonPress ); //Respond to main pause buttons again
			
			FocusManager.setModalClip( this, pausing_player_controller_id );
			FocusManager.setFocus( mc_button_frame.mc_button_resume, pausing_player_controller_id );
		}
		
		//---------------------------------------------------------------------------------------------------
		public function CleanupOptionsDialog()
		{
			ExternalInterface.call( "LocalizePauseMenu" );
			FocusManager.setModalClip( this, pausing_player_controller_id );
			FocusManager.setFocus( mc_button_frame.mc_button_resume, pausing_player_controller_id );
			options_popup.visible = false;
			ExternalInterface.call( "LeaveOptionsMenu" );
		}
		
		
		
		//Events
		//---------------------------------------------------------------------------------------------------
		public function HandleButtonPress( button_event:ButtonEvent )
		{
			if( button_event.target == mc_button_frame.mc_button_resume )
			{
				ResumeGame();
				FocusManager.setFocus( mc_button_frame.mc_button_resume, pausing_player_controller_id );
				return;
			}
			else if( button_event.target == mc_button_frame.mc_button_options )
			{
				ExternalInterface.call( "LocalizeTopOptions" );
				options_popup.visible = true;
				options_popup.ActivateButtonInput();
				options_popup.TransitionToTopOptions( button_event );
				FocusManager.setModalClip( options_popup, pausing_player_controller_id );
				FocusManager.setFocus( options_popup.mc_options_frame.button_options_video, pausing_player_controller_id );
				ExternalInterface.call( "EnterOptionsMenu" );
			}
			else if( button_event.target == mc_button_frame.mc_button_map )
			{
				confirmation_popup = new ConfirmationDialog( pausing_player_controller_id, ConfirmationDialog.TYPE_RETURN );
				
				addChild( confirmation_popup );
				ExternalInterface.call( "LocalizeConfirmationPopup" );
				confirmation_popup.addEventListener( ButtonEvent.CLICK, HandleConfirmationButtonPress );
				removeEventListener( ButtonEvent.CLICK, HandleButtonPress ); //Don't respond to main pause buttons while popup is in play
				FocusManager.setModalClip( confirmation_popup, pausing_player_controller_id );
				FocusManager.setFocus( confirmation_popup.mc_confirm_frame.button_no, pausing_player_controller_id );
			}
			else if( button_event.target == mc_button_frame.mc_button_main_menu )
			{
				confirmation_popup = new ConfirmationDialog( pausing_player_controller_id, ConfirmationDialog.TYPE_MENU );
				
				addChild( confirmation_popup );
				ExternalInterface.call( "LocalizeConfirmationPopup" );
				confirmation_popup.addEventListener( ButtonEvent.CLICK, HandleConfirmationButtonPress );
				removeEventListener( ButtonEvent.CLICK, HandleButtonPress ); //Don't respond to main pause buttons while popup is in play
				FocusManager.setModalClip( confirmation_popup, pausing_player_controller_id );
				FocusManager.setFocus( confirmation_popup.mc_confirm_frame.button_no, pausing_player_controller_id );
			}
			else if( button_event.target == mc_button_frame.mc_button_quit )
			{
				confirmation_popup = new ConfirmationDialog( pausing_player_controller_id, ConfirmationDialog.TYPE_QUIT );
				
				addChild( confirmation_popup );
				ExternalInterface.call( "LocalizeConfirmationPopup" );
				confirmation_popup.addEventListener( ButtonEvent.CLICK, HandleConfirmationButtonPress );
				removeEventListener( ButtonEvent.CLICK, HandleButtonPress ); //Don't respond to main pause buttons while popup is in play
				FocusManager.setModalClip( confirmation_popup, pausing_player_controller_id );
				FocusManager.setFocus( confirmation_popup.mc_confirm_frame.button_no, pausing_player_controller_id );
			}
			else
				return;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function HandleConfirmationButtonPress( button_event:ButtonEvent )
		{
			if( button_event.target == confirmation_popup.mc_confirm_frame.button_yes )
			{
				if( confirmation_popup.type == ConfirmationDialog.TYPE_RETURN )
					ReturnToMap();
				else if( confirmation_popup.type == ConfirmationDialog.TYPE_MENU )
					ReturnToMainMenu();
				else
					QuitGame();
			}
			
			CleanupConfirmationDialog();
		}
		
		//---------------------------------------------------------------------------------------------------
		public function HandleOptionsButtonPress( button_event:ButtonEvent )
		{
			if( button_event.target == options_popup.mc_options_frame.button_back_main_menu )
			{
				CleanupOptionsDialog();
			}
		}
		
		//---------------------------------------------------------------------------------------------------
		public function HandleInput( input_event:InputEvent )
		{
			if( input_event.details.value != InputValue.KEY_UP )
				return;
				
			if( input_event.details.controllerIndex != pausing_player_controller_id )
				return;
				
			switch( input_event.details.code )
			{
			case 87: //W
				FocusManager.moveFocus( "up" );
				break;
			case 83: //S
				FocusManager.moveFocus( "down" );
				break;
			default:
				break;
			}
			
			if( confirmation_popup == null )
			{
				switch( input_event.details.navEquivalent )
				{
				case NavigationCode.GAMEPAD_B:
				case NavigationCode.GAMEPAD_START:
					ResumeGame();
					break;
				default:
					return;
				}
			}
			else
			{
				switch( input_event.details.navEquivalent )
				{
				case NavigationCode.GAMEPAD_B:
					CleanupConfirmationDialog();
					break;
				case NavigationCode.GAMEPAD_START:
					CleanupConfirmationDialog();
					ResumeGame();
					break;
				default:
					return;
				}
			}
		}
		
		
		//External Interface Wrappers
		//---------------------------------------------------------------------------------------------------
		public function ResumeGame()
		{
			ExternalInterface.call( "TogglePauseMenu" );
		}
		
		//---------------------------------------------------------------------------------------------------
		public function ReturnToMainMenu()
		{
			ExternalInterface.call( "ReturnToMainMenu" );
		}
		
		//---------------------------------------------------------------------------------------------------
		public function ReturnToMap()
		{
			ExternalInterface.call( "ReturnToMap" );
		}
		
		//---------------------------------------------------------------------------------------------------
		public function QuitGame()
		{
			ExternalInterface.call( "SafelyQuitGame" );
		}
		
		
		
		//Setters
		//---------------------------------------------------------------------------------------------------
		public function SetTextColor( red:uint = 255, green:uint = 255, blue:uint = 255 )
		{
			text_title.textColor = ( red << 16 ) + ( green << 8 ) + blue;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetTitleText( new_text:String )
		{
			text_title.text = new_text;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetResumeText( new_text:String )
		{
			mc_button_frame.mc_button_resume.label = new_text;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetReturnText( new_text:String )
		{
			mc_button_frame.mc_button_map.label = new_text;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetQuitText( new_text:String )
		{
			mc_button_frame.mc_button_quit.label = new_text;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetPausingPlayerID( pauser_id:uint )
		{
			pausing_player_controller_id = pauser_id;
			options_popup.pausing_player_controller_id = pausing_player_controller_id;
			FocusManager.setFocus( mc_button_frame.mc_button_resume, pausing_player_controller_id );
			FocusManager.setFocusGroupMask( stage, 0x1 << pausing_player_controller_id ); //Set focus mask for scorecard 1 to player 1 only (first bit only)
		}
	}
}
