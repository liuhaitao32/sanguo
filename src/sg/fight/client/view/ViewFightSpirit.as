package sg.fight.client.view 
{
	import laya.display.Animation;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import sg.cfg.ConfigApp;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.utils.FightTime;
	import sg.manager.EffectManager;
	import sg.model.ModelHero;
	import sg.utils.Tools;
	import ui.battle.fightSkillUI;
	import ui.battle.fightSpiritUI;
	import ui.com.hero_icon1UI;
	/**
	 * 战斗中弹出的激励，包含缓动和消失
	 * @author zhuda
	 */
	public class ViewFightSpirit extends fightSpiritUI
	{
		///激励头像数组
		public var spiritArr:Array;
		///激励数据
		public var spiritData:Object;
		///基础翻转
		public var isFlip:Boolean;
		///停留时间毫秒
		public var time:int;
		
		public function ViewFightSpirit(spiritArr:Array, spiritData:Object, isFlip:Boolean, time:int) 
		{
			this.spiritArr = spiritArr;
			this.spiritData = spiritData;
			this.isFlip = isFlip;
			this.time = time;
			
			this.initUI();
		}
		private function initUI():void
		{
			//this.label.text = Tools.getMsgById('spirit_add');
			this.alpha = 0.2;

			this.y = Laya.stage.height * 0.15 + 80;
			var tempX:int = 10;
			if (this.isFlip){
				this.boxBg.scaleX *= -1;
				this.box.scaleX *= -1;
				this.box.x *= -1;
				this.boxTitle.x *= -1;
				//this.label.x *= -1;
				this.tSpirit.x *= -1;
				//this.tSpirit.align = 'right';
				//this.tSpirit.align = this.label.align = 'right';
				this.x = Laya.stage.width - ConfigFightView.SPIRIT_X;
				tempX *= -1;
			}
			else
			{
				this.x = ConfigFightView.SPIRIT_X;
			}
			//拆分激励数组中的内容，放入box
			this.initBox();
			
			var arr:Array = ['atk', 'def', 'spd'];
			var len:int = arr.length;
			var info:String = '';
			var num:int = 0;
			for (var i:int = 0; i < len; i++) 
			{
				var key:String = arr[i];
				if (spiritData[key]){
					if (info.length > 0)
						info += '\n';
					//if (info.length > 12)
						//info += '\n';
					//else if (info.length > 0)
						//info += ' ';
					info += Tools.getMsgById('spirit_' + key, [spiritData[key]]);
					num++;
				}
			}
			if (num == 1){
				this.tSpirit.fontSize += 12;
			}
			else if (num == 2){
				this.tSpirit.fontSize += 6;
			}
			this.tSpirit.text = info;
			

			var tweenTime:int = 800;

			FightTime.tweenTo(this, {alpha: 1}, tweenTime * 0.4, Ease.sineOut);
			FightTime.tweenTo(this, {x: this.x + tempX * 2}, tweenTime, Ease.backOut);
			FightTime.tweenTo(this, {alpha: 0, x: this.x - tempX}, tweenTime, Ease.sineIn, Handler.create(this, this.clear), this.time);
			
			if (ConfigApp.isPC){
				this.scaleX *= 1.2;
				this.scaleY *= 1.2;
			}
			//EffectManager.changeSprColor(this.image, 4);
		}
		/**
		 * 拆分激励数组中的内容，放入box
		 */
		private function initBox():void
		{
			var len:int = this.spiritArr.length;
			var yNum:int;
			var scale:Number ;
			if (len > 6){
				yNum = 3;
				scale = 0.3;
			}
			else if (len > 2){
				yNum = 2;
				if (len > 4)
					scale = 0.4;
				else
					scale = 0.45;
			}else{
				yNum = 1;
				if (len > 1)
					scale = 0.6;
				else
					scale = 0.8;
			}

			
			var itemW:int = 90*scale;
			var itemH:int = 90 * scale;
			if (yNum > 1){
				itemH *= 0.8;
			}
			
			var heroArr:Array;
			var num:int = 0;
			var posX:int;
			var posY:int;
			var offsetY:int;
			var xNum:int = Math.ceil(len/yNum);
			var tempXNum:int;
			
			for (var i:int = 0; i < yNum; i++) 
			{
				if(i<yNum-1){
					tempXNum = xNum;
				}
				else{
					tempXNum = len - num;
				}
				posY = (i - (yNum - 1) / 2) * itemH;
				offsetY = (i - (yNum - 1) / 2) * 10;
				
				for (var j:int = 0; j < tempXNum; j++) 
				{
					heroArr = this.spiritArr[num];
					var heroIcon:hero_icon1UI = new hero_icon1UI();
					heroIcon.setHeroIcon(heroArr[0], true, ModelHero.getHeroStarGradeColor(heroArr[1]));
					heroIcon.scale(scale, scale);
					heroIcon.anchorX = heroIcon.anchorY = 0.5;
					posX = (j - (tempXNum - 1) / 2) * itemW + offsetY;
					heroIcon.centerX = posX;
					heroIcon.centerY = posY;
					
					this.box.addChild(heroIcon);
					
					num++;
				}
			}
		}
		
		override public function clear():void
		{
			this.removeSelf();
			Tools.destroy(this);
		}
	}

}