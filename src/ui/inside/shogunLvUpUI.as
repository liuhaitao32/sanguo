/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.payTypeUI;

	public class shogunLvUpUI extends ViewPanel {
		public var btn1:Button;
		public var btn0:Button;
		public var box0:Box;
		public var img01:Image;
		public var text01:Label;
		public var text02:Label;
		public var text03:Label;
		public var box1:Box;
		public var img11:Image;
		public var text11:Label;
		public var text12:Label;
		public var text13:Label;
		public var comPay0:payTypeUI;
		public var comPay1:payTypeUI;
		public var lvLabel:Label;
		public var titleLabel:Label;
		public var textX:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			super.createChildren();
			loadUI("inside/shogunLvUp");

		}

	}
}