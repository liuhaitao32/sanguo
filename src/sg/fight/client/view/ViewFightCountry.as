package sg.fight.client.view 
{
	import laya.ui.Image;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightUtils;
	import sg.manager.EffectManager;
	import sg.utils.Tools;
	import ui.battle.fightCountryUI;
	import sg.cfg.ConfigServer;
	/**
	 * 国战对战情况，战斗中
	 * @author zhuda
	 */
	public class ViewFightCountry extends fightCountryUI
	{
		public var bar:ViewFightCountryBar;
		
		public function ViewFightCountry(country0:int,country1:int,num0:int,num1:int,fightCount:int) 
		{
			this.bar = new ViewFightCountryBar(country0, country1, num0, num1);
			this.barBox.addChild(this.bar);

			this.setBuffs(0, 0, 0, 0);
			this.updateAll(country0,country1,num0,num1,fightCount);
		}
		/**
		 * 设置tower效果
		 */
		public function setTower(lv0:int,lv1:int):void
		{
			if (lv0 == 0 || lv1 == 0){
				this.imgTower0.centerX = 0;
				this.imgTower1.centerX = 0;
			}
			this.imgTower0.visible = lv0;
			this.imgTower1.visible = lv1;
			
			this.tLv0.text = lv0.toString();
			this.tLv1.text = lv1.toString();
			//this.tTower0.text = Tools.getMsgById('country_tower_lv', [lv0.toString()]);
			//this.tTower1.text = Tools.getMsgById('country_tower_lv', [lv1.toString()]);
		}
		/**
		 * 设置双方的buff效果
		 */
		public function setBuffs(buffDmg0:Number, buffRes0:Number, buffDmg1:Number, buffRes1:Number):void
		{
			this.tDmg0.visible = buffDmg0;
			this.tRes0.visible = buffRes0;
			this.tDmg1.visible = buffDmg1;
			this.tRes1.visible = buffRes1;
			if (buffDmg0){
				Tools.textFitFontSize(this.tDmg0, Tools.getMsgById('country_buff_atk', [Tools.percentFormat(buffDmg0)]));
				//this.tDmg0.text = Tools.getMsgById('country_buff_atk', [Tools.percentFormat(buffDmg0)]);
			}
			if (buffRes0){
				Tools.textFitFontSize(this.tRes0, Tools.getMsgById('country_buff_def', [Tools.percentFormat(buffRes0)]));
				//this.tRes0.text = Tools.getMsgById('country_buff_def', [Tools.percentFormat(buffRes0)]);
			}
			if (buffDmg1){
				Tools.textFitFontSize(this.tDmg1, Tools.getMsgById('country_buff_atk', [Tools.percentFormat(buffDmg1)]));
				//this.tDmg1.text = Tools.getMsgById('country_buff_atk', [Tools.percentFormat(buffDmg1)]);
			}
			if (buffRes1){
				Tools.textFitFontSize(this.tRes1, Tools.getMsgById('country_buff_def', [Tools.percentFormat(buffRes1)]));
				//this.tRes1.text = Tools.getMsgById('country_buff_def', [Tools.percentFormat(buffRes1)]);
			}
		}
		/**
		 * 更新所有
		 */
		public function updateAll(country0:int,country1:int,num0:int,num1:int,fightCount:int, updateBar:Boolean = true):void
		{
			this.country0.setCountryFlag(country0);
			this.country1.setCountryFlag(country1);
			EffectManager.changeSprColor(this.bg0, country0, true, ConfigServer.world.COUNTRY_COLOR_FILTER_MATRIX);
			EffectManager.changeSprColor(this.bg1, country1, true, ConfigServer.world.COUNTRY_COLOR_FILTER_MATRIX);

			if (updateBar)
			{
				this.bar.updateAll(country0, country1, num0, num1);
			}
			this.updateNum(num0, num1, false);
			this.updateFightCount(fightCount);
		}
		/**
		 * 更新双方人数
		 */
		public function updateNum(num0:int, num1:int, updateBar:Boolean = true):void
		{
			this.num0.text = num0.toString();
			this.num1.text = num1.toString();
			
			if (updateBar)
			{
				this.bar.updateNum(num0, num1);
			}
		}
		/**
		 * 更新战斗次数，自动修改石炮倒计时
		 */
		public function updateFightCount(fightCount:int):void
		{
			this.fightIndex.text = Tools.getMsgById('fight_count', [fightCount]);
			
			if (this.imgTower1.visible){
				var num:int;
				if (fightCount == 0){
					num = ConfigFight.towerAct1.cd;
				}
				else{
					num = ConfigFight.towerAct1.cd - (1 + (fightCount + ConfigFight.towerAct1.cd - 1) % ConfigFight.towerAct1.cd);
				}
				this.tTower1.text = num.toString();
				if (num > 5){
					//this.boxTower1.centerX = 0;
					this.tTower1.color = '#664400';
					this.tTower1.stroke = 0;
				}
				else{
					//this.boxTower1.centerX = 4;
					this.tTower1.color = '#FF0000';
					this.tTower1.stroke = 2;
				}
				this.tTower1.strokeColor = '#FFFFFF';
			}
			
		}
	}

}