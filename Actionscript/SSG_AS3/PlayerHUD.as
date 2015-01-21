package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Vector3D;
	import flash.utils.Timer;
	
	public class PlayerHUD extends MovieClip 
	{
		private static const ONE_SECOND:int = 1000;
		private static const POPUP_LIFETIME_SECONDS:uint = 2;
		private static const POPUP_SCALE:Number = 1.5;
		
		var fill_level:Number;
		var fill_movie_clips:Array;
		var back_movie_clips:Array;
		
		var fill_empty_color:ColorTransform;
		var fill_full_color:ColorTransform;
		var background_color:ColorTransform;
		var text_color:ColorTransform;
		
		var popup_spawn_location:Vector3D;
		var popup_timer:Timer;
		var treasure_popups:Array;
		
		//---------------------------------------------------------------------------------------------------
		public function PlayerHUD() //Constructor
		{
			fill_empty_color = new ColorTransform();
			fill_empty_color.color = 0x000000;
			
			fill_full_color = new ColorTransform();
			fill_full_color.color = 0xffffff;
			
			background_color = new ColorTransform();
			background_color.color = 0xffffff;
			
			text_color = new ColorTransform();
			text_color.color = 0xffffff;
			
			fill_level = 2;
			fill_movie_clips = new Array( this.mc_ring_fill_top_left, this.mc_ring_fill_bottom, this.mc_ring_fill_top_right );
			back_movie_clips = new Array( this.mc_ring_back_top_left, this.mc_ring_back_bottom, this.mc_ring_back_top_right );
			SetColorOfClipsFromFillLevel();
			
			treasure_popups = new Array();
			
			popup_spawn_location = new Vector3D();
			popup_spawn_location.x = 0.0;
			popup_spawn_location.y = -275.0;
			
			popup_timer = new Timer( ONE_SECOND );
			popup_timer.addEventListener( TimerEvent.TIMER, CleanupPopups );
			popup_timer.start();
			HideRings();
		}
		
		
		//Timer Functions
		//---------------------------------------------------------------------------------------------------
		private function CleanupPopups( e:Event )
		{
			for each( var popup:ScrollingPopup in treasure_popups )
			{
				if( popup_timer.currentCount - popup.birth_time > popup.lifetime_seconds )
				{
					removeChild( popup );
					treasure_popups.splice( popup, 1 ); //remove the first ScrollingPopup matching popup
				}
			}
		}
		
		
		
		//---------------------------------------------------------------------------------------------------
		public function ReleaseCrossbowPopup( popup_text:String, red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			var new_popup:ScrollingPopup = new ScrollingPopup( ScrollingPopup.TYPE_CROSSBOW, popup_timer.currentCount, POPUP_LIFETIME_SECONDS );
			new_popup.x = popup_spawn_location.x;
			new_popup.y = popup_spawn_location.y;
			new_popup.scaleX = POPUP_SCALE;
			new_popup.scaleY = POPUP_SCALE;
			new_popup.SetText( popup_text );
			new_popup.SetTextColor( red, green, blue );
			
			treasure_popups.push( new_popup );
			addChild( new_popup );
		}
		
		//---------------------------------------------------------------------------------------------------
		public function ReleaseHealthPopup( popup_text:String, red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			var new_popup:ScrollingPopup = new ScrollingPopup( ScrollingPopup.TYPE_HEALTH, popup_timer.currentCount, POPUP_LIFETIME_SECONDS );
			new_popup.x = popup_spawn_location.x;
			new_popup.y = popup_spawn_location.y;
			new_popup.scaleX = POPUP_SCALE;
			new_popup.scaleY = POPUP_SCALE;
			new_popup.SetText( popup_text );
			new_popup.SetTextColor( red, green, blue );
			
			treasure_popups.push( new_popup );
			addChild( new_popup );
		}
		
		//---------------------------------------------------------------------------------------------------
		public function ReleaseMedalPopup()
		{
			var new_popup:ScrollingPopup = new ScrollingPopup( ScrollingPopup.TYPE_MEDAL, popup_timer.currentCount, POPUP_LIFETIME_SECONDS );
			new_popup.x = popup_spawn_location.x;
			new_popup.y = popup_spawn_location.y;
			new_popup.scaleX = POPUP_SCALE;
			new_popup.scaleY = POPUP_SCALE;
			new_popup.SetText( "" );
			
			treasure_popups.push( new_popup );
			addChild( new_popup );
		}
		
		//---------------------------------------------------------------------------------------------------
		public function ReleaseShieldPopup( popup_text:String, red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			var new_popup:ScrollingPopup = new ScrollingPopup( ScrollingPopup.TYPE_SHIELD, popup_timer.currentCount, POPUP_LIFETIME_SECONDS );
			new_popup.x = popup_spawn_location.x;
			new_popup.y = popup_spawn_location.y;
			new_popup.scaleX = POPUP_SCALE;
			new_popup.scaleY = POPUP_SCALE;
			new_popup.SetText( popup_text );
			new_popup.SetTextColor( red, green, blue );
			
			treasure_popups.push( new_popup );
			addChild( new_popup );
		}
		
		//---------------------------------------------------------------------------------------------------
		public function ReleaseTreasurePopup( treasure_text:String, red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			var new_popup:ScrollingPopup = new ScrollingPopup( ScrollingPopup.TYPE_TREASURE, popup_timer.currentCount, POPUP_LIFETIME_SECONDS );
			new_popup.x = popup_spawn_location.x;
			new_popup.y = popup_spawn_location.y;
			new_popup.scaleX = POPUP_SCALE;
			new_popup.scaleY = POPUP_SCALE;
			new_popup.SetText( treasure_text );
			new_popup.SetTextColor( red, green, blue );
			
			treasure_popups.push( new_popup );
			addChild( new_popup );
		}
		
		

		//---------------------------------------------------------------------------------------------------
		public function Hide()
		{
			HideFacingArrow();
			HideNameDisplay();
			HideRings();
			HideTreasureDisplay();
		}
		
		//---------------------------------------------------------------------------------------------------
		public function Show()
		{
			ShowFacingArrow();
			ShowNameDisplay();
			ShowRings();
			ShowTreasureDisplay();
		}
		
		//---------------------------------------------------------------------------------------------------
		public function HideNameDisplay()
		{
			this.text_name.visible = false;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function ShowNameDisplay()
		{
			this.text_name.visible = true;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function HideFacingArrow()
		{
			this.mc_ring_arrow.visible = false;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function ShowFacingArrow()
		{
			this.mc_ring_arrow.visible = true;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function HideRings()
		{
			var i:uint;
			for ( i = 0; i < fill_movie_clips.length; ++i )
			{
				back_movie_clips[ i ].visible = false;
		    	fill_movie_clips[ i ].visible = false;
			}
		}
		
		//---------------------------------------------------------------------------------------------------
		public function ShowRings()
		{
			var i:uint;
			for ( i = 0; i < fill_movie_clips.length; ++i )
			{
				back_movie_clips[ i ].visible = true;
		    	fill_movie_clips[ i ].visible = true;
			}
		}
		
		//---------------------------------------------------------------------------------------------------
		public function HideTreasureDisplay()
		{
			this.text_treasure.visible = false;
			this.mc_image_treasure.visible = false;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function ShowTreasureDisplay()
		{
			this.text_treasure.visible = true;
			this.mc_image_treasure.visible = true;
		}
		
		//---------------------------------------------------------------------------------------------------
		private function SetColorOfClipsFromFillLevel()
		{
			var i:int;
			for ( i = 0; i < fill_level; ++i )
			{
		    	fill_movie_clips[ i ].transform.colorTransform = fill_full_color;
				fill_movie_clips[ i ].visible = true;
				//back_movie_clips[ i ].visible = true;
			}

			for ( i = fill_level; i < 3; ++i )
			{
		    	fill_movie_clips[ i ].transform.colorTransform = fill_empty_color;
				fill_movie_clips[ i ].visible = false;
				//back_movie_clips[ i ].visible = false;
			}
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetFillLevel( new_fill_level:Number )
		{
			fill_level = Math.min( 3, new_fill_level );
			
			SetColorOfClipsFromFillLevel();
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetEmptyFillColor( red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			fill_empty_color.redOffset = red;
			fill_empty_color.greenOffset = green;
			fill_empty_color.blueOffset = blue;
			
			SetFillLevel( fill_level );
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetFullFillColor( red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			fill_full_color.redOffset = red;
			fill_full_color.greenOffset = green;
			fill_full_color.blueOffset = blue;
			
			mc_ring_arrow.mc_ring_arrow_outline.transform.colorTransform = fill_full_color;
			SetFillLevel( fill_level );
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetNameText( newName:String )
		{
			this.text_name.text = newName;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetRingArrowRotation( rotation_degrees:Number )
		{
			this.mc_ring_arrow.rotation = rotation_degrees;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetBackgroundColor( red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			background_color.redOffset = red;
			background_color.greenOffset = green;
			background_color.blueOffset = blue;
			
			for ( var i:String in back_movie_clips )
			{
		    	back_movie_clips[ i ].transform.colorTransform = background_color;
			}
			
			mc_ring_arrow.mc_ring_arrow_back.transform.colorTransform = background_color;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetTextColor( red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			text_color.redOffset = red;
			text_color.greenOffset = green;
			text_color.blueOffset = blue;
			
			this.text_name.transform.colorTransform = text_color;
			this.text_treasure.transform.colorTransform = text_color;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetTreasureText( newName:String )
		{
			this.text_treasure.text = newName;
		}
	}
}
