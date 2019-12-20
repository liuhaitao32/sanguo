package sg.map.model {
	import laya.net.LocalStorage;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.model.entitys.EntityArena;
	import sg.map.model.entitys.EntityFtask;
	import sg.map.model.entitys.EntityGtask;
	import sg.map.model.entitys.EntityHeroCatch;
	import sg.map.model.entitys.EntityMonster;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.TestUtils;
	import sg.map.view.AroundManager;
	import sg.model.ModelArena;
	import sg.model.ModelClimb;
	import sg.model.ModelCountryPvp;
	import sg.model.ModelFTask;
	import sg.model.ModelGame;
	import sg.model.ModelQQDT;
	import sg.model.ModelTask;
	import sg.model.ModelTroopManager;
	import sg.model.ModelVisit;
	import sg.net.NetHttp;
	import sg.net.NetVo;
	import sg.scene.constant.EventConstant;
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
	import sg.scene.constant.ConfigConstant;
	import sg.map.model.entitys.EntityMarch;
	import sg.scene.model.MapGridManager;
	import sg.scene.view.EventLayer;
	import sg.map.view.IsoObject;
	import sg.map.edit.IsoTile;
	import sg.map.model.entitys.EntityCity;
	import sg.map.utils.Vector2D;
	import sg.model.ModelBase;
	import sg.model.ModelTroop;
	import sg.net.NetMethodCfg;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.scene.view.TestButton;
	import sg.utils.FunQueue;
	import sg.model.ModelUser;
	import sg.utils.Tools;
	import sg.model.ModelOfficial;
	import sg.model.ModelItem;
	public class MapModel extends ModelBase {

		public var mapGrid:MapGridManager = new MapGridManager();
		
		
		public static var instance:MapModel;
		
		public var citys:* = {};
		
		public var marchs:* = {};
		
		public var heroCatch:Array = [];
		
		public var monsters:Object = {};
		
		public var queueFun:FunQueue = new FunQueue();
		
		public var thief:Array = [];
		
		public var testMap:Object;
		
		public var arenas:Array = [];
		
		public var reloading:Boolean = false;
		
		public function MapModel() {
			instance = this;
		}	
		
		
		private var reloadQueueFun:FunQueue = new FunQueue();
		
		public function reload():void {
			this.reloading = true;
			//this.initLoadMap();			
			this.reloadQueueFun.clear();
			this.reloadQueueFun.complete = new Handler(this, function():void {
				this.reloading = false;
			});
			TestButton.log("重新reload");
			this.reloadQueueFun.init([
				new Handler(this, this.initReloadTroop),
				new Handler(this, this.initReloadMap),
				new Handler(this, this.updateTroopItem),
			]);		
			
		}
		
		private function updateTroopItem():void {
			ModelManager.instance.modelTroopManager.event(EventConstant.TROOP_CREATE, {model:null});
			for (var name:String in ModelManager.instance.modelTroopManager.troops) {
				ModelTroop(ModelManager.instance.modelTroopManager.troops[name]).event(EventConstant.TROOP_UPDATE);
			}
		}
		
		private function initReloadTroop():void {
			ModelManager.instance.modelTroopManager.reload(new Handler(this.reloadQueueFun, this.reloadQueueFun.next));
		}
		
		private function initReloadMap():void {
			for (var marchUid:String in this.marchs) {
				this.removeMarch(marchUid);
			}			
			NetSocket.instance.send(NetMethodCfg.WS_SR_GET_INFO, null, new Handler(this, function(pkg:NetPackage):void{
				ModelArena.instance.arena = pkg.receiveData.pk_arena;
				parseData2(pkg.receiveData);	
				this.reloadQueueFun.next();
			}), 1);
		}
		
		


		public function initMap(callBack:Handler):void{
			var tJsonData:* = ConfigConstant.mapConfigData;
			this.mapGrid.init(tJsonData.width, tJsonData.height, tJsonData.tilewidth, tJsonData.tileheight, tJsonData.orientation);						
			if (ConfigConstant.isEdit) {
				callBack.run();
				ViewManager.instance.initMap();
				return;
			}
			for (var key:String in ConfigConstant.mapData.city) {
				var entityData:Object = ConfigConstant.mapData.city[key];
				var entity:EntityCity = new EntityCity();
				entity.cityId = parseInt(key);
				entity.initConfig();
				this.citys[key] = entity;
			}
			
			for (var cityKey:String in ConfigConstant.mapData.path) {
				var arr:Array = cityKey.split("_");
				var city1:EntityCity = this.citys[arr[0]];
				var city2:EntityCity = this.citys[arr[1]];
				city1.nearCitys.push(city2);
				city2.nearCitys.push(city1);
			}
			
			this.queueFun.init([
			
								Handler.create(this, this.initLoadMap),
								Handler.create(this, this.initFtask),
								Handler.create(this, this.initVisit),
								Handler.create(this, this.initAerna),
								Handler.create(this, this.initOther)
			])
			
			this.queueFun.complete = callBack;
			
			ModelManager.instance.modelUser.on(EventConstant.HERE_CATCH, this, onAddHeroCatchHandler);			
			ModelManager.instance.modelGame.on(ModelGame.EVENT_PK_NPC_CHECK_MODEL, this, onCheckNpcHandler);
			//涛哥说icon等于空 就清理 不然就增加。
			ModelManager.instance.modelGame.on(ModelGame.EVENT_TASK_WORK_CHANGE, this, function(data:Object):void {
				if (data.icon) {
					addGtask(parseInt(data.cid), data.icon, data.id);
				} else {
					var city:EntityCity = citys[data.cid];
					if (city.gtask) {
						city.gtask.clear();
						city.gtask = null;
					}
				}				
			});
			
			NetSocket.instance.registerHandler(EventConstant.CITY_FIRE, Handler.create(this, this.onCityFireHandler, null, false));
			NetSocket.instance.registerHandler(EventConstant.FIGHT_END, Handler.create(this, function(vo:NetPackage):void {
				onFightEndHandler(vo.receiveData);
			}, null, false));			
			NetSocket.instance.registerHandler(EventConstant.THIEF, Handler.create(this, function(pkg:NetPackage):void {
				 checkThief(pkg.receiveData);
			}, null, false));
			
			NetSocket.instance.registerHandler(EventConstant.CITY_DETECT, Handler.create(this, function(pkg:NetPackage):void {
				 var city:EntityCity = citys[pkg.receiveData.city];
				 city.isDetect = true;
			}, null, false));	
			
			ModelManager.instance.modelGame.heroCatchTimer();//名将切磋
			ModelManager.instance.modelGame.checkPKnpcTimer(1000);//异族入侵		
			NetSocket.instance.on(NetSocket.EVENT_SOCKET_RELOAD, this, this.reload);
		}
		
		private function parseAerna():void {
			for (var i:int = 0, len:int = 8; i < len; i++) {
				var arena:EntityArena = new EntityArena();
				arena.index = i;
				arena.setPos();
				this.arenas.push(arena);
			}
			this.changeAerna();			
			this.queueFun.next();
		}
		
		private function changeAerna():void {
			var obj:Object = ModelArena.getArenaData();
			for (var i:int = 0, len:int = 8; i < len; i++) {
				var arena:EntityArena = this.arenas[i];
				arena.initConfig(obj[(i + 1).toString()]);
			}
		}
		
		private function initAerna():void {
			trace("初始化雕像")
			ModelArena.instance.on(ModelArena.EVENT_UPDATE_ARENA_CLIP, this, this.changeAerna);
			Laya.timer.callLater(this, this.parseAerna);
		}
		
		
		private var qizi:Object = {};
		private function initOther():void {
			trace("初始化其他");
			this.checkQizi(EventConstant.BUFF_CORPS);
			ModelManager.instance.modelGame.on(ModelGame.EVENT_BUFFS_ORDER_CORPS_CHANGE, this, function():void {
				this.checkQizi(EventConstant.BUFF_CORPS);
			})
			this.queueFun.next();
			this.queueFun = null;
		}
		
		/**
		 * 以前写的旗子太着急了。。。 现在 旗子统一走这里。。。 以前的不管了。放那里吧。
		 * @param	type
		 */
		private function checkQizi(type:String):void {
			var now:Array = ModelOfficial.getBuff5Arr(type);
			trace("令牌" + type, now);
			this.qizi[type] ||= [];
			var old:Array = this.qizi[type];
			old = old.filter(function(city:String, index:int, arr:Array):Boolean{				
				var result:Boolean = ArrayUtils.contains(city, now);
				if (result) {
					ArrayUtils.remove(city, now);
				} else {
					EntityCity(citys[city])[type] = false;
				}				
				return result;
			});
			for (var i:int = 0, len:int = now.length; i < len; i++) {
				EntityCity(citys[now[i]])[type] = true;
				old.push(now[i]);
			}
			this.qizi[type] = old;
		}
		
		private function initVisit():void {
			ModelManager.instance.modelGame.once(ModelVisit.EVENT_INIT_VISIT, this, function(e:Event):void {
				queueFun.next();
			});
			ModelManager.instance.modelGame.getCityVisit();//拜访
		}
		
		private function initLoadMap():void {			
			ModelArena.instance;
			NetSocket.instance.send(NetMethodCfg.WS_SR_GET_INFO, null, new Handler(this, function(pkg:NetPackage):void{
				ModelArena.instance.arena = pkg.receiveData.pk_arena;
				parseData(pkg.receiveData);	
				//因为那个雕像得跟这个getInfo一起执行的。。 所以。。 晚点再初始化下一个
				if(queueFun) queueFun.next();
			}));
			trace("初始化map");
		}
		
		private function initFtask():void {
			//ModelManager.instance.modelGame.getFtaskData();
			ModelManager.instance.modelGame.on(ModelFTask.EVENT_ADD_FTASK, this, function(e:ModelFTask):void {
				EntityCity(citys[parseInt(e.city_id)]).ftask = e;
			});
			ModelManager.instance.modelGame.once(ModelFTask.EVENT_INIT_FTASK, this, function(e:ModelFTask):void {
				for (var name:String in ModelFTask.ftaskModels) {
					EntityCity(citys[name]).ftask = ModelFTask.ftaskModels[name];
				}
				queueFun.next();
			});			
		}
		
		private function onCheckNpcHandler(e:Array):void {
			var climbs:Object = e;			
			for (var name:String in climbs) {
				if (monsters[name]) continue;
				var monster:EntityMonster = new EntityMonster();
				monster.initConfig(climbs[name]);
				this.monsters[name] = monster;
			}			
		}
		
		private function onAddHeroCatchHandler(time:Number):void {
			for (var i:int = 0, len:int = ModelManager.instance.modelUser.hero_catch.hero_list.length; i < len; i++) {
				var data:Object = ModelManager.instance.modelUser.hero_catch.hero_list[i];
				var cityId:int = parseInt(data[1]);
				var heroId:String = data[0].hid;
				this.heroCatch[i] ||= new EntityHeroCatch();
				EntityHeroCatch(this.heroCatch[i]).initConfig({cityId:cityId, heroId:heroId});				
			}
			
			this.event(EventConstant.HERE_CATCH);
		}
		
		private function onAddBlessHeroHandler():void {
		}
		
		/**
		 * 
		 * @param	receiveData {city:{cid:1, country:1}}
		 */
		public function onFightEndHandler(receiveData:Object, updateData:Boolean = true):void {
			if (updateData) ModelOfficial.updateFightEnd(receiveData);
			var cid:* = receiveData.city.cid;
			var city:EntityCity = this.citys[cid];
			var country:int = parseInt(receiveData.city.country);
			
			var oldCountry:int = city.country;
			
			if (country != city.country){
				city.country = country;	
				
				city.isDetect = false;
			} else if (!city.myCountry && city.isDetect) {
				city.isDetect = false;
			}

			if(oldCountry == ModelManager.instance.modelUser.country){
				if(ModelFTask.ftaskModels.hasOwnProperty(cid+"")){
					var mft:ModelFTask=ModelManager.instance.modelGame.getModelFtask(cid+"");
					if(mft.status==0){
						ModelManager.instance.modelGame.removeFtask(cid);
						trace("===========",cid+"被攻占   移除ftask");
					}
				}
			}


			if (city.myCountry && updateData) {//代表是我的城池。
				var farr:Array = ModelManager.instance.modelUser.ftask[cid+""];
				if(farr && farr[0]!=-1){
					ModelManager.instance.modelGame.addFtask(cid+"");
				}else{
					if(ConfigServer.city[cid].pctask_id){//该城市有民情才调接口
						if(ModelManager.instance.modelUser.ftask[cid] && ModelManager.instance.modelUser.ftask[cid][0]==-1){
							//trace("========该城市民情已完成。");	
						}else{	
							NetSocket.instance.send("get_ftask",{},Handler.create(this,function(np:NetPackage):void{
								ModelManager.instance.modelUser.updateData(np.receiveData);	
								//trace("========重新调用刷新民情的接口。");	
							}));
						}
					}
				}
				
				//重新添加产业
				for(var i:int = 0; i < ModelManager.instance.modelUser.estate.length; i++){
					if(ModelManager.instance.modelUser.estate[i].active_hid!=null){
						ModelManager.instance.modelGame.addEstate(cid, i);
					}
				}
				
				if(oldCountry != ModelManager.instance.modelUser.country){
					//攻下襄阳城城门
					if(ConfigServer.city[cid].cityType==8){
						ModelManager.instance.modelCountryPvp.showHeroTalk("500043",[Tools.getMsgById(ConfigServer.city[cid].name)]);
					}

					//攻下襄阳城
					if(ConfigServer.city[cid].cityType==9){
						ModelManager.instance.modelCountryPvp.showHeroTalk("500044");
					}
				}

			}
			
			city.fire = false;
			if(oldCountry == ModelManager.instance.modelUser.country){
				ModelTask.checkFireCity(2,receiveData);
			}
			ModelTask.checkCountryArmy(1,city.cityId+"");
		}
		
		private function onCityFireHandler(vo:NetPackage):void {
			var city:EntityCity = this.citys[vo.receiveData.city];
			if("country" in vo.receiveData) city.country = vo.receiveData.country;
			city.fire = true;
			city.isDetect = vo.receiveData.fire_country == ModelManager.instance.modelUser.country;
			
			if(vo.receiveData.fire_country){
				if(vo.receiveData.fire_country == ModelManager.instance.modelUser.country){
					ModelManager.instance.modelGame.event(ModelGame.EVENT_FIGHT_LOG_CHANGE);
				}
				else{
					if(ModelOfficial.checkCityIsMyCountry(vo.receiveData.city)){
						ModelManager.instance.modelGame.event(ModelGame.EVENT_FIGHT_LOG_CHANGE);
						ModelTask.checkFireCity(1,vo.receiveData);
					}
				}
			}
		}
		
		public function getCapital(country:int):EntityCity {
			return this.citys[ConfigServer.country.country[(country < 0?(country + 3):country)]["capital"]];
		}
		
		
		public function get myCapital():EntityCity {
			return this.getCapital(ModelUser.getCountryID());
		}
		
		public function createMarch(data:*):void {		
			if (parseInt(data.status) != ModelTroop.TROOP_STATE_MOVE && parseInt(data.status) != ModelTroop.TROOP_STATE_RECALL) return;
			var march:EntityMarch = new EntityMarch(MapModel.instance, -1);
			march.initConfig(data);
			this.removeMarch(march.id);//据说要处理之前的行军。
			this.marchs[march.id] = march;
			MapModel.instance.event(EventConstant.MARCH_CREATE, march);
			
		}
		
		public function createCountyArmy(data:*):void {		
			if (data.xtype != "country_army") return;
			new CountryArmy().init(data);
		}
		
		
		public function marchSpeedUp(id:String, data:*):void {
			if (!this.marchs) return;
			var march:EntityMarch = this.marchs[id];
			if (!march) return;
			march.setRate(data.data.speedup);
		}
		
		public function removeMarch(id:String):void {
			if (this.marchs[id]) {
				EntityMarch(this.marchs[id]).clear();
				delete this.marchs[id];
			}
		}
		 
		public function getCitys(params:Object):Array {
			var result:Array = [];
			for (var cityId:String in this.citys) {				
				var entity:EntityCity = this.citys[cityId];
				for (var name:String in params) {
					if(entity[name] == params[name]){
						result.push(entity);
						break;
					}
				}
			}
			return result;
		}
		
		
		public function getFilterCitys(fun:Function):Array {
			var result:Array = [];
			for (var cityId:String in this.citys) {				
				var entity:EntityCity = this.citys[cityId];
				if (fun(entity)) {
					result.push(entity);
				}
			}
			return result;
		}
		
		/**
		 * 获取我自己国家城市
		 * @param	params 额外的检测。 属性为EntityCity的属性值。
		 * @return
		 */
		public function getMyCountryCitys(params:Object = null):Array {
			params ||= {};
			params.country = ModelUser.getCountryID();
			return this.getCitys(params);
		}
		
		public function recallMarch(id:String):void {
			var march:EntityMarch = this.marchs[id];
			if(march) {
				march.recall();
			}
		}
		
		private function parseData2(receiveData:Object):void {
			
			this.testMap = receiveData;
			//receiveData = Laya.loader.getRes("testMap.json");
			var cityDatas:Object = receiveData.cities;
			
			for (var name:String in cityDatas) {
				var city:EntityCity = this.citys[name];
				city.reset(cityDatas[name]);
			}
			
			
			var marchDatas:Object = receiveData.troops;
			
			for (var uid:String in marchDatas) {
				for (var hero:String in marchDatas[uid]) {
					this.createMarch(marchDatas[uid][hero]);	
					this.createCountyArmy(marchDatas[uid][hero]);
				}
			}
			
			//this.checkThief(receiveData.attack_npc);
			//var selfGtaskData:Object = ModelTask.gTask_self_take();
			////政务。。。
			//for (var gId:String in selfGtaskData) {
				//var gtask:Object = selfGtaskData[gId];
				//var gtaskData:Object = ModelTask.gTask_city_data(gtask.city_id, ModelTask.GTASK_TYPE_GTASK_COLLECT);
				//if (!gtaskData || gtaskData.status < 1) continue;
				//this.addGtask(parseInt(gtask.city_id), ModelItem.getItemIconAssetUI(gtaskData.reward_key), gId);//gtaskData["bot_hero"]["hid"]
			//}			
			////发送后端数据请求地图逻辑
			//AroundManager.instance.init();
		}
		
		private function parseData(receiveData:Object):void {
			if (TestUtils.isTestShow) {
				
			}
			this.testMap = receiveData;
			//receiveData = Laya.loader.getRes("testMap.json");
			var cityDatas:Object = receiveData.cities;
			
			for (var name:String in cityDatas) {
				var city:EntityCity = this.citys[name];
				city.setWordData(cityDatas[name]);
			}
			
			
			var marchDatas:Object = receiveData.troops;
			
			for (var uid:String in marchDatas) {
				for (var hero:String in marchDatas[uid]) {
					this.createMarch(marchDatas[uid][hero]);	
					this.createCountyArmy(marchDatas[uid][hero]);
				}
			}
			
			this.checkThief(receiveData.attack_npc);
			var selfGtaskData:Object = ModelTask.gTask_self_take();
			//政务。。。
			for (var gId:String in selfGtaskData) {
				var gtask:Object = selfGtaskData[gId];
				var gtaskData:Object = ModelTask.gTask_city_data(gtask.city_id, ModelTask.GTASK_TYPE_GTASK_COLLECT);
				if (!gtaskData || gtaskData.status < 1) continue;
				this.addGtask(parseInt(gtask.city_id), ModelItem.getItemIconAssetUI(gtaskData.reward_key), gId);//gtaskData["bot_hero"]["hid"]
			}			
			//发送后端数据请求地图逻辑
			AroundManager.instance.init();
		}
		
		private function addGtask(cityId:int, icon:String, id:String):void {			
			var gtask:EntityGtask = new EntityGtask();
			gtask.city = this.citys[cityId];
			gtask.icon = icon;
			gtask.name = Tools.getMsgById(id + "_name");
			gtask.city.gtask = gtask;
			gtask.initConfig();
			gtask.city.event(EventConstant.UPDATE_GTASK);
		}
		
		public function checkThief(attack_npc:Array = null):void {
			for (var i:int = this.thief.length - 1; i > -1; i--) {
				if (ConfigServer.getServerTimer() <= this.thief[i].start_time) {
					this.thief.splice(i, 1);
				}				
			}
			if (attack_npc) {
				this.thief = this.thief.concat(attack_npc);
				this.event(EventConstant.THIEF, [attack_npc]);//有更新的派发更新的。 空代表派发所有。
				if(attack_npc[0] && attack_npc[0].cid=="-1"){//襄阳城出现黄巾军
					ModelManager.instance.modelCountryPvp.showHeroTalk(ModelOfficial.cities[-1].country==ModelManager.instance.modelUser.country ? "500045" : "500046");
				}
			} else {
				this.event(EventConstant.THIEF, [this.thief]);//有更新的派发更新的。 空代表派发所有。
			}
			if(this.thief){
				// if(thief.length>0){
					ModelTask.npcInfo_thief_check(this.thief);
				// }
			}
		}

	}
}