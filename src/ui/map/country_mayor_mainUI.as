/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class country_mayor_mainUI extends ItemBase {
		public var list:List;
		public var tab0:Tab;
		public var tInfo1:Label;
		public var tInfo2:Label;
		public var tab:Tab;
		public var tabs0:Button;
		public var tabs1:Button;
		public var text0:Label;
		public var text1:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("map/country_mayor_main");

		}

	}
}