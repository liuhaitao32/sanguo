package sg.map.view.entity {
	
	import sg.map.model.entitys.EntityCity;
	import sg.scene.view.entity.EntityClip;
	import sg.scene.SceneMain;
	import laya.events.Event;
	import sg.scene.view.InputManager;
	import sg.map.model.MapModel;
	import laya.maths.Rectangle;
	import sg.manager.EffectManager;
	import laya.display.Animation;
	import sg.scene.view.ui.Bubble;
	import sg.scene.view.EventGridSprite;
	import sg.utils.Tools;
	import sg.map.view.BlessHeroInfo;
	import sg.manager.AssetsManager;
	import laya.maths.Point;
	import laya.utils.Tween;
	import sg.model.ModelHero;
	import sg.manager.ModelManager;
	import sg.scene.model.MapGrid;
	import sg.model.ModelBlessHero;
	import laya.ui.Image;
	import sg.map.utils.ArrayUtils;
	import laya.display.Node;
	import ui.com.building_tips5UI;

	/**
	 * ...
	 * @author Thor
	 */
	public class BlessHeroClip extends EntityClip {
		
		public var bubble:Bubble;
		public var city:EntityCity;
		public var info:BlessHeroInfo;
		public var grid:MapGrid;
		public var anis:Array;
		
		public function BlessHeroClip(scene:SceneMain) {
			super(scene);
			this.bubble = new Bubble(this);
			this.info = new BlessHeroInfo(scene);
			this.zOrder = 100000;
		}
		
		override public function init():void {
			super.init();
			this._clip.x = this._scene.mapGrid.gridHalfW;
			this._clip.y = this._scene.mapGrid.gridHalfH;
			this.on(Event.CLICK, this, this.onClick);
			
			if (this.parent && !this.parent.destroyed) {
				EventGridSprite(this.parent).removeItemSprite(this);
				this.removeSelf();
			}
			this._scene.mapLayer.getPos(city.mapGrid.col, city.mapGrid.row, Point.TEMP);
			this.bubble.x = Point.TEMP.x;
			this.info.y = Point.TEMP.y + this._scene.mapGrid.gridHalfH - 30;
			this.info.x = Point.TEMP.x;
			
			this.bubble.on(Event.CLICK, this, this.onClick);
			this.alpha = 1;
			Tween.clearAll(this);

			var model:ModelBlessHero = ModelBlessHero.instance;
			model.on(ModelBlessHero.UPDATE_DATA, this, this._updateHandler);

			this._updateHandler();
		}

		private function _updateHandler():void {
			this.clearAnimations();
			var data:Object = ModelBlessHero.instance.getClipData(city.cityId);
			if (data) {
            	var heroId:String = data.hid;
				var awaken:Boolean = data.awaken;
				_clip.addChild((this._ani = EffectManager.loadHeroAnimation(heroId)) as Node); 
				this.bubble.setData({type:0, ui:building_tips5UI, heroId: heroId, flagText: Tools.getMsgById('bless_hero_13'), flagBg: AssetsManager.getAssetsUI('img_icon_39.png')});
				var icon:* = bubble.getChildByName('icon');
				if (icon) {
					var bg:Image = icon.getChildByName('bg');
					bg && (bg.skin = AssetsManager.getAssetsUI('icon_paopao07.png'));
				}
				this.info.setName(ModelHero.getHeroName(heroId, awaken));
				
				// 套装特效
				var effectId:String = data.effectId;
				if (effectId) {
					var ani_effect:Animation = EffectManager.loadAnimation(effectId, 'map');
					ani_effect.blendMode = 'lighter';
					_clip.addChildAt(ani_effect as Node, 1);
				}

				//觉醒特效
				var ani_awaken:Animation = null;
				if (awaken) {
					ani_awaken = EffectManager.loadAnimation('awaken', 'map');
				} else {
					ani_awaken = EffectManager.loadAnimation('glow_bless');
				}
				ani_awaken.blendMode = 'lighter';
				_clip.addChildAt(ani_awaken as Node, 0);
				_clip.scale(data.scale, data.scale);
				this.hitArea = new Rectangle(0, MapModel.instance.mapGrid.gridH * -0.5, MapModel.instance.mapGrid.gridW, MapModel.instance.mapGrid.gridH); // 加了就点不到城了
				this._scene.mapLayer.getPos(city.mapGrid.col, city.mapGrid.row, Point.TEMP);
				this.bubble.y = Point.TEMP.y - this._scene.mapGrid.gridHalfH - 40 * (data.scale - 0.4);
			}
			this.show();
		}

		override public function event(type:String, data:* = null):Boolean {
			var isClick:Boolean = (type == Event.CLICK);
			if (isClick) {
				if (!InputManager.instance.canClick) return true;
				if (data is Event) {
					Event(data).stopPropagation();
				}
			}
			return super.event(type, data);
		}
		
		override public function onClick():void {			
			super.onClick();
			ModelBlessHero.instance.onClickCity(city.cityId);
		}
		
		public override function show():void {
			if (ModelBlessHero.instance.getClipData(city.cityId)) {
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
			var model:ModelBlessHero = ModelBlessHero.instance;
			model.off(ModelBlessHero.UPDATE_DATA, this, this._updateHandler);
			super.destroy(destroyChild);
			ArrayUtils.remove(this.bubble, this._scene.bubbles);	
			ArrayUtils.remove(this.info, this._scene.bubbles);
			Tools.destroy(this.bubble as Node);
			Tools.destroy(this.info as Node);
		}

		private function clearAnimations():void {
			for(var len:int = _clip._childs.length; len; len--) {
				var ele:Node = _clip._childs[len - 1];
				(ele is Animation) && Tools.destroy(ele);
			}
		}
    }
}