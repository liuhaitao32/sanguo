/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import ui.bag.bagItemUI;
	import ui.com.item_talentUI;

	public class heroSuperInfoUI extends ViewPanel {
		public var tempImg:Image;
		public var comHero:hero_icon2UI;
		public var pro:ProgressBar;
		public var imgRa:Image;
		public var list:List;
		public var tNum:Label;
		public var textBox:Box;
		public var imgText:Image;
		public var text2:Label;
		public var tPro:Label;
		public var btn:Button;
		public var preLabel:Label;
		public var bTimer:Box;
		public var textImg3:Image;
		public var tTime:Label;
		public var text3:Label;
		public var boxImg:Image;
		public var boxTalent:Box;
		public var text0:Label;
		public var comTalent:item_talentUI;
		public var boxSkill:Box;
		public var comSkill:bagItemUI;
		public var text1:Label;
		public var text4:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.item_talentUI",item_talentUI);
			super.createChildren();
			loadUI("hero/heroSuperInfo");

		}

	}
}