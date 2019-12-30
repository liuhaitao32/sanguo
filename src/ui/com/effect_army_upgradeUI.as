/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.t_img_t_tUI;

	public class effect_army_upgradeUI extends ComPayType {
		public var adImg:Image;
		public var tTitle:Image;
		public var img:Image;
		public var tLv:Label;
		public var atk:t_img_t_tUI;
		public var def:t_img_t_tUI;
		public var spd:t_img_t_tUI;
		public var hpm:t_img_t_tUI;
		public var aBox:Box;

		override protected function createChildren():void {
			View.regComponent("ui.com.t_img_t_tUI",t_img_t_tUI);
			super.createChildren();
			loadUI("com/effect_army_upgrade");

		}

	}
}