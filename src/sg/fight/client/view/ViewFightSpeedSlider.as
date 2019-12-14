package sg.fight.client.view 
{
	import laya.events.Event;
	import sg.fight.FightMain;
	import sg.fight.client.utils.FightTime;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.guide.model.ModelGuide;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	import ui.battle.fightSpeedSliderUI;
	/**
	 * 底部调节速度
	 * @author zhuda
	 */
	public class ViewFightSpeedSlider extends fightSpeedSliderUI
	{
		
		public function ViewFightSpeedSlider() 
		{
			this.mouseThrough = true;
		}
		
		override public function init() :void
		{
			this.once(Event.REMOVED, this, this.clear);
			
			//this.parent.removeSelf();
			//this.gray = true;
			this.hsSpeed.on(Event.CHANGE, this, this.onChangeSpeed);
			this.hsSpeed.value = FightTime.timer.scale;
		}
		
		
		public function onChangeSpeed():void{
			//this.gray = false;
			var value:Number = this.hsSpeed.value;
			{
				if (value > 10){
					value = 10;
				}
				
				FightTime.setTimeScale(value);
				this.tSpeed.text = value+'倍速';
			}
		}
		
		override public function clear():void{
			this.destroy();
		}
	}

}