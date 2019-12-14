/**Created by the LayaAirIDE,do not modify.*/
package ui.fight {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.army_icon1UI;
	import ui.bag.bagItemUI;
	import ui.com.rank_index_img_tUI;

	public class climbMainUI extends ViewScenes {
		public var adImg:Image;
		public var clip0:Image;
		public var btn_help:Button;
		public var btn_ok:Button;
		public var btn_add:Button;
		public var txt0:Label;
		public var tNumMax:Label;
		public var txt1:Label;
		public var iTimes:Label;
		public var tLv:Label;
		public var text0:Label;
		public var text1:Label;
		public var tTimes:Label;
		public var army0:army_icon1UI;
		public var army1:army_icon1UI;
		public var tSeason:Label;
		public var list:List;
		public var tTips2:Label;
		public var mRankBox:Box;
		public var btn_rank:Button;
		public var award:bagItemUI;
		public var tKill:Label;
		public var award_txt:Label;
		public var iKill:Label;
		public var iRank:Label;
		public var tTips1:Label;
		public var rankCom:rank_index_img_tUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.army_icon1UI",army_icon1UI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.rank_index_img_tUI",rank_index_img_tUI);
			super.createChildren();
			loadUI("fight/climbMain");

		}

	}
}