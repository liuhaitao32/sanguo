/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class effect_power_userUI extends ComPayType {
		public var box:Box;
		public var bgImg:Image;
		public var tPower:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/effect_power_user");

		}

	}
}