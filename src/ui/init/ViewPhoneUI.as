/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.bag.bagItemUI;

	public class ViewPhoneUI extends ViewPanel {
		public var box:Box;
		public var imgTemp:Image;
		public var btn:Button;
		public var input0:TextInput;
		public var comTitle:item_titleUI;
		public var box0:Box;
		public var text4:Label;
		public var box1:Box;
		public var text2:Label;
		public var input1:TextInput;
		public var btnCheck:Button;
		public var text1:Label;
		public var text0:Label;
		public var box2:Box;
		public var list:List;
		public var text3:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("init/ViewPhone");

		}

	}
}