package sg.fight.client.view
{
	import laya.display.Animation;
	import laya.display.Graphics;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Ease;
	import laya.utils.HitArea;
	import laya.utils.Tween;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigColor;
	import sg.cfg.ConfigServer;
	import sg.fight.client.ClientBattle;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.utils.FightLoad;
	import sg.fight.client.utils.FightViewUtils;
	import sg.guide.model.ModelGuide;
	import sg.map.utils.TestUtils;
	import sg.model.ModelBeast;
	import sg.model.ModelFormation;
	import sg.fight.client.unit.ClientHero;
	import sg.fight.client.unit.ClientTroop;
	import sg.manager.*;
	import sg.model.ModelHero;
	import sg.model.ModelOfficial;
	import sg.utils.StringUtil;
	import sg.utils.Tools;
	import ui.battle.fightBeastItemUI;
	import ui.battle.fightTroopInfoUI;
	import ui.com.title_hero_sUI;
	
	/**
	 * 战斗中每个部队的UI
	 * @author zhuda
	 */
	public class ViewFightTroopInfo extends fightTroopInfoUI
	{
		public var clientTroop:ClientTroop;
		//public var fomationAdeptBox:Box;
		public var formationAdept:Animation;
		///是否包含兽灵
		//public var hasBeast:Boolean;
		
		public function ViewFightTroopInfo(clientTroop:ClientTroop)
		{
			this.clientTroop = clientTroop;
			this.init();
		}
		
		public function init():void
		{
			var len:int;
			var i:int;
			var label:Label;
			
			//设定国旗
			var countryIndex:int = this.clientTroop.country;
			this.country.setCountryFlag(countryIndex);
			this.bg.setCountryColor(countryIndex);
			
			//确定兽灵共鸣
			if (this.clientTroop.beast){
				var showNum:int = 0;
				var resonanceArr:Array = ModelBeast.getResonanceArr(this.clientTroop.beast);
				var beastUI:fightBeastItemUI;
				var img:Image;
				len = resonanceArr.length;
				if (len > 0){
					for (i = 0; i < len; i++) 
					{
						var resonanceOne:Array = resonanceArr[i];
						if (resonanceOne[1] == 4){
							//4共鸣，显示
							beastUI = this['beast' + i] as fightBeastItemUI;
							if (beastUI){
								showNum++;
								beastUI.visible = true;
								beastUI.img.skin = AssetsManager.getAssetLater('beastType' + resonanceOne[0] + AssetsManager.PNG_EXT);
								//这里使用黑白色不变的色相滤镜
								var transArr:Array = ConfigColor.COLOR_FILTER_TRANS[resonanceOne[2] + 1];
								EffectManager.changeSprColorTrans(beastUI.img, transArr[0], transArr[1], transArr[2]);
								//点击可弹出说明
								beastUI.on(Event.CLICK, this, this.onClickBeast, [i, resonanceArr]);
								beastUI.on(Event.RIGHT_CLICK, this, this.onClickBeast, [i, resonanceArr]);

								beastUI.label.text = '0';
								beastUI.label.visible = false;
							}
						}else{
							//8共鸣，追加
							if (beastUI){
								var ani:Animation = FightLoad.loadAnimation('beast_level8');
								ani.scale(0.4, 0.4);
								ani.x = 15;
								ani.y = 15;
								beastUI.box.addChildAt(ani,0);
								EffectManager.changeSprColor(ani, resonanceOne[2]+1,false);
							}
						}
					}
					if (showNum == 1){
						beastUI.x += 17;
					}
				}
			}
			
			//将头像翻转
			var isFlip:Boolean = clientTroop.isFlip;
			if (isFlip)
			{
				this.heroIcon.scaleX *= -1;
				this.heroIcon.x += 29;
			}
			
			//设定称号
			if (this.clientTroop.title){
				var title:String = this.clientTroop.title;
				var titleIcon:title_hero_sUI = new title_hero_sUI();
				titleIcon.x = -35;
				titleIcon.y = -80;
				titleIcon.scaleX = 0.6;
				titleIcon.scaleY = 0.6;
				titleIcon.setHeroTitle(title);
				this.addChild(titleIcon);
			}
			
			
			var hero:ClientHero = this.clientTroop.getClientHero();
			label = this.bg.getChildByName('label') as Label;
			var uname:String = FightViewUtils.getTroopUserName(this.clientTroop.data);
			if (!uname)
			{
				uname = ModelHero.getHeroName(this.clientTroop.hid,this.clientTroop.data.awaken);
			}
			Tools.textFitFontSize(label, uname, 0, 8);
			label = this.bg.getChildByName('tLv') as Label;
			Tools.textFitFontSize(label, Tools.getMsgById('fight_lv', [hero.lv]), 0, 8);
			
			this.heroIcon.setHeroIcon(hero.id);
			//傲气
			this.updateProud(this.clientTroop.proud);
			var str:String;
			//官职
			if (this.clientTroop.official > -100)
			{
				this.txtOfficial.visible = true;
				var battle:ClientBattle = clientTroop.getClientTeam().getClientBattle();
				var milepost:int;
				if(battle.isCountry){
					milepost = battle.country_logs[clientTroop.country] ? battle.country_logs[clientTroop.country].milepost : 0;
				}else{
					milepost = clientTroop.data.milepost || 0;
				}
				str = ModelOfficial.getOfficerName(clientTroop.official, milepost, clientTroop.country);
				Tools.textFitFontSize(this.txtOfficial, str);
				//this.txtOfficial.text = ModelOfficial.getOfficerName(clientTroop.official, milepost, clientTroop.country);
				this.txtOfficial.color = EffectManager.getFontColor(ModelOfficial.getOfficerColorLevel(clientTroop.official, milepost));
			}
			else
			{
				this.txtOfficial.visible = false;
			}
		
			//阵法
			if (this.clientTroop.formationType > 0)
			{
				this.txtFormation.visible = true;
				str = ModelFormation.getModel(this.clientTroop.formationType).getName();
				Tools.textFitFontSize(this.txtFormation, str);
				//this.txtFormation.text = ModelFormation.getModel(this.clientTroop.formationType).getName();
				this.txtFormation.color = EffectManager.getFontColor(this.clientTroop.formationStar);
			}
			else
			{
				this.txtFormation.visible = false;
			}
			//先手，阵法优势
			this.imgFirst.visible = this.imgAdept.visible = false;
			if ((!TestUtils.isTestShow && !ConfigApp.testFightType) || (ConfigApp.testFightType && !ConfigFightView.showTest))
			{
				this.txtTest.visible = false;
			}else{
				this.updateTest(clientTroop.uid);
				//EffectManager.bindMouseTips(this.bg, 'ha\nhaha\nhahaha\n测试tips');
			}
			
			this.addHpBarLine(4);
			
			if (ModelGuide.forceGuide())
				return;
			if (ConfigServer.world.allow_fight_play_details || TestUtils.isTestShow)
			{
				var hitArea:HitArea = new HitArea();
				var graphics:Graphics = new Graphics();
				graphics.drawRect(-90,-30,180,80,'#ff9900');
				hitArea.hit = graphics;
				this.hitArea = hitArea;
				
				this.bg.on(Event.CLICK, this, this.onClick);
				this.bg.on(Event.RIGHT_CLICK, this, this.onClick);
			}
		}
		/**
		 * 在血条的若干个分段中加线
		 */
		public function addHpBarLine(num:int):void
		{
			var offset:Number = this.hpBar.width / num;
			var height:Number = this.hpBar.height;
			for (var i:int = 1; i < num; i++) 
			{
				var spr:Sprite = new Sprite();
				spr.graphics.drawLine(0, 0, 0, height, '#776622', 2);
				spr.x = i * offset;
				spr.alpha = 0.4;
				this.hpBar.addChild(spr);
			}
		}
		
		private function onClick():void{
			ViewManager.instance.showView(ConfigClass.VIEW_HERO_INFO, this.clientTroop.data);
        }
		
		private function onClickBeast(index:int, resonanceOne:Array):void{
			var info:String = ModelBeast.getAllResonanceInfo(resonanceOne, false, true);
			//info = StringUtil.substituteWithLineAndColor(info, '#FFDD55', '#AACCDD');
			ViewManager.instance.showTipsPanel(info, 560);
			//ViewManager.instance.showView(ConfigClass.VIEW_HERO_INFO, this.clientTroop.data);
        }
		
		/**
		 * 更新能量(增量)
		 */
		public function changeEnergy(energyType:String, value:int):void
		{
			var len:int = 2;
			var i:int;
			var beastUI:fightBeastItemUI;
			for (i = 0; i < len; i++) 
			{
				beastUI = this['beast' + i] as fightBeastItemUI;
				if(beastUI){
					if (beastUI.img.skin.indexOf(energyType) != -1){
						beastUI.label.visible = true;
						beastUI.label.text = '' + (parseInt(beastUI.label.text) + value);
	
						Tween.clearAll(beastUI.label);
						//label.rotation = 0;
						beastUI.alpha = 1;
						var tempScale:Number = 0.5;
						beastUI.label.scale(tempScale, tempScale, true);
						if (value > 0){
							//获得能量
							Tween.to(beastUI.label, {'scaleX':1.5*tempScale, 'scaleY':1.5*tempScale}, 50, Ease.sineOut);
							Tween.to(beastUI.label, {'scaleX':tempScale, 'scaleY':tempScale}, 150, Ease.sineInOut, null, 150);
						}
						else{
							//消耗能量
							Tween.to(beastUI, {'alpha':0.3}, 100, Ease.sineInOut);
							Tween.to(beastUI, {'alpha':1}, 100, Ease.sineInOut, null, 150);
							Tween.to(beastUI, {'alpha':0.3}, 100, Ease.sineInOut, null, 300);
							Tween.to(beastUI, {'alpha':1}, 100, Ease.sineInOut, null, 450);
							//EffectManager.tweenShake(img,{rotation:5}, 200, Ease.sineInOut, null, 0, 1, 0);
						}
						
					}
				}
			}
		}
		/**
		 * 隐藏能量的值
		 */
		public function hideEnergy():void
		{
			var len:int = 2;
			var i:int;
			var beastUI:fightBeastItemUI;
			for (i = 0; i < len; i++) 
			{
				beastUI = this['beast' + i] as fightBeastItemUI;
				if (beastUI){
					beastUI.label.visible = false;
					beastUI.label.text = '0';
				}
			}
		}
		
		/**
		 * 更新傲气
		 */
		public function updateProud(value:int):void
		{
			if (value == 0)
			{
				this.txtProud.visible = false;
			}
			else
			{
				this.txtProud.visible = true;
				if (value > 0){
					//傲气
					this.txtProud.text = Tools.getMsgById('proud+', [value]);
					this.txtProud.strokeColor = '#904d05';
				}
				else{
					//疲劳
					this.txtProud.text = Tools.getMsgById('proud-', [-value]);
					this.txtProud.strokeColor = '#6b4d7d';
				}
			}
			//this.imgProud.visible = this.txtProud.visible;
		}

		/**
		 * 更新uid
		 */
		public function updateTest(value:int):void
		{
			if (this.txtTest.visible)
			{
				this.txtTest.text = 'uid:' + value;
				//this.txtProud.strokeColor = '#904d05';
			}
			//this.imgProud.visible = this.txtProud.visible;
		}
		
		/**
		 * 更新先手
		 */
		public function updateFirst(b:Boolean):void
		{
			if (!ConfigServer.effect.showFightFirst)
				b = false;
			
			if (b){
				this.imgFirst.alpha = 0;
				this.imgFirst.scale(1,1,true);
				Tween.to(this.imgFirst, {'alpha':1, 'scaleX':0.5, 'scaleY':0.5}, 300, Ease.backOut,null,1000);
			}
			this.imgFirst.visible = b;
			if (this.clientTroop && this.clientTroop.teamIndex==0){
				this.imgFirst.x = 113;
			}
			else{
				this.imgFirst.x = -107;
			}
		}
		
		/**
		 * 更新阵法优势 阵法克制
		 */
		public function updateAdept(b:Boolean):void
		{
			if (!ConfigServer.effect.showFightAdept)
				b = false;

			this.imgAdept.visible = b;
			if (b){
				this.formationAdept = FightLoad.loadAnimation('glow050');
				this.formationAdept.scale(0.6, 0.3);
				this.formationAdept.pos(this.imgAdept.x-5,this.imgAdept.y);
				//ani.blendMode = 'lighter';
				this.addChildAt(this.formationAdept, 0);
			}
			else{
				if (this.formationAdept){
					this.formationAdept.destroy();
					this.formationAdept = null;
				}
			}
		}
	
		/**
		 * 清空兽灵数量
		 */
		public function clearBeastNum():void
		{
			var len:int = 2;
			var i:int;
			var beastUI:fightBeastItemUI;
			for (i = 0; i < len; i++) 
			{
				beastUI = this['beast' + i] as fightBeastItemUI;
				if (beastUI){
					beastUI.label.visible = false;
					beastUI.label.text = '0';
				}
			}
		}
	}

}
