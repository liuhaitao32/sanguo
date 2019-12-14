/**Created by the LayaAirIDE,do not modify.*/
package ui.activities {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;

	public class heroChooseUI extends ViewPanel {
		public var pic3:Image;
		public var btn:Button;
		public var list:List;
		public var img_title:Image;
		public var txt_description:Label;
		public var txt_title:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			super.createChildren();
			loadUI("activities/heroChoose");

		}

	}
}