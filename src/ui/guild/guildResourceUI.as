/**Created by the LayaAirIDE,do not modify.*/
package ui.guild {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.payTypeBigUI;

	public class guildResourceUI extends ViewScenes {
		public var Box0:Box;
		public var Box1:Box;
		public var textLabel02:Label;
		public var textLabel01:Label;
		public var Box2:Box;
		public var timerLabel:Label;
		public var btnInfo:Button;
		public var btnGet:Button;
		public var textLabel03:Label;
		public var boxBottom:Box;
		public var textLabel04:Label;
		public var boxWeekBuild:Box;
		public var weekBuildLabel:Label;
		public var weekBuildNum:Label;
		public var boxWeekKill:Box;
		public var weekKillLabel:Label;
		public var weekKillNum:Label;
		public var conditionBox:Box;
		public var info2:Label;
		public var info0:Label;
		public var info1:Label;
		public var boxReeward:Box;
		public var textLabel05:Label;
		public var rewardList:List;

		override protected function createChildren():void {
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			super.createChildren();
			loadUI("guild/guildResource");

		}

	}
}