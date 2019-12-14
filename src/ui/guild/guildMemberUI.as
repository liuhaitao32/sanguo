/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.guild.guildMemberItemUI;

	public class guildMemberUI extends ViewScenes {
		public var list:List;
		public var myCom:guildMemberItemUI;
		public var list1:List;
		public var btnBG:Button;
		public var box1:Box;
		public var btnSet1:Button;
		public var btnSet2:Button;
		public var btnSet3:Button;

		override protected function createChildren():void {
			View.regComponent("ui.guild.guildMemberItemUI",guildMemberItemUI);
			super.createChildren();
			loadUI("guild/guildMember");

		}

	}
}