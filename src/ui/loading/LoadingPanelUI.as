/**Created by the LayaAirIDE,do not modify.*/
package ui.loading {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class LoadingPanelUI extends ItemBase {
		public var container_b:Box;
		public var sp_logo:Image;
		public var container:Box;
		public var sp_darkLogo:Image;
		public var sp_mask:Image;
		public var hintTxt:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("loading/LoadingPanel");

		}

	}
}