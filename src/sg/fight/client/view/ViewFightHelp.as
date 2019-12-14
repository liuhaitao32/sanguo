package sg.fight.client.view 
{
	import laya.events.Event;
	import laya.utils.Handler;
	import sg.fight.FightMain;
	import sg.utils.Tools;
	import ui.battle.fightCountryHelpUI;
	/**
	 * 战斗帮助
	 * @author zhuda
	 */
	public class ViewFightHelp extends fightCountryHelpUI
	{
		public function ViewFightHelp(title:String, info:String) 
		{
			this.txtTitle.text = title;
			this.txtInfo.text = info;

			this.btnClose.on(Event.CLICK, this, this.onClose);
			this.once(Event.ADDED,this,this.initUI);
		}
		public function onClose():void
		{
			FightMain.instance.ui.closePopView();
		}
		
		private function initUI() :void
		{
			//trace(this.txtInfo.measureHeight);
			//trace(this.txtInfo.height);
			//trace(this.txtInfo.displayHeight);
			//trace(this.txtInfo.textField.textHeight);
			//trace(this.txtInfo.textField.lines);
			//trace(this.txtInfo.textField.width);
			var h:Number = 140 + Math.max(this.txtInfo.textField.textHeight, 0);
			this.panel.height = h;
		}
	}

}