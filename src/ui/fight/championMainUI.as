/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class championMainUI extends ViewScenes {
		public var list:List;
		public var adImg:Image;
		public var mPanel:Box;
		public var mTips:Box;
		public var tInfo:Label;
		public var btn_name:Button;
		public var btnHelp:Button;
		public var btnInfo:Button;
		public var tSession:Label;
		public var tSessionTime:Label;
		public var tTitle:Label;
		public var listFun:List;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("fight/championMain");

		}

	}
}