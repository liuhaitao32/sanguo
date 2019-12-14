package sg.home.view.entity {
	import laya.display.Animation;
	import laya.events.Event;
	import laya.maths.Point;
	import sg.boundFor.GotoManager;
	import sg.cfg.ConfigServer;
	import sg.home.model.HomeModel;
	import sg.home.view.HomeViewMain;
	import sg.manager.EffectManager;
	import sg.scene.SceneMain;
	import sg.scene.view.Effect;
	import sg.scene.view.MapCamera;
	import sg.scene.view.entity.EntityClip;
	import sg.scene.view.ui.Bubble;
	import ui.com.building_tips5UI;
	import sg.altar.legendAwaken.model.ModelLegendAwaken;
	import sg.model.ModelHero;
	import sg.utils.Tools;
	import sg.model.ModelBuiding;
	import sg.model.ModelInside;
	import sg.manager.ModelManager;
	
	/**
	 * ...
	 * @author Thor
	 */
	public class LegendShopClip extends EntityClip {
		
		public var bubble:Bubble;		
		private var _enabled:Boolean = true;		
		private var _range:Array;	
		private var _ani_light:Animation;
		private var build:ModelBuiding;	
        private var model:ModelLegendAwaken = ModelLegendAwaken.instance;
		
		public function LegendShopClip(scene:SceneMain) {
			super(scene);
			this.init();
			this.build = ModelManager.instance.modelInside.getBase();
			this.build.on(ModelInside.BUILDING_STATUS_CHANGE, this, this.changeInfo);
			this.changeInfo();
		}
		
		override public function init():void {
			super.init();
			HomeViewMain.instance.mapLayer.topLayer.addChild(this);
			this._range = ConfigServer.effect["legend_cave"];
			this.x = this._range[0] - HomeModel.instance.mapGrid.gridHalfW;
			this.y = this._range[1] - HomeModel.instance.mapGrid.gridHalfH;
		}

		private function changeInfo():void {
			if (model.shopOpen && !_ani_light && this.scene.mapLayer) {
				_ani = EffectManager.loadAnimation("glow_cave");		
				_ani_light = EffectManager.loadAnimation("glow_cave1");	
				_ani_light.blendMode = "lighter";	
				this._clip.addChildren(_ani, _ani_light);			
				this.bubble = new Bubble(this);
				this.bubble.on(Event.CLICK, this, onBubbleClickHandler);
				
				this.bubble.y = -20;
				
				bubble.setData({type:0, ui:building_tips5UI, heroId: model.bubbleSkin, flagText:Tools.getMsgById(model.cfg.name[1]), flagBg:"ui/img_icon_38.png"});
				this.bubble.x += this.x;
				this.bubble.y += this.y;	
			}
		}
		
		public override function containsPos(screenX:Number, screenY:Number):Boolean {
			if (!_ani_light || !_ani_light.visible) return false;
			return Math.abs((screenX - this._range[0]) * this._range[3]) + Math.abs((screenY - this._range[1]) * this._range[2] ) < this._range[2] * this._range[3] * 0.5;
		}
		
		override public function onClick():void {
			if (!model.shopOpen)	return;
			var p:Point = this.localToGlobal(Point.TEMP.setTo(0, 0));
			MapCamera.lookAtPos(p.x / this._scene.tMap.scale - this._scene.tMap.viewPortX, p.y / this._scene.tMap.scale - this._scene.tMap.viewPortY, 500);
			
			GotoManager.boundForPanel(GotoManager.VIEW_LEGEND_AWAKEN_SHOP);
		}
		
		private function onBubbleClickHandler():void {
			this.onClick();
		}
		
		override public function destroy(destroyChild:Boolean = true):void {	
			if(this.bubble) this.bubble.off(Event.CLICK, this, this.onClick);
			super.destroy(destroyChild);
		}
		
	}

}