package sg.fight.test
{
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Handler;
	import sg.cfg.ConfigServer;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.manager.EffectManager;
	import sg.model.ModelHero;
	import sg.model.ModelSkill;
	import sg.utils.Tools;
	import sg.view.com.ComPayType;
	import ui.battle.fightTestTroopSkillItemUI;
	import ui.battle.fightTestTroopSkillUI;
	import ui.battle.fightTestTroopUI;
	
	/**
	 * 测试模式-1，修改部队技能，此UI为控制一列技能
	 * @author zhuda
	 */
	public class TestFightTroopSkill extends fightTestTroopSkillUI
	{
		public var mArr:Array;
		public var testTroop:TestFightTroop;
		///位置索引 0123
		public var index:int;
		public var skillType:int;
		public var listData:Array;
		
		public function TestFightTroopSkill(index:int,testTroop:TestFightTroop)
		{
			this['noAlignByPC'] = 1;
			super();
			
			this.mouseEnabled = true;
			this.index = index;
			this.testTroop = testTroop;
			this.x = index * 80;
			//this.initUI();
			this.once(Event.ADDED, this, this.initUI);
		}
		
		public function initUI():void
		{
			//this.list.mouseEnabled = true;
			this.list.scrollBar.hide = true;
			//
			this.list.renderHandler = new Handler(this, this.listRender);
			
			if (index == 0 || index == 3){
				this.btn.gray = true;
				EffectManager.bindMouseTips(this.btn, '右键切空满');
			}
			else{
				this.btn.off(Event.CLICK, this, this.onChangeArmyType);
				this.btn.on(Event.CLICK, this, this.onChangeArmyType);
				EffectManager.bindMouseTips(this.btn, '左键换兵种，右键切空满');
			}
			this.btn.off(Event.RIGHT_CLICK, this, this.onChangeTotalSelection);
			this.btn.on(Event.RIGHT_CLICK, this, this.onChangeTotalSelection);
		}
		/**
		 * 仅切换显示 指定技能与原始不同显示红色，反之绿色
		 */
		public function updateArmyType():void
		{
			if (this.skillType <= 3){
				var heroCfg:Object = ConfigServer.hero[this.testTroop.getCurrHid()];
				if (heroCfg.army[this.index -1] == this.skillType){
					this.btn.labelColors = '#008800';
				}
				else{
					this.btn.labelColors = '#880000';
				}
			}
		}
		/**
		 * 设定技能类别并更新
		 */
		public function setType(skillType:int):void
		{
			this.skillType = skillType;
			this.updateArmyType();

			if (this.index == 1){
				TestFightTroop.armyTypeArr[this.testTroop.troopIndex][0] = skillType;
			}
			else if (this.index == 2){
				TestFightTroop.armyTypeArr[this.testTroop.troopIndex][1] = skillType;
			}
			
			
			var data:Object = {};
			//该类技能集合
			var objs:Object = ConfigFight.testSkills[skillType];
			for (var key:String in objs) 
			{
				data[key] = TestFightTroop.openArr[this.testTroop.troopIndex][3];
				//this.openArr.push[1];
			}
			
			
			this.listData = ModelSkill.getSortSkillArr(data, null);
			var smd:ModelSkill;
			var i:int;
			
			var currListArr:Array = TestFightTroop.openSkillArr[this.testTroop.troopIndex];
			var currArr:Array;
			if (currListArr.length <= this.index){
				currArr = [];
				currListArr.push(currArr);
				for (i = 0; i < this.listData.length; i++) 
				{
					smd = this.listData[i];
					currArr.push(objs[smd.id]);
				}
			}
			currArr = currListArr[this.index];
			
			var arr:Array = [];
			for (i = 0; i < this.listData.length; i++) 
			{
				smd = this.listData[i];
				smd['open'+ this.testTroop.troopIndex] = currArr[i];
				//arr.push({});
			}
			
			//this.list.dataSource = listData;
			this.list.array = this.listData;
			
			this.updateBtnLabelNum();
			//listData.reverse()
			//var smd:ModelSkill = ModelSkill.getModel('skill201');
			//this.list.array = [ModelSkill.getModel('skill201'), ModelSkill.getModel('skill202'), ModelSkill.getModel('skill203')];
		
			//this.mouseEnabled = true;
			//this.btnShow.on(Event.CLICK, this, this.onChangeShowTest);
		}
		/**
		 * 刷新当前已选技能数量
		 */
		public function updateBtnLabelNum():void
		{
			var num:int = 0;
			var smd:ModelSkill;
			var i:int;
			for (i = 0; i < this.listData.length; i++) 
			{
				smd = this.listData[i];
				if (smd['open' + this.testTroop.troopIndex]){
					num++;
				}
			}
			
			this.btn.label = Tools.getMsgById('skill_type_simple_' + this.skillType) + num;
		}
		/**
		 * 全选或全不选技能
		 */
		public function onChangeTotalSelection():void
		{
			var currArr:Array = this.getCurrOpenArr();
			var select:Boolean = 1-currArr[0];
			for (var i:int = 0; i < currArr.length; i++) 
			{
				currArr[i] = select;
			}
			this.setType(this.skillType);
			this.testTroop.updateAllData();
		}
		/**
		 * 改变兵种
		 */
		public function onChangeArmyType():void
		{
			var type:int;
			if (this.index == 1){
				//this.setType(type);
				type = 1 - this.skillType;
				this.setType(type);
				this.testTroop.updateAllData();
			}
			else if(this.index == 2){
				//this.setType(5 - this.skillType);
				type = 5 - this.skillType;
				this.setType(type);
				this.testTroop.updateAllData();
			}

		}
		
		private function listRender(cell:Box, index:int):void
		{
			var item:ComPayType = cell.getChildByName('skillItem') as ComPayType;
			var smd:ModelSkill = this.list.array[index];
			if (this.testTroop){
				var troopIndex:int = this.testTroop.troopIndex;
				var lv:int = this.testTroop.getCurrSkillLv(smd);
				//如果有天生的技能，则显示其等级
				var lvBorn:int = TestFightTroop.getHeroBornSkillLv(this.testTroop.getCurrHid(), smd);
				//var lvLabel:Label = item.getChildByName("lvLabel") as Label;
				if (lvBorn){
					item.setSkillItem(smd, lv, '|' + lvBorn);
					//lvLabel.fontSize = 12;
				}
				else
				{
					item.setSkillItem(smd, lv);
					//lvLabel.fontSize = 16;
				}
				
				var nameLabel:Label = item.getChildByName("nameLabel") as Label;
				//var skillName:String;
				if (TestStatistics.showSwitch){
					//技能名称
					//skillName = smd.getName() + smd.id.substr(5);
					nameLabel.text = smd.getName() + smd.id.substr(5);
					//nameLabel.fontSize = 12;
				}
				else{
					//skillName = smd.getName();
					//nameLabel.fontSize = 16;
				}
				//Tools.textFitFontSize2(fightSpeak.tSpeak, this.info);
				
				this.showItem(item, smd['open'+ troopIndex]);
				item.off(Event.CLICK, this, this.clickItem);
				item.on(Event.CLICK, this, this.clickItem, [item, index]);
			}else {
				item.setSkillItem(smd, 1);
			}
		}
		
		private function clickItem(item:Sprite, index:int):void
		{
			var currArr:Array = this.getCurrOpenArr();
			currArr[index] = 1 - currArr[index];
			this.testTroop.initSkills();
		}


		private function showItem(item:Sprite,b:Boolean):void
		{
			if (b)
			{
				item.alpha = 1;
			}
			else
			{
				item.alpha = 0.4;
			}
		}
		private function getCurrOpenArr():Array
		{
			var currListArr:Array = TestFightTroop.openSkillArr[this.testTroop.troopIndex];
			return currListArr[this.index];
		}
	}

}