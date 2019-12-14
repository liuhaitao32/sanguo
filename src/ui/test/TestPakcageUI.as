/**Created by the LayaAirIDE,do not modify.*/
package ui.test {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class TestPakcageUI extends ViewPanel {
		public var selectContent:Box;
		public var log_list:List;
		public var tab:Tab;
		public var editContent:Box;
		public var inputText:TextInput;
		public var back:Button;
		public var send:Button;
		public var title_txt:Label;
		public var beizhu_txt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("test/TestPakcage");

		}

	}
}