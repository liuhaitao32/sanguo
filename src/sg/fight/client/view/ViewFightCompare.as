package sg.fight.client.view
{
	import laya.display.Animation;
	import laya.ui.Label;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import sg.fight.client.unit.ClientHero;
	import sg.fight.client.utils.FightLoad;
	import sg.fight.client.utils.FightTime;
	import sg.manager.EffectManager;
	import sg.utils.Tools;
	import ui.battle.fightCompareUI;
	
	/**
	 * 战斗中弹出的拼点压制板子，包含缓动和消失
	 * @author zhuda
	 */
	public class ViewFightCompare extends fightCompareUI
	{
		///属性值0
		public var value0:int;
		///属性值1
		public var value1:int;
		///拼点属性
		public var compKey:String;
		///是否燃火
		public var isBurn:Boolean;
		///位置排序，自动delay
		public var index:int;
		
		public function ViewFightCompare(value0:int, value1:int, compKey:String, isBurn:Boolean, index:int = 0)
		{
			this.value0 = value0;
			this.value1 = value1;
			this.compKey = compKey;
			this.isBurn = isBurn;
			this.index = index;
			
			this.initUI();
		}
		
		private function initUI():void
		{
			//this.label.text = this.info;
			//var baseX:int = this.x;
			
			var compStr:String = Tools.getMsgById('comp_' + this.compKey);
			this.tInfo.text = compStr;
			this.tValue0.text = value0.toString();
			this.tValue1.text = value1.toString();
			var label:Label;
			//var tempX:int;
			if (this.value1 > this.value0)
			{
				label = this.tValue1;
					//tempX = -30;
			}
			else
			{
				label = this.tValue0;
					//tempX = 30;
			}
			label.fontSize = 20;
			label.color = '#ffff00';
			//label.strokeColor = '#ff5100';
			//label.stroke = 3;
			
			if (this.isBurn)
			{
				//加上动画
				var ani:Animation = FightLoad.loadAnimation('skillFire');
				ani.scale(0.4,0.4);
				ani.y = 14;
				this.addChildAt(ani, 1);
			}
			
			var time:int = 3000;
			var delay:int = time * (0.15 + this.index * 0.1);
			//this.x = baseX - tempX;
			this.y = Laya.stage.height * 0.3 + 80 + (this.index * 35);
			this.x = Laya.stage.width * 0.5;
			this.alpha = 0;
			this.scaleX = 2;
			this.scaleY = 2;
			FightTime.tweenTo(this, {alpha: 1, scaleX: 1, scaleY: 1}, time * 0.1, Ease.backOut, null, delay);
			FightTime.tweenTo(this, {alpha: 0}, time * 0.2, Ease.sineIn, Handler.create(this, this.clear), delay + time * 0.6);
		}
		
		override public function clear():void
		{
			this.removeSelf();
			Tools.destroy(this);
		}
	}

}