package sg.fight.client.view
{
	import laya.events.Event;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.cfg.ConfigApp;
	import sg.fight.FightMain;
	import sg.fight.client.ClientBattle;
	import sg.fight.client.utils.FightSocket;
	import sg.fight.client.utils.FightViewUtils;
	import sg.fight.test.TestCopyrightData;
	import sg.guide.model.ModelGuide;
	import sg.guide.view.GuideFocus;
	import sg.guide.view.ViewGuide;
	import sg.utils.Tools;
	import ui.battle.fightFinishArenaUI;
	
	/**
	 * 擂台战结算面板
	 * @author zhuda
	 */
	public class ViewFightFinishArena extends fightFinishArenaUI
	{
		///有此参数时，点击背景不会关闭面板
		public var onlyClose:int = 1;
		///胜负，为-1时未到结算时间
		public var winner:int; 
		///是否包含下一个的按钮
		public var hasNext:Boolean; 
		///玩家自己队伍的teamIndex
		public var selfTeam:int; 
		
		public function ViewFightFinishArena(winner:int, hasNext:Boolean, selfTeam:int = -1)
		{
			this.winner = winner;
			this.hasNext = hasNext;
			this.selfTeam = selfTeam;
			this.once(Event.ADDED, this, this.initUI);
			//this.initUI();
		}
		
		public function initUI():void
		{
			//this.alpha = 0;
			//Tween.to(this, {alpha: 1}, 600, null, null, 800);
			this.panel.centerY = 60;
			Tween.to(this.panel, {centerY: 0}, 600, Ease.sineOut, Handler.create(this, this.initComplete));
			
			if (this.winner == 0){
				if (this.selfTeam == 1){
					//我方守擂失败
					this.textTitle.text = Tools.getMsgById('fightArenaTeamLose1');
					this.textTitle.color = '#BBBBBB';
					this.textTitle.strokeColor = '#555555';
				}
				else{
					//攻擂成功
					this.textTitle.text = Tools.getMsgById('fightArenaWinFinish');
					this.textTitle.color = '#FFFF99';
					this.textTitle.strokeColor = '#BB6600';
				}
			}
			else if (this.winner == 1){
				if (this.selfTeam == 0){
					//我方攻擂失败
					this.textTitle.text = Tools.getMsgById('fightArenaTeamLose0');
					this.textTitle.color = '#BBBBBB';
					this.textTitle.strokeColor = '#555555';
				}
				else{
					//守擂成功
					this.textTitle.text = Tools.getMsgById('fightArenaLoseFinish');
				}
			}
			else{
				this.textTitle.visible = false;
			}
			
			
			if (this.hasNext)
			{

			}
			else 
			{
				this.btnNext.visible = false;
				this.btnReplay.centerX = -80;
				this.btnExit.centerX = 80;
			}
			
		}
		
		private function initComplete():void
		{
			this.btnReplay.on(Event.CLICK, this, this.onReplay);
			this.btnExit.on(Event.CLICK, null, FightViewUtils.onExit);
			this.btnNext.on(Event.CLICK, this, this.onNext);
			
			if (ModelGuide.forceGuide()){
				//强制引导圈住返回按钮，hint
				GuideFocus.focusInSprite(this.btnExit,false);
			}
		}
		
		/**
		 * 继续观战，下一场挑战
		 */
		private function onNext():void
		{
			//读取下一场攻擂的战斗数据，重开
			if (FightMain.instance && FightMain.instance.client){
				var battle:ClientBattle = FightMain.instance.client;
				FightSocket.sendGetArenaNext(battle.arena_group, battle.data.log_index);
			}	
		}
		
		/**
		 * 重播完整战斗
		 */
		private function onReplay():void
		{
			FightMain.instance.reset();
		}
	
	}

}