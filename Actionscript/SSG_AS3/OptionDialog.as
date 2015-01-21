package
{
	import flash.display.MovieClip;
	import flash.display.InteractiveObject;
	import flash.events.FocusEvent;
	import flash.external.ExternalInterface;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.gfx.FocusManager;
	import flash.events.Event;
	
	public class OptionDialog extends MovieClip
	{
		public var mc_options_frame:TopOptionsFrame;
		public var mc_options_video_frame:VideoOptionsFrame;
		public var mc_options_audio_frame:AudioOptionsFrame;
		public var mc_options_game_frame:GameplayOptionsFrame;
		
		private var current_frame:uint;
		const FRAME_TopOptions:uint = 1;
		const FRAME_VideoOptions:uint = 2;
		const FRAME_AudioOptions:uint = 3;
		const FRAME_GameplayOptions:uint = 4;
		
		public var pausing_player_controller_id:uint;
		
		var last_focus:InteractiveObject;
		
		
		// Constructor
		public function OptionDialog()
		{
			x = 0.0;
			y = 0.0;
			scaleX = 1.75;
			scaleY = 1.75;
			
			pausing_player_controller_id = 0;
			
			mc_options_frame.SetAudioOptionsPressFunction( TransitionToAudioOptions );
			mc_options_frame.SetGameplayOptionsPressFunction( TransitionToGameOptions );
			mc_options_frame.SetVideoOptionsPressFunction( TransitionToVideoOptions );
			
			mc_options_video_frame.SetAcceptPressFunction( VideoAcceptOptions );
			mc_options_video_frame.SetCancelPressFunction( TransitionToTopOptions );
			
			mc_options_audio_frame.SetAcceptPressFunction( AudioAcceptOptions );
			mc_options_audio_frame.SetCancelPressFunction( TransitionToTopOptions );
			
			mc_options_game_frame.SetAcceptPressFunction( GameAcceptOptions );
			mc_options_game_frame.SetCancelPressFunction( TransitionToTopOptions );
			
			addEventListener( FocusEvent.FOCUS_IN, OnFocusChange );
			
			ExternalInterface.call( "LocalizeTopOptions" );
			//TransitionToTopOptions( null );
		}
		
		//---------------------------------------------------------------------------------------------------
		function OnFocusChange( focus_event:FocusEvent )
		{
			last_focus = focus_event.target as InteractiveObject;
		}
		
		//---------------------------------------------------------------------------------------------------
		function ActivateButtonInput()
		{
			InputDelegate.getInstance().addEventListener( InputEvent.INPUT, HandleButtonInput );
		}
		
		//---------------------------------------------------------------------------------------------------
		function DeactivateButtonInput()
		{
			InputDelegate.getInstance().removeEventListener( InputEvent.INPUT, HandleButtonInput );
		}
		
		//Input Function
		//---------------------------------------------------------------------------------------------------
		function HandleButtonInput( input_event:InputEvent )
		{
			if( input_event.details.controllerIndex != pausing_player_controller_id )
				return;
			if( input_event.details.value != InputValue.KEY_UP )
				return;
			
			if( input_event.details.code == 27 || input_event.details.navEquivalent == NavigationCode.GAMEPAD_B )
			{
				switch( current_frame )
				{
				case FRAME_GameplayOptions:
				case FRAME_AudioOptions:
				case FRAME_VideoOptions:
					TransitionToTopOptions( null );
					break;
				case FRAME_TopOptions:
					DeactivateButtonInput();
					dispatchEvent( new Event( "OptionMenuClose" ) );
					break;
				default:
					break;
				}
				return;
			}
			else
			{
				var curFocus:InteractiveObject = FocusManager.getFocus( pausing_player_controller_id );
				if( curFocus == null )
				{
					FocusManager.setFocus( last_focus, pausing_player_controller_id );
				}
				
				if( pausing_player_controller_id != 0 )
					return;
			}
		}
		
		// Transitions
		public function TransitionToTopOptions( button_event:ButtonEvent )
		{
			ExternalInterface.call( "LocalizeTopOptions" );
			
			mc_options_frame.visible = true;
			mc_options_video_frame.visible = false;
			mc_options_audio_frame.visible = false;
			mc_options_game_frame.visible = false;
			
			current_frame = FRAME_TopOptions;
			FocusManager.setFocus( mc_options_frame.button_options_video, pausing_player_controller_id );
		}
		
		public function TransitionToVideoOptions( button_event:ButtonEvent )
		{
			ExternalInterface.call( "LocalizeVideoOptions" );
			ExternalInterface.call( "SetVideoSettingsFromUnrealSettings" );
			
			mc_options_frame.visible = false;
			mc_options_video_frame.visible = true;
			mc_options_audio_frame.visible = false;
			mc_options_game_frame.visible = false;
			
			current_frame = FRAME_VideoOptions;
			FocusManager.setFocus( mc_options_video_frame.mc_resolution_stepper, pausing_player_controller_id );
		}
		
		public function TransitionToAudioOptions( button_event:ButtonEvent )
		{
			ExternalInterface.call( "LocalizeAudioOptions" );
			ExternalInterface.call( "SetAudioSettingsFromUnrealSettings" );
			
			mc_options_frame.visible = false;
			mc_options_video_frame.visible = false;
			mc_options_audio_frame.visible = true;
			mc_options_game_frame.visible = false;
			
			current_frame = FRAME_AudioOptions;
			FocusManager.setFocus( mc_options_audio_frame.mc_slider_volume_music, pausing_player_controller_id );
		}
		
		public function TransitionToGameOptions( button_event:ButtonEvent )
		{
			ExternalInterface.call( "LocalizeGameplayOptions" );
			ExternalInterface.call( "SetGameplaySettingsFromUnrealSettings" );
			
			mc_options_frame.visible = false;
			mc_options_video_frame.visible = false;
			mc_options_audio_frame.visible = false;
			mc_options_game_frame.visible = true;
			
			current_frame = FRAME_GameplayOptions;
			FocusManager.setFocus( mc_options_game_frame.mc_language_stepper, pausing_player_controller_id );
		}
		
		public function AudioAcceptOptions( button_event:ButtonEvent )
		{
			ExternalInterface.call( "SetUnrealSettingsFromAudioSettings" );
			
			TransitionToTopOptions( button_event );
		}
		
		public function GameAcceptOptions( button_event:ButtonEvent )
		{
			ExternalInterface.call( "SetUnrealSettingsFromGameplaySettings" );
			
			TransitionToTopOptions( button_event );
		}
		
		public function VideoAcceptOptions( button_event:ButtonEvent )
		{
			ExternalInterface.call( "SetUnrealSettingsFromVideoSettings" );
			
			TransitionToTopOptions( button_event );
		}
	}
}
