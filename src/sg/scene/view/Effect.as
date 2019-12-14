package sg.scene.view {
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import sg.manager.EffectManager;
	import sg.scene.constant.EventConstant;
	import sg.utils.Tools;
	
	/**
	 * ...
	 * @author light
	 */
	public class Effect extends Sprite {
		
		public var loop:Boolean = false;
		
		public var autoClear:Boolean = true;
		
		public var lifeTime:Number = 0;
		
		public var animation:Animation;
		
		public function Effect() {
			
		}
		
		/**
		 * 
		 * @param	data {loop:true, autoClear:true, lifeTime:0, id:""}
		 * @return
		 */
		public function init(data:Object):Effect {
			if(data.loop != null) this.loop = data.loop;
			if(data.autoClear != null) this.autoClear = data.autoClear;
			if (data.lifeTime != null) this.lifeTime = data.lifeTime;
			//ndType 结尾 默认0循环最终动作 1播放完自动删除 2播放完停止
			
			var endType:int = 0;
			
			if (!loop) {
				endType = autoClear ? 1 : 2;
			}
			
			this.animation = EffectManager.loadAnimation(data.id, "", endType);			
			this.animation.once(EventConstant.DEAD, this, function():void {
				Tools.destroy(this2);
			});
			
			var this2:Effect = this;		
			
			
			if (this.lifeTime != 0) {
				this.timerOnce(this.lifeTime, this, function(e):void {
					Tools.destroy(this2);
				});
			}
			
			this.addChild(this.animation);
			return this;
		}
		
		
		
	}

}