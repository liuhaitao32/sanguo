/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;
	import laya.html.dom.HTMLDivElement;

	public class eventTalk1UI extends ViewPanel {
		public var comHero:hero_icon2UI;
		public var infoLabel:Label;
		public var titleLabel:Label;
		public var htmlLabel1:HTMLDivElement;
		public var htmlLabel0:HTMLDivElement;
		public var btn:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("map/eventTalk1");

		}

	}
}