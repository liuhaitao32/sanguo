package sg.model
{
	import sg.cfg.ConfigServer;
	import sg.map.utils.ArrayUtils;
	import sg.utils.Tools;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.view.map.ViewEstateHeroInfo;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.view.map.ViewEventTalk;
	import sg.utils.StringUtil;
	import sg.utils.ObjectUtil;

	/**
	 * ...
	 * @author
	 */
	public class ModelCityBuild extends ModelBase{
		
		public static var EVENT_UPDATE_CITY_BUILD:String="event_update_city_build";
		public static var EVENT_ADD_CITY_BUILD:String="event_add_city_build";
		public static var EVENT_REMOVE_CITY_BUILD:String="event_remove_city_build";

		public var _showObj:Object;
		public var cityBuildHero:ModelMapHero;

		public static var cityBuildModels:Object={};
		public var city_id:String;
		public var build_id:String;

		public function get b_lv():Number{
			return ModelOfficial.cities[city_id].build[build_id][0];
		}

		public function get b_exp():Number{
			return ModelOfficial.cities[city_id].build[build_id][1];
		}
		

		public function ModelCityBuild(cid:String,bid:String){
			initData(cid,bid);
		}


		public function initData(cid:String,bid:String):void{
			this.city_id=cid;
			this.build_id=bid;
			cityBuildHero=new ModelMapHero(2,{"cid":cid,"bid":bid});
		}

		public function get showObj():Object{
			_showObj = {hid:cityBuildHero.hid, rid:this.cityBuildHero.getRidURL(), "event":cityBuildHero.event_id!="", finish:cityBuildHero.isFinish};
			//_showObj = {hid:"hero701", rid:"", "event":false, finish:false};
			//trace("===================",_showObj);
			return _showObj;
		}

		public static function addCityBuild(cid:String,bid:String, firEvent:Boolean = true):void{
			var cbm:ModelCityBuild=new ModelCityBuild(cid,bid);
			cityBuildModels[cid] ||= {};
			cityBuildModels[cid][bid] = cbm;
			if(firEvent) ModelManager.instance.modelGame.event(ModelCityBuild.EVENT_ADD_CITY_BUILD,cbm);
			trace("========增加了一个城市建筑",cid,bid);
		}

		public static function initCityBuild():void{
			var user_city_build:Object=ModelManager.instance.modelUser.city_build;
			for(var s:String in user_city_build){
				var o:Object=user_city_build[s];
				for(var ss:String in o){
					addCityBuild(s, ss, false);
				}
			}
			//trace("========初始化所有citybuild",cityBuildModels);
		}

		public static function removeCityBuild(cid:String, bid:String):void {
			var cbm:ModelCityBuild = getCityBuild(cid, bid);
			if(cbm){
				cbm.event(ModelCityBuild.EVENT_REMOVE_CITY_BUILD,cbm);
				delete cityBuildModels[cid][bid];
				trace("========删除了一个城市建筑",cid,bid);
			}else{
				trace("========没有这个城市建筑remove",cid,bid);
			}
			
		}

		public static function updateCityBuild(cid:String,bid:String):void{
			var cbm:ModelCityBuild = getCityBuild(cid, bid);
			if(cbm){
				cbm.event(ModelCityBuild.EVENT_UPDATE_CITY_BUILD,cbm);
				trace("========更新了一个城市建筑",cid,bid);
			}else{
				trace("========没有这个城市建筑update",cid,bid);
			}
		}
		
		public static function getCityBuild(cid:String, bid:String):ModelCityBuild {
			cityBuildModels[cid] ||= {};
			return cityBuildModels[cid][bid];
		}

		public function click():void{
			var obj:Object=ModelManager.instance.modelUser.city_build;
			if(!obj[this.city_id] || !obj[this.city_id][this.build_id]){
				trace("======model city build error:not exist");
				return;
			}
			if(cityBuildHero.event_id!=""){
				var arr:Array=[cityBuildHero.event_id,2,{"cid":this.city_id,"bid":this.build_id}];
				ViewManager.instance.showView(["ViewEventTalk",ViewEventTalk],arr);
			}else if(cityBuildHero.isFinish){
				NetSocket.instance.send("city_build_reward",{cid:city_id,bid:build_id},new Handler(this,function(np:NetPackage):void{
					ModelManager.instance.modelUser.updateData(np.receiveData);
					ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
					ModelManager.instance.modelUser.event(ModelUser.EVENT_CITY_BUILD_MAIN);
					ModelCityBuild.removeCityBuild(city_id,build_id);
				}));
			}else{
				ViewManager.instance.showView(["ViewEstateHeroInfo",ViewEstateHeroInfo],[2,this.city_id,{cid:this.city_id,bid:this.build_id}]);
			}
		}
		

		

		/**
		 * 获得含有该建筑的所有城市id
		 */
		public static function getCityArrById(bid:String):Array{
			var arr:Array=[];
			var blv:String=ConfigServer.city_build.buildall[bid].build_lv;
			var lv_arr:Array=[];
			for(var s:String in ConfigServer.city_build.infrastructure){
				var a:Array=ConfigServer.city_build.infrastructure[s];
				if(a.indexOf(blv)!=-1){
					lv_arr.push(Number(s));
				}
			}
			var aa:Array=ModelOfficial.getMyCities(ModelUser.getCountryID());
			for(var i:int=0;i<aa.length;i++){
				var ss:String=aa[i].cid;
				if(ConfigServer.city[ss].cityType){
					if(lv_arr.indexOf(ConfigServer.city[ss].cityType)!=-1){
						arr.push(ss);
					}else if(ConfigServer.city[ss].build){
						if(ConfigServer.city[ss].build.hasOwnProperty(bid)){
							arr.push(ss);
							
						}
					}
				}
			}

			return arr;
		}

		
		public static function getEffectValue(cid:String, type:int):Number {
			var result:Number = 0;
			for (var bid:String in ModelOfficial.cities[cid].build) {
				var lv:int = getBuildLv(cid, bid);
				if (!lv) continue;
				var index:int = ConfigServer.city_build["buildall"][bid]["type"].indexOf(type);
				if (index == -1) continue;
				result += ConfigServer.city_build["buildall"][bid]["effect"][lv - 1][index];
			}
			return result;			
		}
		

		/**
		 * 获得某个城市某个建筑的等级
		 */
		public static function getBuildLv(cid:String,bid:String):Number{
			if(ModelOfficial.cities[cid].build[bid]){
				return ModelOfficial.cities[cid].build[bid][0];
			}			
			return -1;
		}
		/**
		 * 获得城市的名字
		 */
		public static function getCityName(bid:String):String{
			if(ConfigServer.city.hasOwnProperty(bid)){
				return Tools.getMsgById(ConfigServer.city[bid].name);
			}else{
				return "";
			}
		}



		public static function getGreatWall(cid:String, bid:String, notCheck:Boolean):Object {
			var unLock:Object = ConfigServer.city_build["buildall"][bid]["unlock"];
			
			//'unlock':{
				//'2':['1',['111'],400],		#泾阳111
				//'4':['1',['107'],400],		#咸阳107
				//'6':['1',['104'],400],		#高奴104
				//'8':['1',['106'],400],		#新平106
			//},
			var result:Object = {};
			for (var name:String in unLock) {
				if (unLock[name][0] != "1") continue;
				if (notCheck || ModelCityBuild.getBuildLv(cid, bid) >= parseInt(name)) {
					result[unLock[name][1][0]] = unLock[name][2];
				}
			}
			return result;
		}
		
		public static function getGreatWall2(cid:String, bid:String):Array {
			var unLock:Object = ConfigServer.city_build["buildall"][bid]["unlock"];
			
			//'unlock':{
				//'2':['1',['111'],400],		#泾阳111
				//'4':['1',['107'],400],		#咸阳107
				//'6':['1',['104'],400],		#高奴104
				//'8':['1',['106'],400],		#新平106
			//},
			var result:Array = null;
			for (var name:String in unLock) {
				if (unLock[name][0] != "1") continue;				
				result ||= [];				
				result.push({open:ModelCityBuild.getBuildLv(cid, bid) >= parseInt(name), city:unLock[name][1][0], f:parseInt(name)});
			}
			if(result) result = ArrayUtils.sortOn(["f"], result);
			return result;
		}
		
		public static function getGreatWall3(cityId:String):Array {
			for (var bid:String in ModelOfficial.cities[cityId].build) {
				var gw:Array = ModelCityBuild.getGreatWall2(cityId.toString(), bid);
				//key 是目的地 value 是代表是否解锁。
				if (gw) {
					return gw;
				}
			}
			return gw;
		}
		
		public static function getChangeChengId(cityId:String):String {
			for (var bid:String in ModelOfficial.cities[cityId].build) {
				var gw:Array = ModelCityBuild.getGreatWall2(cityId.toString(), bid);
				//key 是目的地 value 是代表是否解锁。
				if (gw) {
					return bid;
				}
			}
			return null;
		}

		/**
		 * 获取指定城市建设度
		 * @param	cid 城市ID
		 * @return
		 */
		public static function getBuildRatio(cid:String):String {
			if(!ConfigServer.city.hasOwnProperty(cid)){
				trace('-----error cid',cid);
				return "";
			}
			var obj:Object=ModelOfficial.cities[cid].build;
			var config_city_build:Object=ConfigServer.city_build.buildall;
			
			var build:Object={};
			for(var bId:String in obj){
				build[bId]=obj[bId][0];
			}
			var init_city_build:Object=ConfigServer.city[cid].build;
			var total_build:Object=ObjectUtil.mergeObjects([build,init_city_build]);

			var totalLv:Number=0;
			var totalLv_max:Number=0;
			for(var key:String in total_build){
				var bLv:Number=0;
				if(build.hasOwnProperty(key)){
					bLv=build[key];
				}else{
					bLv=init_city_build[key];
				}
				totalLv+=bLv;
				totalLv_max+=config_city_build[key].max_lv;
				//trace("-----------",key,bLv);
			}
			return totalLv==0 || totalLv_max==0 ? "0%" : StringUtil.numberToPercent(totalLv / totalLv_max);
		}

		/**
		 * 建设度加成
		 */
		public static function getBuildAdd(cid:String):Number{
			var obj:Object=ModelOfficial.cities[cid].build;
			var config_city_build:Object=ConfigServer.city_build.buildall;
			var n:Number=0;
			for(var s:String in obj){
				var arr:Array=config_city_build[s].type;
				if(arr && arr.indexOf(12)!=-1){
					var m:Number=arr.indexOf(12);
					var bLv:Number=obj[s][0];
					var mm:Number=bLv==0 ? 0 : config_city_build[s].effect[bLv-1][m];
					n+=mm;
				}
			}
			return n;
		}

		/**
		 * 城市建筑增加的资源值
		 * cid 城市id  rid 资源id
		 */
		public static function getResouceByCity(cid:String,rid:String):Number{
			var b_obj:Object=ModelOfficial.cities[cid].build;
			var config_build:Object=ConfigServer.city_build.buildall;
			var captainBlv:Number=getBuildLv(ModelUser.getCaptainID(ModelManager.instance.modelUser.country)+"","b18");//郿坞
			var other_num:Number=0;
			if(captainBlv>0){
				var arr:Array=config_build["b18"].type;
				if(arr.indexOf(18)!=-1){
					other_num=config_build["b18"].effect[captainBlv-1][arr.indexOf(18)];
				}
			}
			var n:Number=0;//+
			var m:Number=0;//*
			for(var b_id:String in b_obj){
				var nn:Number=0;
				var mm:Number=0;
				var type_arr:Array=config_build[b_id].type;
				switch(rid){
					case "gold":
						nn=1;
						mm=4;
					break;
					case "food":
						nn=2;
						mm=5;
					break;
					case "coin":
						nn=3;
					break;
				}
				var b_lv:Number=b_obj[b_id][0];
				if(b_lv>0){
					if(type_arr.indexOf(nn)!=-1){
						n+=config_build[b_id].effect[b_lv-1][type_arr.indexOf(nn)];
					}else if(type_arr.indexOf(mm)!=-1){
						m+=config_build[b_id].effect[b_lv-1][type_arr.indexOf(mm)];
					}
				}
				
			}
			if(rid=="food"){
				m+=other_num;
			}
			//trace("====================",cid,rid,Math.floor(n*(1+m)));
			return Math.floor(n*(1+m));
		}
	}

}