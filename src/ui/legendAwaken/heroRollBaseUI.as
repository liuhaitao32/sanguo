/**Created by the LayaAirIDE,do not modify.*/
package ui.legendAwaken {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;

	public class heroRollBaseUI extends ItemBase {
		public var character:hero_icon2UI;
		public var img:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			super.createChildren();
			loadUI("legendAwaken/heroRollBase");

		}

	}
}