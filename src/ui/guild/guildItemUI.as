/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_power2UI;

	public class guildItemUI extends ItemBase {
		public var btnApply:Button;
		public var img2:Image;
		public var img1:Image;
		public var nameLabel:Label;
		public var idLabel:Label;
		public var numLabel:Label;
		public var comPower:hero_power2UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			super.createChildren();
			loadUI("guild/guildItem");

		}

	}
}