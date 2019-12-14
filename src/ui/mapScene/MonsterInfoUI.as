/**Created by the LayaAirIDE,do not modify.*/
package ui.mapScene {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class MonsterInfoUI extends ItemBase {
		public var name_txt:Label;
		public var bing_pro:ProgressBar;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("mapScene/MonsterInfo");

		}

	}
}