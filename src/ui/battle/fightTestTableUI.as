/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.battle.fightTestTableItemUI;
	import ui.battle.fightTestTableRateItemUI;

	public class fightTestTableUI extends ViewPanel {
		public var inputPrepare:TextInput;
		public var boxMain:Box;
		public var listY:List;
		public var listX:List;
		public var listRate:List;

		override protected function createChildren():void {
			View.regComponent("ui.battle.fightTestTableItemUI",fightTestTableItemUI);
			View.regComponent("ui.battle.fightTestTableRateItemUI",fightTestTableRateItemUI);
			super.createChildren();
			loadUI("battle/fightTestTable");

		}

	}
}