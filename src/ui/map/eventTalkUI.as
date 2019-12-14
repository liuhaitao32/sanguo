/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;

	public class eventTalkUI extends ViewPanel {
		public var allBox:Box;
		public var imgBG:Image;
		public var btnBox:Box;
		public var btn0:Button;
		public var btn1:Button;
		public var img0:hero_icon2UI;
		public var label0:Label;
		public var nameLabel:Label;
		public var btn2:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			super.createChildren();
			loadUI("map/eventTalk");

		}

	}
}