/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class fightTestUI extends ViewScenes {
		public var btnShow:Button;
		public var btnReset:Button;
		public var btnEffect1:Button;
		public var btnEffect2:Button;
		public var btnEffect3:Button;
		public var btnEffect4:Button;
		public var btnEffect5:Button;
		public var btnEffect6:Button;
		public var btnEffect7:Button;
		public var btnEffect8:Button;
		public var btnEffect9:Button;
		public var btnEffectClear:Button;
		public var btnPause:Button;
		public var btnAddTroop0:Button;
		public var btnAddTroop1:Button;
		public var btnTroop:Button;
		public var btnHidePrint:Button;
		public var btnSkillId:Button;
		public var comboMode:ComboBox;
		public var comboPart:ComboBox;
		public var hs1:HSlider;
		public var hs2:HSlider;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("battle/fightTest");

		}

	}
}