/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.item_science_iconUI;
	import laya.html.dom.HTMLDivElement;

	public class item_scienceUI extends ItemBase {
		public var mLine:Box;
		public var ll3:Image;
		public var ll9:Image;
		public var ll11:Image;
		public var ll5:Image;
		public var ll1:Image;
		public var ll7:Image;
		public var ll2:Image;
		public var ll4:Image;
		public var ll6:Image;
		public var ll8:Image;
		public var ll10:Image;
		public var ll12:Image;
		public var mHave:Box;
		public var boxEffect:Box;
		public var icon:item_science_iconUI;
		public var lock:Box;
		public var tName:Label;
		public var tLv:HTMLDivElement;
		public var boxTime:Box;
		public var tTime:Label;
		public var boxClip:Box;
		public var tXY:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.item_science_iconUI",item_science_iconUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("inside/item_science");

		}

	}
}