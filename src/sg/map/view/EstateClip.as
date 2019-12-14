package sg.map.view {
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.utils.Pool;
	import laya.utils.Tween;
	import sg.cfg.ConfigServer;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.TestUtils;
	import sg.map.utils.Vector2D;
	import sg.model.ModelEstate;
	import sg.model.ModelGame;
	import sg.scene.SceneMain;
	import sg.scene.model.MapGrid;
	import sg.scene.view.InputManager;
	import sg.scene.view.MapCamera;
	import sg.scene.view.entity.EntityClip;
	import sg.scene.view.ui.Bubble;
	import sg.utils.Tools;
	import ui.com.building_tips2UI;
	import ui.map.estateMainUI;
	import ui.mapScene.EstateInfoUI;
	import ui.com.building_tips6UI;
	
	/**
	 * ...
	 * @author light
	 */
	public class EstateClip extends EntityClip {
		
		public var city:EntityCity;
		
		public var index:int;
		
		public var estateInfo:EstateInfo;
		
		public var grid:MapGrid;
		
		private var _model:ModelEstate;	
		
		private var _bubble:Bubble;
		
		public function EstateClip(sceneMain:SceneMain) {
			super(sceneMain);			
		}
		
		override public function init():void {
			super.init();
			
			
			this._clip.pivotX = -MapModel.instance.mapGrid.gridHalfW;
			this._clip.pivotY = -MapModel.instance.mapGrid.gridHalfH;
			
			
			this._model = ModelEstate.myCountryEstates[this.city.cityId + "_" + this.index];
			this._bubble = new Bubble(this);
			this._bubble.scale(0.9, 0.9);
			this._bubble.minLost = true;
			MapViewMain.instance.estateViews[this.city.cityId + "_" + this.index] = this;
			this._bubble.on(Event.CLICK, this, this.onClick);
			this.changeGold();
		}
		
		override public function onClick():void {
			if (!this.enabled) return;
			super.onClick();
			MapCamera.lookAtGrid(this.grid, 500);
			ModelManager.instance.modelGame.getModelEstate(this.city.cityId.toString(), this.index).click(this.toScreenPos());			
		}
		
		override public function toScreenPos():Vector2D {
			return this.grid.toScreenPos();
		}
		
		public override function show():void {
			super.show();
			//地皮
			var estateData:Array = city.getParamConfig("estate")[this.index];
			
			var id:String = estateData[0].toString();
			var level:int = estateData[1];
			var aniRes:String = estateData[2]?estateData[2]:ConfigServer.estate.estate[id].shape[level - 1];
			this._ani = this.getAnimation(aniRes);
			this._clip.addChild(this._ani);
			
			
			this.estateInfo = this.getRes("EstateInfo", function():EstateInfo {
				return new EstateInfo(MapViewMain.instance);
			});
			this.estateInfo.sceneMain = MapViewMain.instance;
			
			this.estateInfo.setData({occupy:this._model != null && this._model.user_index != -1, name:Tools.getMsgById(ConfigServer.estate.estate[id].name), level:level.toString()});
			
			if (this._model) {
				this._model.on(ModelGame.EVENT_REMOVE_ESTATE, this, this.onUpdateHandler);
				this._model.on(ModelEstate.EVENT_ESTATE_UPDATE, this, this.onUpdateHandler);				
				
				var state:int = this._model.status;
				var showObj:Object = this._model.showObj;
				if (state != 3) {
					this._bubble.addChild(icon);
					switch(state) {
						case 0://收获
							var icon:building_tips2UI = this.getRes("building_tips2UI", function():building_tips2UI {
								return new building_tips2UI();
							});
							icon.setBuildingTipsIcon(showObj.icon, showObj.num);
							this._bubble.addChild(icon);
							this._bubble.hitArea = new Rectangle(-icon.width / 2, -icon.height, icon.width, icon.height);
							break;
						case 2://道具图标。							
							icon = this.getRes("building_tips2UI", function():building_tips2UI {
								return new building_tips2UI();
							});	
							icon.setBuildingTipsIcon(showObj.icon, "");
							this._bubble.addChild(icon);
							this._bubble.hitArea = new Rectangle(-icon.width / 2, -icon.height, icon.width, icon.height);
							break;
						case 1://英雄图标。							
							var icon2:building_tips6UI = this.getRes("building_tips6UI", function():building_tips6UI {
								return new building_tips6UI();
							});
							icon2.setBuildingTipsIcon3(showObj.hid);
							//{hid:this.estateHero.hid, rid:this.estateHero.getRidURL, event:false, finish:true);
							if (showObj.event) {
								icon2.icon_img.skin = "ui/icon_paopao19.png";
								icon2.icon_img.pos(55, -19);
								icon2.icon_img.scale(1, 1);								
							} else if (showObj.finish) {
								icon2.icon_img.skin = "ui/bg_icon_03.png";
								icon2.icon_img.pos(58, -8);
								icon2.icon_img.scale(1.5, 1.5);
							} else {
								icon2.icon_img.skin = showObj.rid;
								icon2.icon_img.pos(25, -33);
								icon2.icon_img.scale(1, 1);
							}
							icon2.icon.gray = !showObj.finish;
							this._bubble.addChild(icon2);
							this._bubble.hitArea = new Rectangle(-icon2.width / 2, -icon2.height, icon2.width, icon2.height);
							break;
						case 4:
							this._bubble.removeChildren();
							break;
					}
				}
				
				this._bubble.visible = true;
				
			} else {
				this._bubble.visible = false;
			}
			
			this._bubble.resize();
			this.estateInfo.resize();
			ArrayUtils.push(this._bubble, this._scene.bubbles);	
			ArrayUtils.push(this.estateInfo, this._scene.bubbles);
			this._scene.mapLayer.bubbleLayer.addChild(this._bubble);
			
			this._scene.mapLayer.getPos(this.grid.col, this.grid.row, Point.TEMP);
			this.estateInfo.visible = this.enabled;
			this._bubble.x = Point.TEMP.x;
			this._bubble.y = Point.TEMP.y;// - this._scene.mapGrid.gridHalfH - 10;
			
			
			this.estateInfo.x = Point.TEMP.x;
			this.estateInfo.y = Point.TEMP.y + this._scene.mapGrid.gridHalfH - 15;
			
			this.visible = true;
			Tween.clearAll(this.estateInfo);
			this.estateInfo.alpha = InputManager.instance.isDrag ? 0 : 1;
			InputManager.instance.on(Event.DRAG_MOVE, this, this.onDragHandler);
		}
		
		private function onDragHandler():void {
			InputManager.instance.isDrag ? Tween.to(this.estateInfo, {alpha:0}, 300, null, null, 0, true, true) : Tween.to(this.estateInfo, {alpha:1}, 300, null, null, 0, true, true)
		}
		
		private function get enabled():Boolean {
			return ModelGame.unlock(null, "estate").visible;
		}
		
		public override function hide():void {
			super.hide();			
			InputManager.instance.off(Event.DRAG_MOVE, this, this.onDragHandler);
			if (this._model) {
				this._model.off(ModelGame.EVENT_REMOVE_ESTATE, this, this.onUpdateHandler);
				this._model.off(ModelEstate.EVENT_ESTATE_UPDATE, this, this.onUpdateHandler);
			}
			this._bubble.removeSelf();
			ArrayUtils.remove(this._bubble, this._scene.bubbles);	
			ArrayUtils.remove(this.estateInfo, this._scene.bubbles);	
			this._bubble.visible = false;
			this._ani = null;
			this.visible = false;
		}
		
		
		private function onUpdateHandler(e:*):void {
			trace("更新产业！");
			this.hide();
			this.show();
		}
		
		public function get model():ModelEstate {
			return _model;
		}
		
		public function set model(value:ModelEstate):void {
			_model = value;
			if (this.visible) {
				this.onUpdateHandler(null);
			}
		}
		
		override public function destroy(destroyChild:Boolean = true):void {			
			this.hide();
			Tween.clearAll(this.estateInfo);
			super.destroy(destroyChild);
			Tools.destroy(this._bubble);
		}
		
		
		private var effect:Animation;
		public function changeGold():void {
			if (ModelEstate.isGold(this.city.cityId, this.index)) {
				if (!this.effect) {
					this.effect = EffectManager.loadAnimation("glow050");
					this.addChild(this.effect);
					this.effect.pos(MapModel.instance.mapGrid.gridHalfW, MapModel.instance.mapGrid.gridHalfH);
				}
			} else {
				Tools.destroy(this.effect);
				this.effect = null;
			}
		}
	}

}