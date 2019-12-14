package sg.fight.client.view
{
	import laya.ui.Image;
	import laya.ui.Label;
	import sg.fight.client.unit.ClientHero;
	import sg.fight.client.unit.ClientTroop;
	import sg.manager.*;
	import sg.utils.Tools;
	import ui.battle.fightTroopFlagUI;
	
	/**
	 * 战斗中每个部队的旗帜
	 * @author zhuda
	 */
	public class ViewFightTroopFlag extends fightTroopFlagUI
	{
		public var clientTroop:ClientTroop;
		
		
		public function ViewFightTroopFlag(clientTroop:ClientTroop)
		{
			this.clientTroop = clientTroop;
			this.init();
		}

		public function init():void
		{
			//设定国旗
			var countryIndex:int = this.clientTroop.country;
			
			this.setCountryColor(countryIndex);
			
			//将旗帜向后移动少许
			var isFlip:Boolean = clientTroop.isFlip;
			if (isFlip)
			{
				var image:Image = this.getChildByName('flag') as Image;
				image.scaleX *= -1;
			}


			var label:Label = this.getChildByName('label') as Label;
			var hero:ClientHero = this.clientTroop.getClientHero();
			
			var str:String = Tools.getMsgById(hero.id + '_flag');
			if (!str)
				str = hero.name.slice(0, 1);
			label.text = str;

		}

	}

}
