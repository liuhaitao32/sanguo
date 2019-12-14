/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class viewLogin2UI extends ViewPanel {
		public var btn_login:Button;
		public var btn_register:Button;
		public var btn_phone:Button;
		public var btn_fast:Button;
		public var tName:TextInput;
		public var tPwd1:TextInput;
		public var boxReal:Box;
		public var btn_real:Button;
		public var boxReg:Box;
		public var tPwd2:TextInput;
		public var comTitle:Label;
		public var btn_users:Button;
		public var listBox:Box;
		public var listName:List;
		public var btn_fb:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("init/viewLogin2");

		}

	}
}