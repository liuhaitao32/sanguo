package sg.fight.client.view 
{
	import laya.events.Event;
	import sg.cfg.ConfigApp;
	import sg.fight.FightMain;
	import sg.fight.client.ClientBattle;
	import sg.fight.client.utils.FightViewUtils;
	import sg.fight.test.TestFightData;
	import sg.guide.model.ModelGuide;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	import ui.battle.fightTopUI;
	/**
	 * 战斗返回按钮
	 * @author zhuda
	 */
	public class ViewFightTop extends fightTopUI
	{
		public function ViewFightTop() 
		{
			this.once(Event.ADDED, this, this.initUI);
		}
		private function initUI():void
		{
			this.btnExit.on(Event.CLICK, this, this.onExit);
			if (ConfigApp.testFightType == 1){
				this.btnExit.right = -15;
			}
			if (FightMain.instance.isLimitExitButton){
				this.btnExit.gray = true;
			}
		}
		
		private function onExit():void
		{
			if (FightMain.instance.isLimitExitButton){
				//强制引导中禁止跳过
				ViewManager.instance.showTipsTxt(Tools.getMsgById('fightGuideSkip'));
				return;
				//ViewGuide.hintSprite(this.btnExit);
			}
			var client:ClientBattle = FightMain.instance.client;
			if (client.isCountry || client.isDurationPVE){
				FightViewUtils.onExit();
			}
			else{
				FightMain.instance.ui.checkFinish(0);
			}
		}
	}

}