/**Created by the LayaAirIDE,do not modify.*/
package ui {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class EditMenuUI extends View {
		public var astarChange_btn:Button;
		public var save_btn:Button;
		public var img_slider:HSlider;
		public var hideGrid_btn:Button;
		public var check_btn:Button;
		public var lu_btn:Button;
		public var fabu_btn:Button;
		public var daolu_btn:Button;
		public var occupy_btn:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("EditMenu");

		}

	}
}