/**Created by the LayaAirIDE,do not modify.*/
package ui.newTask {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.html.dom.HTMLDivElement;
	import ui.com.payTypeSUI;

	public class item_newtaskUI extends ItemBase {
		public var iconBg:Image;
		public var iconImg:Image;
		public var tName:Label;
		public var text0:Label;
		public var btnOk:Button;
		public var tInfo:HTMLDivElement;
		public var btnNo:Button;
		public var award0:payTypeSUI;
		public var award1:payTypeSUI;

		override protected function createChildren():void {
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.com.payTypeSUI",payTypeSUI);
			super.createChildren();
			loadUI("newTask/item_newtask");

		}

	}
}