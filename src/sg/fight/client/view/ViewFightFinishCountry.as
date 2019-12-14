package sg.fight.client.view
{
	import laya.events.Event;
	import laya.utils.Ease;
	import laya.utils.Tween;
	import sg.cfg.ConfigApp;
	import sg.fight.FightMain;
	import sg.fight.client.utils.FightViewUtils;
	import sg.fight.test.TestCopyrightData;
	import sg.utils.Tools;
	import ui.battle.fightFinishCountryUI;
	
	/**
	 * 国战结束
	 * @author zhuda
	 */
	public class ViewFightFinishCountry extends fightFinishCountryUI
	{
		///有此参数时，点击背景不会关闭面板
		//public var onlyClose:int = 1;
		
		public function ViewFightFinishCountry(country:int, winner:int)
		{
			if (winner == 0){
				this.textTitle.text = Tools.getMsgById('fightCountryWinFinish');
				this.textTitle.color = '#FFFF99';
				this.textTitle.strokeColor = '#BB6600';
			}
			else{
				this.textTitle.text = Tools.getMsgById('fightCountryLoseFinish');
			}
			this.flag.setCountryFlag(country);
		}
		
	
	}

}