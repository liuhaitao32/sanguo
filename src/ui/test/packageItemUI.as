/**Created by the LayaAirIDE,do not modify.*/
package ui.test {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class packageItemUI extends ViewPanel {
		public var change_shoudu_btn:Button;
		public var test_btn:Button;
		public var look_com:ComboBox;
		public var look_txt:TextInput;
		public var look_btn:Button;
		public var log_btn:Button;
		public var log_list:List;
		public var btn_0:Button;
		public var btn_1:Button;
		public var btn_6:Button;
		public var btn_5:Button;
		public var btn_4:Button;
		public var btn_3:Button;
		public var btn_2:Button;
		public var btn_7:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("test/packageItem");

		}

	}
}