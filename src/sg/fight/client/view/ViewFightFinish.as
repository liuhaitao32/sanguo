package sg.fight.client.view
{
	import laya.events.Event;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.cfg.ConfigApp;
	import sg.fight.FightMain;
	import sg.fight.client.utils.FightViewUtils;
	import sg.fight.test.TestCopyrightData;
	import sg.guide.model.ModelGuide;
	import sg.guide.view.GuideFocus;
	import sg.guide.view.ViewGuide;
	import sg.utils.Tools;
	import ui.battle.fightFinishUI;
	
	/**
	 * 0显示重播和退出，1只显示退出，2只显示下一章，3只显示再次挑战，4比赛结束
	 * @author zhuda
	 */
	public class ViewFightFinish extends fightFinishUI
	{
		///有此参数时，点击背景不会关闭面板
		public var onlyClose:int = 1;
		///0显示重播和退出，1只显示退出，2挑战成功可重来，3只显示再次挑战 ，4挑战失败
		public var type:int; 	
		
		public function ViewFightFinish(type:int = 0)
		{
			this.type = type;
			this.once(Event.ADDED, this, this.initUI);
			//this.initUI();
		}
		
		public function initUI():void
		{
			//this.alpha = 0;
			//Tween.to(this, {alpha: 1}, 600, null, null, 800);
			this.panel.centerY = 60;
			Tween.to(this.panel, {centerY: 0}, 600, Ease.sineOut,Handler.create(this,this.initComplete));
			
			if (this.type == 0)
			{
				this.btnReplay.on(Event.CLICK, this, this.onReplay);
				this.textTitle.visible = false;
			}
			else if (this.type == 2)
			{
				this.textTitle.text = Tools.getMsgById('fightWinFinish');
				
				this.btnReplay.on(Event.CLICK, this, this.onReFight);
				this.imgReplay.skin = 'fight/fight_img10.png';
				this.imgReplay.centerX = 0;
				

				this.imgExit.skin = 'fight/fight_img09.png';
				this.imgExit.centerX = 0;
			}
			else if (this.type == 4)
			{
				this.btnReplay.on(Event.CLICK, this, this.onReplay);
				this.textTitle.text = Tools.getMsgById('fightCrossFinish');
			}
			else
			{
				this.btnReplay.visible = false;
				this.btnExit.centerX = 0;
				if (this.type == 1)
				{
					this.textTitle.visible = false;
				}
				else
				{
					this.textTitle.text = Tools.getMsgById('fightLoseFinish');
					this.imgExit.skin = 'fight/fight_img10.png';
					this.imgExit.centerX = 0;
				}
			}
		}
		
		private function initComplete():void
		{
			this.btnExit.on(Event.CLICK, null, FightViewUtils.onExit);
			
			if (ModelGuide.forceGuide()){
				//强制引导圈住返回按钮，hint
				GuideFocus.focusInSprite(this.btnExit,false);
			}
		}
		
		/**
		 * 重播完整战斗
		 */
		private function onReplay():void
		{
			if (!ModelGuide.forceGuide()){
				FightMain.instance.reset();
			}
		}
		
		/**
		 * 胜利，再次挑战
		 */
		private function onReFight():void
		{
			if (ConfigApp.testFightType == 2){
				TestCopyrightData.currChapter = Math.max(TestCopyrightData.currChapter-1, 0);
			}
			FightViewUtils.onExit();
		}
	
	}

}