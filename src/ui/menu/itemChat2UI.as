/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.html.dom.HTMLDivElement;
	import ui.com.comCountryOfficialUI;
	import ui.com.country_flag1UI;

	public class itemChat2UI extends ItemBase {
		public var tHtml:HTMLDivElement;
		public var btnChannel:Button;
		public var comOfficial:comCountryOfficialUI;
		public var tName:Label;
		public var imgMayor:Image;
		public var boxFlag:Box;
		public var comFlag:country_flag1UI;

		override protected function createChildren():void {
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.com.comCountryOfficialUI",comCountryOfficialUI);
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			super.createChildren();
			loadUI("menu/itemChat2");

		}

	}
}