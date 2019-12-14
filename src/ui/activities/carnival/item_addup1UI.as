/**Created by the LayaAirIDE,do not modify.*/
package ui.activities.carnival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.activities.carnival.item_emboUI;

	public class item_addup1UI extends ItemBase {
		public var titleLabel:Label;
		public var imgGet:Image;
		public var btnGet:Button;
		public var list:List;
		public var proBox:Box;
		public var proBar:ProgressBar;
		public var numImg:Image;
		public var text0:Label;
		public var textLabel1:Label;

		override protected function createChildren():void {
			View.regComponent("ui.activities.carnival.item_emboUI",item_emboUI);
			super.createChildren();
			loadUI("activities/carnival/item_addup1");

		}

	}
}