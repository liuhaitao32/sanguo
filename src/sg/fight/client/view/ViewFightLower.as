package sg.fight.client.view 
{
	import laya.events.Event;
	import sg.fight.FightMain;
	import sg.fight.client.utils.FightTime;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.guide.model.ModelGuide;
	import sg.manager.AssetsManager;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	import ui.battle.fightLowerUI;
	/**
	 * 底部按钮区域
	 * @author zhuda
	 */
	public class ViewFightLower extends fightLowerUI
	{
		
		public function ViewFightLower() 
		{
			this.mouseThrough = true;
		}
		
		override public function init() :void
		{
			this.once(Event.REMOVED, this, this.clear);
			
			//this.parent.removeSelf();
			
			if (FightMain.instance.client.isSolo){
				this.btnTimeScale.right = this.btnNextFight.right;
				this.btnNextFight.visible = false;
			}else{
				this.btnNextFight.on(Event.CLICK, this, this.onNextFight);
				//跳过按钮每秒检测灰化
				this.checkCanSkip();
				Laya.timer.loop(500, this, this.checkCanSkip);
			}
			this.btnTimeScale.on(Event.CLICK, this, this.onTimeScale);
			if (FightMain.instance.isLimitSpeedButton){
				this.btnTimeScale.gray = true;
			}
			
			if (Tools.hasMsgById('battleHelpTitle_' + FightMain.instance.client.mode)){
				this.btnHelp.on(Event.CLICK, this, this.onHelp);
			}
			else{
				this.btnHelp.visible = false;
			}
			
			this.onChange();
		}
		
		public function onHelp():void{
			var view:ViewFightHelp = new ViewFightHelp(Tools.getMsgById('battleHelpTitle_' + FightMain.instance.client.mode), Tools.getMsgById('battleHelpInfo_' + FightMain.instance.client.mode));
			FightMain.instance.ui.popView(view, 100);
		}
		
		override public function onChange(type:* = null):void{
			this.btnTimeImg.skin = FightTime.timer.scale == ConfigFight.fightLowSpeed ? AssetsManager.getAssetsFight('fight_img08'):AssetsManager.getAssetsFight('fight_img04');
		}
		
		/**
		 * 修改战斗速度
		 */
		private function onTimeScale():void
		{
			if (FightMain.instance.isLimitSpeedButton){
				//强制引导中禁止修改战斗速度
				ViewManager.instance.showTipsTxt(Tools.getMsgById('fightGuideSpeed'));
				return;
			}
			FightTime.changeTimeScale();
		}
		/**
		 * 跳过当前战斗
		 */
		private function onNextFight():void
		{
			FightMain.instance.client.skip();
			this.checkCanSkip();
		}
		
		private function checkCanSkip():void{
			this.btnNextFight.disabled = !FightMain.instance.client.canSkip();
		}
		
		override public function clear():void{
			Laya.timer.clear(this, this.checkCanSkip);
			this.destroy();
		}
	}

}