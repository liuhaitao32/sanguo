/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.html.dom.HTMLDivElement;
	import ui.com.payTypeUI;

	public class fightCountryConfirmPanelUI extends ViewPanel {
		public var panel:Image;
		public var txtTitle:Label;
		public var htmlInfo:HTMLDivElement;
		public var costItem:payTypeUI;
		public var btnClose:Button;
		public var btnOk:Button;
		public var boxRepeat:Box;
		public var txtRepeat:Label;
		public var btnCheck:Button;

		override protected function createChildren():void {
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			super.createChildren();
			loadUI("battle/fightCountryConfirmPanel");

		}

	}
}