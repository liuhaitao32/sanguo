package sg.cfg
{
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.test.TestFightData;
	import sg.scene.constant.ConfigConstant;
	import sg.utils.Tools;
	import sg.manager.ModelManager;
	import sg.utils.SaveLocal;
	import sg.net.NetSocket;
	import sg.manager.ViewManager;
	import sg.zmPlatform.ConstantZM;
	
	/**
	 * 服务器上的配置
	 * @author
	 */
	public class ConfigServer
	{
		private static var serverNow:Number = 0;
		private static var runGameStartTimer:Number = 0;
		private static var longAdjusted:Boolean = false;

		//
		public static var msg:Object = null;
		public static var config:Object = null;//全部配置
		public static var system_simple:Object = null;//系统杂项全配置
		public static var pay_config:Object = null;
		public static var pay_config_pf:Object = null;
		public static var help_msg:Object = null;
		public static var country:Object = null;//国家
		//
		public static var home:Object = null;//内城封地
		//public static var home_test:Object = null;//封地TEST
		
		public static var hero:Object = null;//英雄
		public static var property:Object = null;//仓库道具
		public static var pub:Object = null;//酒馆
		public static var army:Object = null;//兵种
		public static var skill:Object = null;//技能
		public static var equip:Object = null;//宝物
		public static var shop:Object = null;//商店
		public static var star:Object = null;//星辰
		public static var fate:Object = null;//宿命
		public static var map:* = null;//地图
		public static var zone:Object;//分区
		public static var zone_pf:Object;//分区的pf划分
		//public static var climb:Object;//过关斩将
		public static var pk:Object;//群雄逐鹿
		public static var guild:Object;//军团
		public static var office:Object;//爵位		
		static public var city:Object = null;//城市
		static public var inborn:Object = null;//天赋
		static public var world:Object = null;//世界
		static public var pve:Object = null;//沙盘演义
		public static var fight:Object;//战斗
		public static var effect:Object;//特效
		public static var pk_yard:Object;//比武大会
		public static var title:Object;//称号
		public static var shogun:Object;//幕府
		public static var equip_wash:Object;//宝物洗炼
		public static var estate:Object;//产业
				
		public static var festival:Object; // 节日活动
		public static var visit:Object;//拜访
		public static var science:Object;//科技
		public static var science_type:Object;//科技
		public static var credit:Object;//战功
		public static var gtask:Object;//政务
		public static var city_build:Object;//城市建筑
		public static var pk_npc:Object;//异族入侵
		public static var ftask:Object;//民情
		public static var guide:Object;//引导
		public static var task:Object;//任务
		public static var effort:Object;//成就
		public static var pk_robot:Object;//机器人配置
		public static var attack_city_npc:Object;//黄巾军配置
		public static var npc_info:Object;//斥候情报
		public static var country_pvp:Object;//襄阳争夺战
		public static var notice:Object; // 公告
		public static var country_club:Object;
		public static var mining:Object; // 蓬莱寻宝
		public static var legend:Object; // 见证传奇
		public static var award:Object; // 奖池
		public static var country_army:Object; //国家军队
		public static var bless_hero:Object; // 福将挑战
		public static var bless_hero_npc:Object; // 福将挑战
		public static var arena:Object; // 擂台赛
		public static var beast:Object; // 兽灵
		public static var legend_awaken:Object; // 传奇觉醒
		public static var new_task:Object;//朝廷密旨

		//国王英雄立绘
		public static function get country_king_icon():Array{
			if(ConfigServer.system_simple.king_img){
				return ConfigServer.system_simple.king_img;	
			}
			return ["hero762","hero763","hero764"];
		}
		//国家任务里用的立绘
		public static function get country_task_icon():Array{
			if(ConfigServer.system_simple.country_task_img){
				return ConfigServer.system_simple.country_task_img;	
			}
			return ["hero762","hero763","hero764"];
		}
		//
		public static var skill_type_dic:Object = {};

		public static var honour:Object;//赛季


		public static function get ploy():Object{
			if(ModelManager.instance.modelUser.isMerge){//合服后使用新的活动配置
				return ConfigServer.config['ploy_merge_' + ModelManager.instance.modelUser.mergeNum];
			}
			return ConfigServer.config["ploy"];
		}

		public static function get climb():Object{
			if(ModelManager.instance.modelUser.isMerge){//合服后使用新的过关斩将配置
				return ConfigServer.config["climb_new"];
			}
			return ConfigServer.config["climb"];
		}

		/**
		 * 宝物制作特殊列表
		 */
		public static function get equip_make_special():Object{
			//if(ModelManager.instance.modelUser.isMerge){
			//	return ConfigServer.config.system_simple["equip_make_special_new"];
			//}
			return ConfigServer.system_simple["equip_make_special"];
		}

		public static var config_dict:Object; // 配置文件的配置文件
		public static function updateConfig():void {
			ConfigServer.config = {};
			for(var key:String in config_dict) {
				var url:String = config_dict[key];
				var jsonData:Object = Laya.loader.getRes(url);
				ConfigServer[key] = ConfigServer.config[key] = jsonData;
			}
			Tools.sMsgDic = ConfigServer.msg = ConfigServer.config["return_msg"];

			if (ConfigApp.hasDocument){
				ConfigServer.property = ConfigServer.config["prop"];//
				ConfigServer.science_type = ConfigServer.science["science_type"];//
				//
				ConfigServer.checkSkillType();
				//
				NetSocket.timeOutTimer = ConfigServer.system_simple.hasOwnProperty("net_timeout")?ConfigServer.system_simple.net_timeout:15000;//网络超时时间
			}
			else{
				//纯服务器js用，勿删
				ConfigServer.initData();
			}
		}
		
		public static function formatTo(cfg:Object,isMidUpdate:Boolean):void
		{
			var key:String;
			ConfigApp.cfgVersion = Number(cfg["cfg_version"]);//cfg版号
			if(isMidUpdate){
				var newCfg:Object = cfg["cfg"];
				if(newCfg){
					//把新的合并到本地cfg上
					for(key in newCfg){
						ConfigServer.config[key] = newCfg[key];
					}
				}
			} else {
				ConfigServer.config = cfg["cfg"];//
			}

			// trace("--------配置文件版本----",ConfigApp.cfgVersion,ConfigServer.config);
			//
			if (ConfigApp.configTemp){
				var localCfg:Object = ConfigServer.getLocalCfg();
				
				if(localCfg){
					//把新的合并到本地cfg上
					for(key in ConfigServer.config){
						localCfg[key] = ConfigServer.config[key];
					}	
					ConfigServer.config = localCfg;	
				}
			}
			//
			for(key in ConfigServer.config) {
				ConfigServer[key] = ConfigServer.config[key];
			}
			
			//临时使用home_test 取代home
			//if(ConfigApp.isNewHome)
				//ConfigServer.home = ConfigServer.home_test;
			////
			Tools.sMsgDic = ConfigServer.msg = ConfigServer.config["return_msg"];//文本配置缓存
			// var out:String = "";
			// var va:Object = {};
			// for(var key2:String in Tools.sMsgDic){
			// 	if(!va[Tools.sMsgDic[key2]]){
			// 		va[Tools.sMsgDic[key2]]=Tools.sMsgDic[key2];
			// 		out+=Tools.sMsgDic[key2]+"\n";
			// 	}
			// }	
			// trace(out);

			if (ConfigApp.hasDocument){
				ConfigServer.property = ConfigServer.config["prop"];//
				ConfigServer.science_type = ConfigServer.science["science_type"];//
				//
				ConfigServer.checkSkillType();
				//
				NetSocket.timeOutTimer = ConfigServer.system_simple.hasOwnProperty("net_timeout")?ConfigServer.system_simple.net_timeout:15000;//网络超时时间
				
				Trace.log("----服务器配置---"+Tools.getTimeStyle(ConfigServer.getServerTimer(),3), cfg);
				if(ConfigApp.configTemp){
					ConfigServer.setLocalCfg(ConfigServer.config);//最新版本cfg存储在本地
					ConfigServer.setLocalCfgVersion(ConfigApp.cfgVersion);//cfg版本号存储
				}
			}
			else{
				//纯服务器js用，勿删
				ConfigServer.initData();
			}
			//

		}
		public static function initData():void{
			ConfigFight.init();
			//
			if (ConfigApp.testFightType != 1)
			{
				ConfigConstant.init();
			}
			if (ConfigApp.hasDocument){
				ModelManager.instance.modelProp.initProp(ConfigServer.property);
				ConfigAssets.noAtlasAnimations = ConfigServer.effect.noAtlasAnimations;
				ConfigFightView.init();
			}
			ViewManager.instance.event(ViewManager.EVENT_SHOW_CAROUSE);
		}	
		
		public static function checkServerTime(serverTime:Number, force:Boolean = false):void {
			var localTime:int = new Date().getTime();
			if(isNaN(serverTime) || serverTime<=0){
				return;
			}
			// 第一次校准  或者长连返回才校准
			if (serverNow === 0 || force && (longAdjusted === false || serverTime > (serverNow + (localTime - runGameStartTimer)))) {
				longAdjusted || (longAdjusted = force);
				serverNow = serverTime;
				runGameStartTimer = localTime;
			}
		}
		public static function checkSkillType():void{
			for(var key:String in skill){
				if (key.indexOf("skill") >-1){
					var skillObj:Object = skill[key];
					if (skillObj.hasOwnProperty('type')){
						var type:int = skillObj.type;
						if(!skill_type_dic[type]){
							skill_type_dic[type] = {};
						}
						skill_type_dic[type][key] = skill[key];
					}
				}
			}
		}		
		/**
		 *
		 * 服务器当前时间戳,毫秒
		 */
		public static function getServerTimer():Number
		{
			return ConfigServer.serverNow + (new Date().getTime() - ConfigServer.runGameStartTimer);
			// return ConfigServer.serverNow+(Laya.timer.currTimer-ConfigServer.runGameStartTimer);
		}

		public static function getLocalCfg():Object{
			return SaveLocal.getValue(SaveLocal.KEY_SERVER_CFG);
		}
		public static function setLocalCfg(cfg:Object):void{
			SaveLocal.save(SaveLocal.KEY_SERVER_CFG,cfg);
		}		
		public static function getLocalCfgVersion():Number{
			return Number(SaveLocal.getValue(SaveLocal.KEY_SERVER_CFG_VERSION));
		}
		public static function setLocalCfgVersion(version:Number):void{
			SaveLocal.save(SaveLocal.KEY_SERVER_CFG_VERSION,version);
		}	
		//
		public static function checkZonePfIsOK(zoneID:*):Boolean{
			var b:Boolean = false;
			var pf:String = ConfigApp.pf;
			if (ConstantZM.platform) {
				pf = ConstantZM.platform; // 阿拉丁 速易
			}
			var zid:String = zoneID+"";
			if(ConfigServer.zone_pf && ConfigServer.zone_pf[zid]){
				var cfg:Array = ConfigServer.zone_pf[zid];
				var isTrue:Array = cfg[0];
				if(isTrue && isTrue.length!=0){
					if(isTrue.indexOf(pf)>-1){
						b = true;
					}
					else{
						b = false;
					}
				}
				else{
					var others:Array = cfg[1];
					b = true;
					if(others && others.length!=0){
						if(others.indexOf(pf)>-1){
							b = false;
						}
					}
				}
				
			}
			else{
				b = true;
			}
			return b;
		}	
		public static function checkIsChangeCurrPfTo():void{
			var b:Boolean = false;
			var lastUser:Object = SaveLocal.getValue(SaveLocal.KEY_USER);
			var zoneId:String = null;
			if(lastUser && lastUser.z){
				zoneId = lastUser.z+"";
			}
			if(ConfigApp.changeZonePf && ConfigApp.changeZonePf == "yes"){
				if(ConfigServer.system_simple.pf_change_zone){
					var cfg:Object = ConfigServer.system_simple.pf_change_zone;
					var zones:Array = cfg[ConfigApp.myPackagePf];
					if(zones){
						if(zones && zones.length>0){
							if(zones.indexOf(zoneId)>-1){
								b = true;
							}
						}
						else{
							b = true;
						}
					}
					else{
						b = true;
					}
				}else{
					b = true;
				}
			}
			if(b){
				ConfigApp.pf = ConfigApp.PF_and_1;
			}

			if(ConfigServer.pay_config && ConfigServer.pay_config.pf && ConfigServer.pay_config.pf[ConfigApp.pf]){
				ConfigServer.pay_config_pf = ConfigServer.pay_config.pf[ConfigApp.pf];
			}
			else{
				ConfigServer.pay_config_pf = ConfigServer.pay_config;
			}
			
		}
		
		public static function checkServerIsMade(zone:*):Boolean{
			// return true;
			if(ConfigServer.system_simple.service_info){
				//全服维护
				if(ConfigServer.system_simple.service_info[0]==0) return true;
			}
			var id:String = zone+"";
			var b:Boolean = false;
			var arr:Array = ConfigServer.system_simple.service_zone_list;
			var mergeZone:String = ConfigServer.zone[zone][7];
			if(arr){
				var len:int = arr.length;
				var ids:String = "";
				for(var i:int = 0; i < len; i++)
				{
					ids = arr[i]+"";
					if(ids == id || ids == mergeZone){
						b = true;
						break;
					}
				}
			}
			return b;
		}
		public static function checkServerIsMadeTxt(zone:*):String{
			if(checkServerIsMade(zone)){
				return Tools.getMsgById("_public236");
			}
			return "";
		}
		public static function getAttackNpcConfig(id:String):Object {
			if (id == "thief_three") return ConfigServer.country_pvp[id];
			return ConfigServer.attack_city_npc[id];
		}
		/**
		 * 开服超过这个分钟数禁止玩家注册新号 == pf 获取配置，否则看 forbid_new
		 */
		public static function getForbidNewTime():Number{
			if(ConfigServer.system_simple.forbid_new_pf && ConfigServer.system_simple.forbid_new_pf[ConfigApp.pf]){
				return ConfigServer.system_simple.forbid_new_pf[ConfigApp.pf]*Tools.oneMinuteMilli;
			}
			return ConfigServer.system_simple.forbid_new*Tools.oneMinuteMilli;
		}
	}

}