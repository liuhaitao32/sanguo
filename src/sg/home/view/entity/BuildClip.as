package sg.home.view.entity {
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.resource.Texture;
	import sg.cfg.ConfigApp;
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
	import sg.model.ModelInside;
	import sg.scene.SceneMain;
	import sg.scene.view.Effect;
	import sg.scene.view.InputManager;
	import sg.scene.view.MapCamera;
	import sg.scene.view.entity.EntityClip;
	import sg.scene.view.ui.Bubble;
	import sg.utils.Tools;
	import sg.view.com.ComPayType;
	import ui.com.building_tips3UI;
	
	/**
	 * ...
	 * @author light
	 */
	public class BuildClip extends EntityClip {
		
		
		
		public var buildInfo:BuildInfo = new BuildInfo();
		public var buildingInfo:BuildingInfo = new BuildingInfo();
		public var buildArmyInfo:BuildArmyInfo;
		
		public var bubble:Bubble;
		
		private var _enabled:Boolean = true;
		
		public function BuildClip(scene:SceneMain) {
			super(scene);
			this.bubble = new Bubble(this);
		}
		
		override public function init():void {
			super.init();
			//var build:EntityBuild = this.entityBuild;
			//this.changeState();
			
			
			
			HomeViewMain.instance.mapLayer.topLayer.addChild(this);
			var pos:Array = this.entityBuild.getParamConfig("rect");
			this.x = pos[0] - HomeModel.instance.mapGrid.gridHalfW;
			this.y = pos[1] - HomeModel.instance.mapGrid.gridHalfH;			
			var h:Number = pos[3] / 2;
			
			var yy:Number = Math.max(h , 65) - 20;
			this.buildingInfo.y = this.buildInfo.y = yy;
			
			
			if (TestUtils.isTestShow) {
				this.print(this.entityBuild.name);
				this.graphics.drawCircle(0, 0, 30, "#FF0000");					
				this.draw(pos[2], pos[3]);	
			}
			
			
			this.bubble.y = -h;
			this._scene.mapLayer.infoLayer.addChild(this.buildInfo);
			this._scene.mapLayer.infoLayer.addChild(this.buildingInfo);
			if (this.entityBuild.model.isArmy()){
				this.buildArmyInfo = new BuildArmyInfo(this);
				this.buildArmyInfo.entity = this.entityBuild;
				this.buildArmyInfo.x += this.x;
				this.buildArmyInfo.y = yy + this.y;
				this.buildArmyInfo.visible = false;
				this.buildArmyInfo.kucun.text = Tools.getMsgById("BuildClip_1");
				this._scene.mapLayer.infoLayer.addChild(this.buildArmyInfo);
				ArrayUtils.push(this.buildArmyInfo, this._scene.bubbles);
				ArrayUtils.push(this.buildArmyInfo.yanjiu, this._scene.bubbles);
			}
			
			this.buildInfo.entity = this.entityBuild;
			this.buildInfo.x += this.x;
			this.buildInfo.y += this.y;
			
			this.buildingInfo.x += this.x;
			this.buildingInfo.y += this.y;
			
			this.bubble.x += this.x;
			this.bubble.y += this.y;
			ArrayUtils.push(this.buildingInfo, this._scene.bubbles);
			ArrayUtils.push(this.buildInfo, this._scene.bubbles);
			this.entityBuild.model.on(ModelInside.BUILDING_STATUS_CHANGE, this, this.changeInfo);
			this.bubble.on(Event.CLICK, this, onBubbleClickHandler);
			
			
			this.changeInfo();
			
		}
		
		private function onBubbleClickHandler():void {
			ModelManager.instance.modelInside.checkBuildingFunc(this.entityBuild.model, -1);
		}
		
		
		private function changeInfo(param:* = null):void {
			/**
		 * 检查自己的状态,返回相应数据
		 * info:{name:建筑名称,level:等级}
		 * up:{total:总时间毫秒,cd:剩余时间毫秒,content:文字提升,icon:素材地址,ui:图标类ComPayType(需要 new 出来 addchild 上 使用 setBuildingTipsIcon("icon地址"))}
		 * bubble:{icon:素材地址,num:各种类型下的数量,ui:图标类ComPayType(需要 new 出来 addchild 上 使用 setBuildingTipsIcon("icon地址"))}
		 */
			var obj:Object = this.entityBuild.model.checkMyStatus();
			if (obj.visible >= 0) {			
				
				var id:String = obj.visible ? (this.entityBuild.getParamConfig("res") || this.entityBuild.model.id) : "building_lock";
				if (this._clip.name != id && id.indexOf("001") == -1) {
					this._clip.destroyChildren();//removeChildren();	
					this._clip.addChild(EffectManager.loadAnimation(id));
					this._clip.name = id;
					
					var front_scale:Number = this.entityBuild.getParamConfig("front_scale") || 1;
					var sc:Number = ConfigApp.isNewHome ? front_scale : (id == "building_lock" && front_scale ? front_scale : 1);
					this._clip.scale(sc, sc);
				}				
			}

			
			if (obj.visible == -1) {
				this.buildInfo.visible = false;
				this.buildingInfo.visible = false;
				this.bubble.visible = false;
				this._enabled = false;
			} else {
				this._enabled = true;
				this.buildInfo.setData(obj.info);
				this.buildingInfo.setData(obj.up, this);
				if (this.buildArmyInfo){
					this.buildArmyInfo.setData(obj);
					this.buildArmyInfo.yanjiu.on(Event.CLICK, this, this.onBubbleClickHandler);
				}
				this.bubble.setData(obj.bubble);
				
			}
			
			
			if(param) this.addChild(new Effect().init({id:"building_do"}));//有事件驱动 才开始的！
		}
		
		override public function onClick():void {
			if (!this._enabled) return;
			var p:Point = this.localToGlobal(Point.TEMP.setTo(0, 0));
			MapCamera.lookAtPos(p.x / this._scene.tMap.scale - this._scene.tMap.viewPortX, p.y / this._scene.tMap.scale - this._scene.tMap.viewPortY, 500);
			
			var state:int = ModelManager.instance.modelInside.checkBuildingStatus(this.entityBuild.model);
			
			//如果收获 直接收获！ 不然就弹出菜单。
			if ((state%10) >= 2 || state == -1) {
				ModelManager.instance.modelInside.checkBuildingFunc(this.entityBuild.model);
			} else {
				var range:Array = this.entityBuild.getParamConfig("rect");
				HomeViewMain.instance.mapLayer.menu.showMenu(this, ModelManager.instance.modelInside.checkBuildingView(this.entityBuild.model), range[3] / 2 + 30, new Point(0, 0));	
			}
			
		}
		
		override public function print(str:*, clear:Boolean = false, strokeColor:String = '#333333'):void {
			if (!TestUtils.isTestShow) return;
			super.print(str, clear, strokeColor);
			this._text.x -= MapModel.instance.mapGrid.gridW / 2;
			this._text.y -= MapModel.instance.mapGrid.gridH / 2;
		}
		
		public function changeState():void {			
			var build:EntityBuild = this.entityBuild;
			var state:int = ModelManager.instance.modelInside.checkBuildingStatus(build.model);
			var shouhuo:Boolean = false;
			if (state > 0) {
				state = parseInt(state.toString().slice(state.toString().length - 1, 1));
				shouhuo = state == 2;
			}
			
			
			//-1空地 0建造好 1 升级中 2 可收货
			if(state > 0) {
				var textue:Texture = Laya.loader.getRes("build/" + build.id + ".png");
				this._clip.texture = texture;
				this._clip.x = -textue.width / 2;
				this._clip.y = -textue.height / 2;
			}
		}
		
		
		public function get entityBuild():EntityBuild{
			return EntityBuild(this._entity);
		}
		
		override public function destroy(destroyChild:Boolean = true):void {	
			this.entityBuild.model.off(ModelInside.BUILDING_STATUS_CHANGE, this, this.changeInfo);
			this.bubble.off(Event.CLICK, this, this.onClick);
			super.destroy(destroyChild);
		}
		
	}

}