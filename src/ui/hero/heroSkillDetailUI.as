/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.html.dom.HTMLDivElement;

	public class heroSkillDetailUI extends ItemBase {
		public var panel:Panel;
		public var txtBaseTitle:Label;
		public var hBaseInfo:HTMLDivElement;
		public var hBaseNext:HTMLDivElement;
		public var imgLineBase:Image;
		public var txtHighTitle:Label;
		public var txtHighUnlock:Label;
		public var hHighInfo:HTMLDivElement;
		public var imgLineHigh:Image;
		public var txtMaxTitle:Label;
		public var box:Box;

		override protected function createChildren():void {
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("hero/heroSkillDetail");

		}

	}
}