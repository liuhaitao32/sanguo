package sg.fight.client.view 
{
	import laya.events.Event;
	import laya.utils.Handler;
	import sg.fight.FightMain;
	import sg.utils.Tools;
	import ui.battle.fightCountryHelpUI;
	/**
	 * 国战帮助
	 * @author zhuda
	 */
	public class ViewFightCountryHelp extends ViewFightHelp
	{
		public function ViewFightCountryHelp() 
		{
			super(Tools.getMsgById('countryHelp_title'), Tools.getMsgById('countryHelp_info'));
		}
	}

}