/**Created by the LayaAirIDE,do not modify.*/
package ui.battle {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_power2UI;

	public class fightTestTroopUI extends ViewPanel {
		public var boxMain:Box;
		public var boxSkill:Box;
		public var boxBeast:Box;
		public var btnBeast:Button;
		public var checkBoxBeast:CheckBox;
		public var checkBoxPlayer:CheckBox;
		public var checkBoxAwaken:CheckBox;
		public var checkBoxFate:CheckBox;
		public var checkBoxPolitics:CheckBox;
		public var comboHid:ComboBox;
		public var comboEquip:ComboBox;
		public var comboStar:ComboBox;
		public var comboScience:ComboBox;
		public var comboAdjutant:ComboBox;
		public var comboOfficial:ComboBox;
		public var comboTitle:ComboBox;
		public var comboLegend:ComboBox;
		public var comboFormation:ComboBox;
		public var comboSpirit:ComboBox;
		public var comboDefault:ComboBox;
		public var comboHpPoint:ComboBox;
		public var comboProud:ComboBox;
		public var boxLv:Box;
		public var hsLv:HSlider;
		public var tLv:Label;
		public var boxBuild:Box;
		public var hsBuild:HSlider;
		public var tBuild:Label;
		public var boxStar:Box;
		public var hsStar:HSlider;
		public var tStar:Label;
		public var boxSkillLv:Box;
		public var hsSkillLv:HSlider;
		public var tSkillLv:Label;
		public var boxArmyRank:Box;
		public var hsArmyRank:HSlider;
		public var tArmyRank:Label;
		public var boxArmyLv:Box;
		public var hsArmyLv:HSlider;
		public var tArmyLv:Label;
		public var boxArmyAdd:Box;
		public var hsArmyAdd:HSlider;
		public var tArmyAdd:Label;
		public var boxShogun:Box;
		public var hsShogun:HSlider;
		public var tShogun:Label;
		public var boxJson:Box;
		public var tHeroName:Label;
		public var inputPrepare:TextInput;
		public var uiPower:hero_power2UI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_power2UI",hero_power2UI);
			super.createChildren();
			loadUI("battle/fightTestTroop");

		}

	}
}