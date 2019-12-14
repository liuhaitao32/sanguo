/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class guildMainUI extends ViewScenes {
		public var comTab:Tab;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("guild/guildMain");

		}

	}
}