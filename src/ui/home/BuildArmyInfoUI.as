/**Created by the LayaAirIDE,do not modify.*/
package ui.home {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class BuildArmyInfoUI extends ItemBase {
		public var kucun_container:Box;
		public var kucun:Label;
		public var num_txt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("home/BuildArmyInfo");

		}

	}
}