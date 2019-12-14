package sg.fight.client.view
{
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigClass;
	import sg.fight.FightMain;
	import sg.fight.client.ClientBattle;
	import sg.fight.client.unit.ClientTeam;
	import sg.fight.client.unit.ClientTroop;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.model.ModelPrepare;
	import sg.model.ModelTroop;
	import sg.utils.Tools;
	import ui.battle.fightCountryTurnItemUI;
	import ui.battle.fightCountryTurnUI;
	
	/**
	 * 国战我的部队
	 * @author zhuda
	 */
	public class ViewFightCountryTurn extends fightCountryTurnUI
	{
		private var fightTroop:ClientTroop;
		
		private var clientBattle:ClientBattle;
		private var teamIndex:int;
		private var uid:int;
		private var dataArr:Array;
		
		public function ViewFightCountryTurn(clientBattle:ClientBattle,teamIndex:int,uid:int,uname:String,country:int)
		{
			this['noAlignByPC'] = 1;
			super();
			//this.dataArr = TestCopyrightData.heroInitArr;
			this.clientBattle = clientBattle;
			this.teamIndex = teamIndex;
			this.uid = uid;
			
			this.list.mouseEnabled = true;
			this.list.hScrollBarSkin = '';
			
			this.list.renderHandler = new Handler(this, this.onRender);
			this.list.mouseHandler = new Handler(this, this.onMouse);
			
			this.flag.setCountryFlag(country);
			this.txtName.text = uname;
			
			this.onChange();
		}
		

		
		override public function onChange(type:* = null):void
		{
			//更新每个英雄的数据
			if (type == null)
			{
				//获取该玩家在本队中当前的所有部队
				this.dataArr = this.clientBattle.getUserTroops(this.teamIndex,this.uid);
				this.list.array = this.dataArr;
				
				this.visible = this.dataArr.length > 0;
			}
			else
			{
				if (this.fightTroop && this.fightTroop == type){
					//更新正在战斗的血量
					this.list.changeItem(0, this.dataArr[0]);
				}
			}
		
			//this.gold_var.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_GOLD),Tools.textSytle(ModelManager.instance.modelUser.gold));
		}
		
		private function onRender(cell:Box, index:int):void
		{
			//如果索引不再可索引范围，则终止该函数
			if (index > this.dataArr.length) return;
			//获取当前渲染条目的数据
			var troop:ClientTroop = this.dataArr[index];
			var item:fightCountryTurnItemUI = cell.getChildByName('heroItem') as fightCountryTurnItemUI;
			item.heroItem.setHeroIcon(troop.hid);
			item.textLv.text = troop.heroLogic.lv.toString();
			
			var str:String;
			var fontSize:int = 16;
			var colorStr:String;
			var troopIndex:int = troop.troopIndex;
			if (this.clientBattle && this.clientBattle.readyTime==0 &&!this.clientBattle.isFighting){
				troopIndex -= 1;
			}
			
			if (troopIndex < 0){
				str = Tools.getMsgById('fight_troop_turn_fighting');
				colorStr = '#DD6600';
				fontSize = 18;
				this.fightTroop = troop;
			}else{
				str = Tools.getMsgById('fight_troop_turn_waiting',[troopIndex + 1]);
				colorStr = '#334488';
			}
			
			item.textIndex.text = str;
			item.textIndex.fontSize = fontSize;
			item.textIndex.strokeColor = colorStr;
			
			item.textPower.text = troop.power == 0 ? '' : Tools.getMsgById('fight_troop_turn_power', [Tools.textSytle(troop.power)]);
			item.hpBar.value = troop.getHpPer();
		}
		
		private function onMouse(e:Event, index:int):void
		{
			//鼠标单击事件触发
			if (e.type == Event.CLICK)
			{
				//记录当前条目所包含组件的数据信息(避免后续删除条目后数据结构显示错误)
				var troop:ClientTroop = this.dataArr[index];
				var troopIndex:int = troop.troopIndex;
				if (troopIndex <= 0){
					var str:String = Tools.getMsgById('fight_troop_turn_warning', [troop.getClientHero().name]);
					ViewManager.instance.showTipsTxt(str);
					return;
				}
				
				if (ConfigApp.testFightType == 0){
					//显示我的部队状态，可以撤军和突破
					//ViewManager.instance.showTipsTxt('点击了英雄' + troop.hid);
					var mt:ModelTroop = ModelManager.instance.modelTroopManager.getTroop(troop.hid);
					ViewManager.instance.showView(ConfigClass.VIEW_TROOP_EDIT, mt);
					
					//ViewManager.instance.showView(ConfigClass.VIEW_CITY_SEND,[mt, mt.cityId, -1]);
				}
				else{
					//移除出队伍
					troop.getClientTeam().removeTroop(troopIndex);

				}
			}
		}
	}

}