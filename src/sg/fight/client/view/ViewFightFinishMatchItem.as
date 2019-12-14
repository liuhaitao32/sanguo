package sg.fight.client.view
{
	import laya.events.Event;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import sg.fight.client.utils.FightViewUtils;
	import sg.fight.logic.utils.FightUtils;
	import sg.manager.EffectManager;
	import sg.manager.ViewManager;
	import sg.map.utils.TestUtils;
	import sg.model.ModelHero;
	import sg.utils.Tools;
	import ui.battle.fightFinishMatchItemUI;
	
	/**
	 * 比赛类型的战斗结束
	 * @author zhuda
	 */
	public class ViewFightFinishMatchItem extends fightFinishMatchItemUI
	{
		private var _troopData:Object;
		
		public function ViewFightFinishMatchItem(data:Object, troopData:Object, isFlip:Boolean)
		{
			this._troopData = troopData;
			this.initUI(data, isFlip);
		}
		
		/**
		 * data 部队结算对象
		 * troopData 部队原始对象
		 * winType 0未战 1胜 -1败
		 */
		public function initUI(data:Object, isFlip:Boolean):void
		{
			var heroStar:int = this._troopData.hasOwnProperty('hero_star') ? this._troopData.hero_star : 0;
			var colorType:int = ModelHero.getHeroStarGradeColor(heroStar);
			EffectManager.changeSprColor(this.img, colorType);
			var heroConfig:Object = ConfigServer.hero[data.hid];
			var hName:String = ModelHero.getHeroName(data.hid,this._troopData.awaken);

			this.tName.text = hName;
			this.heroLv.setNum(this._troopData.hasOwnProperty('lv') ? this._troopData.lv : '1');
			this.tHp.text = data.hp + ' / ' + data.hpm;
			this.tArmy.text = Tools.getMsgById('_public28') + ':';
			
			
			this.heroIcon.setHeroIcon(data.hid + (this._troopData.awaken?'_':''), true, colorType);
			this.heroStar.setHeroStar(heroStar);
			
			if (isFlip){
				this.scaleX = -1;
				this.box.scaleX = -1;
				this.box.x = 0 + this.width - 5;
				//this.imgWin.scaleX = -1;
				this.heroLv.x = this.heroLv.displayWidth + 1;
				this.heroLv.scaleX *= -1;
			}
			
			if(ConfigServer.world.allow_fight_end_details || TestUtils.isTestShow)
				this.heroIcon.on(Event.CLICK,this,this.onClick);
		}
	    private function onClick():void{
			var o:* = FightUtils.clone(this._troopData);
			o.proud = 0;
			ViewManager.instance.showView(ConfigClass.VIEW_HERO_INFO, o);
        }
	}

}