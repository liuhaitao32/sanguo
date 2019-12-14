/**Created by the LayaAirIDE,do not modify.*/
package ui.init {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class affiche_mergeUI extends ViewPanel {
		public var img_title:Image;
		public var btn_close:Button;
		public var txt_time:Label;
		public var container_info:Panel;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("init/affiche_merge");

		}

	}
}