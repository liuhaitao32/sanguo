/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.inside.pveItem0UI;
	import ui.com.award_box3UI;

	public class pveMainUI extends ViewScenes {
		public var list:List;
		public var box0:Box;
		public var starNumLabel:Label;
		public var comBox3:Box;
		public var box3:award_box3UI;
		public var comBox2:Box;
		public var box2:award_box3UI;
		public var comBox1:Box;
		public var box1:award_box3UI;
		public var btnAdd:Image;
		public var markLabel:Label;
		public var numLabel:Label;
		public var text0:Label;
		public var titleLabel:Label;
		public var comLeft:Box;
		public var comRight:Box;

		override protected function createChildren():void {
			View.regComponent("ui.inside.pveItem0UI",pveItem0UI);
			View.regComponent("ui.com.award_box3UI",award_box3UI);
			super.createChildren();
			loadUI("inside/pveMain");

		}

	}
}