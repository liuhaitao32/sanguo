package sg.map.view {
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.html.dom.HTMLDivElement;
	import laya.maths.Rectangle;
	import sg.map.utils.ArrayUtils;
	import sg.model.ModelCityBuild;
	import sg.model.ModelVisit;
	import sg.scene.view.InputManager;
	import sg.scene.view.ui.NoScaleUI;
	import sg.utils.StringUtil;
	import sg.utils.Tools;
	import sg.view.com.ComPayType;
	import ui.com.building_tips2UI;
	import ui.com.building_tips9UI;
	
	/**
	 * 队列图标。
	 * @author light
	 */
	public class CityQueueHead extends NoScaleUI {
		
		private var _models:Array = [];//[[model]]
		
		private var _currDisplay:building_tips9UI;
		
		private var _currModel:* = null;
		
		public function CityQueueHead() {
			this.initScene(MapViewMain.instance);
			this.on(Event.CLICK, this, this.onClickHandler);
			this.hitArea = new Rectangle( -68 / 2, -68 / 2, 68, 68);
		}
		
		private function onClickHandler(e:Event):void {
			if (this._currModel) {
				(this._currModel).click();
			}
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
		
		
		public function addItem(model:*):void {			
			ArrayUtils.remove(model, this._models);			
			this._models.push(model);
			this.timer.callLater(this, this.updateTopModel);
			if (model is ModelCityBuild) {
				model.on(ModelCityBuild.EVENT_UPDATE_CITY_BUILD, this, this.onUpdateBuildHandler);
				model.on(ModelCityBuild.EVENT_REMOVE_CITY_BUILD, this, this.onRemoveBuildHandler);
			}
		}
		
		
		private function onUpdateBuildHandler(e:ModelCityBuild):void {
			this.timer.callLater(this, this.updateTopModel);
		}
		
		private function onRemoveBuildHandler(e:ModelCityBuild):void {
			this.removeItem(e);
		}
		
		public function removeItem(model:*):void {
			if (ArrayUtils.remove(model, this._models)){
				this.timer.callLater(this, this.updateTopModel);
				if (this._currModel == model) this._currModel = null;
			}
			
		}
		
		
		private function updateTopModel():void {
			if (!this._models.length) {
				this.visible = false;
				Tools.destroy(this._currDisplay);
				this._currModel = null;
				return;
			}
			this.visible = true;
			this._models = this._models.sort(function(e1:*, e2:*):int {
				var obj1:Object = e1.showObj;
				var obj2:Object = e2.showObj;
				if (obj1.event) return 1;
				if (obj2.event) return -1;
				if (obj1.isFinish) return 1;
				if (obj2.isFinish) return -1;
				return 0;
			});
			if (true) {
				this._currModel = this._models[this._models.length - 1];
				Tools.destroy(this._currDisplay);
				var showObj:Object = this._currModel.showObj;
								
				if (this._currModel is ModelVisit) {//拜访。。。。。。。。。。。。。
					if (ModelVisit(this._currModel).status != 0 && ModelVisit(this._currModel).status != 3) {
						this.removeItem(this._currModel);
						return;
					}
					
					
				} else if (this._currModel is ModelCityBuild) {
					//_showObj = {hid:cityBuildHero.hid, rid:this.cityBuildHero.getRidURL(), "event":cityBuildHero.event_id!="", finish:cityBuildHero.isFinish()};
				}
				
				this._currDisplay = new building_tips9UI();
				this._currDisplay.setBuildingTipsIcon3(showObj.hid);
				
				if (showObj.event) {
					this._currDisplay.icon_img.skin = "ui/icon_paopao19.png";
					this._currDisplay.icon_img.pos(52, 36);
					this._currDisplay.icon_img.scale(1, 1);
				} else if (showObj.finish) {
					this._currDisplay.icon_img.skin = "ui/bg_icon_03.png";
					this._currDisplay.icon_img.pos(55, 46);
					this._currDisplay.icon_img.scale(1, 1);
				} else {
					this._currDisplay.icon_img.skin = showObj.rid;
					this._currDisplay.icon_img.pos(26, 27);
					this._currDisplay.icon_img.scale(1, 1);
				}
				this._currDisplay.icon.gray = !showObj.finish;
				this.addChild(this._currDisplay);
			} 
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			while (this._models.length) {
				var model:Object = this._models.shift();
				if (model is ModelCityBuild) {
					model.off(ModelCityBuild.EVENT_UPDATE_CITY_BUILD, this, this.onUpdateBuildHandler);
					model.off(ModelCityBuild.EVENT_REMOVE_CITY_BUILD, this, this.onRemoveBuildHandler);
				}
			}
			super.destroy(destroyChild);
		}
	}

}