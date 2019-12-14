/**Created by the LayaAirIDE,do not modify.*/
package ui.arena {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.country_flag1UI;

	public class itemArenaLog1UI extends ItemBase {
		public var name0:Label;
		public var text0:Label;
		public var tTime:Label;
		public var name1:Label;
		public var text1:Label;
		public var text2:Label;
		public var box1:Box;
		public var country0:country_flag1UI;
		public var box2:Box;
		public var country1:country_flag1UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			super.createChildren();
			loadUI("arena/itemArenaLog1");

		}

	}
}