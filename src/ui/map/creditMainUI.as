/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.map.item_credit_userUI;
	import ui.map.item_creditUI;
	import ui.com.payTypeUI;
	import ui.bag.bagItemUI;

	public class creditMainUI extends ViewScenes {
		public var btntest:Button;
		public var btnInfo:Button;
		public var box2:Box;
		public var imgUser:Image;
		public var userList:List;
		public var btn1:Button;
		public var textBottom:Label;
		public var label0:Label;
		public var label1:Label;
		public var label2:Label;
		public var label3:Label;
		public var box2Top:Box;
		public var text21BG:Image;
		public var text21:Label;
		public var text22:Label;
		public var box1:Box;
		public var imgBg:Image;
		public var topBox:Box;
		public var timeBox:Box;
		public var text11BG:Image;
		public var text11:Label;
		public var text12:Label;
		public var mainBox:Box;
		public var lineBox:Box;
		public var panel:Panel;
		public var comBox:Box;
		public var com0:item_creditUI;
		public var com1:item_creditUI;
		public var com2:item_creditUI;
		public var com3:item_creditUI;
		public var com4:item_creditUI;
		public var com5:item_creditUI;
		public var com6:item_creditUI;
		public var com7:item_creditUI;
		public var com8:item_creditUI;
		public var com9:item_creditUI;
		public var com10:item_creditUI;
		public var com11:item_creditUI;
		public var com12:item_creditUI;
		public var com13:item_creditUI;
		public var com14:item_creditUI;
		public var upBox:Box;
		public var upLabel:Label;
		public var upNum:payTypeUI;
		public var img:Panel;
		public var roolBox:Box;
		public var roolImg:Panel;
		public var roolCom:bagItemUI;
		public var roolLabel:Label;
		public var roolBG:Image;
		public var roolGet:Label;
		public var roolNum:payTypeUI;
		public var titleBox:Box;
		public var titleLabel:Label;
		public var curBox:Box;
		public var label4:Label;
		public var btnBox:Box;
		public var btnDown:Button;
		public var btnUp:Button;
		public var btn:Button;
		public var tab:Tab;
		public var midLabel:Label;
		public var comNum:payTypeUI;

		override protected function createChildren():void {
			View.regComponent("ui.map.item_credit_userUI",item_credit_userUI);
			View.regComponent("ui.map.item_creditUI",item_creditUI);
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("map/creditMain");

		}

	}
}