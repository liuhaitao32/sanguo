/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.battle.fightTestTroopBeastItemUI;
	import laya.html.dom.HTMLDivElement;

	public class fightTestBeastUI extends ViewPanel {
		public var list:List;
		public var comboType:ComboBox;
		public var comboStar:ComboBox;
		public var comboLv:ComboBox;
		public var comboSuper0:ComboBox;
		public var comboSuper1:ComboBox;
		public var comboSuper2:ComboBox;
		public var comboSuperValue0:ComboBox;
		public var comboSuperValue1:ComboBox;
		public var comboSuperValue2:ComboBox;
		public var tName:Label;
		public var tValueArrInfo:Label;
		public var tResonance:Label;
		public var tResonance0:Label;
		public var tResonance1:Label;
		public var tSuper:Label;
		public var tTest:Label;
		public var checkBoxU:CheckBox;
		public var checkBoxD:CheckBox;
		public var btnResonanceL:Button;
		public var btnResonanceR:Button;
		public var btnStarL:Button;
		public var btnStarR:Button;
		public var btnLvL:Button;
		public var btnLvR:Button;
		public var btnClone:Button;
		public var hsTest:HSlider;
		public var htmlTest:HTMLDivElement;
		public var htmlInfo:HTMLDivElement;

		override protected function createChildren():void {
			View.regComponent("ui.battle.fightTestTroopBeastItemUI",fightTestTroopBeastItemUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("battle/fightTestBeast");

		}

	}
}