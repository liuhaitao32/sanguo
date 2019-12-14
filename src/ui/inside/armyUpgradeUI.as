/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.payTypeUI;
	import ui.com.item_titleUI;

	public class armyUpgradeUI extends ViewPanel {
		public var text5Img:Image;
		public var pro1:ProgressBar;
		public var pro2:ProgressBar;
		public var pro3:ProgressBar;
		public var boxAtk2:Box;
		public var boxAtk3:Box;
		public var boxCenter:Box;
		public var boxAtk:Box;
		public var boxTopLeft:Box;
		public var armyIcon:Image;
		public var text15:Label;
		public var text16:Label;
		public var box2:Box;
		public var com8:payTypeUI;
		public var com9:payTypeUI;
		public var com10:payTypeUI;
		public var btn2:Button;
		public var box1:Box;
		public var com4:payTypeUI;
		public var com5:payTypeUI;
		public var com6:payTypeUI;
		public var btn1:Button;
		public var box0:Box;
		public var com1:payTypeUI;
		public var com2:payTypeUI;
		public var com3:payTypeUI;
		public var btn0:Button;
		public var boxProp0:Box;
		public var text6:Label;
		public var boxProp1:Box;
		public var text7:Label;
		public var boxProp2:Box;
		public var text8:Label;
		public var comAlert:Box;
		public var imgAlert0:Image;
		public var imgAlert1:Image;
		public var text14:Label;
		public var text9:Label;
		public var text5:Label;
		public var text11:Label;
		public var boxText:Box;
		public var text12:Label;
		public var text13:Label;
		public var comTitle:item_titleUI;
		public var com7Box:Box;
		public var com7Img:Image;
		public var com7:payTypeUI;
		public var text10:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("inside/armyUpgrade");

		}

	}
}