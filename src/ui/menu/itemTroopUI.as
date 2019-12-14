/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;

	public class itemTroopUI extends ItemBase {
		public var heroNull:Image;
		public var heroIcon:hero_icon1UI;
		public var pFight:ProgressBar;
		public var sLock:Image;
		public var sNull:Image;
		public var sTimer:Image;
		public var sStatus:Image;
		public var sHome:Image;
		public var sMove:Image;
		public var sFight:Image;
		public var sMoveQuick:Image;
		public var mSelect:Image;
		public var tNull:Label;
		public var tTimer:Label;
		public var tStatus:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			super.createChildren();
			loadUI("menu/itemTroop");

		}

	}
}