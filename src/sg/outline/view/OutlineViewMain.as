package sg.outline.view {
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.filters.ColorFilter;
	import laya.filters.GlowFilter;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.resource.Texture;
	import laya.ui.Image;
	import laya.ui.UIUtils;
	import laya.utils.Ease;
	import laya.utils.Tween;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigColor;
	import sg.cfg.ConfigServer;
	import sg.home.model.HomeModel;
	import sg.home.model.entitys.EntityBuild;
	import sg.home.view.entity.BuildClip;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.map.model.entitys.EntityHeroCatch;
	import sg.map.model.entitys.EntityMarch;
	import sg.map.model.entitys.EntityMonster;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.MapUtils;
	import sg.map.utils.Math2;
	import sg.map.utils.TestUtils;
	import sg.map.utils.Vector2D;
	import sg.map.view.AroundManager;
	import sg.map.view.MapViewMain;
	import sg.model.ModelCityBuild;
	import sg.model.ModelFTask;
	import sg.model.ModelOfficial;
	import sg.model.ModelTask;
	import sg.model.ModelTroop;
	import sg.model.ModelTroopManager;
	import sg.model.ModelVisit;
	import sg.outline.view.ui.MiniMapTop;
	import sg.scene.SceneMain;
	import sg.scene.constant.ConfigConstant;
	import sg.scene.constant.EventConstant;
	import sg.scene.model.MapGrid;
	import sg.scene.view.InputManager;
	import sg.scene.view.MapCamera;
	import sg.scene.view.entity.EntityClip;
	import sg.scene.view.ui.Bubble;
	import sg.utils.Tools;
	import ui.com.building_tips2UI;
	import sg.model.ModelUser;
	import ui.com.building_tips4UI;
	
	/**
	 * ...
	 * @author light
	 */
	public class OutlineViewMain extends SceneMain {
		
		public static var QIE_CUO:int = 3;
		public static var BAI_FANG:int = 5;
		public static var CHANG_CHENG:int = 6;
		public static var ZHENG_WU:int = 4;
		public static var YI_ZU:int = 2;
		public static var BU_DUI:int = 0;
		public static var MIN_QING:int = 1;
		
		private var _selectIndex:int = -1;
		
		private var _rate:Number = 1;
		
		private var _content:Sprite = new Sprite();
		
		private var _fireCotnent:Sprite = new Sprite();
		
		private var command:Object = {};
		
		private var mapUI:*;
		
		private var _occupy:Sprite = new Sprite();
		
		private var _occupyTexture:Object = {0:Laya.loader.getRes("map2/mblue.png"), 1:Laya.loader.getRes("map2/mgreen.png"), 2:Laya.loader.getRes("map2/mred.png")};
		
		public var offset:Point = new Point();
		
		public var fillSprite:Sprite = new Sprite();
		public var lineSprite:Sprite = new Sprite();
		public var citySprite:Sprite = new Sprite();
		
		private var allCitys:Object = {};
		public var waySprite:Sprite = new Sprite();
		
		
		private var topBottom:Boolean;
		
		private var _scene:SceneMain;
		
		public function OutlineViewMain(mapUI:*, tb:Boolean = true) {
			this.type = SceneMain.MINI_MAP;
			this.mapUI = mapUI;
			this.topBottom = tb;
			super();
			this._scene = InputManager.instance.scene;
			this.maxScale = this.minScale = 1;
			this.springMaxScale = this.springMinScale = 0;
			this.mapGrid = MapModel.instance.mapGrid;
			//this.tMap.limitRect.setTo(0, 45 + 55, 0, 0);
			this.initScene("outline/outline");	
			//ViewManager.instance.mLayerMap.addChild(this);
			//this.on(Event.addto)
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			this._content.removeChildren();
			this.hideFire();
			if (this.command[this._selectIndex]) {
				this.command[this._selectIndex].end.call(this);
			}
			
			Tween.clearAll(this.qianwang);
			super.destroy(destroyChild);
			
			for (var name:String in MapModel.instance.citys) {
				EntityCity(MapModel.instance.citys[name]).off(EventConstant.CITY_COUNTRY_CHANGE, this, this.onChangeCityCountry);
			}
			
			InputManager.instance.scene = this._scene;
			InputManager.instance.enaled = true;
			MapCamera.initScene(this._scene);
			this._scene.visible = true;
			this._scene.mouseEnabled = true;
		}
		
		
		override protected function onClickHandler(e:Event):void {
			var p:Point = this.localToGlobal(Point.TEMP.setTo(0, 0));
			
			var screenX:Number = e.stageX - p.x// - HomeModel.instance.mapGrid.gridHalfW;
			var screenY:Number = e.stageY - p.y;// - HomeModel.instance.mapGrid.gridHalfH;
			
			if (screenY < 0 || screenY > this.tMap.height || screenX < 0 || screenX > this.tMap.width) return;
			
			screenX = screenX / this.tMap.scale - this.tMap.viewPortX;
			screenY = screenY / this.tMap.scale - this.tMap.viewPortY;
			
			this.mapLayer.menu.show();
			this.mapLayer.menu.x = screenX - this.tMap.tileWidth / 2;
			this.mapLayer.menu.y = screenY - this.tMap.tileHeight / 2;		
			
		}
		
		
		
		override protected function initMap():void {
			//画城市。
			this._rate = this.tMap.width / MapModel.instance.mapGrid.width;			
			
			
			if (!ConfigApp.isPC) this._scene.visible = false;
			this._scene.mouseEnabled = false;
			super.initMap();
			this.mapLayer.topLayer.addChild(this._occupy);
			//around。。。。。。。。。。。。。
			
			//this._occupy.cacheAsBitmap = true;
			
			var arr:Array = [0, 7, 8];
			var this2:OutlineViewMain = this;
			var citys:Array = MapModel.instance.getFilterCitys(function(entity:EntityCity):Boolean {
				entity.on(EventConstant.CITY_COUNTRY_CHANGE, this2, onChangeCityCountry);
				return !ArrayUtils.contains(entity.cityType, arr);
			});
			var river:Sprite = new Sprite();
			this._occupy.addChild(this.fillSprite);
			this._occupy.addChild(river);
			this._occupy.addChild(this.lineSprite);
			this._occupy.addChild(this.waySprite);
			
			
			this.drawMap();
			for (var name:String in ConfigConstant.mapData["path"]) {				
				var arr1:Array = name.split("_");
				this.drawWay(this.waySprite, parseInt(arr1[0]), parseInt(arr1[1]), "#48525B");
			}
			
			
			for (var i:int = 0, len:int = citys.length; i < len; i++) {
				var entity:EntityCity = citys[i];
				var cityClip:OutlineCity = new OutlineCity(this);					
				cityClip.entity = entity;
				cityClip.init();
				this.citySprite.addChild(cityClip);
				this.setGridPos(entity.mapGrid, cityClip);
				this.allCitys[entity.cityId] = cityClip;
			}
			
			this.mapLayer.topLayer.addChild(this.citySprite);
			this.mapLayer.topLayer.addChild(this._fireCotnent);
			this.showFire();
			//可视地区
			var sc:Number = this._scene.tMap.scale;
			var p:Point = this.toLocal(new Point(Laya.stage.width / sc, (Laya.stage.height - this._scene.tMap.limitRect.bottom) / sc));
			this.mapUI.rect_img.size(p.x, p.y);
			Point.TEMP.setTo(-this._scene.tMap.viewPortX - this._scene.tMap.tileWidth / 2, -this._scene.tMap.viewPortY);
			this.mapUI.rect_img.x = Point.TEMP.x * this._rate - this.tMap.tileWidth / 2;
			this.mapUI.rect_img.y = Math.max(0, Point.TEMP.y) * this._rate - this.tMap.tileHeight / 2;
			this.mapLayer.topLayer.addChild(this.mapUI.rect_img);
			
			this._content.mouseThrough = true;
			this.mapLayer.topLayer.addChild(this._content);
			
			this.mapUI.mouseThrough = true;
			this._occupy.x = -this.tMap.tileWidth / 2;
			this._occupy.y = -this.tMap.tileHeight / 2;
			//MapCamera.lookAtDisplay(EntityBuild(HomeModel.instance.builds["building001"]).view, true);
			//this.command[JIAO_ZHAN] = {start:this.showFire, end:this.hideFire};
			this.command[QIE_CUO] = {start:this.showQieCuo, end:this.hideQieCuo};
			this.command[YI_ZU] = {start:this.showYiZu, end:this.hideYiZu};
			this.command[BAI_FANG] = {start:this.showBaiFang, end:this.hideBaiFang};
			this.command[BU_DUI] = {start:this.showBuDui, end:this.hideBuDui};
			this.command[ZHENG_WU] = {start:this.showZhengWu, end:this.hideZhengWu};
			this.command[MIN_QING] = {start:this.showMinQing, end:this.hideMinQing};
			this.command[CHANG_CHENG ] = {start:this.showChangeCheng, end:this.hideChangeCheng};
			
		//public static var ZHENG_WU:int = 3;
		
		//public static var :int = 5;
			
			
			var bubble:Bubble = new Bubble(null);
			var sp:building_tips2UI = new building_tips2UI();
			sp.setBuildingTipsIcon2(null, Tools.getMsgById("_jia0032"), "ui/icon_paopao03.png");
			sp.mLabel.fontSize = 26;
			sp.mLabel.y -= 5;
			sp.mLabel.color = "#58FEB2";
			bubble.addChild(sp)
			EffectManager.tweenShake(sp, {rotation:5}, 100, Ease.sineInOut, null, Math.random() * 2000 + 300, -1, 2000);
			InputManager.pierceEvent(sp);
			bubble.on(Event.CLICK, this, function(e:Event):void {
				var xx:Number = mapLayer.menu.x + this.tMap.tileWidth / 2;
				var yy:Number = mapLayer.menu.y + this.tMap.tileHeight / 2;
				mapUI.click_closeScenes();
				MapCamera.lookAtPos(xx / _rate, yy / _rate);
			});
			this.mapLayer.menu.addChild(bubble);
			this.qianwang = sp;
			MapCamera.zoom(this.minScale);
			MapCamera.lookAtPos(this.mapUI.rect_img.x + this.mapUI.rect_img.width / 2 + this.tMap.tileWidth / 2, this.mapUI.rect_img.y + this.mapUI.rect_img.width / 2 + this.tMap.tileHeight / 2);
			
			
			if(this.topBottom){
				var top:Sprite = new Sprite();
				var textrue:Texture = Laya.loader.getRes("ui/bg_006.png");
				top.graphics.fillTexture(textrue, 0, 0, this.tMap.viewPortWidth, textrue.sourceHeight);
				top.y = -textrue.sourceHeight;
				this.addChildAt(top, 0);
				
				var bottom:Sprite = new Sprite();
				bottom.graphics.fillTexture(textrue, 0, 0, this.tMap.viewPortWidth, textrue.sourceHeight);
				bottom.scaleY = -1;
				bottom.y = this.tMap.height + textrue.sourceHeight;
				this.addChildAt(bottom, 0);
			} else {				
				this.tMap.changeViewPortBySize(this.tMap.width, this.tMap.height);
			}
		}
		
		private function hideChangeCheng():void {
			
			for (var cityId:String in this.changeCheng) {
				var city:OutlineCity = this.allCitys[cityId];
				city.gray = false;
			}
			
			for (cityId in this.allCitys) {				
				city = this.allCitys[cityId];
				city.visible = true;
				city.alpha = 1;
			}
			this.waySprite.visible = true;
			while (this.changechengs.length) {
				Sprite(this.changechengs.shift()).destroy();
			}
		}
		
		private var changeCheng:Object = {};
		private function showChangeCheng():void {
			this.changeCheng = {};
			this.waySprite.visible = false;
			for (var cityId:String in this.allCitys) {				
				var city:OutlineCity = this.allCitys[cityId];
				city.visible = false;
				
				var entity:EntityCity = city.entity as EntityCity;
				
				if (entity.cityType != 3) continue;				
				//if (entity.faithCountry != entity.country) continue;//不是信仰过 没有长城。
				
				//ModelFTask.ftaskModels[entity.cityId.toString()] 民情不知道是否要过滤。
				
				
				//
				for (var bid:String in ModelOfficial.cities[cityId].build) {
					var gw:Array = ModelCityBuild.getGreatWall2(cityId, bid);
					if (gw) {
						this.changeCheng[cityId] = {};
						for (var i:int = 0, len:int = gw.length; i < len; i++) {
							var name:String = gw[i].city
							this.changeCheng[cityId][name] = gw[i].open;
						}
					}
				}
			}
			
			//长城的cityId bid 准备好了。 现在 可以 显示了。
			for (cityId in this.changeCheng) {
				city = this.allCitys[cityId];
				//添加点击事件。。。
				//city.on(Event.CLICK, this, this.showChangeCheng2, [city]);
				this.showChangeCheng2(cityId);
			}
			
			
		}
		private var changechengs:Array = [];
		private function showChangeCheng2(cityId:String):void {
			var gw:Object = this.changeCheng[cityId];
			var gwCity:OutlineCity = this.allCitys[cityId];
			gwCity.visible = true;
			//不是自己的 有民情任务 不是信仰国的。
			gwCity.gray = !gwCity.entityCity.myCountry || !gwCity.entityCity.isFaith;
			for (var targetCity:String in gw) {
				var city:OutlineCity = this.allCitys[targetCity];
				city.visible = true;
				var gray:Boolean = !gw[targetCity] || gwCity.gray;
				city.gray = gray;
				//city.alpha = 0.8;
				//city.cacheAs = "bitmap";
				Vector2D.TEMP.setXY(city.x - gwCity.x, city.y - gwCity.y);
				
				//this.citySprite.graphics.drawLine(gwCity.x, gwCity.y, city.x, city.y, (gw[targetCity] ? "#FFFFFF" : "#48525B"), 3);
				
				
				var sp:Sprite = new Sprite();
				sp.texture = Laya.loader.getRes("map2/bar_line1.png");
				sp.rotation = Math2.radianToAngle(Vector2D.TEMP.angle);
				sp.scaleX = Vector2D.TEMP.length / sp.texture.width;
				sp.x = gwCity.x;
				sp.y = gwCity.y;
				this.citySprite.addChildAt(sp, 0);
				this.changechengs.push(sp);
				if (gray) {
					UIUtils.gray(sp);
				}
			}
		}
		
		
		
		private function onChangeCityCountry():void {
			this.drawMap();
		}
		
		private function drawMap():void {
			this.fillSprite.removeChildren();
			this.lineSprite.removeChildren();
			AroundManager.instance.fillMiniMap([this.fillSprite, this.lineSprite], this._rate, true, [0.5, 0.2]);
		}
		
		private function drawWay(line:Sprite, cityId1:int, cityId2:int, color:String, lineW:Number = 1):void {			
			var arr:Array = EntityCity.getAllTurnPath(cityId1, cityId2);
			var lines:Array = [];
			
			for (var i:int = 0, len:int = arr.length; i < len; i++) {
				var grid:Vector2D = arr[i][0];
				MapUtils.getPos(grid.x, grid.y, Point.TEMP);
				lines.push(Point.TEMP.x * this._rate);
				lines.push(Point.TEMP.y * this._rate);
			}
			line.graphics.drawLines(0, 0, lines, color, lineW);
			
		}
		
		private var qianwang:Sprite;
		
		public function toLocal(p:Point, result:Point = null):Point {
			result ||= Point.TEMP;
			result.x = p.x * this._rate;
			result.y = p.y * this._rate;
			return result;
		}
		
		public function resize():void {
			this.localToGlobal(this.offset);
			this.y = (Laya.stage.height - this.offset.y - this.tMap.height) / 2;
		}
		
		public function setGridPos(grid:MapGrid, clip:Sprite):void {			
			MapUtils.getPos(grid.col, grid.row, Point.TEMP);
			clip.x = Point.TEMP.x * this._rate - this.tMap.tileWidth / 2;
			clip.y = Point.TEMP.y * this._rate - this.tMap.tileHeight / 2;
		}
		
		private function showMinQing():void {			
			for (var name:String in ModelFTask.ftaskModels) {
				this.createBubble(EntityCity(MapModel.instance.citys[name]).mapGrid, null, null, null, building_tips4UI);
			}
		}
		private function hideMinQing():void {
			
		}
		
		
		private function showZhengWu():void {
			for (var cityId:String in ModelTask.gTask_by_lc()) {
				this.createBubble(MapModel.instance.citys[cityId].mapGrid, "ui/home_40.png", "", "ui/icon_paopao02.png");
			}
			
		}
		private function hideZhengWu():void {
			
		}
		
		
		private var buduiDic:Object = {};
		private function showBuDui():void {			
			//画行军的线。。。
			
			//部队状态更新。
			for each (var item:ModelTroop in ModelManager.instance.modelTroopManager.troops) {
				var obj:Object = this.createBubble(MapModel.instance.citys[item.cityId].mapGrid, null, Tools.getMsgById(ConfigServer.hero[item.hero].name), ["ui/icon_paopao04.png", "ui/icon_paopao03.png", "ui/icon_paopao05.png"][ModelUser.getCountryID()]);
				var sp:building_tips2UI = obj.ui;
				var bubble:Bubble = obj.bu;
				sp.mLabel.color = "#FFFFFF";				
				bubble.offAll();
				buduiDic[item.id] = {sp:bubble};	
				//TestUtils.drawTest(bubble);
				bubble.on(Event.CLICK, this, function(m:ModelTroop):void {
					mapUI.click_closeScenes();
					if (MapModel.instance.marchs[m.id] && EntityMarch(MapModel.instance.marchs[m.id]).view) {
						MapCamera.lookAtDisplay(EntityMarch(MapModel.instance.marchs[m.id]).view);
					} else {						
						MapCamera.lookAtCity(m.cityId);
					}
				}, [item]);
				
				var march:EntityMarch = MapModel.instance.marchs[item.id];
				if (march) {
					var line:Sprite = new Sprite();
					
					for (var i:int = 0, len:int = march.marchData.length - 1; i < len; i++) {
						drawWay(line, march.marchData[i][0], march.marchData[i + 1][0], "#FFFFFF", 2);
					}
					EffectManager.tweenLoop(line, {alpha:0.3}, 500);
					line.once(Event.REMOVED, this, function(l):void {
						Tween.clearAll(l);
					}, [line]);
					this.waySprite.addChild(line);
					buduiDic[item.id].line = line;
				}
			}			
			//不停的跟随行军。
			Laya.timer.frameLoop(1, this, this.followMarchClip);
			this.followMarchClip();
			
			ModelManager.instance.modelTroopManager.on(EventConstant.TROOP_UPDATE, this, this.checkTroop);
			ModelManager.instance.modelTroopManager.on(EventConstant.FIGHT_FINISH_FIGHT, this, this.checkTroop);
			ModelManager.instance.modelTroopManager.on(EventConstant.TROOP_MARCH_REMOVE, this, this.checkMarchRemove);
		}
		
		private function checkMarchRemove(data:Object):void {
			var troop:ModelTroop = data.model;
			if (troop && this.buduiDic[troop.id] && this.buduiDic[troop.id].line) {
				Sprite(this.buduiDic[troop.id].line).destroy(true);
			}
		}
		
		private function checkTroop(data:Object):void {
			var troop:ModelTroop = data.model;
			if (troop && troop.deaded) {
				if (this.buduiDic[troop.id]) {
					this.buduiDic[troop.id].sp.visible = false;
				}
			}
		}
		
		private function followMarchClip():void {
			for (var troopId:String in this.buduiDic) {
				var march:EntityMarch = MapModel.instance.marchs[troopId];
				if (march && march.view) {
					var sp:Sprite = this.buduiDic[troopId].sp;
					sp.x = march.view.x * this._rate - this.tMap.tileWidth / 2;
					sp.y = march.view.y * this._rate - this.tMap.tileHeight / 2;
				}
			}
		}
		
		private function hideBuDui():void {			
			Laya.timer.clear(this, this.followMarchClip);
			for (var troopId:String in this.buduiDic) {
				if (this.buduiDic[troopId].line) {
					Sprite(this.buduiDic[troopId].line).destroy(true);
				}					
			}
			
			ModelManager.instance.modelTroopManager.off(EventConstant.TROOP_UPDATE, this, this.checkTroop);
			ModelManager.instance.modelTroopManager.off(EventConstant.FIGHT_FINISH_FIGHT, this, this.checkTroop);
			ModelManager.instance.modelTroopManager.off(EventConstant.TROOP_MARCH_REMOVE, this, this.checkMarchRemove);
		}
		
		private function showBaiFang():void {
			//异族入侵不需要更新。
			for (var cityId:String in ModelVisit.visitModels) {
				var city:EntityCity = MapModel.instance.citys[parseInt(cityId)];							
				var heroConfig:Object = ConfigServer.hero[ModelVisit(ModelVisit.visitModels[cityId]).visit_hid];
				var sp:building_tips2UI = this.createBubble(city.mapGrid, null, Tools.getMsgById(heroConfig.name), "ui/icon_paopao02.png").ui;				
				sp.mLabel.color = "#FFE96F";
			}
		}
		
		private function hideBaiFang():void {			
			
		}
		
		
		
		
		private function showYiZu():void {			
			//异族入侵不需要更新。
			for (var name:String in MapModel.instance.monsters) {
				var monster:EntityMonster = MapModel.instance.monsters[name];
				this.createBubble(monster.mapGrid, "ui/home_42.png", "", "ui/icon_paopao05.png");
			}
		}
		
		private function hideYiZu():void {			
			
		}
		
		
		private function showQieCuo():void {			
			MapModel.instance.on(EventConstant.HERE_CATCH, this, onAddHeroCatchHandler);
			this.onAddHeroCatchHandler();
		}
		
		
		private function onAddHeroCatchHandler():void {
			if (this._selectIndex != QIE_CUO) return;
			this._content.removeChildren();
			for (var i:int = 0, len:int = MapModel.instance.heroCatch.length; i < len; i++) {
				var heroCatch:EntityHeroCatch = MapModel.instance.heroCatch[i];
				var sp:building_tips2UI = this.createBubble(heroCatch.mapGrid, null, heroCatch.name, "ui/icon_paopao02.png").ui;
				sp.mLabel.color = "#FFE96F";
			}
		}
		
		private function hideQieCuo():void {			
			MapModel.instance.off(EventConstant.HERE_CATCH, this, onAddHeroCatchHandler);
		}
		
		
		
		private function sortContent(content:Sprite):void {
			
			var arr:Array = [];
			for (var i:int = 0, len:int = content.numChildren; i < len; i++) {
				arr.push(content.getChildAt(i));
			}
			arr = ArrayUtils.sortOn(["y", "x"], arr, false, true);
			for (var j:int = 0, len2:int = arr.length; j < len2; j++) {
				Sprite(arr[j]).zOrder = j;
				content.addChild(arr[j]);
			}
		}
		
		
		private var fireDic:Object = {};		
		private function showFire():void {
			for (var name:String in MapModel.instance.citys) {
				var city:EntityCity = MapModel.instance.citys[name];
				if (city.fire) {
					this.onFireHandler(city);
				}				
				city.on(EventConstant.CITY_FIRE, this, this.onFireHandler);
			}
		}
		private function onFireHandler(city:EntityCity):void {
			if (!this.fireDic[city.cityId]) {				
				var bu:Animation = EffectManager.loadAnimation("mmap_battle");
				this.setGridPos(city.mapGrid, bu);
				this.fireDic[city.cityId] = bu;
				this._fireCotnent.addChild(bu);
			}			
			this.fireDic[city.cityId].visible = city.fire;			
			this.sortContent(this._fireCotnent);
		}
		private function hideFire():void {
			for (var name:String in MapModel.instance.citys) {
				var city:EntityCity = MapModel.instance.citys[name];		
				city.off(EventConstant.CITY_FIRE, this, this.onFireHandler);
			}
		}
		
		public function createBubble(grid:MapGrid, icon:String,txt:String = "", bg:String = null, uiClass:Class = null):Object {
			var bubble:Bubble = new Bubble(null);
			var sp:building_tips2UI = uiClass ? new uiClass() : new building_tips2UI();
			bubble.addChild(sp);
			sp.setBuildingTipsIcon2(icon, txt, bg);
			
			bubble.on(Event.CLICK, this, function(mapGrid:MapGrid):void {
				mapUI.click_closeScenes();
				MapCamera.lookAtGrid(mapGrid);
			}, [grid]);
			
			bubble.hitArea = new Rectangle(-sp.width / 2, -sp.height, sp.width, sp.height);
			
			this.setGridPos(grid, bubble);
			this._content.addChild(bubble);
			bubble.birthEffect();
			return {bu:bubble, ui:sp};
		}
		
		
		
		public function showType(type:int):void {			
			if (this._selectIndex == type) return;
			this._content.removeChildren();
			
			if (this.command[this._selectIndex]) {
				this.command[this._selectIndex].end.call(this);
			}
			
			this._selectIndex = type;
			if (this.command[type]) {
				(this.command[type]).start.call(this);				
				this.sortContent(this._content);
			}
		}

		public function get occupy():Sprite {
			return _occupy;
		}

		public function get fireCotnent():Sprite 
		{
			return _fireCotnent;
		}

		public function get scene():SceneMain {			
			return this._scene;
		}
		
	}

}