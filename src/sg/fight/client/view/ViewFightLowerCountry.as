package sg.fight.client.view 
{
	import laya.events.Event;
	import sg.fight.FightMain;
	import ui.battle.fightLowerCountryUI;
	/**
	 * 底部按钮区域
	 * @author zhuda
	 */
	public class ViewFightLowerCountry extends fightLowerCountryUI
	{
		private var uid:int;
		
		public function ViewFightLowerCountry(uid:int) 
		{
			this.mouseThrough = true;
			this.uid = uid;
			
			this.btnRank.on(Event.CLICK, this, this.onRank);
			this.btnHelp.on(Event.CLICK, this, this.onHelp);
		}
		
		
		public function onRank():void{
			var view:ViewFightCountryRank = new ViewFightCountryRank(uid);
			FightMain.instance.ui.popView(view, 100);
		}
		
		public function onHelp():void{
			var view:ViewFightCountryHelp = new ViewFightCountryHelp();
			FightMain.instance.ui.popView(view, 100);
		}

	}

}