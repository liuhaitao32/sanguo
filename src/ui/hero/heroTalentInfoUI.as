/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class heroTalentInfoUI extends ViewPanel {
		public var mBox:Box;
		public var img_name:Image;
		public var tName:Label;
		public var tTalent:Label;
		public var boxTalent:Box;
		public var boxAwaken:Box;
		public var tAwaken:Label;
		public var boxAwakenInfo:Box;
		public var boxLegend:Box;
		public var imgLineLegend:Image;
		public var tLegend:Label;
		public var tLegend1:Label;
		public var tLegend2:Label;
		public var tLegend3:Label;
		public var tLegend4:Label;
		public var imgLine:Image;
		public var tInfoName:Label;
		public var tInfo:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("hero/heroTalentInfo");

		}

	}
}