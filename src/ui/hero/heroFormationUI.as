/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.com.item_title_s1UI;
	import ui.hero.formationPropItemUI;
	import ui.bag.bagItemUI;
	import ui.hero.formationItemUI;

	public class heroFormationUI extends ViewPanel {
		public var imgTitle:Image;
		public var cTitle:item_titleUI;
		public var boxArr:Box;
		public var tName:Label;
		public var cTitle1:item_title_s1UI;
		public var prop0:formationPropItemUI;
		public var cTitle2:item_title_s1UI;
		public var prop1:formationPropItemUI;
		public var prop2:formationPropItemUI;
		public var tLvNum:Label;
		public var tLvTitle:Label;
		public var cLv:bagItemUI;
		public var lvBox:Box;
		public var bLv:Button;
		public var tRaNum:Label;
		public var tRaTitle:Label;
		public var cRa:bagItemUI;
		public var raBox:Box;
		public var bRarity:Button;
		public var btnForget:Button;
		public var com0:Box;
		public var com1:Box;
		public var com2:Box;
		public var imgSpecial:Image;
		public var bInfo:Box;
		public var tInfo:Label;
		public var btnCheck0:Button;
		public var btnCheck1:Button;
		public var aniTitle:Box;
		public var btnAsk:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.com.item_title_s1UI",item_title_s1UI);
			View.regComponent("ui.hero.formationPropItemUI",formationPropItemUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.hero.formationItemUI",formationItemUI);
			super.createChildren();
			loadUI("hero/heroFormation");

		}

	}
}