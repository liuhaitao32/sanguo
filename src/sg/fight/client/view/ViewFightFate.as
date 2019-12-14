package sg.fight.client.view
{
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.ui.Image;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Utils;
	import sg.cfg.ConfigApp;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.utils.FightLoad;
	import sg.fight.client.utils.FightTime;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	import sg.utils.Tools;
	import ui.battle.fightFateUI;
	
	/**
	 * 战斗中弹出的合击技，包含缓动和消失
	 * @author zhuda
	 */
	public class ViewFightFate extends fightFateUI
	{
		///英雄id数组
		public var ids:Array;
		///技能名称
		public var info:String;
		///基础翻转
		public var isFlip:Boolean;
		///人物层
		public var heroLayer:Sprite;
		
		public function ViewFightFate(ids:Array, info:String, isFlip:Boolean)
		{
			this.ids = ids;
			this.info = info;
			this.isFlip = isFlip;
			
			this.initUI();
		}
		
		private function initUI():void
		{
			//this.width = Laya.stage.width;
			//this.height = Laya.stage.height;
			this.heroLayer = new Sprite();
			this.addChildAt(this.heroLayer, 0);
			
			var i:int;
			var len:int = this.ids.length;
			var item:ViewFightFateItem;
			var w:Number = 640;
			//var w:Number = Laya.stage.width;
			var rate:Number = Math.tan(Utils.toRadian(ConfigFightView.FATE_SKILL_ANGLE));
			var h:Number = w * rate;
			var offsetX:Number = w / len;
			var time:int = 3200;
			
			var startX:Number = -400;
			var startY:Number = -startX * rate;
			var endX:Number = 400;
			var endY:Number = -endX * rate;
			var temp1X:Number;
			var temp1Y:Number;
			var temp2X:Number;
			var temp2Y:Number;
			
			var itemArr:Array = [];
			for (i = 0; i < len; i++)
			{
				var id:String = this.ids[i];
				item = new ViewFightFateItem(id, offsetX, i == 0, i == len - 1);
				itemArr.push(item);
			}
			for (i = 0; i < len; i++)
			{
				item = itemArr[i];
				this.heroLayer.addChildAt(item, 0);
				
				startX = -600 - i*200;
				startY = -startX * rate;
				endX = 600;
				endY = -endX * rate;
				temp1X = offsetX * (i - (len - 1) / 2) - 15;
				temp1Y = -temp1X * rate;
				temp2X = temp1X + 30;
				temp2Y = -temp2X * rate;

				//this.heroLayer.addChildAt(item, 0);
				
				item.pos(startX, startY);
				//var time1S:Number = i * 0.01 * time;
				var time1:Number = time * (0.05 +i * 0.01);
				var time2S:Number = (0.07 + i * 0.02) * time;
				var time2:Number = time * 0.71;
				var time3S:Number = (0.8 + i * 0.03) * time;
				var time3:Number = time * 0.1;
				
				//FightTime.tweenTo(item, {x: temp1X, y: temp1Y}, time1, Ease.sineOut, Handler.create(null,function), time1S);

				FightTime.tweenTo(item, {x: temp1X, y: temp1Y}, time1, Ease.sineOut);
				FightTime.tweenTo(item, {x: temp2X, y: temp2Y}, time2, null, null, time2S);
				FightTime.tweenTo(item, {x: endX, y: endY}, time3, Ease.sineIn, null, time3S);
			}
			this.label.text = Tools.getMsgById(info,null,false);
			//this.label.skewX = 0;
			this.label.skewY = -ConfigFightView.FATE_SKILL_ANGLE;
							
			startX = -150;
			startY = -startX * rate + 120;
			endX = 150;
			endY = -endX * rate + 120;
			temp1X = 0;
			temp1Y = -temp1X * rate + 120;
			//temp2X = 10;
			//temp2Y = -temp2X * rate;
			this.label.pos(startX, startY);
			FightTime.tweenTo(this.label, {x: temp1X, y: temp1Y}, time * 0.05, Ease.sineOut);
			//FightTime.tweenTo(this.label, {x: temp2X, y: temp2Y}, time * 0.75, null, null, 0.05 * time);
			FightTime.tweenTo(this.label, {x: endX, y: endY}, time * 0.1, Ease.sineIn, null, 0.85 * time);
			

			if (this.isFlip)
			{
				this.scaleX = -1;
				this.label.scaleX *= -1;
			}
			else
			{
				//this.x = 150;
			}
			
			FightTime.tweenTo(this, {alpha: 1}, time * 0.15, Ease.sineOut);
			//FightTime.tweenTo(this, {x: this.x + tempX * 2}, time * 0.2, Ease.sineOut);
			
			FightTime.tweenTo(this, {alpha: 0}, time * 0.2, Ease.sineIn, Handler.create(this, this.clear), time * 0.8);
			
			var img:Image = new Image(AssetsManager.getAssetsFight('fight_light_2'));
			img.skewY = -ConfigFightView.FATE_SKILL_ANGLE;
			img.width = 700;
			img.height = 60;
			img.anchorX = 0.5;
			img.anchorY = 0.5;
			img.y = 170;
			this.heroLayer.addChild(img);
			
			var ani:Animation = FightLoad.loadAnimation('skillFate');
			ani.scale(1.5, 1.5);
			ani.y = 52;
			ani.skewY = -ConfigFightView.FATE_SKILL_ANGLE;
			this.heroLayer.addChildAt(ani, 0);
			
			if (ConfigApp.isPC){
				this.label.scaleX *= 1.5;
				this.label.scaleY *= 1.5;
				ani.scaleX *= 8;
				this.scaleX *= 1.2;
				this.scaleY *= 1.2;
				//this.x = Laya.stage.width * (this.isFlip?0.65:0.35);
			}
			//else
			//{
				//this.x = Laya.stage.width * 0.5;
			//}
			this.x = Laya.stage.width * 0.5;
			this.y = Laya.stage.height * 0.5;
			//this.pos(Laya.stage.width * 0.5, Laya.stage.height * 0.5);
		}
		
		override public function clear():void
		{
			this.removeSelf();
			Tools.destroy(this);
		}
	}

}