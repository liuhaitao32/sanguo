/**Created by the LayaAirIDE,do not modify.*/
package ui.more {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.more.item_rank_user1UI;
	import ui.more.item_rank_kill1UI;

	public class more_rank_mainUI extends ViewScenes {
		public var box:Box;
		public var tab:Tab;
		public var box_list:Box;
		public var list:List;
		public var box_title:Box;
		public var title0:Label;
		public var title1:Label;
		public var title2:Label;
		public var title3:Label;
		public var box_country:Box;
		public var imgFlag:Image;
		public var tCountry:Label;
		public var box_time:Box;
		public var box_time2:Box;
		public var img2Time:Image;
		public var text0:Label;
		public var tTime:Label;
		public var item_rank_user:item_rank_user1UI;
		public var item_rank_kill:item_rank_kill1UI;
		public var btnChange:Button;

		override protected function createChildren():void {
			View.regComponent("ui.more.item_rank_user1UI",item_rank_user1UI);
			View.regComponent("ui.more.item_rank_kill1UI",item_rank_kill1UI);
			super.createChildren();
			loadUI("more/more_rank_main");

		}

	}
}