package sg.home.view.entity {
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.resource.Texture;
	import sg.boundFor.GotoManager;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigServer;
	import sg.home.model.HomeModel;
	import sg.home.model.entitys.EntityBuild;
	import sg.home.view.HomeViewMain;
	import sg.home.view.ui.build.BuildArmyInfo;
	import sg.home.view.ui.build.BuildInfo;
	import sg.home.view.ui.build.BuildingInfo;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.map.model.MapModel;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.TestUtils;
	import sg.model.ModelBuiding;
	import sg.model.ModelGame;
	import sg.model.ModelInside;
	import sg.scene.SceneMain;
	import sg.scene.view.Effect;
	import sg.scene.view.InputManager;
	import sg.scene.view.MapCamera;
	import sg.scene.view.entity.EntityClip;
	import sg.scene.view.ui.Bubble;
	import sg.view.com.ComPayType;
	import ui.com.building_tips2UI;
	
	/**
	 * ...
	 * @author light
	 */
	public class ShopClip extends EntityClip {
		
		public var bubble:Bubble;
		
		private var _enabled:Boolean = true;
		
		private var _range:Array;
		
		private var build:ModelBuiding;
		
		public function ShopClip(scene:SceneMain) {
			super(scene);
			this.init();
		}
		
		override public function init():void {
			super.init();
			this.build = ModelManager.instance.modelInside.getBase();
			this.build.on(ModelInside.BUILDING_STATUS_CHANGE, this, this.changeInfo);
			
			this.changeInfo();
			
		}
		
		private function changeInfo():void {
			if (!this._ani) {
				var a:Array=ConfigServer.system_simple.func_open["shop"];
				if (this.build.lv >= a[3]) {
					
					HomeViewMain.instance.mapLayer.topLayer.addChild(this);
					this._ani = EffectManager.loadAnimation("building_caravan");					
					this._clip.addChild(this._ani);
					
					
					this.bubble = new Bubble(this);
					this.bubble.on(Event.CLICK, this, onBubbleClickHandler);
					this._range = ConfigServer.effect["building_caravan"];
					this.x = this._range[0] - HomeModel.instance.mapGrid.gridHalfW;
					this.y = this._range[1] - HomeModel.instance.mapGrid.gridHalfH;
					
					this.bubble.y = -20;
					
					this.bubble.setData({ui:building_tips2UI, icon:"ui/home_25.png"})
					this.bubble.x += this.x;
					this.bubble.y += this.y;
					
					//this.draw(_range[2], _range[3]);	
				}
			}
		}
		
		public override function containsPos(screenX:Number, screenY:Number):Boolean {
			if (!this._ani) return false;
			return Math.abs((screenX - this._range[0]) * this._range[3]) + Math.abs((screenY - this._range[1]) * this._range[2] ) < this._range[2] * this._range[3] * 0.5;
		}
		
		override public function onClick():void {
			//super.onClick();
			var p:Point = this.localToGlobal(Point.TEMP.setTo(0, 0));
			MapCamera.lookAtPos(p.x / this._scene.tMap.scale - this._scene.tMap.viewPortX, p.y / this._scene.tMap.scale - this._scene.tMap.viewPortY, 500);
			
			GotoManager.boundForPanel(GotoManager.VIEW_SHOP);
		}
		
		private function onBubbleClickHandler():void {
			this.onClick();
		}
		
		
		override public function destroy(destroyChild:Boolean = true):void {	
			this.build.off(ModelInside.BUILDING_STATUS_CHANGE, this, this.changeInfo);
			if(this.bubble) this.bubble.off(Event.CLICK, this, this.onClick);
			super.destroy(destroyChild);
		}
		
	}

}