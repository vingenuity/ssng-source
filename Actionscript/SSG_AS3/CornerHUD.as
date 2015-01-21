package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import fl.motion.Color;
	
	public class CornerHUD extends MovieClip
	{
		public static const CORNER_None:uint = 0;
		public static const CORNER_NorthWest:uint = 1;
		public static const CORNER_NorthEast:uint = 2;
		public static const CORNER_SouthWest:uint = 3;
		public static const CORNER_SouthEast:uint = 4;
		
		private static const ICON_None:uint = 0;
		private static const ICON_AButton:uint = 1;
		private static const ICON_Sword:uint = 2;
		private static const ICON_Spear:uint = 3;
		private static const ICON_Shield:uint = 4;
		private static const ICON_Crossbow:uint = 5;
		
		public static const MAX_HEALTH = 3;
		
		var background_color:ColorTransform;
		var dead_color:ColorTransform;
		var outline_color:ColorTransform;
		
		var current_corner:uint;
		var health_hearts:Array;
		
		private static const TRANSITION_LENGTH_SECONDS = 5.0;
		var current_color:ColorTransform;
		var start_color:ColorTransform;
		var end_color:ColorTransform;
		var secondsSinceTransitionStarted:Number;
		
		//Constructor
		public function CornerHUD( corner:uint = CORNER_SouthEast )
		{
			current_color = new ColorTransform();
			start_color = new ColorTransform();
			end_color = new ColorTransform();
			
			background_color = new ColorTransform();
			background_color.color = 0xffffff;
			
			dead_color = new ColorTransform();
			dead_color.color = 0xffffff;
			dead_color.redOffset = 128;
			dead_color.greenOffset = 128;
			dead_color.blueOffset = 128;
			
			outline_color = new ColorTransform();
			outline_color.color = 0xffffff;
			
			health_hearts = new Array( mc_health_frame.mc_heart_1, mc_health_frame.mc_heart_2, mc_health_frame.mc_heart_3 );
			current_corner = CORNER_None;
			
			SetAppearanceBasedOnCorner( corner );
			//SetIcon( ICON_Sword );
		}
		
		
		
		//---------------------------------------------------------------------------------------------------
		public function SetAppearanceBasedOnCorner( corner:uint )
		{
			if( current_corner == corner )
				return;
				
			switch( corner )
			{
				case CORNER_NorthWest:
					mc_image_background.rotation = 180;
					mc_health_frame.y = 200;
					mc_treasure_frame.x = 120;
					//mc_place_indicator.x = 475;
					//mc_place_indicator.y = 75;
					text_name.x = 50;
					text_name.y = 50;
					break;
				case CORNER_NorthEast:
					mc_image_background.scaleY = -1; // flip it vertically
					mc_health_frame.y = 200;
					mc_treasure_frame.x = -255;
					//mc_place_indicator.x = -475;
					//mc_place_indicator.y = 75;
					text_name.y = 50;
					break;
				case CORNER_SouthWest:
					mc_image_background.scaleX = -1; // flip it horizontally
					mc_health_frame.y = -190;
					mc_treasure_frame.x = 120;
					//mc_place_indicator.x = 475;
					//mc_place_indicator.y = -75;
					text_name.x = 50;
					break;
				case CORNER_SouthEast:
				default:
					mc_image_background.rotation = 0;
					mc_health_frame.y = -190;
					mc_treasure_frame.x = -255;
					//mc_place_indicator.x = -475;
					//mc_place_indicator.y = -75;
					break;
			}
			current_corner = corner;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetBackgroundColor( red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			background_color.redOffset = red;
			background_color.greenOffset = green;
			background_color.blueOffset = blue;
			
			mc_image_background.mc_image_back.transform.colorTransform = background_color;
			mc_place_indicator.SetBackgroundColor( red, green, blue );
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetOutlineColor( red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			outline_color.redOffset = red;
			outline_color.greenOffset = green;
			outline_color.blueOffset = blue;
			
			mc_image_background.mc_image_outline.transform.colorTransform = outline_color;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetHealthLevel( health_level:int )
		{
			if( health_level > MAX_HEALTH )
				health_level = MAX_HEALTH;
			
			var i:int;
			for ( i = 0; i < health_level; ++i )
			{
				health_hearts[ i ].visible = true;
			}

			for ( i = health_level; i < MAX_HEALTH; ++i )
			{
				health_hearts[ i ].visible = false;
			}
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetPlace( place:uint )
		{
			mc_place_indicator.SetPlace( place );
		}
		
		//---------------------------------------------------------------------------------------------------
		private function SetIcon( icon_id:uint )
		{
			mc_icon_a_button.visible = false;
			mc_icon_crossbow.visible = false;
			mc_icon_shield.visible = false;
			mc_icon_spear.visible = false;
			mc_icon_sword.visible = false;
			switch( icon_id )
			{
				case ICON_AButton:
					mc_icon_a_button.visible = true;
					break;
				case ICON_Crossbow:
					mc_icon_crossbow.visible = true;
					break;
				case ICON_Shield:
					mc_icon_shield.visible = true;
					break;
				case ICON_Spear:
					mc_icon_spear.visible = true;
					break;
				case ICON_Sword:
					mc_icon_sword.visible = true;
					break;
				case ICON_None:
				default:
					break;
			}
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetIconToAButton() { SetIcon( ICON_AButton ); }
		public function SetIconToCrossbow() { SetIcon( ICON_Crossbow ); }
		public function SetIconToNone() { SetIcon( ICON_None ); }
		public function SetIconToShield() { SetIcon( ICON_Shield ); }
		public function SetIconToSpear() { SetIcon( ICON_Spear ); }
		public function SetIconToSword() { SetIcon( ICON_Sword ); }
		
		//---------------------------------------------------------------------------------------------------
		public function SetNameText( new_name:String )
		{
			text_name.text = new_name;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetNameTextColor( red:Number = 255, green:Number = 255, blue:Number = 255 )
		{
			//This code from: http://www.flashandmath.com/intermediate/rgbs/
			text_name.textColor = ( ( red << 16 ) | ( green << 8 ) | blue );
		}
		
		//---------------------------------------------------------------------------------------------------
		public function SetTreasureText( new_treasure_amount:String )
		{
			mc_treasure_frame.text_treasure.text = new_treasure_amount;
		}
	}
}
