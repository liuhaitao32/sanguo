package sg.model {
	import laya.maths.MathUtil;
	import laya.utils.Browser;
	import laya.utils.Handler;
	import sg.cfg.ConfigServer;
	import sg.fight.FightMain;
	import sg.fight.client.ClientBattle;
	import sg.fight.client.unit.ClientTeam;
	import sg.fight.client.unit.ClientTroop;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.model.CountryArmy;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.map.model.entitys.EntityMarch;
	import sg.map.utils.LogicOperation;
	import sg.map.utils.TestUtils;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.scene.constant.ConfigConstant;
	import sg.scene.constant.EventConstant;
	import sg.utils.Tools;
	import sg.utils.MusicManager;
	import sg.map.utils.ArrayUtils;
	import sg.guide.model.ModelGuide;
	/**
	 * ...
	 * @author light
	 */
	public class ModelTroopManager extends ModelBase {
		public var troops:* = {};
		private var initCallBack:Handler;
		public function ModelTroopManager() {
			super();
		}
		
		public function reload(callBack:Handler):void {
			for (var name:String in troops) {
				troops[name].setDead();
			}
			
			troops = {};
			ModelManager.instance.modelTroopManager.event(EventConstant.TROOP_REMOVE, {model:null});
			
			//发送后端数据请求地图逻辑
			NetSocket.instance.send(EventConstant.TROOP_GET_MY_TROOPS, null, new Handler(this, function(pkg:NetPackage):void{				
				this.parseData(pkg.receiveData);				
				callBack.run();
			}));
			
		}
		
		public function init(callBack:Handler):void {
			if (ConfigConstant.isEdit) {
				return;
			}
			this.initCallBack = callBack;
			var events:Array = [
				EventConstant.TROOP_MARCH_STATE_CHANGE,
				EventConstant.TROOP_MARCH_MOVE,
				EventConstant.TROOP_MARCH_REMOVE,
				EventConstant.TROOP_REMOVE,
				EventConstant.JOIN_FIGHT,
				EventConstant.FIGHT_END,
				EventConstant.FIGHT_FINISH_FIGHT,
				EventConstant.COUNTRY_ARMY_DEAD
			]
			
			for (var i:int = 0, len:int = events.length; i < len; i++) {
				NetSocket.instance.registerHandler(events[i], new Handler(this, this.onTroopHandler));
			}			
			
			//发送后端数据请求地图逻辑
			NetSocket.instance.send(EventConstant.TROOP_GET_MY_TROOPS, null, new Handler(this, function(pkg:NetPackage):void{
				trace("初始化部队");
				this.parseData(pkg.receiveData);
				callBack.run();
			}));
			ModelManager.instance.modelCountryPvp.on(ModelCountryPvp.EVENT_XYZ_MOVE_SPEED, this, this.xyzSpeedUp);
		}
		
		private function xyzSpeedUp(speed:int):void {
			for (var name:String in MapModel.instance.marchs) {
				var march:EntityMarch = MapModel.instance.marchs[name];
				if (march.startCity.cityId < 0) {
					march.setRate(march.rate2);
				}
			}
		}
		
		private function parseData(receiveData:*):void {
			for (var name:String in receiveData) {
				receiveData[name]["uid"] = ModelManager.instance.modelUser.mUID;
				var troop:ModelTroop = new ModelTroop(receiveData[name]);
				this.troops[troop.id] = troop;
			}
		}
		
		public function canRecall(hid:String):Boolean {
			var march:EntityMarch = MapModel.instance.marchs[ModelManager.instance.modelUser.mUID + "&" + hid];
			if (!march) {
				// trace("找不到部队");
				return false;
			} else if(march.index > 0){
				// trace("已经经过城市" + march.index);
				return false;
			}else if(ConfigServer.getServerTimer() - march.startTime * 1000 > ConfigServer.world["troop_move_dismiss_limit_time"] * 1000){
				// trace("超出时间" + Browser.now() + " " + (Browser.now() - march.startTime * 1000));
				return false;
			} else if(march.rate2 != 1) {
				// trace("加速过");
				return false;
			} else if (march.moveType != 0) {
				// trace("突进或者撤军不能撤回" + march.moveType);
				return false;
			}
			
			return true;
		}
		
		private function onTroopHandler(pkg:NetPackage):void {
			var data:* = null;
			var troop:ModelTroop = null;
			var march:EntityMarch = null;
			var hmd:ModelHero;
			var id:String = null;
			var mids:String ="mid";
			switch(pkg.receiveMethod) {
				case EventConstant.TROOP_CREATE://添加
					id = ModelManager.instance.modelUser.mUID;
					pkg.sendData.uid = ModelManager.instance.modelUser.mUID;
					mids+=ModelManager.instance.modelUser.mUID;
					hmd = ModelManager.instance.modelGame.getModelHero(pkg.sendData.hid);
					ModelManager.instance.modelGame.creatNewTroopID[hmd.id] = 1;
					pkg.sendData["army"] = pkg.receiveData.hp;
					troop = new ModelTroop(pkg.sendData);
					troop.reset();
					if(pkg.sendData.is_xyz) troop.cityId = -10-ModelManager.instance.modelUser.country;//国阵
					this.troops[troop.id] = troop;
					break;
				case EventConstant.TROOP_REMOVE://移除
					id = ModelManager.instance.modelUser.mUID + "&" + pkg.receiveData.hid;
					mids += ModelManager.instance.modelUser.mUID;
					troop = this.troops[id];
					//在这里需要增加判断，如果部队所在城市非本国城市或城市正在点火，判断部队等级或兵力
					//b弹出提示：XX部队等级不足，
					if (pkg.receiveData.type){
						var type:int = pkg.receiveData.type;
						var heroConfig:Object = ConfigServer.hero[pkg.receiveData.hid];
						var heroName:String = Tools.getMsgById(heroConfig.name);
						var ec:EntityCity = troop.entityCity;

						if (type == 1)
						{
							ViewManager.instance.showTipsTxt(Tools.getMsgById('troopRemove1', [heroName, ec.getName(), ec.getLimitLevel()]),6);
						}
						else if (type == 2)
						{
							ViewManager.instance.showTipsTxt(Tools.getMsgById('troopRemove2', [heroName]),5);
						}
						else if (type == 3)
						{
							ViewManager.instance.showTipsTxt(Tools.getMsgById('troopRemove3', [heroName]),5);
						}
					}
					
					troop.setDead();
					delete this.troops[id];
					MapModel.instance.removeMarch(id);
					break;
				case EventConstant.TROOP_ADD_NUM://补兵 ?????
					id = ModelManager.instance.modelUser.mUID + "&" + pkg.sendData.hid;
					mids+=ModelManager.instance.modelUser.mUID;	
					troop = this.troops[id];
					if (troop) {
						hmd = ModelManager.instance.modelGame.getModelHero(pkg.sendData.hid);
						troop.setData({army:pkg.receiveData.hp});
					}
					break;				
				case EventConstant.TROOP_MARCH_STATE_CHANGE://撤回 加速
					id = pkg.receiveData.uid + "&" + pkg.receiveData.hid;
					mids+=pkg.receiveData.uid;
					troop = this.troops[id];
					if (troop) {
						troop.setData(pkg.receiveData);					
					}
					if (pkg.receiveData.status == ModelTroop.TROOP_STATE_RECALL){
						MapModel.instance.recallMarch(id);
					} else if (pkg.receiveData.status == ModelTroop.TROOP_STATE_MOVE) {
						MapModel.instance.marchSpeedUp(id, pkg.receiveData);
					}
					
					break;
				case EventConstant.TROOP_MARCH_MOVE://行军创建
					id = pkg.receiveData.uid + "&" + pkg.receiveData.hid;
					mids+=pkg.receiveData.uid;
					troop = this.troops[id];
					if (troop) {
						troop.setData(pkg.receiveData);
					}
					MapModel.instance.createMarch(pkg.receiveData);
					MapModel.instance.createCountyArmy(pkg.receiveData);
					break;
				case EventConstant.TROOP_MARCH_REMOVE://行军到达
					id = pkg.receiveData.uid + "&" + pkg.receiveData.hid;
					mids+=pkg.receiveData.uid;
					troop = this.troops[id];
					if (troop) {
						var state:int = troop.state;
						troop.setData(pkg.receiveData);
						if(state == ModelTroop.TROOP_STATE_RECALL) troop.entityCity.addTroop(troop);//就是为了派事件。 本质不是加进去。
					}
					MapModel.instance.removeMarch(id);
					break;
				case EventConstant.JOIN_FIGHT://行军到达备战
					id = ModelManager.instance.modelUser.mUID + "&" + pkg.receiveData.hid;
					mids+=ModelManager.instance.modelUser.mUID;
					troop = this.troops[id];
					if (troop) {
						troop.state = ModelTroop.TROOP_STATE_IDLE;	
						troop.setData(pkg.receiveData)
					}					
					MapModel.instance.removeMarch(id);
					break;
				case EventConstant.FIGHT_READY://备注改变排队。
					id = ModelManager.instance.modelUser.mUID + "&" + pkg.receiveData.hid;
					mids+=ModelManager.instance.modelUser.mUID;
					troop = this.troops[id];
					if(troop) troop.setData(pkg.receiveData);
					break;
				case EventConstant.FIGHT_FINISH_FIGHT://部队完成战斗，改变部队排队
					id = ModelManager.instance.modelUser.mUID + "&" + pkg.receiveData.hid;
					mids+=ModelManager.instance.modelUser.mUID;
					troop = this.troops[id];
					if (troop) {
						troop.setData(pkg.receiveData);
						if (troop.deaded) {
							troop.setDead();
							delete this.troops[id];
						}
					}
					ModelManager.instance.modelUser.updateData(pkg.receiveData);
					var rewardObj:Object = pkg.receiveData.npc_reward;
					if (rewardObj){
						var o:Object;
						if (rewardObj is Array){
							o = {};
							var arr:Array = rewardObj as Array;
							for(var i:int=0;i<arr.length;i++){
								var a:Array=arr[i];
								if(o.hasOwnProperty(a[0])){
									o[a[0]]=o[a[0]]+a[1];
								}else{
									o[a[0]]=a[1];
								}
							}
						}
						else{
							o = rewardObj;
						}
						ViewManager.instance.showReward(o,false);
					}
					break;
				case EventConstant.FIGHT_END://如果这个城市里有我方部队 就派发事件
					id = ModelManager.instance.modelUser.mUID;
					mids+=ModelManager.instance.modelUser.mUID;
					var b:Boolean = false;
					for (var name:String in this.troops) {
						if(ModelTroop(this.troops[name]).cityId == parseInt(pkg.receiveData.city.cid)) {
							ModelTroop(this.troops[name]).index = -1;
							b = true;;
						}
					}
					if (!b) return;
					break;
				case EventConstant.MARCH_CREATE://行军创建，什么也不做
					MusicManager.playSoundUI(MusicManager.SOUND_TROOP_MOVE);
					break;
				case EventConstant.TROOP_BREAK://战斗中突进
				case EventConstant.TROOP_RUN_AWAY://战斗中撤军
					//此消息以后改为 w.exit_fight_follow 之后删除
					//var battle:ClientBattle = FightMain.instance.client;
					//if (battle)
					//{
						//battle.removeTroopBySocket(parseInt(ModelManager.instance.modelUser.mUID), pkg.sendData.hid, -1);
					//}
					
					break;
				case EventConstant.COUNTRY_ARMY_DEAD:
					var uid:String = pkg.receiveData.uid;
					var countryArmy:CountryArmy = CountryArmy.map[uid];
					if (countryArmy) countryArmy.destroy();
					break;
			}

			ModelManager.instance.modelUser.updateData(pkg.receiveData);
			this.event(pkg.receiveMethod, {model:troop,mid:mids});
			if (troop) troop.event(pkg.receiveMethod, troop);
		}
		
		
		public function monster(type:String, hid:String, data:*):void {
		}
		
		/**
		 * 获取我自己的某个英雄的行军对象
		 */
		public function getTroop(heroId:String, uid:* = -1):ModelTroop {
			if (uid < 0){
				uid = ModelManager.instance.modelUser.mUID;
			}
			return this.troops[uid + "&" + heroId];
		}
		
		/**
		 * 获取到某一个城市的我当前所有行军的对象。
		 * @param	cityId 目的地城市id
		 * @param  onlyHero -1所有部队  0本城部队 1本城除外部队
		 * @return [{model:ModelTroop, canMove:false, time:1(秒)}]
		 */
		public function getMoveCityTroop(cityId:int,onlyHere:Number = 0,troopId:String = null,onlyFree:Boolean=false):Array {
			var pathDic:Object = this.getPathDic();
			var result:Array = [];
			
			
			for (var name:String in this.troops) {
				if (troopId && name != troopId){
					//突进撤军用，只遍历单部队
					continue;
				}
				
				var troop:ModelTroop = this.troops[name];
				var pushData:Object = {f:0, model:troop, type:0, time:0, food:0};

				if (troop.cityId == cityId) {
					pushData.type = -1; //本城
					if(onlyHere != -2) pushData.f = 2147483647 / 2;
				}else if(troop.state != ModelTroop.TROOP_STATE_IDLE || troop.isReadyFight) {
					pushData.type = -2;//不是闲置
					pushData.f = 2147483647 / 2 + 10;
				} else {
					if(onlyHere == -2) {
						pushData.type = 0;//直接就可以取出来的。搞不懂他们为什么用这方法额。
					} else if (!MapModel.instance.mapGrid.astarFind.searchCity(MapModel.instance.citys[troop.cityId.toString()], MapModel.instance.citys[cityId.toString()], pathDic)) {
						pushData.type = -3;//到达不了目的地
						pushData.f = 2147483647 / 2 + 20;
					} else if(onlyHere != -2){
						var aimCity:EntityCity = MapModel.instance.citys[cityId];
						var errorType:int = 0;
						if (!MapModel.instance.citys[cityId].myCountry){
							//目的地是敌城，优先显示不能攻城的理由
							errorType = aimCity.getAttackError(troop, false);
						}

						if (errorType != 0){
							pushData.type = -100 + errorType;//该英雄不可攻城
							pushData.f = 2147483647 / 2 + 30;
						} else {
							
							var maxFood:Number = LogicOperation.armyFood(troop.getModelHero().army[0], troop.army[0]) + LogicOperation.armyFood(troop.getModelHero().army[1], troop.army[1]);
							
							if (onlyHere!=0){							
								for (var k:int = 0, len3:int = MapModel.instance.mapGrid.astarFind.path.length - 1; k < len3; k++) {
									var c1:EntityCity = MapModel.instance.mapGrid.astarFind.path[k];
									var c2:EntityCity = MapModel.instance.mapGrid.astarFind.path[k + 1];
									var c_c:String = EntityCity.getConnectKey(c1.cityId, c2.cityId);
									
									var r1:Number = (pathDic[c_c] ? pathDic[c_c][0] : 0) + 1;
									var r2:Number = (pathDic[c_c] ? pathDic[c_c][1] : 0) + 1;
									
									pushData.f += EntityCity.getPathDist(c1, c2) / r1;
									//trace(c_c, maxFood, EntityCity.getPathDist(c1, c2), r2, (maxFood * EntityCity.getPathDist(c1, c2)) / r2)
									pushData.food += (maxFood * EntityCity.getPathDist(c1, c2)) / r2;
								}	
							}
							pushData.food = parseInt(pushData.food);
							var armyGo:Number = LogicOperation.armyGo(troop.hero);
							var xyzRate:Number = cityId < 0 ? ModelManager.instance.modelCountryPvp.getSpeedNum() : 1;
							var buff2:Array = ModelFightTask.instance.buff;
							var fightTastRate:Number = (buff2[1] || 0) + 1;
							pushData.time = parseInt((pushData.f / armyGo / xyzRate / fightTastRate).toString()) + 1;
							pushData.citys = MapModel.instance.mapGrid.astarFind.path.concat();
						}
					}
					
					
					
				}
				if(onlyHere==0){
					var b:Boolean = onlyFree?(troop.state==ModelTroop.TROOP_STATE_IDLE):true;
					if(pushData.type == -1 && b ){
						pushData["pwd"] = ModelManager.instance.modelGame.getModelHero(troop.hero).getPower()*-1;
						result.push(pushData);
					}
				}else if(onlyHere==-1 || onlyHere == -2){
					pushData["pwd"] = ModelManager.instance.modelGame.getModelHero(troop.hero).getPower()*-1;
					result.push(pushData);
				}else if(onlyHere==1){
					if(pushData.type != -1){
						pushData["pwd"] = ModelManager.instance.modelGame.getModelHero(troop.hero).getPower()*-1;
						result.push(pushData);
					}
				}
				/*
				if((onlyHere && pushData.type == -1) || !onlyHere){
					if(onlyHere){
						pushData["pwd"] = ModelManager.instance.modelGame.getModelHero(troop.hero).getPower()*-1;
					}
					result.push(pushData);
				}*/
			}
			if(onlyHere==0){
				result = result.sort(MathUtil.sortByKey("pwd"));
			}
			else{
				//result = result.sort(MathUtil.sortByKey("f"));
				ArrayUtils.sortOn(["f","pwd"],result);
			}
			// trace(result);
			return result;		
		}
		
		public function setTroopData(type:String, heroId:String, data:Object):void {
			var troop:ModelTroop = this.getTroop(heroId);
			if (!troop) {
				// trace("找不到当前部队！" + heroId);
				return;
			}
			switch(type) {
				case EventConstant.TROOP_UPDATE:
					troop.setData(data);
					break;
			}
			if (troop.deaded) {
				troop.setDead();
				delete this.troops[troop.id];
			}
			this.event(type, {model:troop, mid:"mid" + ModelManager.instance.modelUser.mUID});
			troop.event(type);
		}
		
		/**
		 * 重新铺一遍路网。 把所有驿站的比率 叠加起来。
		 * @return
		 */
		private function getPathDic():Object {			
			var citys:Array = MapModel.instance.getMyCountryCitys({"isFaith":true});//这个是自己国家。 后端可以写成取得某个国家的路网。
			//citys.push(MapModel.instance.citys["160"]);
			//citys.push(MapModel.instance.citys["161"]);
			var pathDic:Object = {};
			for (var i:int = 0, len:int = citys.length; i < len; i++) {
				var city:EntityCity = citys[i];
				for (var j:int = 0, len2:int = city.nearCitys.length; j < len2; j++) {
					//检查信仰过 铺路。
					var parent:EntityCity = city;
					var city2:EntityCity = city.nearCitys[j];
					this.setCityDic(parent, city2, pathDic, city.getFaithRate());//设置这段路的系数。
					if (city.cityType == ConfigConstant.CITY_TYPE_FORT || !city.myCountry) continue;
					//驿站等等加速。
					this.setCityDic(parent, city2, pathDic, city.getMarchRate());//设置这段路的系数。
					//如果是要塞 往下查找。
					while (city2.cityType == ConfigConstant.CITY_TYPE_FORT && city2.nearCitys.length == 2) {
						//要塞一定是两个 这个是达哥说的。 所以这里就不循环找节点判断了。
						var nextCity:EntityCity = city2.nearCitys[0] == parent ? city2.nearCitys[1] : city2.nearCitys[0];
						this.setCityDic(city2, nextCity, pathDic, city.getMarchRate());
						parent = city2;
						city2 = nextCity;
					}
				}
			}
			
			
			//腹地。。。
			
			return pathDic;
		}
		
		
		public function setCityDic(city1:EntityCity, city2:EntityCity, dic:Object, arr:Array):void {
			
			var n:String = EntityCity.getConnectKey(city1.cityId, city2.cityId);			
			dic[n] ||= [0, 0];
			dic[n][0] += arr[0];
			dic[n][1] += arr[1];
		}
		public function isMax():Boolean{
			var num:Number = 0;
			if(this.troops){
				for(var key:String in this.troops)
				{
					num+=1;
				}
			}
			if(num>=ModelManager.instance.modelUser.troop_que_max()){
				return true;
			}
			return false;
			
		}
		
		public function deleteXYZTroop():void {
			for (var id:String in this.troops) {				
				
				var troop:ModelTroop = this.troops[id];
				var mids:String = "mid" + ModelManager.instance.modelUser.mUID;
				if (troop.cityId >= 0) continue;
				//if (pkg.receiveData.type){
					//var type:int = pkg.receiveData.type;
					//var heroConfig:Object = ConfigServer.hero[pkg.receiveData.hid];
					//var heroName:String = Tools.getMsgById(heroConfig.name);
					//var ec:EntityCity = troop.entityCity;
					//ViewManager.instance.showTipsTxt(Tools.getMsgById('troopRemove1', [heroName, ec.getName(), ec.getLimitLevel()]),6);						
				//}
				
				troop.setDead();
				delete this.troops[id];
				//MapModel.instance.removeMarch(id);
				
				this.event(EventConstant.TROOP_REMOVE, {model:troop,mid:mids});
				troop.event(EventConstant.TROOP_REMOVE, troop);
			}
			//移除行军。
			for (var name:String in MapModel.instance.marchs) {
				if (EntityMarch(MapModel.instance.marchs[name]).startCity.cityId > 0) continue;
				MapModel.instance.removeMarch(name);
			}
			
			//
		}
		
//——————————————————————————————————网络——————————————————————————————————————————————
		
		
		public function sendMoveTroops(datas:Array):void {
			var params:Array = [];
			for (var i:int = 0, len:int = datas.length; i < len; i++) {
				params.push({hid:datas[i].model.hero, city_list:datas[i].citys.map(
					function(city:EntityCity):int {
						return city.cityId;
					}
				)});
			}
			
			NetSocket.instance.send(EventConstant.MARCH_CREATE, params, Handler.create(this, this.onTroopHandler));
		}
		
		public function sendRemoveTroops(hero:String,forceDel:Boolean):void {
			NetSocket.instance.send(EventConstant.TROOP_REMOVE, {hid:hero,force:forceDel});
		}
		public function sendAddArmyNumTroops(hero:String,isPay:Boolean =false):void {
			NetSocket.instance.send(EventConstant.TROOP_ADD_NUM, {hid:hero,is_pay:isPay}, Handler.create(this, this.onTroopHandler));
		}			
		public function sendCreateTroops(hero:String,isPay:Boolean =false,isXYZ:Boolean=false):void {
			//新手引导时，在主城创建部队
			if(ModelGuide.isNewPlayerGuide()) isXYZ = false;
			NetSocket.instance.send(EventConstant.TROOP_CREATE, {hid:hero,is_pay:isPay,is_xyz:isXYZ}, Handler.create(this, this.onTroopHandler));
		}
		
		public function sendSpeedUpTroops(hero:String, n:Number,cb:Handler):void {
			NetSocket.instance.send(EventConstant.TROOP_MARCH_SPEED_UP, {hid:hero, index:n},cb);
		}
		
		public function sendRecallTroops(hero:String):void {
			NetSocket.instance.send(EventConstant.TROOP_MARCH_RECALL, {hid:hero});
		}
		/**
		 * 突进到某城
		 */
		public function sendBreakTroops(hero:String, city_list:Array):void {
			NetSocket.instance.send(EventConstant.TROOP_BREAK, {hid:hero, city_list:city_list}, Handler.create(this, this.onTroopHandler));
		}
		/**
		 * 撤军到某城
		 */
		public function sendRunAwayTroops(hero:String, city_list:Array):void {
			NetSocket.instance.send(EventConstant.TROOP_RUN_AWAY, {hid:hero, city_list:city_list}, Handler.create(this, this.onTroopHandler));
		}
		
	}

}