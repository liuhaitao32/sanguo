/**Created by the LayaAirIDE,do not modify.*/
package ui.arena {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.country_flag1UI;

	public class itemArenaLogUI extends ItemBase {
		public var img:Image;
		public var imgCheck:Button;
		public var text01:Label;
		public var text02:Label;
		public var country0:country_flag1UI;
		public var text11:Label;
		public var text12:Label;
		public var country1:country_flag1UI;
		public var txtImg:Image;
		public var imgItem:Image;
		public var text1:Label;
		public var text0:Label;
		public var tTime:Label;
		public var tNum:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			super.createChildren();
			loadUI("arena/itemArenaLog");

		}

	}
}