/**Created by the LayaAirIDE,do not modify.*/
package ui.more {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class settings_baseUI extends ItemBase {
		public var switchName:Label;
		public var switchOffPanel:Image;
		public var switchOnPanel:Image;
		public var switchOn:Button;
		public var switchOff:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("more/settings_base");

		}

	}
}