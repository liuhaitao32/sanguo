/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class heroMainUI extends ViewScenes {
		public var tab:Tab;
		public var btn_pub:Button;
		public var list:List;
		public var btnC4:Button;
		public var btnC3:Button;
		public var btnC2:Button;
		public var btnC1:Button;
		public var btnC0:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("hero/heroMain");

		}

	}
}