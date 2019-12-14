/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.guild.guildAchieveItemUI;
	import ui.com.payTypeBigUI;

	public class guildAchieveUI extends ViewScenes {
		public var list:List;
		public var list1:List;
		public var text:Label;
		public var titleLabel:Label;
		public var infoLabel:Label;
		public var boxBottom:Box;
		public var imgGet:Image;
		public var textLabel01:Label;
		public var rewardList:List;

		override protected function createChildren():void {
			View.regComponent("ui.guild.guildAchieveItemUI",guildAchieveItemUI);
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			super.createChildren();
			loadUI("guild/guildAchieve");

		}

	}
}