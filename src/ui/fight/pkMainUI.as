/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class pkMainUI extends ViewScenes {
		public var listCountry:List;
		public var img0:Image;
		public var text0:Label;
		public var list:List;
		public var btn_back:Button;
		public var btn_next:Button;
		public var tPage:Label;
		public var btn_report:Button;
		public var btn_buy:Button;
		public var btn_re:Button;
		public var btn_shop:Button;
		public var tReTime:Label;
		public var tTimes:Label;
		public var text1:Label;
		public var btn_rank:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("fight/pkMain");

		}

	}
}