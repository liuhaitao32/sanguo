package sg.map.view {
	import PathFinding.core.Util;
	import laya.display.Animation;
	import laya.html.dom.HTMLDivElement;
	import laya.net.LocalStorage;
	import laya.ui.Image;
	import laya.utils.Tween;
	import sg.boundFor.GotoManager;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import sg.explore.model.ModelTreasureHunting;
	import sg.fight.FightMain;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.edit.TestFlag;
	import sg.map.model.entitys.EntityFtask;
	import sg.map.model.entitys.EntityHeroCatch;
	import sg.map.model.entitys.EntityMonster;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.MapUtils;
	import sg.map.utils.Math2;
	import sg.map.utils.TestUtils;
	import sg.map.utils.Vector2D;
	import sg.map.view.entity.HeroCatchClip;
	import sg.map.view.entity.ThiefClip;
	import sg.map.view.miniMap.MiniMap0;
	import sg.model.ModelCityBuild;
	import sg.model.ModelEstate;
	import sg.model.ModelFightTask;
	import sg.model.ModelGame;
	import sg.model.ModelHero;
	import sg.model.ModelOfficial;
	import sg.model.ModelPrepare;
	import sg.model.ModelTroop;
	import sg.model.ModelUser;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.scene.constant.EventConstant;
	import sg.scene.model.MapGrid;
	import sg.map.model.MapModel;
	import sg.map.model.astar.AStarFind;
	import laya.display.Sprite;
	import laya.map.MapLayer;
    import laya.map.TiledMap;
	import laya.events.Event;
	import laya.maths.Point;
    import laya.maths.Rectangle;
    import laya.utils.Browser;
	import laya.utils.Dictionary;
    import laya.webgl.WebGL;
	import laya.utils.Handler;
	import laya.display.Text;
	import laya.utils.Stat;
	import sg.map.edit.EditManager;
	import sg.map.model.entitys.EntityCity;
	import sg.scene.constant.ConfigConstant;
	import sg.map.model.entitys.EntityMarch;
	import sg.scene.model.entitys.EntityBase;
	import sg.scene.view.EventLayer;
	import sg.map.view.IsoObject;
	import sg.map.edit.IsoTile;
	import sg.map.view.entity.CityClip;
	import sg.scene.view.MarchPathManager;
	import sg.scene.view.TestButton;
	import sg.scene.view.entity.EntityClip;
	import sg.map.view.entity.MarchClip;
	import sg.scene.SceneMain;
	import sg.scene.view.InputManager;
	import sg.scene.view.MapCamera;
	import sg.net.NetMethodCfg;
	import sg.model.ModelTask;
	import sg.utils.MusicManager;
	import sg.utils.StringUtil;
	import sg.utils.Tools;
	import sg.view.map.ViewCityBuildMain;
	import sg.model.ModelClimb;
	import sg.view.task.ViewFTaskTest;
	import sg.model.ModelVisit;
	import sg.model.ModelOffice;
	import sg.manager.LoadeManager;
	import sg.view.countryPvp.ViewBuildCar;
	
	/**
	 * 视图的主类
	 * @author light
	 */
	public class MapViewMain extends SceneMain {
		
		public var editManager:EditManager;
		
		
		public static var instance:MapViewMain;
		
		public var renderCity:Array = [];
		
		public var miniMap0:MiniMap0;
		
		
		public var estateViews:Object = {};//产业哦！
		
		public var troopAnimation:TroopAnimation = new TroopAnimation();
		
		public var token:Object = {token:{buff_country3:[null, null, "flag_attack"], buff_country4:[null, null, "flag_defense"], buff_fight_task_1:[null, null, this.createBuff, this.checkPos], buff_fight_task_2:[null, null, this.createBuff, this.checkPos]}, citys:{}};
		
		private function checkPos(city:CityClip, buffClip:Sprite):void {
			var v:Vector2D = city.toScreenPos();
			buffClip.pos(v.x, v.y - (city.entityCity.height) * 0.8);
		}
		
		private function createBuff(cid:String, type:String):Sprite {
			var sp:Sprite = new Sprite();
			var entity:EntityCity = MapModel.instance.citys[cid];
			switch(type) {
				case "buff_fight_task_1":
				case "buff_fight_task_2":
					var ani1:Sprite = EffectManager.loadAnimation("glow_fight_task");
					var ani2:Sprite = EffectManager.loadAnimation("glow_fight_task_1");
					sp.addChild(ani1);
					sp.addChild(ani2);
					ani1.blendMode = "lighter";
					ani1.scale(0.5, 0.5);
					ani2.scale(0.5, 0.5);
					var size:Number = Math2.range(entity.size * 0.7, 3, 1);
					sp.scale(size, size);
					break;
			}
			
			return sp;
		}
		
		public function setCityBuff(countryBuff:String, city:CityClip):void {
			this.mapLayer.topLayer.addChild(this.token.token[countryBuff][1]);			
			if (this.token.token[countryBuff][3]) {
				this.token.token[countryBuff][3](city, this.token.token[countryBuff][1]);
			} else {
				var v:Vector2D = city.toScreenPos();
				this.token.token[countryBuff][1].pos(v.x, v.y - Math.max(city.entityCity.height - 72, 0) * 0.3);
			}
		}
		
		public function MapViewMain() {			
			instance = this;
			this.type = SceneMain.MAP;
			if (!ConfigApp.isPC) {
				this.tMap.limitRect.setTo( -64, 30, 0, 40);
			} else {
				this.tMap.limitRect.setTo( -64, 30 - 80, 0, 40 - 80);
			}
			
			
			
			
			this.minScale = 0.6;
			this.maxScale = 1;
			this.mapGrid = MapModel.instance.mapGrid;
			if (ConfigConstant.isEdit) {
				this.editManager = new EditManager();
				LoadeManager.loadImg("edit.txt", new Handler(this, function():void {
					var preStr:String = Laya.loader.getRes("edit.txt");				
					if(preStr == null) {
						preStr = LocalStorage.getItem("editMap");
					}				
					if(preStr != null) {
						var obj:Object = JSON.parse(preStr);
						editManager.floorData = obj.floor;
						editManager.cityCount = obj.cityCount;
						editManager.cityData = obj.cityData;
						editManager.daoluData = obj.path;
					}
					
					
					if (ConfigConstant.isEdit) editManager.init();
					initScene("map/map");
				}));
				return;
					
			}
			
			
			this.initScene("map/map");
			TestButton.init();
			this.timerLoop(1000, this, this.checkTopVisible);
			
			this.on(EventConstant.SPEED_LOW, this, this.checkTopVisible);
			
		}
		
		private function addBuildHandler(e:ModelCityBuild):void {
			var entityCity:EntityCity = MapModel.instance.citys[parseInt(e.city_id)];
			if (entityCity.view) CityClip(entityCity.view).addQueueHead(e);
		}
		
		private function addEstateHandler(e:ModelEstate):void {
			var clip:EstateClip = this.estateViews[e.city_id + "_" + e.config_index];
			if (clip) {
				clip.model = e;
			}
		}
		
		override protected function onClickHandler(e:Event):void {
			
			//disX = 20 * (Math.random() > 0.5 ? -1 : 1);
			//disY = 20 * (Math.random() > 0.5 ? -1 : 1);
			//this.frameLoop(1, this, this.moving, null);
			if (ConfigConstant.isEdit || !this.visible || !this.mouseEnabled) return;
			var screenX:Number = e.stageX;// ;
			var screenY:Number = e.stageY;// - HomeModel.instance.mapGrid.gridHalfH;
			screenX = screenX / this.tMap.scale - this.tMap.viewPortX - this.mapGrid.gridHalfW;
			screenY = screenY / this.tMap.scale - this.tMap.viewPortY - this.mapGrid.gridHalfH;
			
			this.mapLayer.getTilePositionByScreenPos(e.stageX, e.stageY, Point.TEMP);
			var grid:MapGrid = MapModel.instance.mapGrid.getGrid(Point.TEMP.x, Point.TEMP.y);
			if (grid) {
				var clickView:EntityClip;
				var clickEntitys:Array = [ConfigConstant.ENTITY_MONSTER, ConfigConstant. ENTITY_FTASK, ConfigConstant.ENTITY_CITY];
				
				for (var i:int = 0, len:int = clickEntitys.length; i < len; i++) {
					var arr:Array = grid.getEntitysByType(clickEntitys[i], "clickEntitys");
					for (var j:int = 0, len2:int = arr.length; j < len2; j++) {
						if (EntityBase(arr[j]).view && EntityBase(arr[j]).view.containsPos(screenX, screenY)){
							EntityBase(arr[j]).view.onClick();
							clickView = EntityBase(arr[j]).view;
							return;
						}
					}
					
				}
				
				//切磋 政务
				var cityTile:Array = [ConfigConstant.ENTITY_HERO_CATCH, ConfigConstant.ENTITY_GTASK];
				for (i = 0, len = cityTile.length; i < len; i++) {
					var entity:EntityBase = grid.getEntitysByType(cityTile[i])[0];	
					if (entity) {
						entity.view.onClick();
						clickView = entity.view;
						return;
					}
				}
				
				
				
				var occupy:EntityCity = grid.occupyCity;
				if (occupy) {
					var occupyData:Object = occupy.occupyTile[grid.col + "_" + grid.row];
					if (occupyData) {
						if (occupyData.type == ConfigConstant.ENTITY_ESTATE) {
							var estateClip:EstateClip = this.estateViews[occupy.cityId + "_" + occupyData.index];
							if (estateClip) {
								estateClip.onClick();
								clickView = estateClip;
								return;
							}
							
						} else if (occupyData.type == ConfigConstant.ENTITY_XIAN_HE) {							
							
						} else if (occupyData.type == ConfigConstant.ENTITY_CHANG_CHENG) {							
							
						}
					}
				}
				
				//MapCamera.lookAtGrid(grid, false, 500);
			}
		}
		
		private var disX:Number = 0;
		private var disY:Number = 0;
		
		private function moving():void {
			var moveX:Number = ( -this.tMap.viewPortX - (disX) / this.tMap.scale);
			var moveY:Number = ( -this.tMap.viewPortY - (disY) / this.tMap.scale);
			//移动地图视口
			MapCamera.move(moveX, moveY);
		}
		
		private function onCreateMarchHandler(march:EntityMarch):void {
			var m:MarchClip = new MarchClip(this);
			march.view = m;
			m.entity = march;
			m.init();
		}
		
		public function checkTopVisible():void {
			if(this.tMap){
				var centerX:Number = this.tMap._viewPortX + Laya.stage.width / this.tMap.scale / 2;
				var centerY:Number = this.tMap._viewPortY + Laya.stage.height / this.tMap.scale / 2;
				var radius:Number = Math.pow((Math.max(Laya.stage.width, Laya.stage.height) + 200) / this.tMap.scale / 2, 2);
				for (var i:int = 0, len:int = this.mapLayer.topLayer.numChildren; i < len; i++) {
					var sp:Sprite = Sprite(this.mapLayer.topLayer.getChildAt(i))
					sp.visible = Math.pow(sp.x - centerX, 2) + Math.pow(sp.y - centerY, 2) < radius;
				}
			}
		}
		
		protected override function initMap():void {
			super.initMap();		
			this.mapLayer.menu.cityBar = new CityBar();
			for (var name:String in MapModel.instance.marchs) {
				var march:EntityMarch = MapModel.instance.marchs[name];
				this.onCreateMarchHandler(march);
			}
			if (ConfigConstant.isEdit) return;
			
			this.miniMap0 = new MiniMap0();
			//TestUtils.drawTest(this.miniMap);
			this.miniMap0.pos(2, 0);
			ViewManager.instance.mLayerMenu.view_user.boxMap.addChild(this.miniMap0);
			//ViewManager.instance.mLayerMenu.view_user.testMap.addChild(this.miniMap0);
			this.miniMap0.init();
			
			MapCamera.lookAtGrid(MapModel.instance.getCapital(ModelUser.getCountryID()).mapGrid);
			
			
			
			MapModel.instance.on(EventConstant.THIEF, this, this.checkThief);			
			ModelManager.instance.modelGame.on(ModelGame.EVENT_ADD_ESTATE, this, this.addEstateHandler);			
			MapModel.instance.on(EventConstant.MARCH_CREATE, this, this.onCreateMarchHandler);
			ModelManager.instance.modelGame.on(ModelCityBuild.EVENT_ADD_CITY_BUILD, this, this.addBuildHandler);
			ModelManager.instance.modelGame.on(ModelVisit.EVENT_INIT_VISIT, this, this.udpateVisit);
			ModelManager.instance.modelGame.on(ModelGame.EVENT_TASK_WORK_GET_OR_DEL, this, this.gtaskChange);
			ModelManager.instance.modelGame.on(EventConstant.UPDATE_BUILD, this, this.updateBuild);
			ModelManager.instance.modelGame.on(ModelGame.EVENT_BUFFS_ORDER_3_4_CHANGE, this, this.tokenChange);
			ModelManager.instance.modelGame.on(ModelGame.EVENT_BUFFS_ORDER_5_CHANGE, this, this.buffsOder5Change);
			ModelFightTask.instance.on(ModelFightTask.FIGHT_TASK_CHANGE, this, this.tokenChange);
			
			ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_SHOW_GOLD_ESTATE, this, this.updateGoldEstate);
			ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_HIDE_GOLD_ESTATE, this, this.updateGoldEstate);
			
			ModelManager.instance.modelGame.on(ModelGame.EVENT_MAYOR_UDPATE, this, this.updateCity);
			
			ModelManager.instance.modelUser.on(EventConstant.HERE_CATCH_DIE, this, this.onDeadHeroCatch);
			
			ModelManager.instance.modelGame.on(ModelGame.EVENT_SHOW_BALLISTA_MSG, this, this.onShowBallistaMsg);

			ModelManager.instance.modelGame.on(ModelGame.EVENT_CLICK_ARENA_CLIP, this, this.clickArena);
			
			MapModel.instance.checkThief(null);
			this.tokenChange(null);
			this.buffsOder5Change();
			MusicManager.playMusic(MusicManager.BG_MAP);
			
			
			//TestFlag.init();
		}
		
		private function onShowBallistaMsg(country:int, countryName:String, troopName:String):void {
			var cityId:int = ( -country - 10);
			var str:String = Tools.getMsgById("500031", [countryName, troopName]);
			var cityEntity:EntityCity = MapModel.instance.citys[cityId];
			if (!cityEntity.view || !cityEntity.view.visible) return;
			//飘字
			var popText:Sprite = new PopText(str, [], "#ffffff");
			
			this.mapLayer.effectLayer.addChild(popText);
			var p:Vector2D = cityEntity.view.toScreenPos();
			popText.pos(p.x, p.y);
		}
		
		private function updateGoldEstate(estates:Array):void {
			for (var name:String in this.estateViews) {
				var view:EstateClip = this.estateViews[name];
				view.changeGold();
			}
		}
		
		private function updateCity(cid:String):void {
			var cityClip:CityClip = MapModel.instance.citys[cid].view;
			if (cityClip && !cityClip.destroyed && cityClip.visible) {
				cityClip.setCityUI();
			}
		}
		private var buff5:Array = [];
		private function buffsOder5Change():void {
			for (var i:int = 0, len:int = this.buff5.length; i < len; i++) {
				Sprite(this.buff5[i]).removeSelf();
			}
			
			var arr:Array = ModelOfficial.getBuff5Arr();
			for (var j:int = 0, len2:int = arr.length; j < len2; j++) {
				var entityCity:EntityCity = MapModel.instance.citys[arr[j]];
				//if (entityCity.view && !entityCity.view.destroyed) {
					var v:Vector2D = entityCity.mapGrid.toScreenPos();
					this.buff5[j] ||= EffectManager.loadAnimation("glow046");
					var ani:Animation = this.buff5[j];
					ani.zOrder = 101;
					this.mapLayer.topLayer.addChild(ani);
					ani.pos(v.x, v.y);
					ani.scale(entityCity.size * 0.45, entityCity.size * 0.45);
					ani.play();					
				//}				
												
			}
		}
		
		private function onDeadHeroCatch(cityId:String):void {
			for (var i:int = 0, len:int = MapModel.instance.heroCatch.length; i < len; i++) {
				if (EntityHeroCatch(MapModel.instance.heroCatch[i]).city.cityId == parseInt(cityId)) {
					var view:HeroCatchClip = EntityHeroCatch(MapModel.instance.heroCatch[i]).view as HeroCatchClip;
					if (view && !view.destroyed) {
						view.showDead();
					}
				}
			}
		}
		
		private function tokenChange(cc:String):void {
			var token:Object = this.token.token;
			this.token.citys = {};
			for (var name:String in token) {
				var cid:String = ModelOfficial.checkBuffStatus2(name);
				token[name][0] = cid;
				if (cid) {
					this.token.citys[cid] ||= [];
					ArrayUtils.push(name, this.token.citys[cid]);
					if (!token[name][1]) {
						var ani:Animation = token[name][2] is String ? EffectManager.loadAnimation(token[name][2]) : token[name][2].call(this, cid, name);
						ani.zOrder = 100;
						token[name][1] = ani;
					}
					//当前改变了重新添加。 没显示出来view 就先隐藏掉。
					var cityClip:CityClip = MapModel.instance.citys[cid].view;
					if (cityClip) {
						this.setCityBuff(name, cityClip);
					} else {
						Animation(token[name][1]).removeSelf();
					}
					
				} else {
					if (token[name][1]) {
						Animation(token[name][1]).removeSelf();
						//Animation(token[name][1]).stop();
					}
				}
			}
		}
		
		private function updateBuild(obj:Object):void {
			var cityEntity:EntityCity = MapModel.instance.citys[obj.cid];
			if (!cityEntity.view || !cityEntity.view.visible) return;
			//飘字
			var popText:Sprite = new PopText(Tools.getMsgById("city_build22", ["[" + obj.name + "]", "[" + Tools.getMsgById(ConfigServer.city_build["buildall"][obj.bid]["name"]) + "]"]), ["#70ff10", "#FCAA44"], "#ffffff");
			
			this.mapLayer.effectLayer.addChild(popText);
			var p:Vector2D = cityEntity.view.toScreenPos();
			popText.pos(p.x, p.y);	
			CityClip(cityEntity.view).setCityUI();
			
		}

		private function clickArena(index:int):void {
			var cityEntity:EntityCity = MapModel.instance.arenas[index];
			if (!cityEntity.view || !cityEntity.view.visible) return;
			//飘字
			var popText:Sprite = new PopText("["+Tools.getMsgById("500125",[Tools.getMsgById("arena_statue0" + (index + 1))])+"]",["#70ff10"]);
			
			this.mapLayer.effectLayer.addChild(popText);
			var p:Vector2D = cityEntity.view.toScreenPos();
			popText.pos(p.x, p.y);	
			
		}
		
		private function gtaskChange(cid:String):void {
			var cityEntity:EntityCity = MapModel.instance.citys[cid];
			if (!cityEntity.view) return;
			CityClip(cityEntity.view).changeGtask();
		}
		
		private function udpateVisit():void {
			for (var cityId:String in ModelVisit.visitModels) {
				if (MapModel.instance.citys[cityId].view) {
					CityClip(MapModel.instance.citys[cityId].view).checkVisit();
				}
			}
			
		}
		
		/**
		 * 黄巾军。
		 */
		private function checkThief(thief:Array):void {
			
			for each(var thiefData:Object in thief) {
				var cid:int = parseInt(thiefData.cid);
				var city:EntityCity = MapModel.instance.citys[cid];		
				
				var thiefConfig:Object = ConfigServer.getAttackNpcConfig(thiefData.type);

				//if(thiefConfig){//襄阳战出现黄金三军  会报错  先这么容错一下
				for (var i:int = 0, len:int = thiefConfig.dir.length; i < len; i++) {
					var clip:ThiefClip = new ThiefClip(this);
					clip.thiefData = thiefData;
					clip.thiefConfig = thiefConfig;
					clip.city = city;
					if (cid >= 0) {
						clip.dir = thiefConfig.dir[i];
					} else {
						if (cid == -1) {
							clip.dir = 2;
						} else {
							clip.dir = Math.abs(cid) - 2;
						}
					}
					
					clip.init();
				}
				//}
					
			}
		}
		
		override public function createClip(type:int = -1):EntityClip {
			return new CityClip(this);
		}
		
		
		public function getMenu(entityCity:EntityCity):Array {		
			//我国国阵
			var isZhen:Boolean = entityCity.cityId==(ModelManager.instance.modelUser.country+10)*-1;
			var isXYZ:Boolean = ModelManager.instance.modelCountryPvp.isOpen;

			var xiangqing:Object       = {visible:true, label:Tools.getMsgById("_jia0033"), type:0, gray:false, icon:"ui/home_01.png"};
			var qianwang:Object        = {visible:isZhen ? isXYZ : entityCity.myCountry, label:Tools.getMsgById("_jia0032"), type:1, gray:false, icon:"ui/home_39.png"};
			var gongcheng:Object       = {visible:!entityCity.myCountry && entityCity.cityType != ConfigConstant.CITY_TYPE_CAMP, label:Tools.getMsgById("msg_MapViewMain_0") + entityCity.getAttackBtnInfo(), type:2, gray:false, icon:"ui/home_43.png"};
		    var gtask_build:Object     = ModelTask.gTask_city_data(entityCity.cityId,ModelTask.GTASK_TYPE_GTASK_BUILD);
		    var gtask_build_ran:Object = ModelTask.gTask_city_data(entityCity.cityId,ModelTask.GTASK_TYPE_GTASK_BUILD_RAN);
			var gtask_b:Boolean        = ((!Tools.isNullObj(gtask_build) && gtask_build.status>0) || (!Tools.isNullObj(gtask_build_ran) && gtask_build_ran.status>0));
			var jianzao:Object         = {visible:(entityCity.myCountry && entityCity.canBuild && Number(entityCity.id)!=-1), label:Tools.getMsgById("_city_build_text01"), type:3, gray:false, icon:"ui/home_44.png",work:gtask_b};		

			var bianzu:Object          = {visible:isZhen ? isXYZ : (entityCity.myCountry && entityCity.isCapital) || isZhen, label:Tools.getMsgById("msg_MapViewMain_1"), type:isZhen?41:4, gray:false, icon:"ui/home_41.png"};			
			var baifang:Object         = {visible:(entityCity.myCountry && !entityCity.fire && ModelVisit.isShowVisitBtn(entityCity.cityId+"")), label:Tools.getMsgById("_visit_text01") + (ModelVisit.isShowVisitBtn(entityCity.cityId+"") ? ModelHero.getHeroName(ModelOfficial.visit[entityCity.cityId.toString()]) : ""), type:5, gray:ModelGame.unlock(null,"map_visit").gray, icon:"ui/home_38.png"};			
			var zhankuang:Object       = {visible:entityCity.fire && !ConfigServer.world.skip_all_fight, label:Tools.getMsgById("msg_MapViewMain_2"), type:7, gray:false, icon:"ui/home_32.png"};
			
			var gtask_donate:Object    = ModelTask.gTask_city_data(entityCity.cityId,ModelTask.GTASK_TYPE_GTASK_DONATE);
			var zhengwu:Object         = {visible:(entityCity.myCountry && !Tools.isNullObj(gtask_donate) && gtask_donate.status>0), label:Tools.getMsgById("_ftask_text01"), type:61, gray:false, icon:"ui/home_40.png",work:true};// && !entityCity.fire

			//国王或军师
			var b1:Boolean=(ModelOfficial.isKing(ModelManager.instance.modelUser.mUID)>-1 || ModelOfficial.isAdviser(ModelManager.instance.modelUser.mUID)>-1);
			//都尉&&敌方城市
			var b2:Boolean=!entityCity.myCountry && ([1,2,3,4].indexOf(entityCity.cityType)!=-1) && (ModelOfficial.isBeefedUp(ModelManager.instance.modelUser.mUID)>-1);		
			var b3:Boolean = entityCity.cityId >= 0;
			var junling:Object         = {visible:b3 && (b1 || b2),type:(b1?2002:(b2?2004:-1)) ,gray:false, icon:"ui/home_45.png", label:Tools.getMsgById("530062")};
			var mayorCid:* = ModelOfficial.isCityMayor(ModelManager.instance.modelUser.mUID,ModelUser.getCountryID());
			var taishou:Object         = {visible:!Tools.isNullString(mayorCid) && (mayorCid==entityCity.cityId) && entityCity.myCountry, label:Tools.getMsgById("msg_MapViewMain_3"), type:2003, gray:false, icon:"ui/home_45.png"};

			//var xiangyang:Object       = {visible:entityCity.cityType == 9,label:Tools.getMsgById("_lht12"), type:9000, icon:"ui/home_45.png"};
			var qixie:Object           = {visible:isZhen, label:Tools.getMsgById("_countrypvp_text26"), type:9001, gray:false, icon:"ui/home_61.png"};
			return [xiangqing, qianwang, gongcheng, jianzao, bianzu, baifang, zhengwu, zhankuang,junling,taishou,qixie];
		}
		
		public function checkMenu(entityCity:EntityCity, type:int):void {
			switch(type) {
				case 0:	//详情
					//this.testCitySend(entityCity);
					//return;
					NetSocket.instance.send(NetMethodCfg.WS_SR_GET_CITY_INFO,{cid:entityCity.cityId},Handler.create(this,function (re:NetPackage):void
					{
						ViewManager.instance.showView(ConfigClass.VIEW_CITY_INFO,re.receiveData);
					}));
					break;
				case 1:	//前往	
					if (ModelManager.instance.modelCountryPvp.checkActive() && entityCity.cityId < 0 && !ModelManager.instance.modelCountryPvp.isOpen){
						ViewManager.instance.showHeroTalk([['hero403', 'troopAttackTalkName', 'troopAttackTalk' + 10, []]], null);					
					} else {
						ModelManager.instance.modelGame.checkTroopToAction(entityCity.cityId,null,null,false,1,-1,1);
					}
					break;
				case 2:	//攻城
					var errorType:int = entityCity.getAttackError(null);
					if (errorType == 0){
						var power:int = entityCity.getPower();
						ModelManager.instance.modelGame.checkTroopToAction(entityCity.cityId,null,null,false,1,power,1);
					}else{
						var obj:Object = entityCity.getAttackErrorObj(errorType);
						ViewManager.instance.showHeroTalk([['hero403', 'troopAttackTalkName', 'troopAttackTalk' + obj.errorType, obj.arr]], null);
						//ViewManager.instance.showTipsTxt(entityCity.getAttackErrorInfo(errorType), 3);
					}
					break;
				case 3:	//建造
					if(!ModelManager.instance.modelUser.isFinishFtask(entityCity.cityId+"")){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_ftask_tips01"));
						return;
					}
					if(ModelManager.instance.modelUser.office<ConfigServer.city_build.lock[1]){
						//ViewManager.instance.showTipsTxt("爵位等级不足"+config_city_build.lock[2]);
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_office4",[ModelOffice.getOfficeName(ConfigServer.city_build.lock[1])]));
						return;
					} 
					if(entityCity.cityId==-1 && ModelManager.instance.modelCountryPvp.checkActive()){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_countrypvp_text36"));
						return;
					}
					NetSocket.instance.send(NetMethodCfg.WS_SR_GET_CITY_INFO, {cid:entityCity.cityId,"is_simple":true}, Handler.create(this, function(vo:NetPackage):void {
						ViewManager.instance.showView(ConfigClass.VIEW_CITY_BUILD_MAIN,[vo.receiveData.build,entityCity.cityId+""]);
					}));
					break;
				case 4:	//编组
					if(ModelManager.instance.modelTroopManager.isMax()){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_lht35"));
					}
					else{
						ViewManager.instance.showView(ConfigClass.VIEW_TROOP_EDIT,false);
					}
					break;
				case 41: //国阵编组
					if(ModelManager.instance.modelTroopManager.isMax()){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_lht35"));
					}
					else{
						if(ModelManager.instance.modelCountryPvp.isOpen){
							ViewManager.instance.showView(ConfigClass.VIEW_TROOP_EDIT,true);
						}else{
							ViewManager.instance.showTipsTxt("不在襄阳战期间");
						}
					}
					break;
				case 5:	//拜访
					ModelManager.instance.modelGame.getModelVisit(entityCity.cityId+"").click2();
					break;
				case 61:	//政务上缴
					ViewManager.instance.showView(ConfigClass.VIEW_WORK_DONATION,ModelTask.gTask_city_data(entityCity.cityId,ModelTask.GTASK_TYPE_GTASK_DONATE));
					break;
				case 62:	//政务打仗
					ViewManager.instance.showView(ConfigClass.VIEW_WORK_CONQUEST,ModelTask.gTask_city_data(entityCity.cityId,ModelTask.GTASK_TYPE_GTASK_COLLECT));
					break;					
				case 7:	//战况
					this.sendNetToInFight(entityCity);
					break;
				case 9000:	//襄阳争夺战test
					ViewManager.instance.showView(ConfigClass.VIEW_OVERLORD);
					break;
				case 2001:	//建设令
					ViewManager.instance.showView(ConfigClass.VIEW_OFFICER_ORDER_A,["buff_country2",entityCity.cityId]);
					break;
				case 2002:	//军令
					if(ModelOfficial.checkCityIsMyCountry(entityCity.cityId)){//本城就是守城令  他国就是攻城令
						if(ModelOfficial.getBuffByCid(entityCity.cityId+"","buff_country4")!=null){
							ViewManager.instance.showTipsTxt(Tools.getMsgById("_country72"));
							return;
						}
						ViewManager.instance.showView(ConfigClass.VIEW_OFFICER_ORDER_A,["buff_country4",entityCity.cityId]);
					}else{
						if(ModelOfficial.getBuffByCid(entityCity.cityId+"","buff_country3")!=null){
							ViewManager.instance.showTipsTxt(Tools.getMsgById("_country72"));
							return;
						}
						ViewManager.instance.showView(ConfigClass.VIEW_OFFICER_ORDER_A,["buff_country3",entityCity.cityId]);
					}
					
					//ViewManager.instance.showView(ConfigClass.VIEW_OFFICER_ORDER_B,entityCity.cityId);
					break;
				case 2003:	//太守令
					ViewManager.instance.showView(ConfigClass.VIEW_OFFICER_ORDER_A,["buff_corps",entityCity.cityId]);
					break;
				case 2004:	//都尉令
					if(ModelOfficial.getBuffByCid(entityCity.cityId+"","buff_country5")!=null){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_country73"));
						return;
					}
					ViewManager.instance.showView(ConfigClass.VIEW_OFFICER_ORDER_A,["buff_country5",entityCity.cityId]);
					break;					
				case 10003:	//测试接口 没用了现在
					NetSocket.instance.send("get_ftask",{},Handler.create(this,function(np:NetPackage):void{
						ModelManager.instance.modelUser.updateData(np.receiveData);
						ViewManager.instance.showView(["ViewFTaskTest",ViewFTaskTest]);
					}));	
					break;
				case 9001:
					//if(ModelManager.instance.modelCountryPvp.isOpen){
						ViewManager.instance.showView(["ViewBuildCar",ViewBuildCar]);
					//}else{
					//	ViewManager.instance.showTipsTxt("不在襄阳战期间");
					//}
					break;
			}
		}
		public function sendNetToInFight(entityCity:EntityCity):void{
			var _this:* = this;
			NetSocket.instance.send(EventConstant.LOOK_FIGHT_IN, {cid:entityCity.cityId}, Handler.create(_this, function(vo:NetPackage):void {
				//vo.receiveData
				
				_this.inFight(entityCity,vo.receiveData);
				//ViewManager.instance.showView(ConfigClass.VIEW_TEST_FIGHT, entityCity);
			}));			
		}
		/**
		 * 临时测试，马超部队移动到临近城市
		 */
		public function testCitySend(entityCity:EntityCity):Boolean {
			var citys:Array = EntityCity.exportNearCitys(entityCity.cityId);
			var mt:ModelTroop = ModelManager.instance.modelTroopManager.getTroop('hero701');
			if (!mt)
				return false;
			var arr:Array = [mt, entityCity.cityId, citys, -1];
			var len:int = citys.length;
			var i:int;
			var	cityIds:Array = [];	
			for (i = 0; i < len; i++) 
			{
				cityIds.push(citys[i].cid);
			}
			NetSocket.instance.send(NetMethodCfg.WS_SR_GET_CITY_INFO,{cid:cityIds},Handler.create(this,function (re:NetPackage):void
			{
				for (i = 0; i < len; i++) 
				{
					var cityObj:Object = citys[i];
					var reObj:Object = re.receiveData[i];
					cityObj.city_total = reObj.city_total;
					cityObj.troop = reObj.troop;
				}
				ViewManager.instance.showView(ConfigClass.VIEW_CITY_SEND, arr);
			}));	
			return true;
		}
		
		/**
		 * 国战进入战斗
		 */
		public function inFight(entityCity:EntityCity, data:Object):void {
			data.mode = 0;
			data.country = entityCity.country;
			var serverSec:int = Math.floor(ConfigServer.getServerTimer() / 1000);
			var readTime:int = entityCity.isXYZ?ConfigServer.country_pvp.special_time.wait:ConfigServer.world.city_fire_ready_time;
			var readySec:int = Math.max(0, data.fireTime + readTime - serverSec);
			if (readySec > 0)
			{
				data.readyTime = readySec * 1000;
			}
			FightMain.startFight(data, this, this.outFight, [entityCity]);
		}
		public function outFight(entityCity:EntityCity):void {
			//ViewManager.instance.closeFightScenes();
			NetSocket.instance.send(EventConstant.LOOK_FIGHT_OUT, {cid:entityCity.cityId});
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			for (var name:String in AroundManager.instance.occupy) {
				Tools.destroy(AroundManager.instance.occupy[name]);
			}
			AroundManager.instance.occupy = {};
			MarchPathManager.instance.clearAll();
			ModelManager.instance.modelGame.off(ModelGame.EVENT_MAYOR_UDPATE, this, this.updateCity);
			MapModel.instance.off(EventConstant.MARCH_CREATE, this, this.onCreateMarchHandler);
			ModelManager.instance.modelGame.off(ModelGame.EVENT_ADD_ESTATE, this, this.addEstateHandler);
			MapModel.instance.off(EventConstant.THIEF, this, this.checkThief);
			ModelManager.instance.modelGame.off(ModelCityBuild.EVENT_ADD_CITY_BUILD, this, this.addBuildHandler);
			ModelManager.instance.modelGame.off(ModelVisit.EVENT_INIT_VISIT, this, this.udpateVisit);			
			ModelManager.instance.modelGame.off(ModelGame.EVENT_TASK_WORK_GET_OR_DEL, this, this.gtaskChange);
			ModelManager.instance.modelGame.off(EventConstant.UPDATE_BUILD, this, this.updateBuild);
			
			ModelManager.instance.modelGame.off(ModelGame.EVENT_BUFFS_ORDER_3_4_CHANGE, this, this.tokenChange);
			ModelManager.instance.modelGame.off(ModelGame.EVENT_BUFFS_ORDER_5_CHANGE, this, this.buffsOder5Change);
			ModelFightTask.instance.off(ModelFightTask.FIGHT_TASK_CHANGE, this, this.tokenChange);
			ModelManager.instance.modelOfficel.off(ModelOfficial.EVENT_SHOW_GOLD_ESTATE, this, this.updateGoldEstate);
			ModelManager.instance.modelOfficel.off(ModelOfficial.EVENT_HIDE_GOLD_ESTATE, this, this.updateGoldEstate);
			ModelManager.instance.modelUser.off(EventConstant.HERE_CATCH_DIE, this, this.onDeadHeroCatch);
			
			ModelManager.instance.modelGame.off(ModelGame.EVENT_SHOW_BALLISTA_MSG, this, this.onShowBallistaMsg);

			ModelManager.instance.modelGame.off(ModelGame.EVENT_CLICK_ARENA_CLIP, this, this.clickArena);
			
			this.troopAnimation.destroy();
			
			for (var i:int = 0, len:int = MapModel.instance.heroCatch.length; i < len; i++) {
				if (MapModel.instance.heroCatch[i]) {
					Tools.destroy(MapModel.instance.heroCatch[i].view);
				}
			}
			EffectManager.clearCacheGroup("map");
			
			LoadeManager.clearHeroIcon();
			Tools.destroy(this.miniMap0);
			super.destroy(destroyChild);
		}

        
		
	}

}