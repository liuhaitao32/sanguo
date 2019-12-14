/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import laya.html.dom.HTMLDivElement;

	public class guildInfoItemUI extends ItemBase {
		public var icon0:hero_icon1UI;
		public var img0:Image;
		public var textLabel1:Label;
		public var btn0:Button;
		public var textLabel2:HTMLDivElement;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("guild/guildInfoItem");

		}

	}
}