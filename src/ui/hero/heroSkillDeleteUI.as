/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;
	import ui.com.com_text_picUI;

	public class heroSkillDeleteUI extends ViewPanel {
		public var btn_del:Button;
		public var mItem:bagItemUI;
		public var tInfo:Label;
		public var tText:Label;
		public var tReel:Label;
		public var mGold:bagItemUI;
		public var tBack:Label;
		public var checkBox:Box;
		public var cb:CheckBox;
		public var comPic:com_text_picUI;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.com_text_picUI",com_text_picUI);
			super.createChildren();
			loadUI("hero/heroSkillDelete");

		}

	}
}