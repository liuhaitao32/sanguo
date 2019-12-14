/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightTestStatisticsUI extends ViewPanel {
		public var boxTop:Box;
		public var comboMode:ComboBox;
		public var checkBoxSkill:CheckBox;
		public var btnCurr:Button;
		public var btnAll:Button;
		public var btnTable:Button;
		public var btnClean:Button;
		public var tTPower0:Label;
		public var tTPower1:Label;
		public var tT0:Label;
		public var tT1:Label;
		public var tT2:Label;
		public var tT3:Label;
		public var tT4:Label;
		public var tT5:Label;
		public var list:List;
		public var boxTroop:Box;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightTestStatistics");

		}

	}
}