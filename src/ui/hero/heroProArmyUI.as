/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.SoldiersinformationUI;
	import ui.com.btn_icon_txt_sureUI;
	import ui.bag.bagItemSmallUI;

	public class heroProArmyUI extends ItemBase {
		public var boxProp:SoldiersinformationUI;
		public var tError:Label;
		public var mBoxUpgrade:Box;
		public var barItem0:ProgressBar;
		public var barItem1:ProgressBar;
		public var tItemNum0:Label;
		public var tItemNum1:Label;
		public var btn_gold:btn_icon_txt_sureUI;
		public var item0:bagItemSmallUI;
		public var item1:bagItemSmallUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.SoldiersinformationUI",SoldiersinformationUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("ui.bag.bagItemSmallUI",bagItemSmallUI);
			super.createChildren();
			loadUI("hero/heroProArmy");

		}

	}
}