package sg.map.model.entitys {
	import laya.events.Event;
	import laya.maths.Point;
	import laya.utils.Utils;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.map.model.astar.AstarNode;
	import sg.map.model.MapModel;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.LogicOperation;
	import sg.map.utils.MapUtils;
	import sg.map.utils.TestUtils;
	import sg.map.view.MapViewMain;
	import sg.model.ModelCityBuild;
	import sg.model.ModelFTask;
	import sg.model.ModelHero;
	import sg.model.ModelOfficial;
	import sg.model.ModelPrepare;
	import sg.model.ModelTroop;
	import sg.model.ModelVisit;
	import sg.scene.constant.ConfigConstant;
	import sg.map.utils.Vector2D;
	import sg.scene.constant.EventConstant;
	import sg.scene.model.MapGrid;
	import sg.scene.model.entitys.EntityBase;
	import sg.utils.Tools;
	import sg.model.ModelUser;
	import sg.utils.StringUtil;

	/**
	 * ...
	 * @author light
	 */
	public class EntityCity extends EntityBase {
		
		public var cityId:int;
		
		public var cityType:int = ConfigConstant.CITY_TYPE_FORT;
		
		public var nearCitys:Array = [];
		
		private var _country:int;
		
		public var fight:* = null;
		
		private var _fire:Boolean = false;
		
		public var monster:EntityMonster;
		
		public var heroCatch:EntityHeroCatch;
		
		
		//正式版为了内存考虑 不打算生成entity对象！ 所以这个只用于编辑器里存储。
		public var estates:Array = [];
		
		public var greateWall:EntityGreatWall = null;
		
		public var xianHe:EntityXianHe = null;
		
		public var occupyTile:Object = {};
		
		public var _map:MapModel = MapModel.instance;
		
		public var editData:Object;
		
		public var around:Array = [];
		
		public var occupyGrids:Array = [];
		private var _ftask:ModelFTask;
		
		private var _visit:ModelVisit;
		
		public var ftaskEntity:EntityFtask;
		
		private var _gtask:EntityGtask;
		
		public var myTroops:Array = [];
		
		private var _buff_corps:Boolean;
		
		private var _isDetect:Boolean = false;
		
		public var countryArms:Array = [];
		
		//public var food:int = 0;
		//public var coin:int = 0;
		//public var gold:int = 0;
		//public var peace:int = 0;
		
		public function EntityCity(netId:int = -1) {
			super(netId);
			if (ConfigConstant.isEdit) {
				this.editData = {
					occupy:Utils.toHexColor(Math.random() * 0xFFFFFF),
					occupySp:{},
					state:0,
					occupy2:[],
					occupySet:0
				}
			}
		}
		public function get isXYZ():Boolean {
			return this.cityId.toString().indexOf('-') == 0;
		}
		public function get isCapital():Boolean {
			return this.cityId == MapModel.instance.getCapital(this.country).cityId;
		}
		
		/**
		 * 城池名称
		 */
		public function getName():String {
			var cityConfig:Object = ConfigServer.city[this.cityId];
			return Tools.getMsgById(cityConfig.name);
		}
		/**
		 * 读取当前驻军等级
		 */
		public function getNPCLevel():int {
			
			var lv:int = 0;
			
			
			if (this.cityId < 0 && this.country > 2) {
				var _lower_lv:int = ConfigServer.country_pvp["thief_three"]['lower_lv_'+ModelManager.instance.modelUser.mergeNum];
				lv = Math.ceil(Math.max(ConfigServer.country_pvp["thief_three"].upper_lv * ModelManager.instance.modelUser.world_lv, _lower_lv));
			} else {
				var troop:Array = this.getParamConfig('troop');
				lv = Math.max(troop[1], ModelManager.instance.modelUser.world_lv);
			}
			
			
			var faith:Array = this.getParamConfig('faith');
			if (faith && this.country == faith[0]){
				lv += faith[3];
			}
			return lv;
		}
		/**
		 * 按当前驻军等级，得到推荐战力
		 */
		public function getPower():int {
			var lv:int = this.getNPCLevel();
			//var power:int = ModelPrepare.getNPCPower('base', lv, ConfigServer.system_simple.guard_enemy_power);
			var powerType:String;
			var rate:Number;
			if (this.cityId < 0){
				//襄阳战
				powerType = 'xyz';
				rate = ConfigServer.country_pvp["thief_three"].enemy_power;
			}
			else{
				rate = ConfigServer.system_simple.guard_enemy_power;
			}
			var power:int = ModelPrepare.getNPCPower(ConfigServer.system_simple.guard_base, lv, rate, powerType);
			return power;
		}
		
		/**
		 * 当前可攻城（参加国战）等级，如果为负则永久免战
		 */
		public function getLimitLevel():int {
			//return this.getParamConfig('limit');
			var limit:int = this.getParamConfig('limit');
			if(limit > 0)
				return Math.max(Math.floor(ModelManager.instance.modelUser.world_lv * ConfigServer.world.countryFightLvRate), limit);
			else
				return limit;
		}
		
		/**
         * 获得城市开战时间字符串
         */
        public function getFightTimeStr():String{
			if (this.getParamConfig('limit') <= 0){
				return Tools.getMsgById("_city_fighttime3");
			}
			var cfg:* = ConfigServer.world.cityType[this.cityType];
            if(cfg){
                cfg=cfg.fightTime;
                if(cfg==0){//不可攻打
                    return Tools.getMsgById("_city_fighttime3");
                }else if(cfg==-1){//襄阳战期间才能打
                    return Tools.getMsgById("_city_fighttime4");
                }else if(cfg==1){//任意时间可以打
                    return Tools.getMsgById("_city_fighttime2");
                }else{
                    var arr:Array=cfg as Array;
                    var s:String="";
                    for(var i:int=0;i<arr.length;i++){
                        var a:Array=arr[i];
                        var ss:String=i==arr.length-1?"":"  ";
                        s+=a[0]+":"+(a[1]<9 ? "0"+a[1] : a[1])+"~"+a[2]+":"+(a[3]<9 ? "0"+a[3] : a[3])+ss;
                    }
                    return Tools.getMsgById("_city_fighttime1",[s]);
                }
            }
            return "";

        }
		
		/**
		 * 得到当前时间，攻城按钮上应该显示的文字
		 */
		public function getAttackBtnInfo():String {
			var errorType:int = this.getAttackError();
			if (errorType == 0){
				return Tools.getMsgById('cityAttackLv',[this.getLimitLevel()]);
			}
			return Tools.getMsgById('cityAttackBan'); 
		}
		/**
		 * 检测尝试攻击该城市的错误，0可攻击 1该城市不可被攻击 2该城市不在可攻击时段内 3该城市要求攻城英雄等级未达标 4该英雄当前血量不足半数 9襄阳战期间不可攻城。10襄阳战城时间内，玩家不可操作时间。
		 */
		public function getAttackError(modelTroop:ModelTroop = null,checkCity:Boolean = true):int {
			var limit:int = this.getLimitLevel();
			var day:int = ModelManager.instance.modelUser.isMerge?this.getParamConfig('mergeDay'):this.getParamConfig('day');
			var gameDate:int = day?ModelManager.instance.modelUser.getGameDate():0;
			if(checkCity){
				if (limit < 0){
					return 1;
				}
				else if (day && day > gameDate){
					//明日才能攻打,都城
					if(day-gameDate==1){
						if (this.cityType == ConfigConstant.CITY_TYPE_CITY_L){
							return 5;
						}
						else{
							return 7;
						}
					}
					else{
						return 8;
					}
				}
				else {
					var fightTime:* = ConfigServer.world.cityType[this.cityType].fightTime;
					//只在襄阳战内可打
					if (ModelManager.instance.modelCountryPvp.checkActive()){
						if (this.cityId > 0) {
							return 9;
						} else if(!ModelManager.instance.modelCountryPvp.isOpen){
							return 10;
						} else {
							return 0;
						}
						
					}
					if (fightTime == 0){
						return 1;
					}
					else if (fightTime == -1){
						return 2;
					}
					else{
						var canAttack:Boolean = false;
						if (fightTime == 1){
							canAttack = true;
						}else{
							var fightTimeArr:Array = fightTime as Array;
							var i:int;
							var len:int = fightTimeArr.length;
							var date:Date = new Date(ConfigServer.getServerTimer());
							var currM:Number = date.getHours() * 60 + date.getMinutes();
							for (i = 0; i < len; i++ ){
								var timeArr:Array = fightTimeArr[i];
								var startM:Number = timeArr[0] * 60 + timeArr[1];
								var endM:Number = timeArr[2] * 60 + timeArr[3];
								if (currM >= startM && currM < endM){
									canAttack = true;
									break;
								}
							}
						}
						if (!canAttack){
							return 2;
						}
					}
				}
			}
			
			if (modelTroop){
				var hmd:ModelHero = ModelManager.instance.modelGame.getModelHero(modelTroop.hero);
				if (hmd.getLv() < limit){
					return 3;
				}
				var hpPer:Number = modelTroop.getHpPer();
				if (hpPer < ConfigServer.world.troop_atk_per){
					return 4;
				}
			}
			return 0;
		}
		/**
		 * 返回错误编号的文字信息
		 */
		public function getAttackErrorInfo(errorType:int):String {
			var obj:Object = this.getAttackErrorObj(errorType);
			var info:String = Tools.getMsgById('troopAttackWarning' + obj.errorType, obj.arr);
			return info;
		}
		public function getAttackErrorObj(errorType:int):Object {
			var arr:Array = [];
			if (errorType == 2){
				var fightTime:* = ConfigServer.world.cityType[this.cityType].fightTime;
				if (fightTime ==-1){
					errorType = 6;
				}
				else{
					arr.push(Tools.getOpenTimesInfo(fightTime));
				}
			}
			arr.push(this.getLimitLevel());
			return {errorType:errorType, arr:arr};
		}
		/**
		 * 得到军营等级
		 */
		public function getB07lv():int {
			return ModelCityBuild.getBuildLv(this.cityId + "", "b07");
		}
		
		public function get cityTypeName():String {
			return Tools.getMsgById('cityType'+this.getParamConfig("cityType"));
		}
		public function get isUserCountry():Boolean {
			return this.country < 3;
		}
		
		public function get myCountry():Boolean {
			return this.country == ModelManager.instance.modelUser.country;
		}
		
		override public function initConfig(data:* = null):void {
			var cfg:Object = ConfigServer.city[this.cityId.toString()];
			//cfg = null;
			if (!cfg){
				cfg = ConfigServer.world.cityDefault;
			}
			super.initConfig(cfg);
			var entityData:Object = ConfigConstant.mapData.city[this.cityId.toString()];
			var pos:Vector2D = Vector2D.toVector(entityData.pos);
			this.mapGrid = this._map.mapGrid.getGrid(pos.x, pos.y);
			//双向的引用。
			this.mapGrid.node = new AstarNode(this.mapGrid.col, this.mapGrid.row);
			this.mapGrid.node.grid = this.mapGrid;
			this.mapGrid.node.city = this;
			this.mapGrid.addEntity(this);
			this.cityType = this.getParamConfig("cityType");
			
			MapUtils.getPos(this.mapGrid.col, this.mapGrid.row);
			var offset:Array = this.getParamConfig("offset");
			this.x = Point.TEMP.x + (offset ? offset[0] : 0);
			this.y = Point.TEMP.y + (offset ? offset[1] : 0);
			
			
			var size:Number = this.size;
			this.width = this._map.mapGrid.gridW * size;
			this.height = this._map.mapGrid.gridH * size;
			//在襄阳城里的 咱们手动的放大点击范围 反正contans里面还有检测。
			if (this.cityId < 0 && this.cityId > -10) {
				size *= 5;
			}
			var grids:Array = MapUtils.getOccupyGrid(size, [this.mapGrid.col, this.mapGrid.row]);
			
			for (var i:int = 0, len:int = grids.length; i < len; i++) {
				var grid:MapGrid = MapModel.instance.mapGrid.getGrid(this.mapGrid.col + grids[i][0], this.mapGrid.row + grids[i][1]);
				if (grid) grid.addClickEntity(this);
			}
			
			this.initOccupy(entityData.occupy);
			
			this.name = Tools.getMsgById(this.getParamConfig("name"));
			var estate:Object = entityData.estate;
			if (estate) {
				len = Math.min(estate.length, this.getParamConfig("estate").length);
				for (i = 0; i < len; i++) {
					this.occupyTile[estate[i].x + "_" + estate[i].y] = {type:ConfigConstant.ENTITY_ESTATE, index:i};
				}
				if (estate.length != this.getParamConfig("estate").length) {
					trace(this.cityId, "地编：" + estate.length, "配置：" + this.getParamConfig("estate").length);
				}
			}
			var xianhe:Object = entityData.xianhe;
			if (xianhe) {
				this.occupyTile[xianhe.x + "_" + xianhe.y] = {type:ConfigConstant.ENTITY_XIAN_HE};
			}
			
			var wall:Object = entityData.wall;
			if (wall) {
				this.occupyTile[wall.x + "_" + wall.y] = {type:ConfigConstant.ENTITY_CHANG_CHENG};
			}
			
			//if (this.cityId > 0 && this.cityType > 0) {
				//if (!estate) {
					//trace(this.cityId + "---没有产业！");
				//} else {
					//if (len < 4) {
						//trace(this.cityId + "---产业数小于4个");
					//}
				//}
				//
				//if (!entityData.monster) {
					//trace(this.cityId + "---没有野怪");
				//}
				//
				//if (!entityData.heroCatch) {
					//trace(this.cityId + "---没有切磋");
				//}
			//}
			
		}
		
		
		private function initOccupy(occupy:Array):void {
			var grids:Array = null;
			if (occupy == null) {
				if (this.cityType == ConfigConstant.CITY_TYPE_FORT) {
					grids = MapUtils.getOccupyGrid(1.5, [this.mapGrid.col, this.mapGrid.row]).map(function(a:Array, index:int, arr:Array):Array {						
						return [a[0] + mapGrid.col, a[1] + mapGrid.row];
					});					
				}
			} else {
				grids = [];
				for (var i:int = 0, len:int = occupy.length; i < len; i++) {
					var v:Vector2D = Vector2D.toVector(occupy[i], "_", Vector2D.TEMP);
					grids.push([v.x, v.y]);
				}
				if (this.editData) this.editData.occupySet = 1;
			}
			if (grids) {
				for (var j:int = 0, len2:int = grids.length; j < len2; j++) {
					var grid:MapGrid = this._map.mapGrid.getGrid(grids[j][0], grids[j][1]);
					if (!grid.getEntitysByType(ConfigConstant.ENTITY_CITY, "occupyEntitys")[0]) {
						grid.addOccupyEntity(this);
						if (this.editData) {
							this.editData.occupy2.push(grid.col + "_" + grid.row);
						}						
						this.occupyGrids.push(grid);
					}
				}
			}
			
		}
		
		override public function setData(data:*):void {
			this.cityId = data.cityId;
			this.cityType = data.cityType;			
			this.mapGrid = this._map.mapGrid.getGrid(data.center.x, data.center.y);
			this.mapGrid.addEntity(this);
			var this2:EntityCity = this;
			var createTile:Function =  function(a:EntityCityTile, o:Object):EntityCityTile {
				a.city = this2;
				a.x = o.x;
				a.y = o.y;
				a.mapGrid = this2._map.mapGrid.getGrid(o.x, o.y);
				a.mapGrid.addEntity(a);				
				return a;
			}
			
			
			if (data.estate) {
				this.estates = data.estate.map(function(o:Object, i:int, arr:Array):EntityEstate{
					return createTile(new EntityEstate(), o) as EntityEstate;					
				});			
			}
			
			if (data.monster) {
				this.monster = createTile(new EntityMonster(), data.monster) as EntityMonster;
			}
			
			if (data.heroCatch) {
				this.heroCatch = createTile(new EntityHeroCatch(), data.heroCatch) as EntityHeroCatch;
			}
			
			if (data.wall) {
				this.greateWall = createTile(new EntityGreatWall(), data.wall) as EntityGreatWall;
			}
			
			if (data.xianhe) {
				this.xianHe = createTile(new EntityXianHe(), data.xianhe) as EntityXianHe;
			}
			this.initOccupy(data.occupy);
			super.setData(data);
			
		}
		
		public function get size():Number {return this.getParamConfig("scale")}
		
		override public function getData():Object {
			var result:Object = super.getData();			
			result.center = {"x":mapGrid.col, "y":mapGrid.row};
			
			result.cityId = this.cityId;
			result.cityType = this.cityType;
			this.setOccupyData(result);
			return result;
		}		
		
		public function setOccupyData(result:Object):void {
			if (this.monster) {
				result.monster = this.monster.getData();
			}
			if(this.heroCatch)
				result.heroCatch = this.heroCatch.getData();
				
			if(this.xianHe)
				result.xianhe = this.xianHe.getData();
				
			if(this.greateWall)
				result.wall = this.greateWall.getData();
			if(this.estates.length)
				result.estate = this.estates.map(function(item:EntityEstate, i:int, arr:Array):Object{return item.getData(); });
			if (this.editData.occupySet && this.editData.occupy2.length > 0) {
				result.occupy = this.editData.occupy2;
			}
		}
		
		
		override public function get type():int {
			return ConfigConstant.ENTITY_CITY;
		}
		
		public function get fire():Boolean {
			return this._fire;
		}
		
		public function set fire(value:Boolean):void {
			var fireEvent:Boolean = this._fire != value;
			this._fire = value;
			if (fireEvent) this.event(EventConstant.CITY_FIRE, this);
		}
		
		public function get ftask():ModelFTask {
			return this._ftask;
		}
		
		public function set ftask(value:ModelFTask):void {
			if (this._ftask == value) return;
			
			this._ftask = value;
			if (this._ftask) {
				this._ftask.on(ModelFTask.EVENT_UPDATE_FTASK, this, this.onFtaskUpdateHandler);
				this._ftask.on(ModelFTask.EVENT_REMOVE_FTASK, this, this.onFtaskUpdateHandler);
				this.onFtaskUpdateHandler(null);
			}
		}
		
		public function get gtask():EntityGtask {
			return this._gtask;
		}
		
		public function set gtask(value:EntityGtask):void {
			this._gtask = value;
			this.event(EventConstant.UPDATE_GTASK);
		}
		
		
		private function onFtaskUpdateHandler(e:*):void {
			if (this._ftask.status == 1) {//领取的话 生成地图的entity。
				var taskData:Object = ConfigServer.ftask["people_task"][this._ftask.task_id];
				var type:int = parseInt(taskData["type"]);
				
				
				if (type < 2) {				
					if (!this.ftaskEntity) {
						this.ftaskEntity = new EntityFtask();
						this.ftaskEntity.city = this;
						this.ftaskEntity.initConfig(this._ftask);
					}
					
				}
			} else {
				if (this.ftaskEntity) {
					this.ftaskEntity.clear();
					this.ftaskEntity = null;
				}
			}
			this.event(ModelFTask.EVENT_UPDATE_FTASK);
		}
		
		
		public function getGreatWallDist(entityCity:EntityCity):Number {
			for (var bid:String in this._data["build"]) {			
				var gw:Object = ModelCityBuild.getGreatWall(this.cityId.toString(), bid, true);
				if (gw[entityCity.cityId]) return gw[entityCity.cityId];
			}
			return 10;
		}
		
		public function geAlltNearDist():Object {
			var result:Object = {};
			for (var i:int = 0, len:int = this.nearCitys.length; i < len; i++) {
				result[EntityCity(this.nearCitys[i]).cityId] = {isWall:false, path:EntityCity.getPathDist(this, EntityCity(this.nearCitys[i]))};
			}
			//检查长城的。
			if (this.cityType == 3 && this.isFaith && !ModelFTask.ftaskModels[this.cityId.toString()]) {
				for (var bid:String in ModelOfficial.cities[this.cityId.toString()].build) {
					var gw:Object = ModelCityBuild.getGreatWall(this.cityId.toString(), bid, false);
					for (var name:String in gw) {
						result[name] = {isWall:true, path:gw[name]};
					}
				}
			}
			return result;
		}
		
		public function get faithCountry():int {
			if(this._data["faith"])
			{
				return this._data["faith"][0];
			}
			return -1;
		}
		public function get isFaith():Boolean {
			return this._data["faith"] && this._data["faith"][0] == ModelManager.instance.modelUser.country;
		}
		
		public static function getConnectKey(cityId1:int, cityId2:int):String {
			return cityId1 > cityId2 ? cityId2 + "_" + cityId1 : cityId1 + "_" + cityId2;
		}
		
		public static function getPathData(city1:EntityCity, city2:EntityCity):* { return getPathDataById(city1.cityId, city2.cityId); }
		
		public static function getPathDataById(city1:int, city2:int):* { return ConfigConstant.mapData.path[city1 + "_" + city2] || ConfigConstant.mapData.path[city2 + "_" + city1]; }
		
		public static function getPathDistById(city1:int, city2:int):Number {
			var pathData:Object = getPathDataById(city1, city2);
			if (pathData) return pathData.dis || (pathData.path.length - 1) * ConfigConstant.WAY_DIST_UNIT;
			//不然就是长城建筑 从city里面自己取。
			
			return EntityCity(MapModel.instance.citys[city1]).getGreatWallDist(EntityCity(MapModel.instance.citys[city2]));;
		}
		
		
		
		public static function getPathDist(city1:EntityCity, city2:EntityCity):Number {
			return getPathDistById(city1.cityId, city2.cityId);
		}
		
		public function getMarchRate():Array {
			return [LogicOperation.armyGo2(this.cityId), LogicOperation.armyFood2(this.cityId)];
		}
		
		public function getFaithRate():Array {
			return [LogicOperation.armyGo3(this.cityId), 0];
		}
		
		/**
		 * 获取两个城市的拐点。
		 * @param	city1
		 * @param	city2
		 * @return
		 */
		public static function getAllTurnPath(city1:int, city2:int):Array {
			var pathData:Object = EntityCity.getPathDataById(city1, city2);
			var path:Array = null;
			if (!pathData) {
				path = [
						Vector2D(EntityCity(MapModel.instance.citys[city1]).mapGrid.toString2()),
						Vector2D(EntityCity(MapModel.instance.citys[city2]).mapGrid.toString2())
					];
			} else {
				path = pathData.path.concat();
				if(city1 > city2) {
					path = path.reverse();
				}
			}			
			
			var turnArr:Array = [];
			
			var f:int = 0;
			var iii:int = 0;
			for (var j:int = 0, len2:int = path.length - 1; j < len2; j++) {
				
				var grid1:Vector2D = Vector2D.toVector(path[j]);
				var grid2:Vector2D = Vector2D.toVector(path[j + 1]);
				
				var gridX1:Vector2D = MapUtils.tileToIso(grid1);
				var gridX2:Vector2D = MapUtils.tileToIso(grid2);
				
				if(f == 0) {
					f = gridX1.x == gridX2.x ? 1 : -1;
					turnArr.push([grid1, j]);
					iii = 0;
				} else if((f == 1 && gridX1.x != gridX2.x) || (f == -1 && gridX1.y != gridX2.y)) {
					turnArr.push([grid1, j]);
					f = -f;
					iii = 0;
				}
				iii++;
			}
			var grid:Vector2D = Vector2D.toVector(path[path.length - 1]);
			turnArr.push([grid, path.length - 1, j]);
			return turnArr;
			
		}
		
		public function setWordData(wordData:Object):void {			
			this.fight = wordData.fight;
			this.fire = this.fight != null;
			this.country = wordData.country;
			if (!this.myCountry && this.fight != null) {
				this.isDetect = this.fight["country_logs"][ModelManager.instance.modelUser.country.toString()];
			} else {
				this.isDetect = false;
			}
			//
			//var arr:Array = [-1, 137];
			//for (var i:int = 0, len:int = arr.length; i < len; i++) {
				//if (ArrayUtils.contains(this.cityId, arr)) {
					//this.country = 5;
				//} else {
					//this.country = 5;
				//}
			//}
			//if (this.country == 1) this.country = 5;
			//if (this.country == 2) this.country = 5;
			
			//arr = [283, 69, 284];
			//for (i = 0, len = arr.length; i < len; i++) {
				//if (ArrayUtils.contains(this.cityId, arr)) {
					//this.country = 1;
				//}			
			//}
			//if (this.cityId == 146 || this.cityId == 148 || this.cityId == 149 || this.cityId == 162 || this.cityId == 161 || this.cityId == 144 || this.cityId == 143) {
				//this.country = 2;
			//}
			//if (this.cityId == 140) {
				//this.country = 0;
			//}
			//if (this.cityId == 147) {
				//this.country = 0;
			//} else {
				//this.country = 2;
			//}
			//
			//if (this.country == 2) {
				//this.country = 5;
			//}
		}
		

		public static function getEntityCity(cid:*):EntityCity {
			return MapModel.instance.citys[cid];
		}

		
		/**
		 * 导出临近的城市ids, type0我方1敌方-1任意    （dir0右上1右下2左下1左上）
		 */
		public static function exportNearCitys(cid:int, type:int = -1):Array {
			var entity:EntityCity = getEntityCity(cid);
			var arr:Array = [];
			
			for (var i:int = 0, len:int = entity.nearCitys.length; i < len; i++) {
				var nearCity:EntityCity = entity.nearCitys[i];
				if ((type == 0 && !nearCity.myCountry) || (type == 1 && nearCity.myCountry))
					continue;
				
				var path:Array = EntityCity.getPathDataById(entity.cityId, nearCity.cityId).path.concat();
				//目标格子
				var str:String = (entity.cityId < nearCity.cityId ? path[1] : path[path.length - 2]);
				Vector2D.toVector(str, "_", Vector2D.TEMP);
				//起始方向
				var dir:int = MapUtils.getGridDir(entity.mapGrid, MapModel.instance.mapGrid.getGrid(Vector2D.TEMP.x, Vector2D.TEMP.y));
				//直线方向角度
				var angle:Number = (entity.mapGrid.toScreenPos().subtract(nearCity.mapGrid.toScreenPos())).angle;
				
				arr.push({cid:nearCity.cityId, dir:dir, angle:angle});		
			}
			return arr;
		}
		
		public function removeTroop(modelTroop:ModelTroop):void {
			ArrayUtils.remove(modelTroop, this.myTroops);
			this.event(EventConstant.TROOP_REMOVE, modelTroop);
		}
		
		public function addTroop(modelTroop:ModelTroop):void {
			ArrayUtils.push(modelTroop, this.myTroops);
			this.event(EventConstant.TROOP_CREATE, modelTroop);
		}
		
		public function getTroop(states:Array = null):Array {
			return this.myTroops.filter(function(item:ModelTroop, index:int, arr:Array):Boolean {
				return states ? ArrayUtils.contains(item.state, states) : true;
			});
		}
		
		/**
		 * 检查城市是否能进行建造（或任命太守）
		 */
		public function get canBuild():Boolean {
			return (ConfigServer.world['cityTypeCanBuild'] as Array).indexOf(this.cityType) !== -1;
		}
		
		public function get buff_corps():Boolean {
			return this._buff_corps;
		}
		
		public function set buff_corps(value:Boolean):void {			
			this._buff_corps = value;
			this.event(EventConstant.BUFF_CORPS);
		}
		
		override public function clear():void {			
			for (var i:int = 0, len:int = this.occupyGrids.length; i < len; i++) {
				MapGrid(this.occupyGrids[i]).removeOccupyEntity(this);
			}
			super.clear();
		}
		
		/**
		 * 是否侦查过。要显示白框。
		 */
		public function get isDetect():Boolean {
			//return true;
			//襄阳战开启时候。。 这些城都可以被侦查。
			if (this.cityId < 0 && ModelManager.instance.modelCountryPvp.checkActive()) {
				return true;
			}
			return this.myCountry || this._isDetect;
		}
		
		public function set isDetect(value:Boolean):void {
			var old:Boolean = this._isDetect;
			this._isDetect = value;				
			if (old != this._isDetect) {
				MapModel.instance.event(EventConstant.CITY_DETECT, [this]);
				this.event(EventConstant.CITY_DETECT);
			}
			
		}
		
		public function get country():int {
			return this._country;
		}
		
		public function set country(value:int):void {
			if (value == this._country) return;			
			this._country = value;			
			this._map.event(EventConstant.CITY_COUNTRY_CHANGE, this);
			this.event(EventConstant.CITY_COUNTRY_CHANGE);
		}
		
		public function reset(data:Object):void {
			this.setWordData(data);
			if (this.view && !this.view.destroyed) this.view.reset();
		}
	}

}