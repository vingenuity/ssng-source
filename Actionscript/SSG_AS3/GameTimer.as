package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Vector3D;
	import flash.utils.Timer;
	
	//---------------------------------------------------------------------------------------------------
	public class GameTimer extends MovieClip
	{
		private static const ONE_SECOND:int = 1000;
		private static const POPUP_SCALE:Number = 0.8;
		
		var popup_spawn_location:Vector3D;
		var popup_timer:Timer;
		var time_popups:Array;
		
		var tweening_down:Boolean;
		var siren_color:ColorTransform;
		var text_color:ColorTransform;
		
		
		
		//---------------------------------------------------------------------------------------------------
		public function GameTimer() //Constructor
		{
			siren_color = new ColorTransform();
			siren_color.color = 0xffffff;
			SetSirenColor( 255, 0, 0 );
			tweening_down = true;
			StopSiren();
			
			text_color = new ColorTransform();
			text_color.color = 0xffffff;
			SetTextColor( 255, 0, 0 );
			
			time_popups = new Array();
			
			popup_spawn_location = new Vector3D();
			popup_spawn_location.x = 0.0;
			popup_spawn_location.y = ( stage.stageHeight / 2 ) - this.y - 100.0; //screen center is stage height - object y
			
			popup_timer = new Timer( ONE_SECOND );
			popup_timer.addEventListener( TimerEvent.TIMER, CleanupPopups );
			popup_timer.start();
			
			mc_anim_guard_1.gotoAndPlay( 0 );
			mc_anim_guard_2.gotoAndPlay( 12 );
			mc_anim_guard_3.gotoAndPlay( 22 );
			HideGuards();
		}
		
		
		
		//Timer Functions
		//---------------------------------------------------------------------------------------------------
		private function CleanupPopups( e:Event )
		{
			for each( var popup:ScrollingPopup in time_popups )
			{
				if( popup_timer.currentCount - popup.birth_time > popup.lifetime_seconds )
				{
					removeChild( popup );
					time_popups.splice( popup, 1 ); //remove the first ScrollingPopup matching popup
				}
			}
		}
		
		
		
		//---------------------------------------------------------------------------------------------------
		public function ReleaseTimePopup( timer_text:String, red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			var new_popup:ScrollingPopup = new ScrollingPopup( ScrollingPopup.TYPE_TIMER, popup_timer.currentCount, 2 );
			new_popup.x = popup_spawn_location.x;
			new_popup.y = popup_spawn_location.y;
			new_popup.scaleX = POPUP_SCALE;
			new_popup.scaleY = POPUP_SCALE;
			new_popup.SetText( timer_text );
			new_popup.SetTextColor( red, green, blue );
			
			time_popups.push( new_popup );
			addChild( new_popup );
		}
		
		
		
		//Show/Hide
		//---------------------------------------------------------------------------------------------------
		public function HideGuards()
		{
			mc_anim_guard_1.visible = false;
			mc_anim_guard_2.visible = false;
			mc_anim_guard_3.visible = false;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function ShowGuards()
		{
			mc_anim_guard_1.visible = true;
			mc_anim_guard_2.visible = true;
			mc_anim_guard_3.visible = true;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function HideText()
		{
			text_timer.visible = false;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function ShowText()
		{
			text_timer.visible = true;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function StartSiren()
		{
			this.mc_image_siren.visible = true;
			addEventListener( Event.ENTER_FRAME, TweenSirenAlpha );
		}
		
		//---------------------------------------------------------------------------------------------------
		public function StopSiren()
		{
			this.mc_image_siren.visible = false;
			removeEventListener( Event.ENTER_FRAME, TweenSirenAlpha );
		}
		
		
		
		//Modifiers
		//---------------------------------------------------------------------------------------------------
		public function SetText( new_text:String )
		{
			text_timer.text = new_text;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetSirenColor( red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			siren_color.redOffset = red;
			siren_color.greenOffset = green;
			siren_color.blueOffset = blue;
			siren_color.alphaOffset = -128;
			
			this.mc_image_siren.transform.colorTransform = siren_color;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetTextColor( red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			text_color.redOffset = red;
			text_color.greenOffset = green;
			text_color.blueOffset = blue;
			
			this.text_timer.transform.colorTransform = text_color;
		}
		
		//---------------------------------------------------------------------------------------------------
		private function TweenSirenAlpha( e:Event )
		{
			if( tweening_down )
			{
				siren_color.alphaOffset -= 5;
				if( siren_color.alphaOffset <= -155 )
					tweening_down = false;
			}
			else
			{
				siren_color.alphaOffset += 5;
				if( siren_color.alphaOffset >= 0 )
					tweening_down = true;
			}
			this.mc_image_siren.transform.colorTransform = siren_color;
		}
	}
}
