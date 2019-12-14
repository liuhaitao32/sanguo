/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class championMatchAUI extends ItemBase {
		public var list:List;
		public var btn:Button;
		public var tTime:Label;
		public var tPage:Label;
		public var tGroup:Button;
		public var btn_next:Button;
		public var btn_back:Button;
		public var boxTime:Box;
		public var tRound0:Label;
		public var tRound1:Label;
		public var text0:Label;
		public var pageNum:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("fight/championMatchA");

		}

	}
}