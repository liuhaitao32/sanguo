/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import laya.html.dom.HTMLDivElement;

	public class heroSkillDetailItemUI extends ItemBase {
		public var txtUnlock:Label;
		public var hInfo:HTMLDivElement;

		override protected function createChildren():void {
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("hero/heroSkillDetailItem");

		}

	}
}