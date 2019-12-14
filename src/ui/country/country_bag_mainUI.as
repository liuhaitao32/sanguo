/**Created by the LayaAirIDE,do not modify.*/
package ui.country {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.html.dom.HTMLDivElement;
	import ui.com.hero_icon1UI;
	import ui.com.comCountryOfficialUI;
	import ui.com.award_box4UI;

	public class country_bag_mainUI extends ItemBase {
		public var imgTitle0:Image;
		public var btnAsk0:Button;
		public var list1:List;
		public var text0:Label;
		public var title0:Label;
		public var btnGet:Button;
		public var imgTitle1:Image;
		public var comBox:award_box4UI;
		public var btnAsk1:Button;
		public var text1:Label;
		public var title1:Label;
		public var numImg:Image;
		public var boxLabel:Label;
		public var taskBox0:Box;
		public var taskBox1:Box;
		public var taskBox2:Box;
		public var btnAsk2:Button;
		public var bagList:List;
		public var imgTitle2:Image;
		public var title2:Label;

		override protected function createChildren():void {
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.comCountryOfficialUI",comCountryOfficialUI);
			View.regComponent("ui.com.award_box4UI",award_box4UI);
			super.createChildren();
			loadUI("country/country_bag_main");

		}

	}
}