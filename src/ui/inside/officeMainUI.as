/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class officeMainUI extends ViewScenes {
		public var mBoxAward:Box;
		public var txt_reward0:Label;
		public var txt_baseLimit:Label;
		public var tMin:Label;
		public var tMax:Label;
		public var award:Box;
		public var txt_reward1:Label;
		public var tCoin:Label;
		public var btn:Button;
		public var isGet:Image;
		public var mBoxPre:Box;
		public var txt_title:Label;
		public var list:List;
		public var listRight:List;
		public var bg1:Box;
		public var adImg1:Image;
		public var adImg2:Image;
		public var mOffice:Box;
		public var officeIcon:Image;
		public var btn_pre:Button;
		public var btn_next:Button;
		public var tName:Label;
		public var conditionNo:Image;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("inside/officeMain");

		}

	}
}