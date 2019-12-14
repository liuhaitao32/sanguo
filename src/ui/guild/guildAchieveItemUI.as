/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class guildAchieveItemUI extends ItemBase {
		public var imgFinish:Image;
		public var titleLabel:Label;
		public var imgSelect:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("guild/guildAchieveItem");

		}

	}
}