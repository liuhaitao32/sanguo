package sg.fight.client.spr 
{
	import laya.ui.Image;
	import laya.ui.Label;
	import sg.cfg.ConfigApp;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.unit.ClientArmy;
	import sg.fight.test.TestStatistics;
	import sg.manager.AssetsManager;
	import sg.map.utils.TestUtils;
	import sg.utils.StringUtil;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.client.view.FightScene;
	import sg.fight.client.view.ViewFightTroopInfo;
	import sg.utils.Tools;
	/**
	 * 战斗部队的信息，包含缓动和消失(控制器，spr为显示对象)
	 * @author zhuda
	 */
	public class FTroopInfo extends FInfoBase
	{
		public var troop:ClientTroop;
		public var tPower:Label;
		public var tHp0:Label;
		public var tHp1:Label;
		
		
		
		public function FTroopInfo(troop:ClientTroop)
		{
			this.troop = troop;
			var scene:FightScene = troop.getClientTeam().getClientBattle().fightMain.scene;
			super(scene, '', this.getX(), ConfigFightView.TROOP_INFO_Y, ConfigFightView.TROOP_INFO_Z, troop.isFlip, 1);
		}
		
		override public function init():void
		{
			var view:ViewFightTroopInfo = new ViewFightTroopInfo(this.troop);
			
			this.spr = view;
			
			//FightTime.timer.once(6000, this, this.clear);
			this.addToScene();
		}
		public function get view():ViewFightTroopInfo
		{
			return this.spr as ViewFightTroopInfo;
		}
		
		override public function getX():int
		{
			return this.troop.getCenterX();
		}
		/**
		 * 更新血量
		 */
		public function updateHp(value:Number):void
		{
			if(this.spr != null){
				this.view.hpBar.value = value;
			}
		}
		

		/**
		 * 更新前后军血量
		 */
		public function updateArmysHp(army0:ClientArmy,army1:ClientArmy, isEnd:Boolean = false):void
		{
			if (this.spr != null){
				var hpm0:int = army0.hpm;
				var hpm1:int = army1.hpm;
				var hp0:int = isEnd?army0.hp:army0.lastHp;
				var hp1:int = isEnd?army1.hp:army1.lastHp;
				
				if ((TestUtils.isTestShow || TestStatistics.showSwitch) && (!ConfigApp.testFightType || ConfigFightView.showTest)){
					if (!this.tPower){
						this.tPower = new Label();
						this.tPower.fontSize = 24;
						this.tPower.x = -40;
						this.tPower.y = 15 - 100;
						this.tPower.scale(0.5,0.5);
						this.tPower.color = '#FFFF99';
						this.tPower.strokeColor = '#996633';
						this.tPower.stroke = 2;
						//this.tPower.bold = true;
						this.spr.addChild(this.tPower);
						this.tPower.text = '战力:' + army0.getClientTroop().power;
					}
					if (!this.tHp0){
						this.tHp0 = new Label();
						this.tHp0.fontSize = 24;
						this.tHp0.x = -40;
						this.tHp0.y = 30 - 100;
						this.tHp0.scale(0.5,0.5);
						this.tHp0.color = '#88FFFF';
						this.tHp0.strokeColor = '#336699';
						this.tHp0.stroke = 2;
						this.spr.addChild(this.tHp0);
						//Tools.textFitFontSize(this.tHp0, 60);
					}
					if (!this.tHp1){
						this.tHp1 = new Label();
						this.tHp1.fontSize = 24;
						this.tHp1.x = -40;
						this.tHp1.y = 45 - 100;
						this.tHp1.scale(0.5,0.5);
						this.tHp1.color = '#88FFFF';
						this.tHp1.strokeColor = '#336699';
						this.tHp1.stroke = 2;
						this.spr.addChild(this.tHp1);
						//Tools.textFitFontSize(this.tHp1, 60);
					}
					var txt0:String = '前军' + StringUtil.fillSpace(hp0.toString(), 5) + ' / ' + StringUtil.fillSpace(hpm0.toString(), 5);
					var txt1:String = '后军' + StringUtil.fillSpace(hp1.toString(), 5) + ' / ' + StringUtil.fillSpace(hpm1.toString(), 5);
					
					//if (Math.random() > 0.4){
						//txt0 += 'ABCDEF';
						//txt1 = '311';
					//}
					
					this.tHp0.text = txt0;
					this.tHp1.text = txt1;
				}
				
				var per:Number = (hp0 + hp1) / (hpm0 + hpm1);
				
				this.view.hpBar.value = per;
			}
		}
		
		/**
		 * 更新傲气
		 */
		public function updateProud(value:int):void
		{
			if (this.spr != null){
				this.view.updateProud(value);
			}
		}
		
				
		/**
		 * 改变能量
		 */
		public function changeEnergy(energyType:String, value:int):void
		{
			if (this.spr != null){
				this.view.changeEnergy(energyType,value);
			}
		}
		
		/**
		 * 更新测试内容
		 */
		public function updateTest(value:int):void
		{
			if (this.spr != null){
				this.view.updateTest(value);
			}
		}

		/**
		 * 更新先手
		 */
		public function updateFirst(b:Boolean):void
		{
			if (this.spr != null){
				this.view.updateFirst(b);
			}
		}
		/**
		 * 更新阵法克制
		 */
		public function updateAdept(b:Boolean):void
		{
			if (this.spr != null){
				this.view.updateAdept(b);
			}
		}
		/**
		 * 清空兽灵数量
		 */
		public function clearBeastNum():void
		{
			if (this.spr != null){
				this.view.clearBeastNum();
			}
		}
		
	}

}