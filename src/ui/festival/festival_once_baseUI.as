/**Created by the LayaAirIDE,do not modify.*/
package ui.festival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class festival_once_baseUI extends ItemBase {
		public var panel:Image;
		public var img_description:Image;
		public var needPayTxt:Label;
		public var btn_get:Button;
		public var list:List;
		public var txt_tips:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("festival/festival_once_base");

		}

	}
}