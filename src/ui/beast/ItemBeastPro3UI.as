/**Created by the LayaAirIDE,do not modify.*/
package ui.beast {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.html.dom.HTMLDivElement;

	public class ItemBeastPro3UI extends ItemBase {
		public var tHtml:HTMLDivElement;

		override protected function createChildren():void {
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("beast/ItemBeastPro3");

		}

	}
}