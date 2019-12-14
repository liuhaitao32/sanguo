/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.championMatchLineUI;
	import ui.fight.itemChampion8UI;

	public class championMatchBUI extends ItemBase {
		public var panel:Panel;
		public var lineBox:Box;
		public var l11:Image;
		public var l12:Image;
		public var l13:Image;
		public var l14:Image;
		public var l21:Image;
		public var l22:Image;
		public var l31:Image;
		public var l00:championMatchLineUI;
		public var l03:championMatchLineUI;
		public var l05:championMatchLineUI;
		public var l06:championMatchLineUI;
		public var l04:championMatchLineUI;
		public var l07:championMatchLineUI;
		public var l01:championMatchLineUI;
		public var l02:championMatchLineUI;
		public var winner:Box;
		public var text0:Label;
		public var p00:itemChampion8UI;
		public var p03:itemChampion8UI;
		public var p04:itemChampion8UI;
		public var p07:itemChampion8UI;
		public var p11:itemChampion8UI;
		public var p13:itemChampion8UI;
		public var p21:itemChampion8UI;
		public var p01:itemChampion8UI;
		public var p02:itemChampion8UI;
		public var p05:itemChampion8UI;
		public var p06:itemChampion8UI;
		public var p12:itemChampion8UI;
		public var p14:itemChampion8UI;
		public var p22:itemChampion8UI;
		public var p31:itemChampion8UI;
		public var f0:Button;
		public var f2:Button;
		public var f1:Button;
		public var f3:Button;
		public var f4:Button;
		public var f6:Button;
		public var f8:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.championMatchLineUI",championMatchLineUI);
			View.regComponent("ui.fight.itemChampion8UI",itemChampion8UI);
			super.createChildren();
			loadUI("fight/championMatchB");

		}

	}
}