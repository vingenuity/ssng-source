package
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	
	public class ThievesMarker extends MovieClip
	{
		public var mc_thief_1:MovieClip;
		public var mc_thief_2:MovieClip;
		public var mc_thief_3:MovieClip;
		public var mc_thief_4:MovieClip;
		public var mc_sword_cross:MovieClip;
		
		public function ThievesMarker()
		{
			// constructor code
			mc_sword_cross.gotoAndStop( 0 );
			ExternalInterface.call( "SetThiefVisibility" );
		}
		
		public function PlaySwordCross()
		{
			mc_sword_cross.gotoAndPlay( 0 );
		}
	}
}
