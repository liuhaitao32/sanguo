package sg.fight.client.spr 
{
	import laya.display.Animation;
	import laya.display.Node;
	import laya.display.Sprite;
	import laya.events.Event;
	import sg.cfg.ConfigServer;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.interfaces.IClientUnit;
	import sg.fight.client.utils.FightTime;
	import sg.fight.client.view.FightSceneBase;
	import sg.manager.EffectManager;
	import sg.utils.Tools;
	/**
	 * 战斗场景中的英雄，副将
	 * @author zhuda
	 */
	public class FHero extends FPerson
	{
		private var _ani:Animation;
		
		public function FHero(unit:IClientUnit, id:String, x:Number, y:Number)
		{
			var scene:FightSceneBase = unit.getScene();
			var baseScale:Number = ConfigFightView.HERO_BASE_SCALE;
			
			//var heroConfig:Object = ConfigServer.hero[id];
			//id = heroConfig.res ? heroConfig.res : id;
			//if (heroConfig.scale)
			//{
				//baseScale *= heroConfig.scale;
			//}
			super(scene, unit, id, x, y, baseScale);
		}
		
		override public function get ani():Animation
		{
			//return this.spr;
			return this._ani;
		}
		
		override public function init():void {
            var animation:Animation = EffectManager.loadHeroAnimation(this.id, false);
			animation.timer = FightTime.timer;
			this._ani = animation;
			this._ani.hasActionName();
			this.spr = new Sprite();
			this.spr.addChild(this._ani);
			//this._ani = animation;
			//this.spr = this._ani;
			this.addToScene();
			
			this.toStand();
			//FPerson.lastPerson = this;
        }
		
		/**
		 * 加上装备强化法球
		 */
		public function addEquipBall(riseArr:Array):void
		{
			if (!riseArr)
				return;
			var cfg:Object = ConfigServer.effect.equipRiseBall;
			if (cfg){
				var colorArr:Array = cfg.colorArr;
				var len:int = colorArr.length;
				var res:String = cfg.res;
				var delayArr:Array = cfg.delay;
				var offsetArr:Array = cfg.offset;
				var shadowArr:Array = cfg.shadow;
				var i:int;
				var j:int;
				var shadowLen:int = shadowArr.length;
				for (i = 0; i < 5; i++) 
				{
					var rise:int = riseArr[i];
					var color:int = -1;
					for (j = 0; j < len; j++) 
					{
						if (rise >= colorArr[j]){
							color = j;
						}else{
							break;
						}
					}
					if (color >= 0){
						for (j = 0; j < shadowLen; j++) 
						{
							//添加残像
							var shadowTempArr:Array = shadowArr[j];
							//this.delayTo(delayArr[i]+shadowTempArr[0], this, this.addAnimation2, [res, '', 0, 0, false, false, true, shadowTempArr[1],'awaken', color]);
							FightTime.scaleTimerDelayTo(delayArr[i]+shadowTempArr[0], this, this.addAnimation2, [res, '', 0, 0, true, false, true, 1, shadowTempArr[1], true,'awaken', color],false);
							//this.delayTo(delayArr[i]+shadowTempArr[0], this, this.addAnimation2, [res, '', 0, 0, false, false, true, 'awaken', color,1,shadowTempArr[1]]);
						}
						//this.delayTo(delayArr[i]+shadowTempArr[0], this, this.addAnimation2, [res, '', 0, 0, false, false, true, 1, 'awaken', color]);
						FightTime.scaleTimerDelayTo(delayArr[i], this, this.addAnimation2, [res, '', 0, 0, false, false, true, 1, 1, true,'awaken', color],false);
						//this.delayTo(delayArr[i], this, this.addAnimation2, [res, '', 0, 0, false, false, true, 'awaken', color]);
						//this.delayTo(delayArr[i], this, this.addAnimation2, [res, '', offsetArr[i], 0, false, false,true,'awaken',color,0.3]);
						//this.addAnimation(cfg.res, 'fight', 0, 10, true, false,true,'awaken');
						
					}
				}
				
			}
		}
		/**
		 * 加上套装id
		 */
		public function addGroup(group:String):void
		{
			if (!group)
				return;
			var cfg:Object = ConfigServer.effect.group[group];
			if (cfg){
				this.addAnimation(cfg.hero, 'fight', 0, 10, true, false);
			}
		}
		/**
		 * 加上觉醒效果
		 */
		public function addAwaken(hid:String):void
		{
			var cfg:Object = ConfigServer.inborn[hid + 'a'];
			if (cfg){
				this.addAnimation('awaken', 'fight', 0, 0, true, false, false, 1, 1, true);
				//this.addAnimation('glow_catch', '', 0, 0, true, false, false);
			}
		}
		
		/**
		 * 移除所有附着物动画(排除自身、套装和觉醒)
		 */
		override public function removeAllAnimation():void
		{
			if (this.spr && !this.spr.destroyed)
			{
				for (var i:int = this.spr.numChildren - 1; i >= 0; i--)
				{
					var node:Node = this.spr.getChildAt(i);
					if(node != this._ani){
						var name:String = node.name;
						if(name.indexOf('equipH')==-1 && name.indexOf('awaken')==-1){
							Tools.destroy(node);
						}
					}
				}
			}
		}
		
		/**
		 * 受伤
		 */
		override public function injured(hurtObj:Object):void
		{
			if (!this.alive || hurtObj == null) return;
			var ani:Animation = this.ani;
			ani.play(0, false, ConfigFightView.ANIMATION_INJURED1);
			ani.once(Event.COMPLETE, this, this.stand);
			
			this.beHit(hurtObj);
		}
		/**
		 * 死亡
		 */
		override public function dead(hurtObj:Object):void
		{
			if (!this.alive) return;
			this.ani.offAll(Event.COMPLETE);
			
			this.alive = false;
			this.aniPlay(0, false, ConfigFightView.ANIMATION_DEAD1);
			
			this.deadAndHide();
		}
		
		
		/**
         * 播放动画
         */
        override public function aniPlay(start:* = 0, loop:Boolean = true, name:String = ""):void {
			if (!this.ani.hasActionName(name)){
				name = ConfigFightView.ANIMATION_STAND;
			}
			super.aniPlay(start, loop, name ,false);
		}
	}

}