package
{
	import fl.transitions.easing.*;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.utils.Timer;
	import scaleform.clik.constants.InputValue;
	import scaleform.clik.constants.NavigationCode;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.InputEvent;
	import scaleform.clik.managers.InputDelegate;
	import scaleform.gfx.Extensions;
	import scaleform.gfx.FocusManager;
	import PlayUDKSound;
	
	public class PlayerScorecard extends MovieClip
	{
		private static const FRAME_None:uint = 0;
		private static const FRAME_Stats:uint = 1;
		private static const FRAME_Titles:uint = 2;
		private static const FRAME_Ready:uint = 3;
		
		public var text_name:TextField;
		public var mc_place_indicator:PlaceIndicator;
		public var mc_stats_frame:MovieClip;
		public var mc_titles_frame:MovieClip;
		public var mc_ready_frame:MovieClip;
		public var mc_image_background:MovieClip;
		
		private var background_color:ColorTransform;
		public var controller_id:uint;
		private var current_frame:uint;
		private var enable_inputs_timer:Timer;
		
		//List Item Tweening
		private var hide_list_items_timer:Timer;
		private var show_medal_tween:Tween;
		private var show_stat_item_tween:Tween;
		private var next_list_index_to_animate:int;
		
		private var transition_in_alpha_tween:Tween;
		private var transition_in_move_tween:Tween;
		private var transition_in_rotate_tween:Tween;
		
		private var transition_out_alpha_tween:Tween;
		private var transition_out_move_tween:Tween;
		private var transition_out_rotate_tween:Tween;
		
		//---------------------------------------------------------------------------------------------------
		// Constructor
		public function PlayerScorecard()
		{
			current_frame = FRAME_None;
			
			background_color = new ColorTransform();
			background_color.color = 0xffffff;
			
			hide_list_items_timer = new Timer( 100, 1 );
			enable_inputs_timer = new Timer( 1000, 1 );
			enable_inputs_timer.addEventListener( TimerEvent.TIMER_COMPLETE, AllowInputs );
			
			SetPlayerPlace( 4 );
			
			mc_place_indicator.alpha = 0;
			mc_stats_frame.alpha = 0;
			mc_stats_frame.rotationY = -90;
			mc_titles_frame.alpha = 0;
			mc_titles_frame.rotationY = -90;
			mc_ready_frame.alpha = 0;
			
			TransitionToStatsFrame();
		}
		
		
		
		//++++++++++++++++++++++++++++++++++++++++ Animation Events ++++++++++++++++++++++++++++++++++++++++++++++
		//---------------------------------------------------------------------------------------------------
		private function HideListItems( timer_event:TimerEvent )
		{
			for( var i:uint = 0; i < mc_stats_frame.mc_list.dataProvider.length; ++i )
			{
				mc_stats_frame.mc_list.getRendererAt( i ).alpha = 0;
			}
		}
		
		//---------------------------------------------------------------------------------------------------
		public function StartListItemTweening()
		{
			next_list_index_to_animate = -1;
			AnimateNextItem( null );
		}
		
		//---------------------------------------------------------------------------------------------------
		private function AnimateNextItem( tween_event:TweenEvent )
		{
			++next_list_index_to_animate;
			if( mc_stats_frame.mc_list.dataProvider.length > next_list_index_to_animate )
			{
				show_stat_item_tween = new Tween( mc_stats_frame.mc_list.getRendererAt( next_list_index_to_animate ), "alpha", Regular.easeOut, 0.0, 1.0, 1.0, true );
				show_stat_item_tween.addEventListener( TweenEvent.MOTION_FINISH, AnimateNextItem );
				
				if( next_list_index_to_animate + 1 == mc_stats_frame.mc_list.dataProvider.length )
				{
					show_medal_tween = new Tween( mc_place_indicator, "alpha", Regular.easeOut, 0.0, 1.0, 1.0, true );
					show_stat_item_tween.addEventListener( TweenEvent.MOTION_FINISH, AllowInputs );
					PlayUDKSound( "MenuSounds", "TotalShowCue" );
					ExternalInterface.call( "PlayVictorySound" );
				}
				else if( next_list_index_to_animate + 2 == mc_stats_frame.mc_list.dataProvider.length )
				{
					PlayUDKSound( "MenuSounds", "MultiplierShowCue" );
				}
				else
				{
					PlayUDKSound( "MenuSounds", "StatShowCue" );
				}
			}
		}
		
		//---------------------------------------------------------------------------------------------------
		private function AllowInputs( event:Event )
		{
			InputDelegate.getInstance().addEventListener( InputEvent.INPUT, HandleButtonPresses );
		}
		
		//---------------------------------------------------------------------------------------------------
		private function DisallowInputs()
		{
			InputDelegate.getInstance().removeEventListener( InputEvent.INPUT, HandleButtonPresses );
			enable_inputs_timer.start();
		}
		
		
		
		//++++++++++++++++++++++++++++++++++++++++ Input Events ++++++++++++++++++++++++++++++++++++++++++++++
		//---------------------------------------------------------------------------------------------------
		private function HandleButtonPresses( input_event:InputEvent )
		{
			if( input_event.details.value != InputValue.KEY_UP )
				return;
				
			if( input_event.details.controllerIndex != controller_id )
			{
				return;
			}
			
			if( current_frame == FRAME_Stats )
			{
				switch( input_event.details.navEquivalent )
				{
				case NavigationCode.RIGHT:
				case NavigationCode.GAMEPAD_A:
					TransitionToTitlesFrame();
					break;
				case NavigationCode.GAMEPAD_START:
					TransitionToReadyFrame();
					break;
				default:
					if( input_event.details.code == 68 ) // D key
					{
						TransitionToTitlesFrame();
					}
					break;
				}
			}
			else if( current_frame == FRAME_Titles )
			{
				switch( input_event.details.navEquivalent )
				{
				case NavigationCode.LEFT:
				case NavigationCode.GAMEPAD_B:
					TransitionToStatsFrame();
					break;
				case NavigationCode.GAMEPAD_A:
				case NavigationCode.GAMEPAD_START:
					TransitionToReadyFrame();
					break;
				default:
					if( input_event.details.code == 65 ) // A key
					{
						TransitionToStatsFrame();
					}
					break;
				}
			}
			else if( current_frame == FRAME_Ready )
			{
				switch( input_event.details.navEquivalent )
				{
				case NavigationCode.GAMEPAD_B:
					TransitionToStatsFrame();
					break;
				default:
					break;
				}
			}
		}
		
		
		
		//++++++++++++++++++++++++++++++++++++++++ Transitions ++++++++++++++++++++++++++++++++++++++++++++++
		//---------------------------------------------------------------------------------------------------
		public function TransitionToStatsFrame()
		{
			TransitionOutPreviousFrame();
			
			if( Extensions.isGFxPlayer )
				mc_stats_frame.text_title.text = "Stats:";
			ExternalInterface.call( "LocalizeAndPopulateStatsFrame", controller_id );
			
			FocusManager.setFocus( mc_stats_frame.mc_list, controller_id );
			FocusManager.setModalClip( mc_stats_frame.mc_list, controller_id );
			PlayUDKSound( "MenuSounds", "ScorecardTransition" );
			
			text_name.visible = true;
			mc_place_indicator.visible = true;
			
			transition_in_alpha_tween = new Tween( mc_stats_frame, "alpha", Regular.easeOut, 0.0, 1.0, 1.0, true );
			transition_in_move_tween = new Tween( mc_stats_frame, "x", Regular.easeOut, 125.0, 0.0, 1.0, true );
			transition_in_rotate_tween = new Tween( mc_stats_frame, "rotationY", Regular.easeOut, -90.0, 0.0, 1.0, true );
			mc_ready_frame.mc_sword_cross.gotoAndStop( 0 );
			current_frame = FRAME_Stats;
		}
		
		//---------------------------------------------------------------------------------------------------
		private function TransitionToTitlesFrame()
		{
			TransitionOutPreviousFrame();
			
			if( Extensions.isGFxPlayer )
				mc_titles_frame.text_title.text = "Titles Earned:";
			ExternalInterface.call( "LocalizeAndPopulateTitlesFrame", controller_id );
			
			FocusManager.setFocus( mc_titles_frame.mc_list, controller_id );
			FocusManager.setModalClip( mc_titles_frame.mc_list, controller_id );
			PlayUDKSound( "MenuSounds", "ScorecardTransition" );
			
			text_name.visible = true;
			mc_place_indicator.visible = true;
			
			transition_in_alpha_tween = new Tween( mc_titles_frame, "alpha", Regular.easeOut, 0.0, 1.0, 1.0, true );
			transition_in_move_tween = new Tween( mc_titles_frame, "x", Regular.easeOut, 125.0, 0.0, 1.0, true );
			transition_in_rotate_tween = new Tween( mc_titles_frame, "rotationY", Regular.easeOut, -90.0, 0.0, 1.0, true );
			mc_ready_frame.mc_sword_cross.gotoAndStop( 0 );
			current_frame = FRAME_Titles;
		}
		
		//---------------------------------------------------------------------------------------------------
		private function TransitionToReadyFrame()
		{
			TransitionOutPreviousFrame();
			
			ExternalInterface.call( "LocalizeReadyFrame", controller_id );
			
			FocusManager.setFocus( mc_ready_frame, controller_id );
			FocusManager.setModalClip( mc_ready_frame, controller_id );
			PlayUDKSound( "MenuSounds", "ScorecardTransition" );
			
			text_name.visible = false;
			mc_place_indicator.visible = false;
			
			transition_in_alpha_tween = new Tween( mc_ready_frame, "alpha", Regular.easeOut, 0.0, 1.0, 2.0, true );
			mc_ready_frame.mc_sword_cross.gotoAndPlay( 0 );
			current_frame = FRAME_Ready;
		}
		
		//---------------------------------------------------------------------------------------------------
		private function TransitionOutPreviousFrame()
		{
			switch( current_frame )
			{
			case FRAME_Stats:
				transition_out_alpha_tween = new Tween( mc_stats_frame, "alpha", Regular.easeOut, 1.0, 0.0, 1.0, true );
				transition_out_move_tween = new Tween( mc_stats_frame, "x", Regular.easeOut, 0.0, -125.0, 1.0, true );
				transition_out_rotate_tween = new Tween( mc_stats_frame, "rotationY", Regular.easeOut, 0.0, 90.0, 1.0, true );
				transition_out_alpha_tween.addEventListener( TweenEvent.MOTION_FINISH, AllowInputs );
				DisallowInputs();
				break;
			case FRAME_Titles:
				transition_out_alpha_tween = new Tween( mc_titles_frame, "alpha", Regular.easeOut, 1.0, 0.0, 1.0, true );
				transition_out_move_tween = new Tween( mc_titles_frame, "x", Regular.easeOut, 0.0, -125.0, 1.0, true );
				transition_out_rotate_tween = new Tween( mc_titles_frame, "rotationY", Regular.easeOut, 0.0, 90.0, 1.0, true );
				transition_out_alpha_tween.addEventListener( TweenEvent.MOTION_FINISH, AllowInputs );
				DisallowInputs();
				break;
			case FRAME_Ready:
				transition_out_alpha_tween = new Tween( mc_ready_frame, "alpha", Regular.easeOut, 1.0, 0.0, 1.0, true );
				transition_out_alpha_tween.addEventListener( TweenEvent.MOTION_FINISH, AllowInputs );
				DisallowInputs();
				break;
			case FRAME_None:
			default:
				break;
			}
		}
		
		
		
		//++++++++++++++++++++++++++++++++++++++++++ Setters ++++++++++++++++++++++++++++++++++++++++++++++++
		//---------------------------------------------------------------------------------------------------
		public function SetBackgroundColor( red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			background_color.redOffset   = red;
			background_color.greenOffset = green;
			background_color.blueOffset  = blue;
			background_color.alphaOffset = 0;
			
			mc_image_background.transform.colorTransform = background_color;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetStatData( stat_data:Array )
		{
			if( Extensions.isGFxPlayer )
			{
				var total_gold:uint = 0;
				for( var i:uint = 0; i < stat_data.length; ++i )
				{
					if( ( stat_data[i].gold.charAt(0) == 'x' ) || ( stat_data[i].gold.charAt(0) == 'X' ) ) //x indicates Multiplier
						total_gold *= uint( stat_data[i].gold.slice( 1 ) );
					else
						total_gold += uint( stat_data[i].gold );
				}
				var total_object:Object = new Object();
				total_object.label = "Total:";
				total_object.score = "";
				total_object.gold = total_gold;
				stat_data.push( total_object );
			}
			
			var stat_data_provider:DataProvider = new DataProvider( stat_data );
			mc_stats_frame.mc_list.dataProvider = stat_data_provider;
			mc_stats_frame.mc_list.selectedIndex = 0;
			
			hide_list_items_timer.addEventListener( TimerEvent.TIMER_COMPLETE, HideListItems );
			hide_list_items_timer.start();
			
			if( Extensions.isGFxPlayer )
			{
				stat_data.pop();
			}
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetTitleData( title_data:Array )
		{
			var title_data_provider:DataProvider = new DataProvider( title_data );
			
			mc_titles_frame.mc_list.dataProvider = title_data_provider;
			mc_titles_frame.mc_list.selectedIndex = 0;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetPlayerPlace( place:uint )
		{
			mc_place_indicator.SetPlace( place );
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetPlayerName( player_name:String )
		{
			text_name.text = player_name;
		}
	}
}
