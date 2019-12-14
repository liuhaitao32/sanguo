/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.award_box2UI;
	import ui.guild.guildInfoItemUI;
	import laya.html.dom.HTMLDivElement;
	import ui.com.hero_power2UI;

	public class guildInfoUI extends ViewScenes {
		public var pro:ProgressBar;
		public var comBox:award_box2UI;
		public var boxNumLabel:Label;
		public var btnAsk:Button;
		public var boxLabel:Label;
		public var textLabel2:Label;
		public var proText:Label;
		public var btnTest:Button;
		public var list:List;
		public var btnSet:Button;
		public var btnMsg:Button;
		public var btnEditor:Button;
		public var nameLabel:Label;
		public var leaderLabel:Label;
		public var leaderLabel2:Label;
		public var numLabel:Label;
		public var textLabel1:Label;
		public var text0:Label;
		public var text1:Label;
		public var text3:Label;
		public var text2:Label;
		public var contentLabel:TextInput;
		public var panel:Panel;
		public var msgLabel0:HTMLDivElement;
		public var msgLabel1:HTMLDivElement;
		public var msgLabel2:HTMLDivElement;
		public var comPower:hero_power2UI;
		public var box1:Box;
		public var btnCheck:Button;
		public var btnChange:Button;
		public var btnQuit:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.award_box2UI",award_box2UI);
			View.regComponent("ui.guild.guildInfoItemUI",guildInfoItemUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			super.createChildren();
			loadUI("guild/guildInfo");

		}

	}
}