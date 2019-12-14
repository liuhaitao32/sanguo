package sg.fight.client.view
{
	import laya.events.Event;
	import laya.ui.Image;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.cfg.ConfigServer;
	import sg.fight.FightMain;
	import sg.fight.client.utils.FightViewUtils;
	import sg.manager.AssetsManager;
	import sg.map.utils.TestUtils;
	import sg.model.ModelPrepare;
	import sg.utils.Tools;
	import ui.battle.fightFinishMatchUI;
	
	/**
	 * 比赛类型的战斗结束
	 * @author zhuda
	 */
	public class ViewFightFinishMatch extends fightFinishMatchUI
	{
		private var canExit:Boolean = false;
		
		public function ViewFightFinishMatch(data:Object, showWin:Boolean, delay:int)
		{
			this.initUI(data, showWin, delay);
		}
		
		public function initUI(data:Object, showWin:Boolean, delay:int):void
		{
			var h0:int = 100;
			var h1:int = 100;
			var i:int;
			var len:int = data.records.length;
			this.panel.height = h0 + h1 * len + 20;
			
			//this.alpha = 0;
			//Tween.to(this, {alpha: 1}, 600, null, null, delay);
			this.panel.centerY = 60;
			Tween.to(this.panel, {centerY: 0}, 600, Ease.sineOut, Handler.create(this, this.showComplete), delay);

			
			var w0:int = data.teamWin[0];
			var w1:int = data.teamWin[1];
			this.win0.visible = this.win1.visible = this.imgWin.visible = showWin;
			if(showWin){
				this.win0.text = w0.toString();
				this.win1.text = w1.toString();
				if (w0 == w1)
				{
					this.imgWin.skin = AssetsManager.getAssetsUI('icon_win03.png'); 
				}
				else if (w0 > w1)
				{
					if (w1 == 0)
					{
						this.imgWin.skin = AssetsManager.getAssetsUI('icon_win01.png'); 
					}
					else
					{
						this.imgWin.skin = AssetsManager.getAssetsUI('icon_win02.png'); 
					}
				}
				else
				{
					if (w0 == 0)
					{
						this.imgWin.skin = AssetsManager.getAssetsUI('icon_win05.png'); 
					}
					else
					{
						this.imgWin.skin = AssetsManager.getAssetsUI('icon_win04.png');
					}
				}
			}
			this.name0.text = FightViewUtils.getTroopUserName(data.unames[0]);
			this.name1.text = FightViewUtils.getTroopUserName(data.unames[1]) || Tools.getMsgById('fightEnemyTroop');

			//部分战斗战报可能未完成战斗，或只有单方有人
			for (i = 0; i < len; i++)
			{
				var recordObj:Object = data.records[i];
				for (var j:int = 0; j < 2; j++)
				{
					var troopObj:Object = recordObj.troop[j];
					if (troopObj)
					{
						//加入胜败字眼
						var skin:String;
						if (recordObj.winner == j){
							skin = AssetsManager.getAssetsUI('icon_win09.png');
						}else if (recordObj.winner != -1){
							skin = AssetsManager.getAssetsUI('icon_win10.png');
						}
						else{
							skin = '';
						}
						if(skin){
							var img:Image = new Image(skin);
							img.centerX = 35 * (j == 0? -1:1);
							img.y = i * 100 + 125;
							this.panel.addChild(img);
						}
						
						var troopData:Object = FightMain.instance.client.findTroopData(j, i);
						troopData = ModelPrepare.getData(troopData, true);
						
						var item:ViewFightFinishMatchItem = new ViewFightFinishMatchItem(troopObj, troopData, j == 1);
						item.centerX = 175*(j == 0? -1:1);
						item.y = i * h1 + h0;
						this.panel.addChildAt(item, 1);
					}
				}
			}
			var per0:Number = data.teamHpPer[0];
			var per1:Number = data.teamHpPer[1];
			this.hp0.text = Tools.getMsgById('fightLastHp', [Tools.percentFormat(per0)]);
			this.hp1.text = Tools.getMsgById('fightLastHp', [Tools.percentFormat(per1)]);
			this.bar0.value = per0;
			this.bar1.value = per1;
			
			if (ConfigServer.world.allow_fight_end_details || TestUtils.isTestShow){
				
			}
			else{
				this.on(Event.CLICK, this, this.onExit);
			}
		}
		
		private function showComplete():void
		{
			this.canExit = true;
		}
		
		private function onExit():void
		{
			//不再直接退出，给玩家机会查看英雄
			if (this.canExit)
			{
				FightViewUtils.onExit();
			}
		}
	
	}

}