/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.hero.itemFateUI;
	import laya.html.dom.HTMLDivElement;

	public class heroFateUI extends ItemBase {
		public var adImg:Image;
		public var btn_ok:Button;
		public var sok1:Button;
		public var sok3:Button;
		public var sok0:Button;
		public var sok2:Button;
		public var mClipBox:Box;
		public var b1:Image;
		public var b2:Image;
		public var b0:Image;
		public var b3:Image;
		public var heroMine:itemFateUI;
		public var hero3:itemFateUI;
		public var hero2:itemFateUI;
		public var hero1:itemFateUI;
		public var hero0:itemFateUI;
		public var namebg0:Image;
		public var namebg3:Image;
		public var namebg2:Image;
		public var namebg1:Image;
		public var status_no:Image;
		public var status_ok:Image;
		public var tStatus:Label;
		public var heroName0:Label;
		public var heroName1:Label;
		public var heroName2:Label;
		public var heroName3:Label;
		public var heroName:Label;
		public var hj0:Image;
		public var hj1:Image;
		public var hj3:Image;
		public var hj2:Image;
		public var tStatusType:Label;
		public var tGet:HTMLDivElement;
		public var tInfo:HTMLDivElement;

		override protected function createChildren():void {
			View.regComponent("ui.hero.itemFateUI",itemFateUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("hero/heroFate");

		}

	}
}