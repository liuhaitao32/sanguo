package sg.map.view.entity {
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityHeroCatch;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.TestUtils;
	import sg.map.view.HeroCatchInfo;
	import sg.map.view.MapViewMain;
	import sg.scene.SceneMain;
	import sg.scene.constant.EventConstant;
	import sg.scene.view.EventGridSprite;
	import sg.scene.view.entity.EntityClip;
	import sg.scene.view.ui.Bubble;
	import sg.utils.Tools;
	import ui.com.building_tips2UI;
	import ui.com.building_tips5UI;
	import ui.mapScene.herocatchDeadUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class HeroCatchClip extends EntityClip {
		
		public function get heroCatch():EntityHeroCatch { return EntityHeroCatch(this._entity); }
		
		public var bubble:Bubble;
		
		public var info:HeroCatchInfo;
		
		public var gridSprite:Animation;
		
		public var deadInfo:herocatchDeadUI;
		
		public function HeroCatchClip(scene:SceneMain) {
			super(scene);		
			this.bubble = new Bubble(this);
			this.info = new HeroCatchInfo(scene);
			//
		}
		
		override public function init():void {
			super.init();
			this.heroCatch.on(EventConstant.HERE_CATCH, this, this.updateHandler);
			this.heroCatch.on(EventConstant.HERO_CATCH_CHANGE, this, this.onChangeComplete);
			this.updateHandler();
			this._clip.scale(0.8, 0.8);
			this._clip.x = this._scene.mapGrid.gridHalfW;
			this._clip.y = this._scene.mapGrid.gridHalfH;
			this.gridSprite ||= EffectManager.loadAnimation("glow_catch", '', 0, null, "map");
			this.addChildAt(this.gridSprite, 0);
			this.gridSprite.x = this._scene.mapGrid.gridHalfW;
			this.gridSprite.y = this._scene.mapGrid.gridHalfH;
			//this.gridSprite.texture = Laya.loader.getRes("map2/qiecuo.png");
			
		}
		
		private function onChangeComplete(e:Event):void {
			if(this.heroCatch.enabled) this.hide();
		}
		
		
		
		private function updateHandler(e:Event = null):void {
			if (this.parent && !this.parent.destroyed) {
				EventGridSprite(this.parent).removeItemSprite(this);
				this.removeSelf();
			}
			
			Tools.destroy(this._ani);
			this._clip.addChild(this._ani = EffectManager.loadHeroAnimation(this.heroCatch.heroId));
			
			
			this.bubble.setData({type:0, ui:building_tips5UI, heroId:this.heroCatch.heroId, flagText:Tools.getMsgById("_hero_chatch_text02"), flagBg:"ui/img_icon_36.png"});
			this.info.setData(this.heroCatch);
			
			this._scene.mapLayer.getPos(this.heroCatch.mapGrid.col, this.heroCatch.mapGrid.row, Point.TEMP);
			
			this.bubble.x = Point.TEMP.x;
			this.bubble.y = Point.TEMP.y - this._scene.mapGrid.gridHalfH - 10;
			
			
			this.info.x = Point.TEMP.x;
			this.info.y = Point.TEMP.y + this._scene.mapGrid.gridHalfH - 15;
			
			this.bubble.on(Event.CLICK, this, this.onClick);
			if (this.deadInfo) this.deadInfo.visible = false;
			this.alpha = 1;
			Tween.clearAll(this);
			if (this.heroCatch.mapGrid.gridSprite && !this.heroCatch.mapGrid.gridSprite.destroyed) {
				MapViewMain.instance.mapLayer.addItemSprite(this.heroCatch.mapGrid.gridSprite, this, this.heroCatch.mapGrid.col, this.heroCatch.mapGrid.row);
				this.show();
			}
		}
		
		override public function onClick():void {
			if (!this.heroCatch.enabled) return;
			super.onClick();
			ModelManager.instance.modelGame.clickHeroCatch(this.heroCatch.city.cityId.toString(), this.toScreenPos());
		}
		
		public override function show():void {
			if (this.heroCatch.enabled) {
				super.show();
				this.bubble.visible = true;		
				this.info.visible = true;
				this.visible = true;
				this.bubble.resize();
				this.info.resize();
				ArrayUtils.push(this.bubble, this._scene.bubbles);	
				ArrayUtils.push(this.info, this._scene.bubbles);
			} else {
				this.hide();					
			}
		}
		
		public override function hide():void {
			super.hide();
			ArrayUtils.remove(this.bubble, this._scene.bubbles);	
			ArrayUtils.remove(this.info, this._scene.bubbles);
			this.bubble.visible = false;
			this.info.visible = false;
			this.visible = false;
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			super.destroy(destroyChild);
			ArrayUtils.remove(this.bubble, this._scene.bubbles);	
			ArrayUtils.remove(this.info, this._scene.bubbles);
			if (this.heroCatch) {
				this.heroCatch.off(EventConstant.HERE_CATCH, this, this.updateHandler);
				this.heroCatch.off(EventConstant.HERO_CATCH_CHANGE, this, this.onChangeComplete);
				this.heroCatch.view = null;
			}
			Tools.destroy(this.bubble);
			Tools.destroy(this.info);
			//this.heroCatch.on(EventConstant.HERE_CATCH, this.changeHandler);
		}
		
		
		public function showDead():void {
			this.deadInfo ||= new herocatchDeadUI();
			this.deadInfo.visible = true;
			//
			this.deadInfo.name_txt.text = Tools.getMsgById("catch_dead_speak");
			this.deadInfo.x += MapModel.instance.mapGrid.gridHalfW;
			this.addChild(this.deadInfo);
			
			Tween.to(this, {alpha:0}, 1000, null, Handler.create(this, function():void {
				destroy();				
			}), 3000, true);
			this.bubble.visible = false;
			this.info.visible = false;
			this.heroCatch.off(EventConstant.HERE_CATCH, this, this.updateHandler);
			this.heroCatch.off(EventConstant.HERO_CATCH_CHANGE, this, this.onChangeComplete);
			this.heroCatch.view = null;
			this._entity = null;
			if (this.parent is EventGridSprite) EventGridSprite(this.parent).removeItemSprite(this);
		}
	}

}