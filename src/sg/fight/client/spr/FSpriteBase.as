package sg.fight.client.spr
{
	import laya.display.Animation;
	import laya.display.Node;
	import laya.display.Sprite;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.utils.FightLoad;
	import sg.fight.client.utils.FightTime;
	import sg.fight.client.view.FightSceneBase;
	import sg.manager.EffectManager;
	import sg.utils.Tools;
	
	/**
	 * 战斗中需要伪透视的显示对象(控制器，spr为显示对象)
	 * @author zhuda
	 */
	public class FSpriteBase
	{
		public var scene:FightSceneBase;
		public var id:String;
		public var spr:Sprite;
		///阵型顶视图xyz
		public var x:Number;
		public var y:Number;
		public var z:Number;
		///翻转
		public var isFlip:Boolean;
		protected var _baseScale:Number;
		protected var _baseAlpha:Number;
		///强制渲染（作战部队，防止缓动失效）
		public var forcedRender:Boolean;

		
		public var isCleared:Boolean = false;
		
		public function FSpriteBase(scene:FightSceneBase, id:String, x:Number, y:Number, z:Number, isFlip:Boolean, baseScale:Number = 1, baseAlpha:Number = 1, forcedRender = false)
		{
			this.scene = scene;
			this.id = id;
			this.x = x;
			this.y = y;
			this.z = z;
			this.isFlip = isFlip;
			this._baseScale = baseScale?baseScale:1;
			this._baseAlpha = baseAlpha?baseAlpha:1;
			this.forcedRender = forcedRender;
			this.init();
		}
		
		public function init():void
		{
		}
		
		public function get res():String
		{
			return this.id;
		}
		
		public function setItemIndex(index:int):void
		{
			this.scene.setItemIndex(this,index);
		}
		
		
		public function addToScene():void
		{
			if(this.scene){
				this.scene.addItem(this);
				this.updatePos(true);
			}
		}
		public function addBgToScene():void
		{
			if(this.scene){
				this.scene.addBgItem(this);
				this.updatePos(true);
			}
		}
		public function addInfoToScene():void
		{
			if(this.scene){
				this.scene.addInfoItem(this);
				this.updatePos(true);
			}
		}
		
		public function removeFromScene():void
		{
			if(this.scene){
				this.scene.removeItem(this);
			}
		}
		
		/**
		 * 增加缓动
		 */
		protected function tweenTo(target:*, props:Object, duration:int, ease:Function = null, complete:Handler = null, delay:int = 0):void
		{
			FightTime.tweenTo(target, props, duration, ease, complete, delay);
		}
		
		/**
		 * 平面y映射到视图y,采用指数公式
		 */
		protected function transScreenY(tempY:Number):Number
		{
			return tempY + ConfigFightView.TRANS_SCREEN_Y*tempY*tempY*ConfigFightView.PERSPECTIVE;
		}
		
		/**
		 * 平面转换视图坐标(可以不做缩放变换)
		 */
		public function updatePos(changeScale:Boolean = false):void
		{
			if (!this.spr || this.spr.destroyed)
				return;
			//var scale:Number = 1 + this.y * ConfigFightView.PERSPECTIVE;
			//this.spr.y = this.y * scale;
			this.spr.y = this.transScreenY(this.y);
			var scale:Number = 1 + this.spr.y * ConfigFightView.PERSPECTIVE;
			var tempX:Number = (this.x - this.scene.cameraOffset) * scale;
			if (!this.forcedRender && (tempX < -ConfigFightView.VISIBLE_HALF_WIDTH || tempX > ConfigFightView.VISIBLE_HALF_WIDTH))
			{
				this.spr.visible = false;
			}
			else
			{
				this.spr.visible = true;
				this.spr.x = tempX;
				this.spr.y -= this.z * scale;
			}
			
			if (changeScale)
			{
				//this.ani.alpha = scale*0.9;
				scale *= this._baseScale;
				this.spr.scale(this.isFlip ? -scale : scale, scale);
					//this._ani.scale(-3, scale);
			}
		}
		
		/**
		 * 设置翻转
		 */
		public function setFlip(b:Boolean):void
		{
			if (this.isFlip != b)
			{
				this.isFlip = b;
				if(this.spr && !this.spr.destroyed)
					this.spr.scaleX *= -1;
			}
		}
		
		/**
		 * 渐显
		 */
		public function appear(time:Number = 500):void
		{
			if (!this.spr){
				return;
			}
			this.tweenTo(this.spr, {alpha: this._baseAlpha}, time);
		}
		
		/**
		 * 渐隐消失
		 */
		public function disappear(isClear:Boolean = true):void
		{
			if (!this.spr){
				return;
			}
			var handler:Handler = isClear ? Handler.create(this, this.clear) : null;
			this.tweenTo(this.spr, {alpha: 0}, 500, null, handler, 200);
		}
		
		/**
		 * 创建附着物动画并加入显示
		 */
		public function addAnimation(res:String,  stateName:String = '', x:Number = 0, y:Number = 0, isAdd:Boolean = false, isLoaded:Boolean = true, isTop:Boolean = true, scale:Number = 1, alpha:Number = 1, canRepeat:Boolean = false):Animation
		{
			var ani:Animation;
			if (this.spr && !this.spr.destroyed && res && (canRepeat || this.spr.getChildByName(res) == null))
			{
				if (isLoaded){
					ani = EffectManager.getAnimation(res, stateName, 0);
				}
				else{
					ani = FightLoad.loadAnimation(res, stateName, 0);
				}
				//ani.timer = FightTime.timer;
				ani.name = res;
				if (scale is Number && scale != 1){
					ani.scale(scale, scale);
				}
				alpha = alpha?alpha:1;
				ani.alpha = alpha * 0.2;
				ani.pos(x, y);
				this.tweenTo(ani, {alpha: alpha}, 300);
				if(isTop)
					this.spr.addChild(ani);
				else
					this.spr.addChildAt(ani,0);
				
				if (isAdd)
				{
					ani.blendMode = 'lighter';
				}
			}
			return ani;
		}
		/**
		 * 创建附着物动画并加入显示，复杂
		 */
		public function addAnimation2(res:String,  stateName:String = '', x:Number = 0, y:Number = 0, isAdd:Boolean = false, isLoaded:Boolean = true, isTop:Boolean = true, scale:Number = 1, alpha:Number = 1,canRepeat:Boolean = false, setName:String = null, setColor:int = -1):Animation
		{
			//isAdd = true;
			var ani:Animation = this.addAnimation(res,stateName,x,y,isAdd,isLoaded,isTop,scale,alpha,canRepeat);
			if (ani)
			{
				ani.name = setName?setName:res;
				if (setColor >= 0){
					EffectManager.changeSprColor(ani, setColor, false);
				}
			}
			return ani;
		}
		
		/**
		 * 移除附着物动画
		 */
		public function removeAnimation(res:String):void
		{
			if (this.spr && !this.spr.destroyed && res)
			{
				for (var i:int = this.spr.numChildren - 1; i >= 0; i--)
				{
					var node:Node = this.spr.getChildAt(i);
					if (node.name == res)
					{
						node.name = '';
						this.tweenTo(node, {alpha: 0}, 300, null, Handler.create(null, Tools.destroy, [node]));
						return;
					}
				}
			}
		}
		/**
		 * 移除所有附着物动画
		 */
		public function removeAllAnimation():void
		{
			if (this.spr && !this.spr.destroyed)
			{
				for (var i:int = this.spr.numChildren - 1; i >= 0; i--)
				{
					var node:Node = this.spr.getChildAt(i);
					Tools.destroy(node);
					//if(node.name.indexOf('equipH')==-1){
						//Tools.destroy(node);
					//}
				}
			}
		}
		
		/**
		 * 延迟执行
		 */
		public function delayTo(delay:int, caller:*, method:Function, args:Array = null):void
		{
			FightTime.delayTo(delay, caller, method, args);
		}
		/**
		 * 移除延迟执行
		 */
		public function clearDelayTo(caller:*, method:Function = null):void
		{
			if(method)
				FightTime.timer.clear(caller, method);
			else
				FightTime.timer.clearAll(caller);
		}
		
		public function clear():void
		{
			if (this.spr && !this.spr.destroyed)
			{
				this.removeFromScene();
				Tween.clearAll(this.spr);
				this.spr.destroy();
				this.spr = null;
			}
			this.isCleared = true;
		}
	}

}