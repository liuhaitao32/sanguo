package sg.model
{
	import sg.cfg.ConfigColor;
	import ui.inside.pubItemUI;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import laya.maths.MathUtil;
	import sg.manager.AssetsManager;
	import sg.utils.ObjectUtil;
	import sg.festival.model.ModelFestival;
	import sg.manager.ViewManager;
	import sg.map.utils.ArrayUtils;
	import sg.model.ModelCounter;

	/**
	 * ...
	 * @author
	 */
	public class ModelHero extends ModelBase{
		public static const NAEM_HEAD:String = "hero";
		public static const NAEM_ITEM_HEAD:String = "item";
		public static var BEST_HID:String = "";
		public static var festivalHids:Array;//节日活动投放的英雄

		public static function setFestivalHids():void{
			festivalHids=[];
			var o:Object={};
			var cfg:Object=ConfigServer.festival;
			for(var s:String in cfg){
				if(cfg[s].about_hero){
					var arr:Array=cfg[s].about_hero;
					var n:Number=Tools.getTimeStamp(arr[1]);
					if(o.hasOwnProperty(arr[0])){
						var nn:Number=o[arr[0]][0];
						if(nn>n){
							o[arr[0]]=[nn,n];
						}else{
							if(o[arr[0]][1]){
								if(nn>o[arr[0]][1]){
									o[arr[0]]=[n,nn];
								}
							}else{
								o[arr[0]]=[n,nn];
							}
						}
					}else{
						o[arr[0]]=[n];
					}
				}
			}
			//开服时间
			var startTime:Number = ModelManager.instance.modelUser.gameServerStartTimer;
			//注册时间
			var addTime:Number = Tools.getTimeStamp(ModelManager.instance.modelUser.add_time);
			//取较小值
			startTime = startTime < addTime ? startTime : addTime;
			//当前时间
			var curTime:Number=ConfigServer.getServerTimer();
			for(var hid:String in o){
				if(o[hid][1]){
					if(startTime<o[hid][1] && curTime>o[hid][1]){//倒数第二期之前开服的 倒数第二期时间之后可见
						continue;
					}else if(startTime>o[hid][1] && startTime<o[hid][0] && curTime>o[hid][0]){//倒数第二期到最后一期开服的 最后一期之后可见
						continue;
					}
				}else{//仅有一期
					if(startTime<o[hid][0] && curTime>o[hid][0]){
						continue;
					}
				}
				festivalHids.push(hid);
			}
			trace("festivalHideHero",festivalHids);

		}
		/**
		 * 设置战斗力最高的英雄id
		 */
		public static function setBestHid():void{
			var h:*=ModelManager.instance.modelUser.getMyHeroArr(true)[0];
			if(h){
				ModelHero.BEST_HID=h.id;
			}
		}

		//
		public static const super_hero_bg:String="actPay1_14.png";
		public static const img_awaken_normal:String="actPay1_19.png";
		public static const img_awaken_normal_s:String="actPay1_16.png";
		public static const img_awaken_super:String="actPay1_27.png";
		public static const img_awaken_super_s:String="actPay1_17.png";

		public static const rarity_name:Array = [
			Tools.getMsgById(90002),
			Tools.getMsgById(90003),
			Tools.getMsgById(90004),
			Tools.getMsgById(90005),
			Tools.getMsgById(90103)
		];
		public static const sex_name:Array = [
			Tools.getMsgById(90005),
			Tools.getMsgById("_hero2"),
		];		
		public static const rarity_skin:Array = [
			// "ui/icon_59.png",
			// "ui/icon_58.png",
			// "ui/icon_57.png",
			// "ui/icon_69.png",
			"icon_herologo04.png",
			"icon_herologo03.png",
			"icon_herologo01.png",
			"icon_herologo02.png",
			"icon_herologo00.png"
		];
		public static const rarity_skin_s:Array = [
			"icon_herologo08.png",
			"icon_herologo07.png",
			"icon_herologo05.png",
			"icon_herologo06.png",
			"icon_herologo09.png"
		];

		public static const type_name:Array = [
			Tools.getMsgById("_hero3"),
			Tools.getMsgById("_hero4"),
			Tools.getMsgById("_hero5")
		];
		public static const type_name_all:Array = [
			Tools.getMsgById("_hero6"),
			Tools.getMsgById("_hero7"),
			Tools.getMsgById("_hero8")
		];		
		public static const army_seat_name:Array = [
			Tools.getMsgById("rslt_army[0]"),
			Tools.getMsgById("rslt_army[1]")
		];
		public static const army_type_name:Array = [
			Tools.getMsgById("skill_type_0"),
			Tools.getMsgById("skill_type_1"),
			Tools.getMsgById("skill_type_2"),
			Tools.getMsgById("skill_type_3"),
			Tools.getMsgById("skill_type_4"),
			Tools.getMsgById("skill_type_5"),
			Tools.getMsgById("skill_type_6")
		];		

		public static const army_prop_name:Array = [
			Tools.getMsgById("_hero9"),
			Tools.getMsgById("_hero10"),
			Tools.getMsgById("_hero11"),
			Tools.getMsgById("_hero12")
		];
		public static const star_lv_name:Array = [
			Tools.getMsgById("_public165"),//"蓝色",
			Tools.getMsgById("_public166"),//"紫色",
			Tools.getMsgById("_public167"),//"橙色",
			Tools.getMsgById("_public168")//"红色"
		];	
		public static const shogun_name:Array=[
			Tools.getMsgById("90005"),
			Tools.getMsgById("_hero6"),
			Tools.getMsgById("_hero7"),
			Tools.getMsgById("_hero8"),
			Tools.getMsgById("skill_type_0"),
			Tools.getMsgById("skill_type_1"),
			Tools.getMsgById("skill_type_2"),
			Tools.getMsgById("skill_type_3")
		];
		public static const shogun_rank_color:Array=[
			AssetsManager.getAssetsUI("icon_grade01.png"),
			AssetsManager.getAssetsUI("icon_grade02.png"),
			AssetsManager.getAssetsUI("icon_grade03.png"),
			AssetsManager.getAssetsUI("icon_grade04.png"),
			AssetsManager.getAssetsUI("icon_grade05.png"),
			AssetsManager.getAssetsUI("icon_grade06.png")
		];
		public static const army_icon_ui:Array = [
			// "icon_bu.png",
			// "icon_qi.png",
			// "icon_gong.png",
			// "icon_nu.png"
			"army_01.png",
			"army_04.png",
			"army_02.png",
			"army_03.png"			
		];

		public static const army_icon_ui2:Array = [
			"icon_bu.png",
			"icon_qi.png",
			"icon_gong.png",
			"icon_nu.png"
		]

		public static const hero_card_bg:Array=[
			"bg_card03.png",
			"bg_card02.png",
			"bg_card01.png",
			"bg_card01.png"

		];

		public static const hero_4d_name:Array=[
			Tools.getMsgById("info_str"),Tools.getMsgById("info_agi"),Tools.getMsgById("info_cha"),Tools.getMsgById("info_lead")];
		/**
		 * 英雄子功能数据变化更新
		 */
		public static const EVENT_HERO_STAR_CHANGE:String = "event_hero_star_change";
		public static const EVENT_HERO_EXP_CHANGE:String = "event_hero_exp_change";
		public static const EVENT_HERO_ARMY_LV_CHANGE:String = "event_hero_army_lv_change";
		public static const EVENT_HERO_RUNE_CHANGE:String = "event_hero_rune_change";
		public static const EVENT_HERO_FATE_CHANGE:String = "event_hero_fate_change";
		public static const EVENT_HERO_TITLE_CHANGE:String = "event_hero_title_change";
		public static const EVENT_HERO_ADJUTANT_CHANGE:String = "event_hero_adjutant_change";
		public static const EVENT_HERO_LOOK_UP:String = "event_hero_look_up";
		public static const EVENT_HERO_FORMATION_CHANGE:String = "event_hero_formation_change";
		public static const EVENT_HERO_FORMATION_DELETE:String = "event_hero_formation_delate";
		public static const EVENT_HERO_BEAST_CHANGE:String = "event_hero_beast_change";


		public var id:String;
		public var index:int;
		public var cfg:Object;
		public var name:String;
		public var info:String;
		public var state:int;
		public var merge:int;
		public var open_date:Object;
		public var sex:int;
		public var rarity:int;//品质
		public var type:int;//文、武、all
		public var str:Number;//力量
		public var agi:Number;//智力//agi
		public var cha:Number;//魅力
		public var lead:Number;//统帅
		public var adjs:Array; // 优先安装的副将
		public var army:Array;//兵种 0：步兵 1：骑兵 2：弓兵 3：方士
		public var special:Array;//天赋
		public var skill:Object;//技能 - 有技能配置表
		public var fate:Object;//宿命
		public var resolve:Array;//问道
		public var block:int;//问道锁
		public var title:Array;//称号
		public var work:String;//产业or拜访
		public var adjutant:Array; // 副将
		public var beast_ids:Array; //兽灵
		
		
		//
		public var armyUpgrade:Array;//兵种等级[0,0]
		public var itemRuler:Number;//招募 碎片 个数
		public var itemID:String;//本英雄碎片 id
		public var mModelPrepare:ModelPrepare;
		public var fast_hero_star:Array;
		public var skillSelectIndexDic:int = 0;

		/**
		 * 宿敌
		 */
		public function get counter():Object{
			ModelCounter.isOpen();
			if(ModelManager.instance.modelUser.hero[this.id].counter){
				return ModelManager.instance.modelUser.hero[this.id].counter;
			}
			return null;
		}
		//
		public static var heroModels:* = {};
		//
		public var isOther:Boolean = false;
		public function ModelHero(other:Boolean = false){
			this.isOther = other;
		}
		public function initData(key:String,obj:Object):void{
			this.cfg = obj;
			this.id = key;
			for(var m:String in obj)
			{
				if(this.hasOwnProperty(m)){
					this[m] = obj[m];
				}
			}
			//
			this.itemRuler = Number(ConfigServer.system_simple.hero_buy[(rarity==4)?1:0]);
			this.itemID = this.id.replace(NAEM_HEAD,NAEM_ITEM_HEAD);
			//
		}
		

		/**
		 * 非我的英雄,数据初始化
		 * obj == 里面必须要有 英雄的配置id( id or hid)
		 */
		public function setData(obj:Object):void{
			this.mData = obj;
			var hid:String = "";
			if(obj.hasOwnProperty("id")){
				hid = obj.id;
			}
			else if(obj.hasOwnProperty("hid")){
				hid = obj.hid;
			}
			if(!Tools.isNullString(hid)){
				this.initData(hid,ConfigServer.hero[hid]);
			}
		}

		/**
		 * 四维总和
		 **/
		public function get sum():int{
			return this.str + this.agi + this.cha + this.lead;
		}
		/**
		 * 前后军等级 
		 **/
		public function get armyLv():Array{
			if(this.isMine()){
				var a:Array=ModelManager.instance.modelUser.hero[this.id].army;
				return a;
			}
			if(this.mData && this.mData.army){
				return [this.mData.army[0].lv,this.mData.army[1].lv];
			}
			return [0,0];
		}
		/**
		 * 前后军兵阶 
		 **/
		public function get armyRank():Array{
			var arr:Array=["building009","building010","building011","building012"];
			if(this.isMine()){
				var n0:Number=ModelManager.instance.modelInside.getBuildingModel(arr[this.army[0]]).lv - 1;
				var n1:Number=ModelManager.instance.modelInside.getBuildingModel(arr[this.army[1]]).lv - 1;
				if(n0<0) n0=0;
				if(n1<0) n1=0;
				var m0:Number=ConfigServer.system_simple.barracks[arr[this.army[0]]][n0][3];
				var m1:Number=ConfigServer.system_simple.barracks[arr[this.army[1]]][n1][3];
				return [m0,m1];
			}
			if(this.mData && this.mData.army){
				return [this.mData.army[0].rank,this.mData.army[1].rank];
			}
			return [0,0];
		}

		/**
		 * 是否可显示该英雄，可见show
		 */
		public function get isOpenState():Boolean{
			//如果我已获得，则显示
			var modelUser:ModelUser = ModelManager.instance.modelUser;
			if (modelUser.hero[this.id]){
				return true;
			}
			//如果我已获得道具碎片，则显示
			//if (this.getMyItemNum() > 0){
				//return true;
			//}
			
			//节日活动期间  不参与活动的区 不显示该英雄
			if(!ModelManager.instance.modelUser.isMerge){
				if(ModelHero.festivalHids.indexOf(this.id)!=-1){
					return false;
				}
			}

			//当前时间比设定开启时间晚
			if (this.open_date){
				if (ConfigServer.getServerTimer() < Tools.getTimeStamp(this.open_date)){
					return false;
				}
			}
			if (this.state <= 0){
				return false;
			}

			

						
			var mergeNum:int = modelUser.mergeNum;
			if (mergeNum > this.merge){
				return true;
			}
			else if (mergeNum < this.merge){
				return false;
			}
			else{
				if (this.state == 1){
					return true;
				}
				else if (this.state > 1){
					//已开服天数 >=this.state可显示
					return modelUser.getGameDate() >= this.state;
				}
			}

			return false;
		}

		public function getProp(key:String, hmp:ModelPrepare = null):Number{
			var num:int;
			if (hmp && hmp.getData().hasOwnProperty(key)){
				return hmp.getData()[key];
			}
			else if (this[key])
			{
				return this[key];
			}
			else if (this.cfg[key])
			{
				return this.cfg[key];
			}
			return 0;
		}
		public function getStr(hmp:ModelPrepare = null):Number{
			return this.getProp('str',hmp);
		}
		public function getInt(hmp:ModelPrepare = null):Number{
			return this.getProp('agi',hmp);
		}
		public function getCha(hmp:ModelPrepare = null):Number{
			return this.getProp('cha',hmp);
		}
		public function getLead(hmp:ModelPrepare = null):Number{
			return this.getProp('lead',hmp);
		}
		
		public function getType(all:Boolean = false):String{
			if(all){
				return type_name_all[this.type];
			}
			else{
				return type_name[this.type];
			}
		}
		/**
		 * 原始数据或配置
		 */
		public function getMyData():Object{
			if(this.isMine()){
				return ModelManager.instance.modelUser.hero[this.id];
			}
			else if(this.mData){
				return this.mData;
			}
			else{
				return null;//this.cfg;
			}
		}
		/**
		 * 称号
		 */
		public function getTitle():Array{
			var arr:Array = null;
			var heroData:Object = this.getMyData();
			if(heroData){
				if(heroData.hasOwnProperty("title")){
					arr = heroData["title"];
				}
			}
			return arr;
		}
		/**
		 * 副将
		 */
		public function getAdjutant():Array{
			var arr:Array = null;
			var heroData:Object = this.getMyData();
			if(heroData){
				if(heroData.hasOwnProperty("adjutant")){
					arr = heroData["adjutant"];
				}
			}
			return arr ? arr : [null, null];
		}

		public function getWork():String{
			var heroData:Object = this.getMyData();
			if(heroData){
				if(heroData.hasOwnProperty("work") && heroData["work"]){
					return heroData["work"];
				}
			}
			return "";
		}
		/**
		 * 检查,称号状态,返回称号 id,没有或过期为空
		 */
		public function getTitleStatus():String{
			var arr:Array = this.getTitle();
			var b:Boolean = false;
			if(arr){
				if(checkTitleIsOK(Tools.getTimeStamp(arr[1]))){
					b = true;
				}
			}
			return b?arr[0]:"";
		}
		public static function getTitleName(id:String):String{
			return Tools.getMsgById(id);
		}
		public static function getTitleInfo(id:String):String{
			return Tools.getMsgById("titleinfo_"+id.replace("title",""));
		}		
		public static function checkTitleIsOK(ms:Number):Boolean{
			return (ms>ConfigServer.getServerTimer());
		}
		/**
		 * 获得英雄所有技能 表， 如果不是我的英雄，则取得配置技能
		 */
		public function getMySkills():Object{
			var obj:Object = {};
			var heroData:Object = this.getMyData();
			var hadSkill:Boolean = false;
			if(heroData){
				if(heroData.hasOwnProperty("skill")){
					obj = heroData["skill"];
					hadSkill = true;
				}
			}
			
			if(!hadSkill){
				obj = Tools.copyObj(this.skill);
			}
			return obj;
		}
		/**
		 * 根据技能id 返回我的英雄该技能的初始等级 
		 */
		public function getMySkillInitLv(sid:String):Number{
			if(this.skill.hasOwnProperty(sid))
				return this.skill[sid];
			return 0;
		}
		/**
		 * 获得英雄 技能 哪种 类型 个数
		 */
		public function getMySkillsNum(skillType:int):Number{
			var obj:Object = this.getMySkills();
			var num:Number = 0;
			var skillModel:ModelSkill;
			for(var key:String in obj)
			{
				skillModel = ModelManager.instance.modelGame.getModelSkill(key);
				// trace(skillModel.type,skillType);
				if(skillType==skillModel.type){
					num+=1;
				}
			}
			return num;
		}
		/**
		 * 获得 英雄 技能 等级 上限
		 */
		public function getMySkillLimit(skillType:int):Number{
			if (skillType < 0)
				return 999;
			
			var cfg:Array = getSkillLimitCfg(skillType,this.rarity);
			var t:String = cfg[0];
			var arr:String = cfg[1];
			var v:Number = 0;
			if(t=="level"){
				v = this.getLv();
			}
			else if(t=="star"){
				v = this.getStar();
			}
			var len:int = arr.length;
			for(var i:int = 1; i < len; i++)
			{
				if(v<arr[i]){
					break;
				}
			}

			if(skillType==4){
				return i + ModelScience.func_sum_type(ModelScience.sex_skills,this.sex+"");
			}
			return i;
		}
		/**
		 * 技能是否有能够升级的,只判断了材料
		 */
		public function checkSkillWill(isUp:Boolean = false):Boolean{
			var arr:Array = [4,5];
			arr.unshift(this.army[0]);
			arr.unshift(this.army[1]);
			var len:int = arr.length;
			var m:Number;
			var n:Number;
			var skillCfg:Object;
			for(var i:int = 0;i < len;i++){
				m = this.getMySkillsNum(arr[i]);
				n = this.getMySkillLimit(arr[i]);
				if(ConfigServer.skill_type_dic[arr[i]]){
					skillCfg = ConfigServer.skill_type_dic[arr[i]];
					for(var key:String in skillCfg){
						var smd:ModelSkill = ModelManager.instance.modelGame.getModelSkill(key);
						if(smd.id=="skill288" && this.rarity == 4){
							//trace("传奇英雄不可学习豪杰");
						}else{
							var reData:Object = smd.isCanGetOrUpgrade(this);
						
							var pveArr:Array = ModelSkill.isCanLvUpByPVE(smd.getLv(this)+1);
					//
							var sk:String = ModelSkill.getSpecial(smd.id);
							var b:Boolean = sk?sk == this.id:true;
							
							var lv:Number = smd.getLv(this);
							if(!isUp && m<n && lv == 0 && smd.getMyItemNum()>=smd.getUpgradeItemNum(this) && reData.isOK && pveArr[0] && b){
								return true;
							}
							else if(isUp && lv > 0 && lv< smd.getMaxLv() && smd.getMyItemNum()>=smd.getUpgradeItemNum(this) && reData.isOK && pveArr[0] && b){
								return true;
							}
						}
					}					
				}
			}
			return false;
		}
		
		public function checkSkillWill2(index:int = -2):Boolean{
			var arr:Array = [index];
			var len:int = arr.length;
			var m:Number;
			var n:Number;
			var skillCfg:Object;
			for(var i:int = 0;i < len;i++){
				m = this.getMySkillsNum(arr[i]);
				n = this.getMySkillLimit(arr[i]);
				if(ConfigServer.skill_type_dic[arr[i]] || index < 0){
					skillCfg = index >= 0 ? ConfigServer.skill_type_dic[arr[i]] : this.getMySkills();
					for(var key:String in skillCfg){
						var smd:ModelSkill = ModelManager.instance.modelGame.getModelSkill(key);
						
						var reData:Object = smd.isCanGetOrUpgrade(this);
						
						var pveArr:Array = ModelSkill.isCanLvUpByPVE(smd.getLv(this)+1);
                //
						var sk:String = ModelSkill.getSpecial(smd.id);
						var b:Boolean = sk?sk == this.id:true;
						
						var lv:Number = smd.getLv(this);
						if(m<n && lv == 0 && smd.getMyItemNum()>=smd.getUpgradeItemNum(this) && reData.isOK && pveArr[0] && b){
							return true;
						}
						if(lv > 0 && lv< smd.getMaxLv() && smd.getMyItemNum()>=smd.getUpgradeItemNum(this) && reData.isOK && pveArr[0] && b){
							return true;
						}
					}					
				}
			}
			return false;
		}
		
		/**
		 * 技能 位, 开启 条件 文字
		 */
		public function getMySkillNextString(skillType:int):String{
			var cfg:Array = getSkillLimitCfg(skillType,this.rarity);
			var t:String = cfg[0];
			var arr:String = cfg[1];
			var h1:String = Tools.getMsgById("_hero1");//英雄//army_type_name[skillType];
			var h2:String = "";
			//
			var science_add:Number=0;
			if(skillType==4) science_add = ModelScience.func_sum_type(ModelScience.sex_skills,this.sex+"");
			var len:int = this.getMySkillLimit(skillType) - science_add;
			var v:int = 0;
			var str:String = "";
			if(len<arr.length){
				v = arr[len];
				if(t=="star"){
					h2 +=h1;
					h2 += getHeroStarColorName(v);
					h2 +=Tools.getMsgById("_hero13");//品质
				}
				else{
					h2 += h1;
					h2 += Tools.getMsgById("100001",[v]);//等级
					//h2 +=v+Tools.getMsgById("_hero14");//等级
				}
				str = Tools.getMsgById("_hero15")+h2;//下一技能位
			}
			return str;
		}
		/**
		 * 获得技能等级上限配置
		 */
		public static function getSkillLimitCfg(skillType:Number,heroRarity:Number):Array{
			if(heroRarity == 4){
				return ConfigServer.system_simple.skill_bag_limit_super[skillType];
			}
			else{
				return ConfigServer.system_simple.skill_bag_limit[skillType];
			}
		}
		/**
		 * 用户英雄自己的 前后军阶等级
		 */
		public function getMyArmyLv():Array{
			var arr:Array = [0,0];
			var heroData:Object = this.getMyData();
			if(heroData){
				if(heroData.hasOwnProperty("army")){
					arr = heroData["army"] as Array;
				}else if(heroData.hasOwnProperty("armyLv")){
					arr = [heroData["armyLv"],heroData["armyLv"]];
				}
			}
			return arr;
		}

        /**
		 * 获得前后军的名字
		 */
		public function getMyarmyName():Array{
			var lv_arr:Array=this.getMyArmyLv();
			var arr:Array=[Tools.getMsgById("_hero16",[lv_arr[0]])+ModelHero.army_type_name[this.army[0]],
				Tools.getMsgById("_hero16",[lv_arr[1]])+ModelHero.army_type_name[this.army[1]]];//"阶"
			return arr;
		}

		/**
		 * npc的兵营等级
		 */
		public function getNPCArmyRank():Number{
			var rank:Number=0;
			var heroData:Object = this.getMyData();
			if(heroData){
				if(heroData.hasOwnProperty("armyRank")){
					rank = heroData["armyRank"];
				}
			}
			return rank;
		}


		/**
		 * 获得 兵种的道具 个数
		 */
		public static function getArmyItemNum(propId:String):Number{
			var num:Number = 0;
			if(ModelManager.instance.modelUser.property.hasOwnProperty(propId)){
				num = ModelManager.instance.modelUser.property[propId];
			}
			return num;
		}
		/**
		 * 前/后军哪个,[0]前,[1]后
		 */
		public function getMyArmyItems(fb:int):Array{
			return getArmyItemsArr(this.getMyArmyLv()[fb],this.army[fb]);
		}
		/**
		 * 进阶材料配置
		 */
		public static function getArmyUpgradeCfg(armyLv:int):Array{
			var arr:Array = ConfigServer.army.upgrade_cost;
			var len:int = arr.length;
			var pArr:Array;
			var max:int=-1;
			for(var i:int = 0; i < len-1; i++)
			{
				pArr = arr[i];
				max = pArr[7];
				if(armyLv<max){
					break;
				}
			}
			return arr[i];
		}
		/**
		 * 兵阶 最大等级上限
		 */
		public static function getArmyUpgradeLvMax():Number{
			var arr:Array = ConfigServer.army.upgrade_cost[ConfigServer.army.upgrade_cost.length-1];
			return arr[arr.length-1];
		}
		/**
		 * 英雄前/后?,哪个等级?,进阶材料配置
		 */
		public static function getArmyItemsArr(armyLv:int,armyType:int):Array{
			var arr:Array = getArmyUpgradeCfg(armyLv);
			var gold:Number = arr[5][0]*(armyLv+1)+arr[5][1];
			var num:Number = arr[4][0]*(armyLv+1)+arr[4][1];
			//
			var itemArr:Array = arr[armyType];
			var len:int = itemArr.length;
			var itemNum:Number = 0;
			var normalNum:Number = 0;
			for(var i:int = 0; i < len; i++)
			{
				itemNum = getArmyItemNum(itemArr[i]);
				if(itemNum<num){
					normalNum+=(num-itemNum)*arr[6];
				}
			}
			//
			return [arr[armyType],num,gold,normalNum,arr[7]];
		}
		/**
		 * 检查 前后军队 是否开启了
		 */
		public function checkArmyIsOK(fb:int):Array{
			var type:int = this.army[fb];
			var bmd:ModelBuiding = ModelBuiding.getArmyBuildingByType(type);
			return [bmd.lv>0,bmd];
		}
		/**
		 * ModelPrepare 里面的 前/后军 的army 
		 */
		public function getArmyPrepare(fb:int,hmp:ModelPrepare):Object {
			var army:Array = hmp.getData().army;
			var armyObj:Object = army[fb];
			return armyObj
		}
		/**
		 * 获取 兵种 攻击
		 */
		public function getArmyAtk(fb:int,hmp:ModelPrepare):Number{
			// {"id":"army11","lv":0,"hpm":119,"spd":30,"def":80,"atk":218,"block":0,"crit":0,"resArmy3":0,"resArmy2":0,"resArmy1":0,"resArmy0":0,"resSkill1":0,"resSkill0":0,"resSex1":0,"resSex0":0,"resType2":0,"resType1":0,"resType0":0,"res":0,"dmgArmy3":0,"dmgArmy2":0,"dmgArmy1":0,"dmgArmy0":0,"dmgSkill1":0,"dmgSkill0":0,"dmgSex1":0,"dmgSex0":0,"dmgType2":0,"dmgType1":0,"dmgType0":0,"dmg":0,"hp":119}

			// return checkArmyByHeroAbility(this.army[fb],0,this);
			
			return this.getArmyPrepare(fb,hmp).atk;
		}
		/**
		 * 获取 兵种 防御
		 */
		public function getArmyDef(fb:int,hmp:ModelPrepare):Number{
			// return checkArmyByHeroAbility(this.army[fb],1,this);
			return this.getArmyPrepare(fb,hmp).def;		
		}
		/**
		 * 获取 兵种 速度
		 */
		public function getArmySpd(fb:int,hmp:ModelPrepare):Number{
			// return checkArmyByHeroAbility(this.army[fb],2,this);
			return this.getArmyPrepare(fb,hmp).spd;	
		}
		/**
		 * 获取 兵种 兵力
		 */
		public function getArmyHpm(fb:int,hmp:ModelPrepare):Number{
			// return checkArmyByHeroAbility(this.army[fb],3,this);
			return this.getArmyPrepare(fb,hmp).hpm;
		}
		/**
		 * 英雄 需要 补兵 的数量
		 */
		public function getArmyFillHpmArr():Array
		{
			this.mModelPrepare = this.getPrepare(true);
			var arr:Array = [Math.min(ModelBuiding.getArmyBuildingByType(this.army[0]).getArmyNum(),this.getArmyHpm(0,this.mModelPrepare)),Math.min(ModelBuiding.getArmyBuildingByType(this.army[1]).getArmyNum(),this.getArmyHpm(1,this.mModelPrepare))];
			return arr;
		}
		/**
		 * 获取 兵种 兵力 百分比
		 */		
		public function getArmyHpmPerc(hmp:ModelPrepare):Array{
			// return checkArmyByHeroAbility(this.army[fb],3,this);
			var myNum0:Number = ModelBuiding.getArmyBuildingByType(this.army[0]).getArmyNum();
			var heroMax0:Number = this.getArmyHpm(0,hmp);
			var myNum1:Number = ModelBuiding.getArmyBuildingByType(this.army[1]).getArmyNum();
			var heroMax1:Number = this.getArmyHpm(1,hmp);			
			return [[myNum0,heroMax0,Math.min(myNum0,heroMax0)/heroMax0],[myNum1,heroMax1,Math.min(myNum1,heroMax1)/heroMax1]];
		}		
		/**
		 * 英雄,总兵力上限
		 */
		public function getArmrHpmMax():Number{
			// return checkArmyByHeroAbility(this.army[fb],3,this);
			this.mModelPrepare = this.getPrepare(true);
			return (this.getArmyHpm(0,this.mModelPrepare)+this.getArmyHpm(1,this.mModelPrepare));
		}
		
		public function getLv():Number{
			var num:Number = 0;
			var heroData:Object = this.getMyData();
			if(heroData){
				if(heroData.hasOwnProperty("lv")){
					num = heroData["lv"];
				}
			}
			return num;
		}
		public function getExp():Number{
			var num:Number = 0;
			var heroData:Object = this.getMyData();
			if(heroData){
				if(heroData.hasOwnProperty("exp")){
					num = heroData["exp"];
				}
			}
			return num;
		}
		/**
		 * 获得等级经验值
		 */
		public function getLvExp(lv:Number):Number{
			var arr:Array = ConfigServer.system_simple.hero_exp as Array;
			var len:int = arr.length;
			var min:Number = 0;
			var index:int = -1;
			for(var i:int = 0; i < len; i++)
			{
				min = arr[i][0];
				if(lv<=min){
					index = i;
					break;
				}
			}
			if(index == -1 && lv>min){
				index = len-1;
			}
			var a:Number = arr[index][1];
			var b:Number = arr[index][2];
			return a*lv+b;
		}
		/**
		 * 获得 觉醒状态
		 */
		public function getAwaken():int{
			var heroData:Object = this.getMyData();
			if(heroData){
				if(heroData.hasOwnProperty("awaken")){
					return heroData["awaken"];
				}
			}
			return 0;
		}
		
		
		/**
		 * 后台数据包含阵法设置
		 */
		public function get hasFormation():Boolean{
			var heroData:Object = this.getMyData();
			if(heroData){
				if(heroData.hasOwnProperty("formation") || heroData.hasOwnProperty("formation_index")){
					return true;
				}
			}
			return false;
		};
		/**
		 * 获得 激活阵法索引
		 */
		public function get formation_index():Number{
			var heroData:Object = this.getMyData();
			if(heroData){
				if(heroData.hasOwnProperty("formation_index")){
					return heroData["formation_index"];
				}
			}
			return -1;
		};

		/**
		 * 获得 用户身上的阵法数据
		 */
		public function get formation():Array{
			var heroData:Object = this.getMyData();
			if(heroData){
				if(heroData.hasOwnProperty("formation")){
					return heroData["formation"];
				}
			}
			return [[0,0],[0,0],[0,0]];
		};

		/**
		 * 获得 星阶, 0~18
		 */
		public function getStar(hmp:ModelPrepare = null):Number{
			var num:Number = 0;
			var heroData:Object = hmp?hmp.data:this.getMyData();
			if(heroData){
				if(heroData.hasOwnProperty("hero_star")){
					num = heroData["hero_star"];
				}
			}
			return num;
		}
		/**
		 * 获得 最高星级18
		 */
		public static function getStarMax():Number{
			return ConfigServer.system_simple.hero_star.length;
		}
		/**
		 * 获得 当前爵位下最高星级
		 */
		public static function hero_star_lv_max():Number{
			return ConfigServer.system_simple.star_limit_init+ModelOffice.func_addstar();
		}	
		/**
		 * 星星 对应的颜色编号
		 */
		public function getStarGradeColor(hmp:ModelPrepare = null):int{
			return getHeroStarGradeColor(this.getStar(hmp));
		}
		/**
		 * hero_star转 显示星阶段
		 */
		public static function getHeroStarGrade(hs:Number):int{
			return Math.max(0,Math.min(3,Math.floor(hs/6)));
		}
		/**
		 * hero_star转 显示星阶段 颜色序列
		 */		
		public static function getHeroStarGradeColor(hs:Number):int{
			return getHeroStarGrade(hs)+2;
		}
		/**
		 * hero_star转 显示星阶段 str
		 */			
		public static function getHeroStarColorName(hs:Number):String{
			return star_lv_name[getHeroStarGrade(hs)];
		}			
		/**
		 * 是否能用 coin 升级
		 */
		public static function checkHeroStartUpByCoin(hid:String):Boolean{
			var arr:Array = ModelManager.instance.modelUser.records["star_up_hids"];
			var index:int = arr.indexOf(hid);
			var isNewDay:Boolean = Tools.isNewDay(Tools.getTimeStamp(ModelManager.instance.modelUser.records["star_up_time"]));
			if(isNewDay){
				return true;
			}
			else{
				if(index<0){
					return true;
				}
			}
			return false;
		}
		public function getName():String{
			//var str:String = Tools.getMsgById(this.name);
			var heroData:Object = this.getMyData();
			if (heroData && heroData.awaken){
				return this.getAwakenName();
			}
			return Tools.getMsgById(this.name);
		}
		/**
		 * 得到觉醒后名称
		 */
		public function getAwakenName():String{
			var str:String = Tools.getMsgById(this.name);
			if (ConfigServer.inborn[this.id + 'a']){
				return Tools.getMsgById('hero_awaken_name', [str]);
			}
			else{
				return Tools.getMsgById('hero_awake_name', [str]);
			}
		}
		public function getNameColor():String{
			return ConfigColor.FONT_COLORS[this.getStarGradeColor()];
		}
		public function getStrokeColor():String{
			return ConfigColor.FONT_STROKE_COLORS[this.getStarGradeColor()];
		}

		
		public static function getHeroRes(hid:String):String
		{
			var heroConfig:Object = ConfigServer.hero[hid];
			return heroConfig.res ? heroConfig.res : hid;
		}
		public static function getHeroName(_hid:String, _awaken:Boolean = false):String{
			var str:String = Tools.getMsgById(ConfigServer.hero[_hid].name);
			if(_awaken){
				if (ConfigServer.inborn[_hid + 'a']) return Tools.getMsgById('hero_awaken_name', [str]);
				else return Tools.getMsgById('hero_awake_name', [str]);
			}
			return str;
		}
		public static function getHeroExtendName(_hid:String, _awaken:Boolean = false):String{
			var heroCfg:Object = ConfigServer.hero[_hid];
			var name:String = _hid;
			if (heroCfg){
				name = ModelHero.rarity_name[heroCfg.rarity].substring(0,1) + _hid.replace('hero','') + '【'+Tools.getMsgById('_hero' + (heroCfg.type+3))+'】' + ModelHero.getHeroName(_hid,_awaken);
			}
			return name;
		}
		

		
		/**
		 * 判断该英雄是否为自由副将
		 * 允许作为任意兵种的副将
		 */
		public function get isFreeAdjutant():Boolean{
			var heroObj:Object = ConfigServer.fight.adjutantSpecial[this.id];
			if (heroObj && heroObj.free){
				return true;
			}
			return false;
		}

		/**
		 * 主将
		 */
		public function get commander():String {
			return ModelManager.instance.modelUser.getCommander(id);
		}

		/**
		 * 判断该英雄是否处于 空闲状态
		 */
		public function get idle():Boolean {
			var modelTroop:ModelTroop = ModelManager.instance.modelTroopManager.troops[ModelManager.instance.modelUser.mUID + "&" + this.id];
			if (modelTroop) { // 检测自身是否空闲
				return modelTroop.state === ModelTroop.TROOP_STATE_IDLE && !modelTroop.cityInFire;
			} else if (commander) { // 检测主将是否空闲
				modelTroop = ModelManager.instance.modelTroopManager.troops[ModelManager.instance.modelUser.mUID + "&" + commander]
				if (modelTroop) {
					return modelTroop.state === ModelTroop.TROOP_STATE_IDLE && !modelTroop.cityInFire;
				}
			}
			return true;
		}

		/**
		 * 忙碌提示
		 */
		public function busyHint():void {
			ViewManager.instance.showTipsTxt(Tools.getMsgById("_public241"));
		}

		/**
		 * 判断该英雄是否学习任意技能时不受属性限制
		 */
		public function get isStudyUnlimit():Boolean{
			var str:String = Tools.getMsgById(this.name);
			var heroObj:Object = ConfigServer.fight.adjutantSpecial[this.id];
			if (heroObj && heroObj.studyUnlimit){
				return true;
			}
			return false;
		}
		/**
		 * 品质 名称
		 */
		public function getRarity():String{
			return rarity_name[this.rarity];
		}
		/**
		 * 英雄卡牌背景
		 */
		public function getCardBg():String{
			return AssetsManager.getAssetLater(hero_card_bg[this.rarity]);
		}
		/**
		 * 品质 皮肤 false就是大图
		 */
		public function getRaritySkin(b:Boolean=false):String{
			if(b){
				return AssetsManager.getAssetsUI(rarity_skin_s[this.rarity]);
			}
			return AssetsManager.getAssetsUI(rarity_skin[this.rarity]);
		}
		/**
		 * 是否是我已经获得的英雄
		 */
		public function isMine():Boolean{
			if(!this.isOther && ModelManager.instance.modelUser.hero.hasOwnProperty(this.id)){
				return true;
			}
			else{
				return false;
			}
		}
		public static function get_system_simple_hero_star(n:Number,heroRarity:int):Array
		{
			var indexN:Number = (n>=ConfigServer.system_simple.hero_star.length?(ConfigServer.system_simple.hero_star.length-1):n);
			if(heroRarity==4){
				return ConfigServer.system_simple.super_hero_star[indexN];
			}
			else{
				return ConfigServer.system_simple.hero_star[indexN];
			}
		}
		/**
		 * 星星 升级用的 item
		 */
		public function getStarUpItemNum():Number{	
			return isMine() ? get_system_simple_hero_star(this.getStar(),this.rarity)[0] : itemRuler;
		}
		/**
		 * 星星 升级用的 gold
		 */
		public function getStarUpGold():Number{
			return get_system_simple_hero_star(this.getStar(),this.rarity)[1];
		}
		/**
		 * 星星 升级用的 coin
		 */		
		public function getStarUpCoin():Number{
			var num:Number = 0;
			if(this.fast_hero_star){
				if(this.fast_hero_star.length>0){
					var index:int = this.getStar();
					if(index<this.fast_hero_star.length){
						num = this.fast_hero_star[index];
					}
				}
			}
			return num;
		}
		/**
		 * 获取英雄 碎片 数量
		 */
		public function getMyItemNum():Number{
			return ModelItem.getMyItemNum(this.itemID);
		}
		/**
		 * 招募条件满足,准备招募
		 */
		public function isReadyGetMine():Boolean{
			var b:Boolean = false;
			if(!this.isMine()){
				if(this.getMyItemNum()>=itemRuler){
					b = true;
				}
			}
			return b;
		}
		/**
		 * 技能升级 快速学习技能 有 时间条件限制
		 */
		public function getFastLearn():Number{
			var timer:Number = 0;
			var heroData:Object = this.getMyData();
			if(heroData){
				if(heroData.hasOwnProperty("fast_learn")){
					timer = Tools.getTimeStamp(heroData["fast_learn"]);
				}
			}
			return timer;
		}
		/**
		 * 凑元
		 */
		public function getMyFate():Array{
			var obj:Array = [];
			var heroData:Object = this.getMyData();
			if(heroData){
				if(heroData.hasOwnProperty("fate")){
					obj = heroData["fate"];
				}
			}			
			return obj?obj:[];
		}		
		/**
		 * 检查宿命时候有可以开启的
		 */
		public function checkFateWillOpen(fateID:String = ""):Boolean
		{
			var had:Array = this.getMyFate();
			var hid:String = "";
			var len:int;
			var i:int;
			if(fateID){
				if(had.indexOf(fateID)<0 && this.fate[fateID]){
					len = this.fate[fateID].length;
					for(i = 0;i < len;i++){
						hid = this.fate[key][i];
						if(hid.indexOf("hero")>-1){
							if(ModelManager.instance.modelUser.hero[hid]){
								return true;
							}
						}
					}	
				}	
				return false;		
			}			
			for(var key:String in this.fate){
				if(had.indexOf(key)<0 && this.fate[key]){
					len = this.fate[key].length;
					for(i = 0;i < len;i++){
						hid = this.fate[key][i]+"";
						if(hid.indexOf("hero")>-1){
							if(ModelManager.instance.modelUser.hero[hid]){
								return true;
							}
						}
					}
				}
			}
			return false;
		}
		/**
		 * 战斗力  战力
		 */
		public function getPower(hmp:ModelPrepare = null):Number{
			return hmp?hmp.getData().power:this.getPrepare().getData().power;
		}
		/**
		 * 当前英雄的 组合 数据 ModelPrepare
		 */
		public function getPrepare(update:Boolean = false,obj:Object = null):ModelPrepare{
			if(this.mModelPrepare && !update){
				return this.mModelPrepare;
			}
			var fm:Object = obj;
			if(!obj){
				fm = this.getPrepareObjBy();
			}
			if(!this.mModelPrepare){
				this.mModelPrepare = getModelPrepare(fm);
			}
			else{
				if(update){
					this.mModelPrepare.setData(fm);
				}
			}
			return this.mModelPrepare;
		}
		/**
		 * 获得玩家自己某英雄的 四维 计算数据,参数 用来控制 临时数据  封装js
		 */
		public function getPrepareObjBy(lv:int = -1,heroStar:int = -1,armyLv:Array = null):Object{
			var officialID:int = ModelOfficial.getUserOfficer(ModelManager.instance.modelUser.mUID,true);
			var obj:Object = {
				hid:this.id,
				hero_star:(heroStar<0)?this.getStar():heroStar,
				lv:(lv < 0)?this.getLv():lv,
				awaken:this.getAwaken(),
				army:[
						// {id:"army"+this.army[0]+""+ModelBuiding.getArmyCurrGradeByType(this.army[0]),"lv":this.getMyArmyLv()[0]},
						{type:this.army[0],rank:ModelBuiding.getArmyCurrGradeByType(this.army[0]),"lv":(armyLv)?armyLv[0]:this.getMyArmyLv()[0],add:ModelBuiding.getArmyCurrScienceByType(this.army[0],true)},
						// {id:"army"+this.army[1]+""+ModelBuiding.getArmyCurrGradeByType(this.army[1]),"lv":this.getMyArmyLv()[1]}
						{type:this.army[1],rank:ModelBuiding.getArmyCurrGradeByType(this.army[1]),"lv":(armyLv)?armyLv[1]:this.getMyArmyLv()[1],add:ModelBuiding.getArmyCurrScienceByType(this.army[1],true)}
					],
				skill:this.getMySkills(),
				equip:ModelEquip.getPrepareObj(this),
				fate:this.getMyFate(),
				star:this.getRunesLv(),
				building:[ModelManager.instance.modelInside.getBuildingModel("building007").lv,ModelManager.instance.modelInside.getBuildingModel("building008").lv],
				official:officialID,
				title:this.getTitleStatus(),
				legend:this.getLegendObj(),
				science_passive:ModelManager.instance.modelUser.science.passive
			};
			if (this.hasFormation){
				//开启了阵法
				obj["formation_arr"] = this.formation;
				obj["formation_index"] = this.formation_index;
			}
			if(officialID>=0 && officialID<=4){
				obj["milepost"] = ModelOfficial.getInvade();
			}
			var adjutantData:Object = this.getAdjutantData();
			if(adjutantData){
				obj["adjutant"] = adjutantData;
			}
			
			var beastArr:Object = this.getBeastArr();
			if(beastArr){
				obj["beast"] = beastArr;
			}
			
			var shogunValueArr:Array = ModelManager.instance.modelUser.shogun_value;
			//if (!shogunValueArr)
				//shogunValueArr = [1, 2, 3, 4, 5, 6, 7];
			if (shogunValueArr){
				//开启了幕府，找到对应的幕府效果值加入
				var shogunArr:Array = [0, 0, 0];
				shogunArr[0] = shogunValueArr[this.type];
				shogunArr[1] = shogunValueArr[3+this.army[0]];
				shogunArr[2] = shogunValueArr[3+this.army[1]];
				if(shogunArr[0] + shogunArr[1] + shogunArr[2] > 0)
					obj["shogun"] = shogunArr;
			}
			// trace("英雄Prepare组装数据",obj);
			return obj;
		}
		
		/**
		 * 获得玩家拥有的传奇英雄数据
		 */
		public function getLegendObj():Object{
			var reObj:Object = {};
			var heroes:Object = ModelManager.instance.modelUser.hero;
			var cfg:Object = ConfigServer.fight.legendTalent;
			for (var hid:String in cfg){
				if (heroes[hid]){
					reObj[hid] = heroes[hid].hero_star;
				}
			}
			return reObj;
		}
		
		/**
		 * 得到该英雄所携带宝物（含洗炼）中，提升的行军速度总值
		 */
		public function getAllEquipArmyGo():Number{
			var value:Number = 0;
			var equipArr:Array = ModelEquip.getPrepareObj(this);
			for (var j:int = equipArr.length - 1; j >= 0; j--) {
                var equipDataArr:Array = equipArr[j];
				var key:String = equipDataArr[0];
                var equipCfg:* = ConfigServer.equip[key];
                if (equipCfg != null) {
					var i:int;
                    var equipLv:int = equipDataArr[1];
					for (i = 0; i <= equipLv; i++) {
                        var lvData:Object = equipCfg.upgrade[i.toString()];
                        if (lvData && lvData.hasOwnProperty('army_go')) {
							value += lvData.army_go;
                        }
                    }

					var equipWashArr:Array = equipDataArr[2];
					//洗炼属性
					for (i = equipWashArr.length - 1; i >= 0; i--) {
						var washId:String = equipWashArr[i];
						var washCfg:* = ConfigServer.equip_wash[washId];
						if (washCfg && washCfg.hasOwnProperty('army_go')) {
							value += washCfg.army_go;
						}
					}
				}
			}
			return value;
		}
		
		/**
		 * 计算 真实 组合 数据 ModelPrepare
		 */
		public static function getModelPrepare(obj:Object):ModelPrepare{
			return new ModelPrepare(obj);
		}
		/**
		 * 自己英雄的数量
		 */
		public static function getHeroNum():Array{
			var m:Number = 0;
			var n:Number = 0;
			for(var key:String in ConfigServer.hero)
			{
				if(ModelManager.instance.modelGame.getModelHero(key).isMine()){
					m+=1;
				}
				else{
					n+=1;
				}
			}
			return [m,n]
		}
		/**
		 * 英雄 等级 上限
		 */
		public static function getMaxLv(nlv:int = -1):Number{
			var blv:Number = (nlv>-1)?nlv:ModelManager.instance.modelInside.getBase().lv;
			var cfg:Array = ConfigServer.system_simple.level_limit;
			//
			// trace(blv*cfg[0]+cfg[1]);
			return blv*cfg[0]+cfg[1];
		}
		/**
		 * 英雄 所有 宝物 (仅宝物id列表)
		 */
		public function getEquip():Array{
			var arr:Array = [];
			var heroData:Object = this.getMyData();
			if(heroData){
				if(heroData.hasOwnProperty("equip")){
					arr = heroData["equip"];
				}
			}
			return arr;
		}

		/**
		 * 英雄 所有 宝物 (仅宝物id列表)
		 */
		public function getEquipData():Array{
			var arr:Array = [];
			var a:Array = this.getEquip();
			for(var i:int=0;i<a.length;i++){
				var emd:ModelEquip = ModelManager.instance.modelGame.getModelEquip(a[i]);
				arr.push([emd.id,emd.getLv(),emd.getEnhanceLv()]);
			}
			return arr;
		}


		/**
		 * 我的英雄 宝物形成的套装id
		 */
		public function getEquipGroup():String{
			var group:String;
			var equipArr:Array = this.getEquip();
			var len:int = equipArr.length;
			if (len >= 5){
				var equipId:String = equipArr[0];
				var equipCfg:* = ConfigServer.equip[equipId];
				if (equipCfg != null && equipCfg.group){
					group = equipCfg.group;
					for (var i:int = 1; i < len; i++){
						equipId = equipArr[i];
						equipCfg = ConfigServer.equip[equipId];
						if (equipCfg == null || equipCfg.group != group){
							group = null;
							break;
						}
					}
				}
			}
			return group;
		}
		
		
		public function checkEquipWill(type:Number = -1):Boolean{
			var mine:Array = this.getEquip();
			var len:int = mine.length;
			var num:Number = 0;
			var numOK:Number = 0;
			var key:String;
			var hid:String;
			if(len<5){
				var full:Array = [null,null,null,null,null];
				var i:int = 0;
				var emd:ModelEquip;
				for(i = 0;i < len;i++){
					emd = ModelManager.instance.modelGame.getModelEquip(mine[i]);
					full[emd.type] = emd.id;
				}
				if(type>-1){
					if(!full[type]){
						if(ModelUser.equip_type_dic[i]){
							num = 0;
							numOK = 0;
							for(key in ModelUser.equip_type_dic[i])
							{
								num+=1;
								for(hid in ModelManager.instance.modelUser.hero){
									if(ModelManager.instance.modelUser.hero[hid].equip.indexOf(key)>-1){
										numOK+=1;
										break;
									}
								}
								if(num>numOK){
									return true;
								}								
							}

						}						
					}
				}
				else{
					len = full.length;
					for(i = 0;i < len;i++){
						if(!full[i]){
							if(ModelUser.equip_type_dic[i]){
								num = 0;
								numOK = 0;								
								for(key in ModelUser.equip_type_dic[i])
								{
									num+=1;
									for(hid in ModelManager.instance.modelUser.hero){
										if(ModelManager.instance.modelUser.hero[hid].equip.indexOf(key)>-1){
											numOK+=1;
											break;
										}
									}
									if(num>numOK){
										return true;
									}									
								}
							}
						}
					}
				}
			}
			return false;
		}
		/**
		 * 英雄身上的,所有星辰
		 */
		public function getRune():Object{
			var obj:Object = {};
			var heroData:Object = this.getMyData();
			if(heroData){
				if(heroData.hasOwnProperty("star")){
					obj = heroData["star"];
				}
			}
			return obj;
		}
		/**
		 * 星辰 等级
		 */
		public function getRunesLv():Object{
			var runes:Object = this.getRune();
			var sidArr:Array;
			var re:Object = {};
			var lvNum:int = 0;
			for(var key:String in runes)
			{
				sidArr = runes[key].split("|");
				if(ModelManager.instance.modelUser.star.hasOwnProperty(runes[key])){
					lvNum = ModelManager.instance.modelUser.star[runes[key]].lv;
					if(re.hasOwnProperty(sidArr[0])){
						re[sidArr[0]] += lvNum;
					}
					else{
						re[sidArr[0]] = lvNum;
					}
				}else{
					// trace("============error",this.id,"上安装的星辰",key,"不存在");
				}
			}
			return re;
		}
		
		/**
		 * 英雄身上的所有兽灵数组
		 */
		public function getBeastArr():Array{
			var heroData:Object = this.getMyData();
			if(heroData){
				if (heroData.hasOwnProperty("beast_ids")){
					var arr:Array = heroData["beast_ids"];
					var reArr:Array = [];
					var len:int = arr.length;
					for (var i:int = 0; i < len; i++) 
					{
						var id:String = arr[i];
						reArr.push(ModelManager.instance.modelUser.beast[id]);
					}
					return reArr;
				}
			}
			return null;
		}

		/**
		 * 获取玩家自己某英雄的英雄技等级总和
		 */
		public function getSkillHeroNum(adjuId:String, fb:int):int {
			var sum:int = 0;
            var data:Object = ModelManager.instance.modelUser.hero[adjuId];
			
            var armyType:int = army[fb];
            var skill:Object = data['skill']; // 所有技能
            for(var key:String in skill)
            {
                var value:int = skill[key];
                var type:int = ModelSkill.getConfig(key)['type'];
                if (type === 4) {
                    sum += value;
                }
            }
			//return Math.min(ConfigServer.system_simple.skill_cost_max_lv['7'],sum);
			return Math.min(ModelSkill.getMaxLvByType(7),sum);
		}

		/**
		 * 获取玩家自己某英雄的兵种技等级总和
		 */
		public function getSkillArmyNum(adjuId:String, fb:int):int {
			var sum:int = 0;
            var data:Object = ModelManager.instance.modelUser.hero[adjuId];
			
            var skill:Object = data['skill']; // 所有技能
            for(var key:String in skill)
            {
                var value:int = skill[key];
                var type:int = ModelSkill.getConfig(key)['type'];
                if (type < 4) {
                    sum += value;
                }
            }
			//return Math.min(ConfigServer.system_simple.skill_cost_max_lv['8'],sum);
			return Math.min(ModelSkill.getMaxLvByType(8),sum);
			
		}

		/**
		 * 获取玩家自己某英雄的副将数据
		 */
		private function getAdjutantData():Array {
			var arr:Array = [];
			var hero:Object = ModelManager.instance.modelUser.hero;
			if (!hero[id])	return null;
			var adjutantArr:Array = hero[id]['adjutant'];

			for (var i:int = 0; i < 2; ++i) {
				var adjuId:String = adjutantArr[i];
				if (adjuId) {
					var adjutantModelHero:ModelHero = ModelManager.instance.modelGame.getModelHero(adjuId);
					arr.push([adjuId, this.getSkillHeroNum(adjuId, i), this.getSkillArmyNum(adjuId, i), ModelManager.instance.modelUser.hero[adjuId].hero_star, adjutantModelHero.getEquipScore()]);
				}
				else {
					arr.push(null);
				}
			}
			return arr.length ? arr : null;
		}
		
		
		/**
		 * 获取自身全身宝物的评分
		 */
		public function getEquipScore():int {
			var adjutant_wash:Array = ConfigServer.system_simple.adjutant_wash;
            var adjutant_enhance:Array = ConfigServer.system_simple.adjutant_enhance;
			var score:int = 0;
			var equipArr:Array = this.getEquip();
			equipArr.forEach(function(equipId:String):void {
                var equipModel:ModelEquip = ModelManager.instance.modelGame.getModelEquip(equipId);
                var a:int = ModelEquip.getConfig(equipId).adjutant_equip[equipModel.getLv()];
                var b:int = 0;
                equipModel.wash
				.filter(function(washId:String):Boolean {
                    return Boolean(washId);
                }, this)
				.forEach(function(washId:String):void {
                    var washData:Object = ModelEquip.getWashData(washId);
                    b += adjutant_wash[washData.rarity];
                }, this);
                var c:int = adjutant_enhance[equipModel.getEnhanceLv()];
                score += a + b + c;
            }, this);
			return score;
		}


		/**
		 * 根据位置类型,英雄身上的,星辰
		 */
		public function getRuneByIndex(index:int):ModelRune{
			var obj:Object = this.getRune();
			var rmd:ModelRune;
			if(obj.hasOwnProperty(index)){
				rmd = ModelManager.instance.modelGame.getModelRune(obj[index]);
			}
			return rmd;
		}
		public function checkRuneWill(posIndex:Number = -1):Boolean{
			var myRunes:Object = this.getRune();
			var type:String;
			var key:String;
			if(posIndex>-1){
				if(!myRunes[posIndex]){
					type = ConfigServer.system_simple.fix_position[posIndex];
					if(ModelUser.rune_type_dic[type]){
						for(key in ModelUser.rune_type_dic[type]){
							if(!ModelUser.rune_type_dic[type][key].hid){
								return true;
							}
						}
					}	
				}
				return false;		
			}
			var len:int = ConfigServer.system_simple.fix_position.length;
			for(var i:int = 0;i < len;i++){
				if(!myRunes[i]){
					type = ConfigServer.system_simple.fix_position[i];
					if(ModelUser.rune_type_dic[type]){
						for(key in ModelUser.rune_type_dic[type]){
							if(!ModelUser.rune_type_dic[type][key].hid){
								return true;
							}
						}
					}
					
				}
			}
			return false;
		}

		public function checkAdjutantCanInstallByType(type:int):Boolean
		{
			if (ModelGame.unlock(null,"hero_adjutant").gray || this.getStar() < ConfigServer.system_simple.adjutant_level) {
				return false;
			}

			var modelUser:ModelUser = ModelManager.instance.modelUser;
            var heros:Object = ObjectUtil.clone(modelUser.hero, true);
			var heroData:Object = heros[id];
			var arr:Array = [];
			if (heroData['commander']) return false; // 副將不能安裝副將
			if (heroData['adjutant'][type]) return false; // 已拥有该类型副將

            // 奖当前英雄移除
            heroData && delete heros[id];
            var armyType:int = army[type];
            var troops:Object = ModelManager.instance.modelTroopManager.troops;
            for(var hid:String in heros)
            {
                // 移除主将
                if (heros[hid]['isCommander']) {
                    delete heros[hid];
                    continue;
                }

                var hmd:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);  

                // 移除已编组的英雄
                if (troops[modelUser.mUID + "&" + hid]) {
                    delete heros[hid];
                    continue;
                }
                
                // 移除兵种类型不同的英雄          
                if (armyType !== hmd.army[type]) {
                    delete heros[hid];
                    continue;
                }
                arr.push(hmd);
            }
			return arr.length > 0;
		}

		public function checkRuneWillByType(index:Number):Boolean{
			if(!this.isMine()){
				return false;
			}
			var runes:Object = this.getRune();
			var star:Object = ModelManager.instance.modelUser.star;
			var num:Number = index*5;
			for(var i:Number=0;i<5;i++){
				var type:Number = num+i;//ConfigServer.system_simple.fix_position[num+i];
				
				if(runes.hasOwnProperty(type)){
					
				}
				else{
					var red:Boolean = this.checkRuneWill(type);
					var ft:int = ModelRune.pageAndTypeToPosValue(index,i);
					var arr:Array = ModelRune.getMyRunesByType(ft,this,type);
					// trace("星辰类型---status---",num+i,type,red);
					if(ft==0){
						red = red && (ModelRune.getFixType0(arr,runes).length>0);
					}	
					if(red){
						return true;
					}				
				}
			}
			return false;
		}

		/**
		 * 获得幕府得分
		 */
		public function getShogunScore(shogun_lv:int=1):Object{
			var data:Object=ConfigServer.shogun;
			var cd:Object=data.shogun_score;
			var o:Object={};
			var n1:Number=cd.hero_rarity[this.rarity];
			var n2:Number=Math.floor(cd.hero_property*(this.str+this.agi+this.cha+this.lead));
			var n3:Number=this.getLv()*cd.hero_level;
			var n4:Number=cd.hero_star[this.rarity][this.getStar()];
			var n5:Number=0;
			var skillData:Object=this.getMySkills();
			for(var s:String in skillData)
			{
				var skillModel:ModelSkill=ModelManager.instance.modelGame.getModelSkill(s);
				var cd_skill:Array=cd.skill[skillModel.shogun_type];
				n5+=(skillData[s]-1>=cd_skill.length-1)?cd_skill[cd_skill.length-1]:cd_skill[skillData[s]-1];
			}
			var n6:Number=0;
			var a:Array=this.getEquip();			
			for(var i:int=0;i<a.length;i++){
				var q:ModelEquip=ModelManager.instance.modelGame.getModelEquip(a[i]);
				n6+=cd.equip[q.getLv()];
			}
			var army_arr:Array=this.getMyArmyLv();
			var army_index0:Number=army_arr[0]>cd.army.length-1?cd.army.length-1:army_arr[0];
			var army_index1:Number=army_arr[1]>cd.army.length?cd.army.length-1:army_arr[1];
			var n7:Number=cd.army[army_index0]+cd.army[army_index1];
			var n8:Number=n1+n2+n3+n4+n5+n6+n7;
			var n9:Number=0;
			var shogunLv:int=shogun_lv;
			var top_score:Number=data.shogun_levelup[shogunLv-1][2];
			if(n8>=top_score){
				n8=top_score;
			}
			n9=n8/top_score;
			//trace("shogun score "this.hid,n1,n2,n3,n4,n5,n6,n7,n8,n9);
			var shogun_rank:Array=data.shogun_rank;
			for(var k:int=0;k<shogun_rank.length;k++){
				if(n9>=shogun_rank[k]){
					n9=k;
					break;
				}
			}

			o["hero_rarity"]=n1;//品质评分
			o["hero_property"]=n2;//初始四维评分
			o["hero_level"]=n3;//等级评分
			o["hero_star"]=n4;//星级评分
			o["skill"]=n5;//技能评分
			o["equip"]=n6;//宝物评分
			o["amry"]=n7;//兵种评分
			o["score"]=n8;//总分
			o["rank"]=n9;
			//trace("打印英雄评分 ",this.id,o);	
			return o;
		}


		/**
		 * 获得幕府英雄列表
		 */
		public static function getShogunHeroList(shogun_index:int,shogun_lv:int):Array{
			var a:Array=ModelManager.instance.modelUser.getMyHeroArr();
			var listData:Array=[];
			for(var j:int=0;j<a.length;j++){
				var hmd:ModelHero=a[j];
				hmd["shogun_score"]=hmd.getShogunScore(shogun_lv).score;
				if(shogun_index<=2){
					if(hmd.type==shogun_index){
						listData.push(hmd);
					}
				}else if(shogun_index==3){
					if(hmd.army[0]==0){
						listData.push(hmd);
					}
				}else if(shogun_index==4){
					if(hmd.army[0]==1){
						listData.push(hmd);
					}
				}else if(shogun_index==5){
					if(hmd.army[1]==2){
						listData.push(hmd);
					}
				}else if(shogun_index==6){
					if(hmd.army[1]==3){
						listData.push(hmd);
					}
				}
			}
			listData.sort(MathUtil.sortByKey("shogun_score",true,true));
			return listData;
		}

		/**
		 * 获得英雄所在的幕府
		 */
		public function getHeroShogun():String{
			var o:Array=ModelManager.instance.modelUser.shogun;
			for(var i:int=0;i<o.length;i++){
				var d:Object=o[i];
				var hids:Array=d["hids"];
				for(var j:int=0;j<hids.length;j++){
					if(hids[j]!=null && hids[j]==this.id){
						return Tools.getMsgById("_public169",[shogun_name[i+1]])//shogun_name[i+1]+"府";
					}
				}
			}
			return "";
		}
		/**
		 * 幕府可上阵英雄
		 */
		public static function getUpShogun(index:int,lv:int):Array{
			var arr:Array=ModelHero.getShogunHeroList(index,lv);
			var a:Array=[];
			for(var i:int=0;i<arr.length;i++){
				var s:String=(arr[i] as ModelHero).getHeroShogun();
				if(s==""){
					a.push(arr[i]);
				}
			}
			return a;
		}

		/**
		 * 获得英雄状态（产业挂机、拜访、建造）
		 */
		public function getHeroEstate():Object{//1村落，2港口，3农田，4林场，5矿场，6牧场
			var oo:Object={};
			oo["id"]=10;
			oo["status"]=0;//0.空闲  1.忙碌  2.完成
			oo["text"]=Tools.getMsgById("_public161");//"空闲中";
			var user_estate:Array=ModelManager.instance.modelUser.estate;
			var config_estate:Object=ConfigServer.estate.estate;
			var now:Number=ConfigServer.getServerTimer();
			for(var i:int=0;i<user_estate.length;i++){
				var o:Object=user_estate[i];
				var sss:String="";
				if(this.id == o.active_hid){
					var eid:String = ConfigServer.city[o.city_id].estate[o.estate_index][0];
					var s:String=Tools.getMsgById(config_estate[eid].active_name);
					var ss:String=Tools.getMsgById(ConfigServer.city[o.city_id].name);
					var aht:Number=Tools.getTimeStamp(o.active_harvest_time);
					sss=Tools.getMsgById(now>=aht?"_public170":"_public171");//"完成":"中";
					oo["id"]=Number(eid);
					oo["status"]=(now>=aht)?2:1;
					oo["text"]=ss+"-"+s+sss;
					//this["estate_index"]=i;
					//this["estateFinish"]=(now>=aht);
					break;
				}
			}
			var user_visit:Object=ModelManager.instance.modelUser.visit;
			for(var key:String in user_visit){
				var a:Array=user_visit[key];
				var v_time:Number=Tools.getTimeStamp(a[2]);
				var v_city:String=Tools.getMsgById(ConfigServer.city[key].name);
				sss=Tools.getMsgById(now>=v_time?"_public170":"_public171");//now>=v_time?"完成":"中";
				if(a[0]==this.id){
					oo["id"]=7;
					oo["status"]=(now>=v_time)?2:1;
					oo["text"]=v_city+"-"+Tools.getMsgById("_visit_text01")+sss;
					oo["visit_obj"]={"cid":key,"hid":a[1]};	
					//this["visit_obj"]={"cid":key,"hid":a[1]};	
					//this["estateFinish"]=(now>=v_time);
					break;
				}
			}

			var user_cb:Object=ModelManager.instance.modelUser.city_build;
			for(var ckey:String in user_cb){
				var c_obj:Object=user_cb[ckey];
				for(var bkey:String in c_obj){
					var b_arr:Array=c_obj[bkey];
					var b_time:Number=Tools.getTimeStamp(b_arr[1]);
					sss=Tools.getMsgById(now>=b_time?"_public170":"_public171");//?"完成":"中";
					if(b_arr[0]==this.id){
						oo["id"]=8;
						oo["status"]=(now>=b_time)?2:1;
						oo["text"]=Tools.getMsgById(ConfigServer.city[ckey].name)+"-"+Tools.getMsgById("_public91")+sss;
						oo["visit_obj"]={"cid":ckey,"bid":bkey};	
					}
				}
			}

			return oo;
		}
		
		/**
		 * 判断这个英雄是不是我的宿命
		 */
		public function isMyFate(hid:String):Boolean{
			if(hid==""){
				return false;
			}
			for(var s:String in this.fate ){
				var a:Array=this.fate[s];
				if(a[1]==hid){
					return true;
				}
			}
			return false;
		}

		/**
		 * 获得基础四维最高的一项
		 */
		public function getTopDimensional():Array{
			var arr:Array=[this.str,this.agi,this.cha,this.lead];
			var max:int=0;
			for(var i:int=1;i<arr.length;i++){
				if(arr[i]>arr[max]){
					max=i;
				}
			}
			return [hero_4d_name[max],arr[max],max];
		}

		/**
		 * 获得四维中的一个值
		 */
		public function getOneDimensional(index:int):Number{
			var arr:Array=[this.str,this.agi,this.cha,this.lead];
			return arr[index];
		}


		/**
		 * 获得英雄产业或拜访时的事件
		 */
		public static function getEventById(work_type:int,hid:String):String{
			if(hid==""){
				// trace("getEventById:hid is null");
				return "";
			}
			if(work_type==0){
				var user_visit:Object=ModelManager.instance.modelUser.visit;
				for(var key:String in user_visit){
					var a:Array=user_visit[key];
					if(a[0]==hid){
						return a[3]?a[3]:"";
					}
				}
			}else if(work_type==1){
				var user_estate:Array=ModelManager.instance.modelUser.estate;
				for(var i:int=0;i<user_estate.length;i++){
					var o:Object=user_estate[i];
					if(o.active_hid && o.active_hid==hid){
						return o.event?o.event:"";
					}
				}

			}else if(work_type==2){
				var user_city_build:Object=ModelManager.instance.modelUser.city_build;
				for(var c_key:String in user_city_build){
					var c_obj:Object=user_city_build[c_key];
					for(var b_key:String in c_obj){
						var b_arr:Array=c_obj[b_key];
						if(b_arr[0]==hid){
							return b_arr[2]?b_arr[2]:"";
						}
					}
				}
			}
			return "";
		}
		public static function getFateCfg(fid:String):Object
		{
			return ConfigServer.fate[fid];
		}
		
		public function checkRuneWill2():Boolean {
			if (!ModelGame.unlock(null, "hero_star").stop) {
				for (var i:int = 0; i < 4; i++){
					if (this.checkRuneWillByType(i)) return true;
				}
			}
			return false;
		}
		public static const fate_type_name:Array = [
			Tools.getMsgById("_hero17"),Tools.getMsgById("_hero18"),"",Tools.getMsgById("_hero27")
		];//合击技,被动技能


		/**
		 * 获得头像字符串
		 */
		public function getHeadId():String{
			if(this.getAwaken()==1){
				return this.id+"_1";
			}
			return this.id;
		}

		/**
		 * 获得阵法的三个model
		 */
		public function getFormationArr():Array{
			var arr:Array=ConfigServer.hero[this.id].arr;
			var a:Array=[];
			for(var i:int=0;i<arr.length;i++){
				var fmd:ModelFormation=ModelFormation.getModel(arr[i]);
				a.push(fmd);
			}
			return a;
		}

		/**
		 * 遗忘阵法获得的道具
		 */
		public function forgetFormationObj():Object{
			var arr:Array = this.getFormationArr();
			var o:Object = {};
			var cfg1:Array = ConfigServer.system_simple.arr_level;
			var cfg2:Array = ConfigServer.system_simple.arr_quality;
			var cfg3:Array = ConfigServer.system_simple.arr_cost;
			for(var i:int=0;i<arr.length;i++){
				var fmd:ModelFormation = arr[i];
				var _lv:int = fmd.curLv(this);
				var n1:Number = 0;
				for(var j:int=0;j<_lv;j++){
					n1+=cfg1[j][1];
				}
				if(n1!=0)
					o[cfg3[fmd.id][1]] = n1;

				var _star:int = fmd.curStar(this);
				var n2:Number = 0;
				for(var k:int=0;k<_star;k++){
					n2+=cfg2[k][2];
				}
				if(n2!=0)
					o[cfg3[fmd.id][0]] = n2;
			}
			return o;
		}
		/**
		 * 查看红点状态 0等级升级  1品质升级  2=0&1
		 */
		public function checkFormationRed(type:int):Boolean{
			if(ModelGame.unlock(null,"hero_formation",false).stop) return false;

			var n:Number = this.formation_index;
			if(n==-1) return false;
			//本来是三个循环检测的  后来改成只判断激活的那个了  
			var arr:Array=[getFormationArr()[n]];
			//var arr:Array=getFormationArr();
			for(var i:int=0;i<arr.length;i++){
				var m:ModelFormation=arr[i];
				var nn:Number = n;//i;
				if(type==0){
					if(m.checkLv(this,n)){
						return true;
					}
				}else if(type==1){
					if(m.checkStar(this,n)){
						return true;
					}
				}else{
					if(m.checkLv(this,n)){
						return true;
					}
					if(m.checkStar(this,n)){
						return true;
					}
				}
				
			}
			return false;
		}

		/**
		 * 获得擂台英雄列表
		 */
		public static function getArenaHeroList(index:int,len:int = 0):Array{
			var a:Array=ModelManager.instance.modelUser.getMyHeroArr(true,"",null,true);
			var arr:Array=[];
			for(var i:int=0;i<a.length;i++){
				var hmd:ModelHero=a[i];
				if(index<=3){//武文全
					if(hmd.type==(index-1)){
						arr.push(hmd);
					}
				}else if(index==4){//巾帼
					if(hmd.rarity==3){
						arr.push(hmd);
					}
				}else if(index==5){//步
					if(hmd.army[0]==0){
						arr.push(hmd);
					}
				}else if(index==6){//骑
					if(hmd.army[0]==1){
						arr.push(hmd);
					}
				}else if(index==7){//弓
					if(hmd.army[1]==2){
						arr.push(hmd);
					}
				}else if(index==8){//方
					if(hmd.army[1]==3){
						arr.push(hmd);
					}
				}
				
				if(len!=0 && arr.length==len)
					break;
			}
			return arr;
		}

		/**
		 * 获得兽灵列表
		 */
		public function getBeastIds():Array{
			if(ModelManager.instance.modelUser.hero[this.id].beast_ids){
				return ModelManager.instance.modelUser.hero[this.id].beast_ids;
			}
			return [];
		}

		/**
		 * 是否有兽灵
		 */
		public function hasBeast():Boolean{
			var a:Array = ModelManager.instance.modelUser.hero[this.id].beast_ids;
			var b:Boolean = false;
			if(a && a.length>0){
				for(var i:int=0;i<a.length;i++){
					if(a[i]!=null){
						b = true;
						break;
					}
				}
			}
			return b;
		}

		/**
		 * 兽灵套装数据[[type,4,最低的star],[type,8,最低的star]]
		 */
		public function getBeastResonanceArr(data:Array = null):Array{
			var arr:Array = [];
			var beast:Array = data ? data : [];
			if(data == null){
				var userBeast:Array = this.getBeastIds();
				for(var i0:int=0;i0<userBeast.length;i0++){
					if(ModelManager.instance.modelUser.beast[userBeast[i0]]){
						beast.push(ModelManager.instance.modelUser.beast[userBeast[i0]]);
					}
				}
			}
			var o:Object = {};
			var _type:String = "";
			for(var i:int=0;i<beast.length;i++){
				if(beast[i]){
					_type = beast[i][0];
					if(o[_type]) o[_type] = o[_type]+1;
					else o[_type] = 1;
				}
			}
			for(var s:String in o){
				if(o[s]>=4){
					var n:Number = 99;
					var _star:Number = 0;
					var starArr:Array = [];
					for(var j:int=0;j<beast.length;j++){
						if(beast[j]){
							_star = beast[j][2];
							_type = beast[j][0];
							if(s == _type){
								starArr.push(_star);
							}
						}
					}
					starArr.sort(function(a:*, b:*):int{
						return b - a;//从大到小
					});
					n = starArr[3];
					arr.push([s,4,n]);

					if(o[s] == 8){
						n = 99;
						for(var k:int=0;k<beast.length;k++){
							if(beast[k]){
								_star = beast[k][2];
								_type = beast[k][0];
								if(s == _type && _star < n){
									n = _star;
								}
							}
						}
						arr.push([s,8,n]);
					}
				}
			}
			return arr;
		}

		/**
		 * 根据英雄id返回套装数据[4,[[index,index,index,index],[index,index,index,index]]] 或 [8,[]]
		 */
		public function getBeastResonanceData():Array{
			var arr:Array = [];
			var beast:Array = this.getBeastIds();
			var o:Object = {};
			var _type:String = "";
			for(var i:int=0;i<beast.length;i++){
				if(beast[i]){
					_type = ModelManager.instance.modelUser.beast[beast[i]][0];
					if(o[_type]) o[_type] = o[_type]+1;
					else o[_type] = 1;
				}
			}
			for(var s:String in o){
				var _star:Number = 0;
				if(o[s] == 8){
					var n:Number = 999;
					for(var l:int=0;l<8;l++){
						_star = ModelManager.instance.modelUser.beast[beast[l]][2];
						if(_star < n){
							n = _star;
						}
					}
					arr.push([8,n,[0,1,2,3,4,5,6,7]]);
				}

				if(o[s]>=4){
					var starArr:Array = [];
					for(var j:int=0;j<beast.length;j++){
						if(beast[j]){
							_star = ModelManager.instance.modelUser.beast[beast[j]][2];
							_type = ModelManager.instance.modelUser.beast[beast[j]][0];
							if(s == _type){
								starArr.push([j,_star]);
							}
						}
					}
					ArrayUtils.sortOn(['1','0'],starArr,false);
					var a:Array = [];
					for(var k:int=starArr.length-4;k<starArr.length;k++){
						a.push(starArr[k][0]);
					}
					arr.push([4,starArr[starArr.length-4][1],a]);
				}
			}
			return arr;
		}

		/**
		 * 获得兽灵套装是几件套  0或4或8
		 */
		public function getBeastResonanceNum():Number{
			var n:Number = 0;
			var beast:Array = this.getBeastIds();
			var o:Object = {};
			var _type:String = "";
			for(var i:int=0;i<beast.length;i++){
				if(beast[i]){
					_type = ModelManager.instance.modelUser.beast[beast[i]][0];
					if(o[_type]) o[_type] = o[_type]+1;
					else o[_type] = 1;
				}
			}
			for(var s1:String in o){
				if(o[s1] == 8) return 8;
			}
			for(var s2:String in o){
				if(o[s2] >= 4) return 4;
			}
			return 0;
		}

		/**
		 * 携带的兽灵属性
		 */
		public function getBeastInfo():String{
			var beastArr:Array = [];
			var beast:Array = this.getBeastIds();
			var o:Object = {};
			for(var i:int=0;i<beast.length;i++){
				if(beast[i]){
					beastArr.push(ModelBeast.getModel(beast[i]));
				}
			}
			var s1:String = ModelBeast.getAllLvInfo(beastArr);
			var s2:String = ModelBeast.getAllSuperInfo(beastArr);

			return s1+"\n"+s2;
		}

		/**
		 * 获得觉醒背景图
		 */
		public static function awakenImgUrl(hid:String,ad:Boolean = false):String{
			var s:String = "";
			if(ad) s = AssetsManager.getAssetsAD(ModelManager.instance.modelGame.getModelHero(hid).rarity == 4 ? img_awaken_super : img_awaken_normal);
			else s = AssetsManager.getAssetsUI(ModelManager.instance.modelGame.getModelHero(hid).rarity == 4 ? img_awaken_super_s : img_awaken_normal_s);
			return s;
		}

		/**
		 * 赛季等级
		 */
		public function get honourLv():int{
			if(ModelManager.instance.modelUser.honour_hero){
				if(ModelManager.instance.modelUser.honour_hero[this.id]){
					return ModelManager.instance.modelUser.honour_hero[this.id].lv;
				}
			}
			return 0;
		}

		/**
		 * 赛季等级当前的经验值
		 */
		public function get honourExp():int{
			if(ModelManager.instance.modelUser.honour_hero){
				if(ModelManager.instance.modelUser.honour_hero[this.id]){
					return ModelManager.instance.modelUser.honour_hero[this.id].exp;
				}
			}
			return 0;
		}
	}

}