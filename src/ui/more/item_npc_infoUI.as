/**Created by the LayaAirIDE,do not modify.*/
package ui.more {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import laya.html.dom.HTMLDivElement;

	public class item_npc_infoUI extends ItemBase {
		public var flagBox:Box;
		public var img0:Image;
		public var img2:Image;
		public var img1:Image;
		public var heroIcon:hero_icon1UI;
		public var tInfo:HTMLDivElement;
		public var btnGo:Button;
		public var tName:Label;
		public var tDiff:Label;
		public var tTime:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("more/item_npc_info");

		}

	}
}