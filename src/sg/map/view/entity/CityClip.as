package sg.map.view.entity {
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.filters.ColorFilter;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.Pool;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import sg.guide.view.GuideFocus;
	import sg.home.view.ui.build.BuildInfo;
	import sg.home.view.ui.build.BuildingInfo;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.TestUtils;
	import sg.map.utils.Vector2D;
	import sg.map.view.CityFightBar;
	import sg.map.view.CityInfo1;
	import sg.map.view.CityInfo2;
	import sg.map.view.CityQueueHead;
	import sg.map.view.CityTroopBar;
	import sg.map.view.CityTroopView;
	import sg.map.view.MapViewMain;
	import sg.model.ModelCityBuild;
	import sg.model.ModelFTask;
	import sg.model.ModelOfficial;
	import sg.model.ModelTask;
	import sg.model.ModelTroop;
	import sg.model.ModelUser;
	import sg.model.ModelVisit;
	import sg.net.NetMethodCfg;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.scene.SceneMain;
	import sg.scene.constant.ConfigConstant;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.scene.constant.EventConstant;
	import sg.scene.view.Effect;
	import sg.scene.view.EventLayer;
	import sg.scene.view.MapCamera;
	import sg.scene.view.entity.EntityClip;
	import sg.scene.view.ui.Bubble;
	import sg.scene.view.ui.NoScaleUI;
	import sg.utils.Tools;
	import ui.com.building_tips2UI;
	import ui.com.building_tips8UI;
	import ui.com.country_flag1UI;
	import ui.com.country_flag2UI;
	import ui.home.HomeMenuItemUI;
	import ui.mapScene.CityInfo_0UI;
	import ui.mapScene.CityInfo_1UI;
	import ui.mapScene.CountryArmyIconUI;
	import ui.com.building_tips5UI;
	import sg.manager.AssetsManager;

	/**
	 * ...
	 * @author light
	 */
	public class CityClip extends EntityClip {
		
		private var fire:Effect;
		
		public var cityInfo:NoScaleUI;
		
		private var _inited:Boolean = false;
		
		public var visit:ModelVisit;
		
		public var queueHead:CityQueueHead;
		
		public var _bubble:Bubble;
		
		private var _cityTroopView:CityTroopView;
		
		private var _countryArmInfo:CountryArmyIconUI;
		
		public function CityClip(scene:SceneMain) {
			super(scene);			
		}
		
		override public function init():void {
			super.init();	
		}
		
		public function addTroop(troop:ModelTroop, effect:Boolean = true):void {
			if (troop.state == ModelTroop.TROOP_STATE_MOVE) return;
			if (!this._cityTroopView) {
				this._cityTroopView = new CityTroopView();
				this._cityTroopView.init(this);
				if(this.visible) ArrayUtils.push(this._cityTroopView, this._scene.bubbles);
			}
			troop.once(EventConstant.TROOP_MARCH_MOVE, this, this.removeTroop);
			this._cityTroopView.addTroop(troop);
			if(effect) this._cityTroopView.addChild(EffectManager.loadAnimation("glow040", "", 1));
		}
		
		public function removeTroop(troop:ModelTroop):void {
			if (this._cityTroopView) {
				this._cityTroopView.removeTroop(troop);
			}
		}
		
		private function init2():void {
			if (TestUtils.isTestShow){
				//this.print(this.entityCity.name + "\n" + this.entityCity.cityId);
				var cfg:Object = ConfigServer.city[this.entityCity.cityId];
				var troopStr:String = '\n[' + (cfg.troop as Array).join(',') + ']';
				//驿站，军营初始等级
				if (cfg.build){
					if (cfg.build.b03){
						troopStr += '\n驿' + cfg.build.b03;
					}
					if (cfg.build.b07){
						troopStr += '营' + cfg.build.b07;
					}
				}
				var faithCountry:int = this.entityCity.faithCountry;
				var color:String = faithCountry >= 0? ConfigServer.world.COUNTRY_FONT_STROKE_COLORS[faithCountry]: '#333333';
				this.print(this.entityCity.cityId + '\n' + this.entityCity.name + troopStr, false, color);
			}
			this.entityCity.on(EventConstant.CITY_FIRE, this, this.onCityFireHandler);
			this.entityCity.on(EventConstant.BUFF_CORPS, this, this.onBuffCorpsHandler);
			
			this.entityCity.on(ModelFTask.EVENT_UPDATE_FTASK, this, this.updateFtask);
			this.updateFtask();
			var res:String = this._entity.getParamConfig("res");
			var arr:Array = res.split("_");
			res = arr[0];
			
			var ani:Animation = EffectManager.loadAnimation(res, '', 0, null, "map");
			this._clip.addChild(ani);
			this._clip.x = this._scene.mapGrid.gridHalfW;
			this._clip.y = this._scene.mapGrid.gridHalfH;
			//_clip.addChild(new Effect().init({id:res, loop:true}));
			
			if (arr.length > 1) {
				ani.scaleX *= -1;
			}
			
			this.draw(this._entity.width, this._entity.height);
			
			this.onCityFireHandler(null);
			this.onBuffCorpsHandler();
			
			//拜访
			this.checkVisit();
			//建筑
			var builds:Array = ModelCityBuild.cityBuildModels[this.entityCity.cityId.toString()];			
			for each (var item:ModelCityBuild in builds) {				
				this.addQueueHead(item);
			}
			
			//政务
			this.changeGtask();
			
			for each (var troop:ModelTroop in this.entityCity.getTroop([ModelTroop.TROOP_STATE_IDLE, ModelTroop.TROOP_STATE_MONSTER])) {
				this.addTroop(troop, false);
			}
			//攻城守城令
			var countryBuff:Array = MapViewMain.instance.token.citys[this.entityCity.cityId.toString()];
			if (countryBuff) {
				for (var i:int = 0, len:int = countryBuff.length; i < len; i++) {
					MapViewMain.instance.setCityBuff(countryBuff[i], this);
				}
				
			}
			
			
			
			
			//驻军部队
			this.entityCity.on(EventConstant.TROOP_CREATE, this, this.addTroop);
			this.entityCity.on(EventConstant.TROOP_REMOVE, this, this.removeTroop);			
		}
		
		private var buffCorps:Effect;
		private static const qiziPos:Object = {"map002":new Point(-45, -10), "map003":new Point( -46, -10), "map004":new Point(-68 , -10), "map005":new Point(-79, -12), "map006":new Point(-30 , 0), "map007":new Point(-145, -20), "map008":new Point(-137, -20), "map009":new Point(-151, -30), "map010":new Point(-150, -30)};
		private function onBuffCorpsHandler():void {
			Tools.destroy(this.buffCorps);			
			var res:String = String(this.entityCity.getParamConfig("res")).replace("_", "");
			var p:Point = CityClip.qiziPos[res];
			if (!p) return;
			if (this.entityCity.buff_corps) {
				this.buffCorps = new Effect().init({id:"glow051", loop:true});
				this._clip.addChildAt(this.buffCorps, 0);
				this.buffCorps.x = p.x;
				this.buffCorps.y = p.y;
			}
		}
		
		public function checkVisit():void {
			//v1 拜访是永远都存在的 所以 存到这个类里面。
			//v2 又得到需求不是永远存在的 所以打一个补丁 加一个remove
			var visit:ModelVisit = ModelVisit.visitModels[this.entityCity.cityId.toString()];
			if (visit) {
				this.visit = visit;
				this.visit.on(ModelVisit.EVENT_UPDATE_VISIT, this, this.onVisitChange);
				this.visit.on(ModelVisit.EVENT_REMOVE_VISIT, this, this.onVisitChange);
				this.onVisitChange();
			}
		}
		
		public function changeGtask():void {
			var type:String = ModelTask.gTaskByCityGetType(this.entityCity.cityId.toString());

			if (type) {
				this.addBubble("gtask", {ui:building_tips2UI, icon:"ui/home_40.png"});
			} else {
				this.clearBubble("gtask");
			}
		}
		
		private function addBubble(type:String, data:Object):Bubble {
			if(this._bubble) this.clearBubble(this._bubble.name);
			this._bubble = new Bubble(this);
			this._bubble.x = this.entity.x;
			this._bubble.y = this.entity.y - 74 / 2;// - this.entity.height / 2;			
			this._bubble.on(Event.CLICK, this, this.onBubbleHandler);
			this._bubble.name = type;
			this._bubble.setData(data);
			return this._bubble;
		}
		
		private function onBubbleHandler(e:Event):void {
			switch(this._bubble.name) {
				case "ftask":
					if (this.entityCity.ftask) this.entityCity.ftask.click();
					break;
				case "gtask":
					var type:String = ModelTask.gTaskByCityGetType(this.entityCity.cityId.toString());
					if (type == ModelTask.GTASK_TYPE_GTASK_COLLECT) {
						if(this.entityCity.gtask) MapCamera.lookAtGrid(this.entityCity.gtask.mapGrid, 500);
					} else {
						this.onClick();
						var menus:Array = this._scene.mapLayer.menu.menus.filter(function(item:HomeMenuItemUI, index:int, arr:Array):Boolean{
							return item.name == "61" || item.name == "3";
						});
						if (menus.length) {
							var menuItem:HomeMenuItemUI = menus[menus.length - 1];
							GuideFocus.focusIn(menuItem, new Rectangle(4, 4, 58, 58));
						}						
					}
					break;
				case "gold":
					ViewManager.instance.showView(ConfigClass.GOLD_CITY_PANEL);
					break;
				case "xyz":
					//ViewManager.instance.showView(ConfigClass.GOLD_CITY_PANEL);
					ViewManager.instance.showView(ConfigClass.VIEW_OVERLORD);
					break;
				// case "yaosai":
				// 	ModelBlessHero.instance.onClickCity(entityCity.cityId);
				// 	break;
			}
		}
		
		private function clearBubble(n:String):void {
			if (this._bubble && this._bubble.name == n) {
				Tools.destroy(this._bubble);
				this._bubble = null;
			}
		}
		
		public function addQueueHead(model:*):void {
			if (!this.queueHead){
				this.queueHead = new CityQueueHead();
				this.addChild(this.queueHead);
				this.queueHead.x = MapModel.instance.mapGrid.gridHalfW;
				this.queueHead.y = MapModel.instance.mapGrid.gridHalfH;
				this.queueHead.resize();
			}
			this.queueHead.addItem(model);
		}
		
		private function onVisitChange():void {
			if (this.visit.status == 0 || this.visit.status == 3) {
				this.addQueueHead(this.visit);		
			}else {
				if(this.queueHead) this.queueHead.removeItem(this.visit);
			}

			if(this.cityInfo && this.cityInfo.name == "cityInfo2"){
				if(this.visit) (this.cityInfo as CityInfo2).setHeroIconGray(this.visit.status == 2);
			}
		}
		
		
		private function updateFtask():void {
			if (this.entityCity.ftask) {
				var state:int = this.entityCity.ftask.status;
				var dataObj:Object = null;
				
				//0 待接取（新民情） 1 领取(...)   2 完成（？）  3 全部完成/没有民情呢（空）
				switch(state) {
					case 3:
						this.clearBubble("ftask");
						break;
					case 0:
						if(!entityCity.myCountry){
							this.clearBubble("ftask");
						} else {
							dataObj = {ui:building_tips8UI, icon:"ui/home_05.png", gray:!this.entityCity.ftask.is_can_do, handlerValue:{"topIcon_img":function(img:Image):void {
								img.skin = "ui/icon_paopao4.png";
								img.visible = true; 
								
							}}};
						}
						break;
					case 1:
						dataObj = {ui:building_tips8UI, icon:"ui/home_47.png", handlerValue:{"topIcon_img":function(img:Image):void {img.visible = false; }}};
						break;
					case 2:
						dataObj = {ui:building_tips8UI, icon:this.entityCity.ftask.itemIcon[0], handlerValue:{"topIcon_img":function(img:Image):void {
							img.skin = "ui/icon_paopao2.png";
							img.visible = true; 
							
						}}};
						break
				}
				
				if(dataObj) this.addBubble("ftask", dataObj);
				
			} else {
				this.clearBubble("ftask");
			}
		}
		
		public function clearCityUI():void {
			if (this.cityInfo) {
				this.cityInfo.removeSelf();
				Pool.recover(this.cityInfo.name, this.cityInfo);
				ArrayUtils.remove(this.cityInfo, this._scene.bubbles);
				this.cityInfo = null;
			}
			
			if (this._countryArmInfo) {
				this._countryArmInfo.removeSelf();
				Pool.recover(this._countryArmInfo.name, this._countryArmInfo);
				this.cityInfo = null;
			}
		}
		
		public function setCityUI():void {
			this.clearCityUI();
			var entity:EntityCity = this.entityCity;
			if (this.isLittleUI) {//要塞	
				this.cityInfo = Pool.getItemByClass("cityInfo1", CityInfo1);				
				this.cityInfo.initScene(this._scene);
				this.cityInfo.name = "cityInfo1";
				CityInfo1(this.cityInfo).init(this);				
			} else {
				this.cityInfo = Pool.getItemByClass("cityInfo2", CityInfo2);	
				this.cityInfo.initScene(this._scene);	
				this.cityInfo.name = "cityInfo2";
				CityInfo2(this.cityInfo).init(this);
				if(this.visit) (this.cityInfo as CityInfo2).setHeroIconGray(this.visit.status == 2);
			}
			//this.cityInfo.zoomWithParent = true;
			this.cityInfo.x = this.entity.x;
			this.cityInfo.y = this.entity.y + this.entity.height / 2;	
			
			this._scene.mapLayer.infoLayer.addChild(this.cityInfo);
			//this.cityInfo.resize();
			//ArrayUtils.push(this.cityInfo, this._scene.bubbles);
			//不是我的城池 要加气泡。
			if (this.entityCity.cityType == 4 && !this.entityCity.myCountry) {
				this._bubble ||= this.addBubble("gold", {ui:building_tips2UI, icon:"ui/img_icon_09_big.png"});
			} else {
				this.clearBubble("gold");
			}
			//单独的襄阳站
			if (this.entityCity.cityId == -1) {				
				ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_HIDE_XYZ, this, this.changeXYZ);
				ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_SHOW_XYZ, this, this.changeXYZ);
				this.changeXYZ();
			}
			
			// 福将挑战气泡
			// this.updateBlessBubble();
			// if (ModelBlessHero.instance.cids.indexOf(entityCity.cityId) !== -1) {
			// 	ModelBlessHero.instance.on(ModelBlessHero.UPDATE_DATA, this, this.updateBlessBubble);
			// }
			
			
			//先判断是否是护国军城池。
			if (ModelUser.isHaveCountryArmy() && this.entityCity.faithCountry != this.entityCity.country && ConfigServer.country_army[this.entityCity.faithCountry.toString()]) {
				var target_citys:Array = ConfigServer.country_army[this.entityCity.faithCountry.toString()]["target_city"];
				var cityId:String = this.entityCity.cityId.toString();
				//满足护国军的城池。
				if (target_citys.some(function(a:Array):Boolean{return a[a.length - 1] == cityId})) {
					this._countryArmInfo = Pool.getItemByClass("countryArmInfo", CountryArmyIconUI);
					this._scene.mapLayer.infoLayer.addChild(this._countryArmInfo);
					this._countryArmInfo.icon.filters = [new ColorFilter(ConfigServer.world.COUNTRY_COLOR_WHITE_FILTER_MATRIX[this.entityCity.faithCountry])];
					this._countryArmInfo.x = this.entity.x - 100;
					this._countryArmInfo.y = this.entity.y + this.entity.height / 2 - 85;	
					//这个代表护国军正在进发！
					this.checkCountryArmy();
					this.timerLoop(1000, this, this.checkCountryArmy)
				}
			}
			
		}
		
		private function checkCountryArmy():void {
			if (!this._countryArmInfo) return;
			var cityId:String = this.entityCity.cityId.toString();
			if (this.entityCity.countryArms.length) {
				this._countryArmInfo.info_txt.text = Tools.getMsgById("500054", [Tools.getMsgById("country_" + this.entityCity.faithCountry)]);
				this._countryArmInfo.visible = true;
			} else {//判断是否要显示 not_belong_country
				var data:Object = ModelUser.getCountryArmyAriseTime() || {};
				var o:Array = data[cityId];	
				var not_belong_country:Number = ModelOfficial.cities[cityId]["not_belong_country"][this.entityCity.faithCountry];
				//if (!not_belong_country || ConfigServer.getServerTimer() / 1000 - not_belong_country > 3600) {//判断是否到时间											
					this._countryArmInfo.visible = o != null;
					if (o) {						
						this._countryArmInfo.info_txt.text = Tools.getTimeStyle(Tools.getToDayHourMill(o) - ConfigServer.getServerTimer(), 2);
					}
				//}
			}
		}
		
		private function changeXYZ():void {
			if (parseInt(this.entityCity.cityId.toString()) == -1 && !ModelManager.instance.modelCountryPvp.checkActive() && !ModelManager.instance.modelCountryPvp.checkAfficheMerge() && ((ConfigServer.country_pvp.merge == 1 && ModelManager.instance.modelUser.isMerge) || ConfigServer.country_pvp.merge == 0)) {
				this._bubble ||= this.addBubble("xyz", {ui:building_tips2UI, icon:"ui/icon_paopao47.png"});
			} else {
				this.clearBubble("xyz");
			}
		}

		// private function updateBlessBubble():void {
		// 	var data:Object = ModelBlessHero.instance.getClipData(entityCity.cityId);
		// 	if (data) {
		// 		this._bubble ||= this.addBubble("yaosai", {type:0, ui:building_tips5UI, heroId: data.hid, flagText: Tools.getMsgById('bless_hero_13'), flagBg: AssetsManager.getAssetsUI('img_icon_39.png')});
		// 		var icon:* = this._bubble.getChildByName('icon');
		// 		if (icon) {
		// 			var bg:Image = icon.getChildByName('bg');
		// 			bg && (bg.skin = AssetsManager.getAssetsUI('icon_paopao07.png'));
		// 		}
		// 	} else {
		// 		this.clearBubble("yaosai");
		// 	}
		// }
		
		
		public override function show():void {
		
			if (MapCamera.fast) {
				this.visible = false;
				this._scene.once(EventConstant.SPEED_LOW, this, this.show);
				return;				
			}
			super.show();
			if (!this._inited) {
				this._inited = true;
				this.init2();
			}
			this.visible = true;
			
			if (this._bubble) {
				ArrayUtils.push(this._bubble, this._scene.bubbles);
				this._bubble.resize();
				this._bubble.visible = true;
			}
			
			if (this._cityTroopView) {
				ArrayUtils.push(this._cityTroopView, this._scene.bubbles);
				this._cityTroopView.visible = true;
				this._cityTroopView.resize();
			}
			
			if (this.fire) this.fire.visible = true;
			this.setCityUI();
			if(this.queueHead) ArrayUtils.push(this.queueHead, this._scene.bubbles);
		}
		
		public override function hide():void {		
			super.hide();
			this.visible = false;
			if (this._bubble){
				ArrayUtils.remove(this._bubble, this._scene.bubbles);
				this._bubble.visible = false;
			}
			
			if (this._cityTroopView) {
				ArrayUtils.remove(this._cityTroopView, this._scene.bubbles);
				this._cityTroopView.visible = false;
			}
			
			this._scene.off(EventConstant.SPEED_LOW, this, this.show);
			this.clearCityUI();
			if (this.queueHead) ArrayUtils.remove(this.queueHead, this._scene.bubbles);
			if (this.fire) this.fire.visible = false;
		}
		
		
		
		private function onCityFireHandler(e:EntityCity):void {			
			Tools.destroy(this.fire);
			this.fire = null;
			if (this.entityCity.fire) {
				this.fire = new Effect().init({id:this.entityCity.getParamConfig("fireRes") || "building_fire", loop:true});
				
				MapViewMain.instance.mapLayer.addChild2(this.fire, EventLayer.EFFECT_LAYER, this.entityCity.mapGrid);
				
				var size:Number = Math.pow(this.entityCity.size, 0.7);
				if (this.entityCity.cityType == 0){
					size *= 0.7;
				}
				this.fire.scale(size, size);	
			}
			if(this.visible) this.setCityUI();
		}
		
		public function addChildToCenter(display:Sprite, offset:Vector2D = null):void {
			offset ||= Vector2D.ZERO;
			this.addChild(display);
			display.x = this._scene.mapGrid.gridHalfW + offset.x;
			display.y = this._scene.mapGrid.gridHalfH + offset.y;
		}
		
		override public function containsPos(screenX:Number, screenY:Number):Boolean {
			var clickRect:Array = this.entityCity.getParamConfig("rect");
			if (clickRect) {				
				var rect:Rectangle = new Rectangle(this.entityCity.x + clickRect[0], this.entityCity.y + clickRect[1], clickRect[2], clickRect[3]);
				return rect.contains(screenX, screenY);
			}
			return super.containsPos(screenX, screenY);
		}
		
		override public function onClick():void {
			super.onClick();
			//var v4:Object = {visible:false,label:"",type:4,gray:false,icon:""};
			var r:Number = 0;
			
			_scene.mapLayer.menu.cityBar.hide();
			if (this.isLittleUI){
				_scene.mapLayer.menu.cityBar.pos(0, this.entity.height / 2 - 9 + 10);
				r = this.entityCity.height / 2 + 65;
			} else {
				_scene.mapLayer.menu.cityBar.pos(0, this.entity.height / 2 - 7 + 10);
				r = this.entityCity.height / 2 + 95;
			}
			
			this._scene.mapLayer.menu.showMenu(this, MapViewMain.instance.getMenu(this.entityCity), r, new Point(this._scene.mapGrid.gridHalfW, this._scene.mapGrid.gridHalfH));
			
			
			NetSocket.instance.send(NetMethodCfg.WS_SR_GET_CITY_INFO,{cid:entityCity.cityId, is_simple:true},Handler.create(this,function (re:NetPackage):void {				
				if (!_destroyed && _scene) {
					_scene.mapLayer.menu.cityBar.updateData(re.receiveData, this.entity.height);
				}
			}));
		}
		
		private function get isLittleUI():Boolean {
			var entity:EntityCity = this.entityCity;
			return entity.cityType == ConfigConstant.CITY_TYPE_FORT || entity.cityType == ConfigConstant.CITY_TYPE_CAMP || entity.cityType == ConfigConstant.CITY_TYPE_GATE;
		}
		
		override public function draw(w:Number, h:Number):void {
			if (!TestUtils.isTestShow) return;
			var rect:Array = this.entityCity.getParamConfig("rect");
			if (rect) {
				this._line ||= new Sprite();
				this._line.graphics.drawRect(rect[0], rect[1], rect[2], rect[3], null, "#000000", 2);
				this._line.x = MapModel.instance.mapGrid.gridHalfW;
				this._line.y = MapModel.instance.mapGrid.gridHalfH;
				this.addChild(_line);
			} else {
				super.draw(w, h);
				this._line.x = MapModel.instance.mapGrid.gridHalfW;
				this._line.y = MapModel.instance.mapGrid.gridHalfH;
			}
			
		}
		
		
		public function get entityCity():EntityCity {
			return this.entity as EntityCity;
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			this.entityCity.off(EventConstant.CITY_FIRE, this, this.onCityFireHandler);
			this.entityCity.off(EventConstant.BUFF_CORPS, this, this.onBuffCorpsHandler);
			this.entityCity.off(ModelFTask.EVENT_UPDATE_FTASK, this, this.updateFtask);
			if (this.visit) {
				this.visit.off(ModelVisit.EVENT_UPDATE_VISIT, this, this.onVisitChange);
				this.visit.off(ModelVisit.EVENT_REMOVE_VISIT, this, this.onVisitChange);
			}
			
			if (this.entityCity.cityId == -1) {				
				ModelManager.instance.modelOfficel.off(ModelOfficial.EVENT_HIDE_XYZ, this, this.changeXYZ);
				ModelManager.instance.modelOfficel.off(ModelOfficial.EVENT_SHOW_XYZ, this, this.changeXYZ);
				this.changeXYZ();
			}

			
			// if (ModelBlessHero.instance.cids.indexOf(entityCity.cityId) !== -1) {
			// 	ModelBlessHero.instance.off(ModelBlessHero.UPDATE_DATA, this, this.updateBlessBubble);
			// 	this.updateBlessBubble();
			// }
			
			this.entityCity.off(EventConstant.TROOP_CREATE, this, this.addTroop);
			this.entityCity.off(EventConstant.TROOP_REMOVE, this, this.removeTroop);
			Tools.destroy(this.queueHead);
			Tools.destroy(this._cityTroopView);
			this.entityCity.view = null;
			super.destroy(destroyChild);
		}
		
		override public function reset():void {
			super.reset();
			if (this.visible) {				
				 MapModel.instance.event(EventConstant.CITY_DETECT, [this.entityCity]);
				 this.entityCity.event(EventConstant.CITY_DETECT);
			}
		}
	}

}