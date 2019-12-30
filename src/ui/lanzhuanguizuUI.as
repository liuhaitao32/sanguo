/**Created by the LayaAirIDE,do not modify.*/
package ui {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.display.Text;

	public class lanzhuanguizuUI extends ViewPanel {
		public var tabs:Tab;
		public var kaitong_btn:Button;
		public var nianfei_btn:Button;
		public var content_0:Image;
		public var herf_txt:Text;
		public var content_1:Image;
		public var lingqu_btn:Button;
		public var container:HBox;
		public var content_2:List;
		public var content_3:Box;
		public var ling1_btn:Button;
		public var dengjibao1_content:Image;
		public var ling2_btn:Button;
		public var dengjibao2_content:Image;

		override protected function createChildren():void {
			View.regComponent("Text",Text);
			super.createChildren();
			loadUI("lanzhuanguizu");

		}

	}
}