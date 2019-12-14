/**Created by the LayaAirIDE,do not modify.*/
package ui.shop {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;
	import laya.html.dom.HTMLDivElement;

	public class shopSkillTipsUI extends ViewPanel {
		public var boxCom:Box;
		public var viewBG:Image;
		public var icon:bagItemUI;
		public var nameLabel:Label;
		public var numLabel:Label;
		public var tType:Label;
		public var hInfo:HTMLDivElement;
		public var box1:Box;
		public var text0:Label;
		public var list1:List;
		public var box2:Box;
		public var text1:Label;
		public var list2:List;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("shop/shopSkillTips");

		}

	}
}