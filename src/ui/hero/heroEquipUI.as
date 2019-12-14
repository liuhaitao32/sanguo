/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon_equipUI;

	public class heroEquipUI extends ItemBase {
		public var adImg:Image;
		public var groupPanel:Panel;
		public var btn_go:Button;
		public var tType0:Label;
		public var tType1:Label;
		public var tType2:Label;
		public var tType3:Label;
		public var tType4:Label;
		public var equip0:hero_icon_equipUI;
		public var equip1:hero_icon_equipUI;
		public var equip2:hero_icon_equipUI;
		public var equip3:hero_icon_equipUI;
		public var equip4:hero_icon_equipUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon_equipUI",hero_icon_equipUI);
			super.createChildren();
			loadUI("hero/heroEquip");

		}

	}
}