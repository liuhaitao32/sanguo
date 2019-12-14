/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.equipBox {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.bag.bagItemUI;
	import ui.com.payTypeBigUI;

	public class equipBoxRecylceUI extends ViewPanel {
		public var imgTitle:Image;
		public var btn:Button;
		public var list:List;
		public var cCom:payTypeBigUI;
		public var tTitle:Label;

		override protected function createChildren():void {
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			super.createChildren();
			loadUI("activities/equipBox/equipBoxRecylce");

		}

	}
}