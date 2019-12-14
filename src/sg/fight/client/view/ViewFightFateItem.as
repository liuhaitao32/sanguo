package sg.fight.client.view
{
	import laya.events.Event;
	import laya.ui.Image;
	import laya.utils.Utils;
	import sg.fight.client.cfg.ConfigFightView;
	import ui.com.hero_icon_fight_fateUI;
	
	/**
	 * 战斗中弹出的合击技单位，包含缓动和消失
	 * @author zhuda
	 */
	public class ViewFightFateItem extends hero_icon_fight_fateUI
	{
		private static const WIDTH:Number = 350;
		private static const HEIGHT:Number = 420;
		
		///英雄id
		public var id:String;
		///宽度
		public var w:Number;
		
		public var isFirst:Boolean;
		public var isEnd:Boolean;
		
		//private var _poly:Polygon;
		
		public function ViewFightFateItem(id:String, w:Number, isFirst:Boolean = false, isEnd:Boolean = false)
		{
			this.id = id;
			this.w = w;
			this.isFirst = isFirst;
			this.isEnd = isEnd;
			this.once(Event.ADDED, this, this.initUI);
			//this.initUI();
		}
		
		private function initUI():void
		{
			this.mImg = this.getChildByName('img') as Image;
			this.setHeroIcon(this.id);
			
			var rate:Number = Math.tan(Utils.toRadian(ConfigFightView.FATE_SKILL_ANGLE));
			var startX:Number = isFirst ? 0 : Math.floor((WIDTH - this.w) * 0.5);
			
			var endX:Number = isEnd ? WIDTH : (WIDTH - Math.floor((WIDTH - this.w) * 0.5));
			this.w = endX - startX;
			
			var startY:Number = Math.ceil(HEIGHT - startX * rate);
			var endY:Number = Math.ceil(HEIGHT - endX * rate);
			
			var pointArr:Array = [startX, 0, endX, 0, endX, endY, startX, startY, startX, HEIGHT, startX, startY];
			
			this.spr.graphics.drawPoly(0, 0, pointArr, '#000000', '#000000', 1);
			//this.mImg.scaleX = -1;
			//if (this._poly.rebuild(pointArr));
		
			//ConfigFightView.FATE_SKILL_ANGLE
		}
	}

}