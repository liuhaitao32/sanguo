package sg.model
{
	import laya.maths.MathUtil;
	import laya.utils.Handler;
	import sg.fight.logic.utils.FightUtils;

	import sg.achievement.model.ModelAchievement;
	import sg.activities.ActivityHelper;
	import sg.activities.model.ModelActivities;
	import sg.activities.model.ModelFreeBuy;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import sg.explore.model.ModelExplore;
	import sg.fight.FightMain;
	import sg.fight.test.TestCopyright;
	import sg.fight.test.TestCopyrightData;
	import sg.guide.model.GuideChecker;
	import sg.manager.FilterManager;
	import sg.manager.LoadeManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.model.MapModel;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.TestUtils;
	import sg.net.NetHttp;
	import sg.net.NetMethodCfg;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.scene.constant.EventConstant;
	import sg.task.TaskHelper;
	import sg.utils.FunQueue;
	import sg.utils.SaveLocal;
	import sg.utils.ThirdRecording;
	import sg.utils.Tools;
	import sg.view.effect.UserPowerChange;
	import sg.manager.QueueManager;
	import sg.activities.model.ModelAuction;
	import sg.altar.legend.model.ModelLegend;
	import sg.utils.ArrayUtil;
	import sg.map.model.CountryArmy;
	import sg.activities.model.ModelMemberCard;
	import sg.utils.ObjectUtil;
	import sg.altar.legendAwaken.model.ModelLegendAwaken;
	import sg.cfg.HelpConfig;

	/**
	 * ...
	 * @author
	 */
	public class ModelUser extends ModelBase{
		//
		public static const EVENT_PAY_SUCCESS:String="event_pay_success";//充值成功
		public static const EVENT_IS_NEW_DAY:String = "event_is_new_day";//新的一天
		public static const EVENT_USER_UPDATE_POWER:String = "event_user_update_power";//更新最新战力
		public static const EVENT_USER_UPDATE:String = "event_user_update";
		public static const EVENT_TOP_UPDATE:String="event_top_update";
		public static const EVENT_PROP_CHECK:String="event_prop_check";//问道筛选
		public static const EVENT_GUILD_CREAT_SUC:String="event_guild_creat_suc";//创建军团成功
		public static const EVENT_GUILD_APPLY_SUC:String="event_guild_apply_suc";//成功加入军团
		public static const EVENT_GUILD_QUIT_SUC:String="event_guild_quit_suc";//退出军团
		public static const EVENT_PVE_UPDATE:String="event_pve_update";//刷新pve主界面
		public static const EVENT_USER_INFO_UPDATE:String="event_user_info_update";//改完名字和头像的时候通知刷新面板
		public static const EVENT_UPDATE_ARMY_UPGRADE:String="event_update_army_upgrade";//兵种科技面板
		public static const EVENT_UPDATE_MAIL_CHAT:String="event_update_mail_chat";//添加新对话发的事件
		public static const EVENT_UPDATE_MAIL_SYSTEM:String="event_update_mail_system";//服务器通知有新邮件
		public static const EVENT_UPDATE_MAIL_CHAT_MAIN:String="event_update_mail_chat_main";//通知私人邮箱面板刷新
		public static const EVENT_UPDATE_SHOGUN_HERO:String="event_update_shogun_hero";//升级幕府时派发的消息
		public static const EVENT_ACT_TIME_OUT:String="event_act_time_out";//free buy到期
		public static const EVENT_EQUIP_WASH:String="event_equip_wash";//宝物洗炼
		public static const EVNET_ESTATE_HERO:String="event_estate_hero";//产业挂机
		public static const EVNET_ESTATE_MAIN:String="event_estate_Main_pdate";
		public static const EVENT_CITY_BUILD_MAIN:String="evnet_city_build_main";
		public static const EVENT_UPDATE_BTM_BTN:String="event_update_btm_btn";
		public static const EVENT_UPDATE_ARMY_ITEM:String="event_update_army_item";//扫荡
		public static const EVENT_UPDATE_CREDIT:String="event_update_credt";//战功(新的一年才派发一次)
		public static const EVENT_UPDATE_SKILL_NUM:String="event_update_skill_num";//问道获得技能碎片以后刷新英雄界面
		
		//
		public static const country_name:Array = [
			Tools.getMsgById("flag_0"),Tools.getMsgById("flag_1"),Tools.getMsgById("flag_2")];
		public static const country_name2:Array = [
			Tools.getMsgById("country_0"),Tools.getMsgById("country_1"),Tools.getMsgById("country_2")];
		public static const cost_id_arr:Array = ["gold","food","wood","iron"];
		//
		public var pf:String = "";
		public var food:Number = 0;//粮草
		public var wood:Number = 0;//木材
		public var iron:Number = 0;//铁矿石
		public var gold:Number = 0;//铜币
		public var merit:Number = 0;//功勋
		public var office:Number = 1;//爵位
		public var country:int = 0;//国家0魏,1蜀,2吴
		//
		public var home:Object = {};//封地
		public var property:Object = {};//仓库
		public var hero:Object = {};//英雄
		public var equip:Object = {};//宝物
		public var building_cd:Object = {};//升级cd队列
		public var building_cd_arr:Array = [];//升级cd队列
		public var pub_records:Object={};//酒馆
		public var baggage:Object={};//辎重站
		public var equip_cd:Array = [];//宝物建造升级队列
		public var shop:Object={};//商店
		public var star:Object={};//星辰
		public var star_records:Object={};//观星记录
		public var add_time:Object;//注册时间
		public var login_time:Object;
		//
		public var coin:Number = 0;//消费币
		//
		public var mUID:String = "";//uid
		public var mUID_base:String = "";//uid
		public var mSessionid:String = "";//pwd
		//
		public var mFunQueue:FunQueue;
		public var zone:String;//服务器区
		//
		public var gameServerStartTimer:Number = 0;
		//
		public var farm:Number = 0;//产业
		public var history:Number = 0;//史册
		//
		public var guild_id:*=null;
		public var application_log:Object={};//已申请的军团
		public var total_records:Object;//数据累计记录,等
		public var office_right:Array;//爵位特权
		//
		public var officeModel:ModelOffice;//当前爵位的model
		public var gtask:Object;
		public var uname:String;//用户名称
		public var alien_reward:Array=[];
		public var isLogin:Boolean = false;//是否登录
		public var pk_records:Object;//pk模块记录
		
		public var pve_records:Object={};//pve模块记录
		public var climb_records:Object={};//climb 过关斩将 模块记录
		public var head:String="";//头像id
		public var msg:Object={};//邮件消息
		public var records:Object={};//记录
		public var shogun:Array = [];//幕府
		public var shogun_value:Array;//幕府效果值
		public var hero_catch:Object={};//名将切磋
		public var milepost_reward:Array = [];//国家大势,国家奖励
		public var milepost_fight_reward:Array = [];//国家大势,功勋奖励
		public var estate:Array=[];//产业
		public var visit:Object={};//拜访
		public var science:Object={};//科技
		//
		public var credit:Number=0;//总的战功
		public var year_credit:Number=0;//年度战功
		public var credit_get_gifts:Array=[];//已经领取过的奖励
		public var credit_lv:Number=0;//战功等级
		public var credit_year:Number=0;//战功年度
		public var credit_settle:Array=null;//战功结算数据
		public var is_credit_lv_up:Number=0;

		public var online_time:Number=0;//在线时长

		public var mUserCode:String = "";
		public var city_build:Object={};//城市建设
		//
		public var loginDateNum:Number = -1;
		public var birthday:Object;
		public var pk_npc:Object;
		public var ftask:Object;//民情
		
		public var task:Object; // 任务
		public var effort:Object; // 成就
		public var effort_records:Object; // 成就记录
		public var mining :Object; // 蓬莱寻宝
		public var credit_rool_gifts_num:Number;//额外的额外的战功奖励个数

		public var banned_users:Object;//黑名单
		public var last_year_credit:Number;//上赛季战功

		public var year_build:Number;			//年度建设
		public var year_dead_num:Number;        //年度战损
		public var year_kill_num:Number;        //年度杀敌
		public var year_kill_troop:Number;     	//年度杀部队
		public var quota_gift:*;                //国家里的年度奖励
		public var zones_user_num:Object;       //推荐新服务器的人数列表
		public var pay_ip_check:Boolean = false;//符合要求的ip
		public var impeach_time:*;              //发起弹劾的时间
		public var accountId:String;            //特殊平台用的登录id
		public var ip:String;            		// 用户IP
		
		public var auction:Object;              // 拍卖
		public var legend:Object;               // 传奇
		public var xyz:Object;                  // 襄阳战相关数据
		public var pay_rank_gift:Object;       	// 消费榜奖励
		public var bless_hero:Object;       	// 福将挑战
		
		public var sale_pay:Array;              // 抵扣券

		public var member_check:int;            // 短连身份(当前UID是否购买过永久卡)
		public var member:Array;              	// 第0位 身份(是否购买过永久卡) 第1位 领奖时间

		public var arena:Object;                //擂台赛数据

		public var beast:Object;                //兽灵
		public var beast_times:int;             //兽灵背包格子数购买次数
		public var beast_lock_ids:Array;        //兽灵锁定列表
		public var records_360:Array = [];		// 关注、认证等记录
		public var legend_awaken:Object;        // 传奇觉醒

		public var new_task:Object;             // 朝廷密旨

		/**
		 * 合服后的区  如果没合服 就还是原区
		 */
		public function get mergeZone():String{
			if(this.zone && ConfigServer.zone[this.zone][7]!="")
				return ConfigServer.zone[this.zone][7];
			return this.zone;
		}
		/**
		 * 手机号
		 */
		public function get tel():String{
			if(this.records.hasOwnProperty("tel")){
				return this.records.tel;
			}
			return "";
		};
		public var userPhoneCount:Number = 0;//手机号绑定时的倒计时

		public var myPowerTemp:Number = -1;
		public var myPowerChangeNum:Number = 0;
		public var world_lv:Number = 0;
		public var free_buy_key:String="";//“福利兑换”弹出关键字
		public var isLoginHttp:Boolean = false;
		public var champion_user:Array;//比武大会第一名[uid,uname]
		//
		public static var rune_type_dic:Object = {};//星辰分类
		public static var rune_type_dic_sp:Object = {};//星辰分类
		public static var equip_type_dic:Object = {};//装备没有分给英雄的分类
		//
		public static var sInitLoadPer:Number = 0.1;
		public static var sInitLoadMax:Number = 0;
		public static function getInitLoadPer():Number{
			sInitLoadMax+=sInitLoadPer;
			return sInitLoadMax;
		}

		/**
		 * 总的充值金额
		 */
		public function get pay_money():Number{
			if(this.records){
				return this.records.pay_money;
			}
			return 0;
		}
		/**
		 * 默认是 自己的数据
		 */
		public function ModelUser(self:Boolean = true){
			sInitLoadMax = 0;
			if(self){
				this.mFunQueue = new FunQueue();
			}
		}
		
		/**
		 * 是否合服
		 */
		public function get isMerge():Boolean{
			return this.mergeNum>0;
		}
		
		/**
		 * 是否可以支付
		 */
		public function get canPay():Boolean{
			if (ConfigApp.pf === ConfigApp.PF_QQ && ConfigApp.onIOS()) {
				return false;
			}
			return ConfigServer.system_simple.pay_active !== 0;
		}

		/**
		 * 得到当前真正的区号（合区后id）
		 */
		public function get currZone():String{
			var zoneArr:Array = ConfigServer.zone[this.zone];
			if (zoneArr && zoneArr[7]){
				return zoneArr[7];
			}
			return this.zone;
		}
		/**
		 * 第几次合服
		 */
		public function get mergeNum():Number{
			if (this.zone && ConfigServer.zone[this.zone]){
				return ConfigServer.zone[this.zone][8];
			}
			return 0;
		}


		/**
		 * socket 打开 触发
		 */
		public function loginSocket():void{
			NetSocket.instance.off(NetSocket.EVENT_SOCKET_OPENED,this,this.loginSocket);
			NetSocket.instance.on(NetSocket.EVENT_SOCKET_OPENED,this,this.loginSocket);	
			//			
			if(!Tools.isNullString(this.mUID_base) && !Tools.isNullString(this.mSessionid)){
				this.zone = ModelPlayer.recommendServer;
				var user:Object = {uid:this.mUID_base,sessionid:this.mSessionid,zone:this.zone,user_code:this.mUserCode,pf_data:Platform.pf_login_data,pf:ConfigApp.pf, pf_key: (ModelPlayer.instance.mPlayer["name"] || "")};
				//
				NetSocket.instance.send(NetMethodCfg.WS_SR_LOGIN,user,Handler.create(this,this.ws_sr_login));
			}
			else{
				Trace.log("::::ModelUser 准备 socket 登录,没有 mUID_base mSessionid",this);
			}

		}
		/**
		 * socket 登陆 成功
		 */
		private function ws_sr_login(re:NetPackage):void{
			this.mFunQueue.init([
				Handler.create(this,this.initUserData,[re.receiveData]),
				Handler.create(this,this.initSupporUI)
			]);
		}
		/**
		 * http 登陆请求
		 */
		public function initUserLogin(pa:Object,call:Handler,andSocket:Boolean):void{
			var _this:* = this;
			NetHttp.instance.send(NetMethodCfg.HTTP_USER_LOGIN,pa,Handler.create(_this,function(re:Object):void{
				if(NetHttp.checkReIsError(re)){
					ViewManager.instance.showTipsTxt(re.msg);
					if(ConfigApp.useMyLogin()){
						ViewManager.instance.showView(ConfigClass.VIEW_LOGIN,-1);
					}
					return;
				}
				_this.http_user_login(re);
				if(call){
					call.runWith(andSocket);
				}
			}));
		}
		/**
		 * http 登陆返回
		 */
		private function http_user_login(re:Object):void{
			Platform.checkGameStatus(1500);
			//
			if(re) {
				member_check = re.member;
				this.isLoginHttp = true;
				//{"uid": 8, "pf_key": null, "last_zone": null, "zones": "", "sessionid": "d2388121adc9d6605e407399888de4be", "pf": ""}
				this.mUID = this.mUID_base =  re["uid"]?re["uid"]:"";
				// 
				this.mSessionid = re["sessionid"]?re["sessionid"]:"";
				// this.zone = ModelPlayer.instance.getCurrZone();
				this.mUserCode = re["user_code"]?re["user_code"]:"";
				this.zones_user_num = re["zones_user_num"];
				// this.pay_ip_check = re["is_china"];
				this.accountId = re["user_id"];
				this.ip = re["user_ip"];
				//
				ModelPlayer.instance.setUID(this.mUID_base);
				ModelPlayer.instance.setSessionid(this.mSessionid);
				ModelPlayer.instance.setPlayerCardID(this.mUserCode);
				ModelPlayer.instance.setName(re["username"]);
            	ModelPlayer.instance.setPWDs(re["pwd"]);
				ModelPlayer.instance.setServerZones(re["zones"]);
				//
				ModelPlayer.instance.setPlayerList();
				ModelPlayer.instance.tel=re["tel"];
				ModelPlayer.instance.clearReadyTemp();
				//
			}
		}
		public function clear_uid_sessionid():void{
			this.mUID = "";
			this.mUID_base = "";
			this.mSessionid = "";
			this.zone = "";
		}

		/**
		 * 设置自己的初始数据
		 */
		private function initUserData(re:Object):void{
			if(!this.isLogin){
				Platform.checkGameStatus(2000);
				//
				this.data = re;
				if (re.records.writeList) TestUtils.isTestShow = re.records.writeList;
				//
				NetSocket.instance.registerHandler(NetMethodCfg.WS_SR_SYNC_CONFIG,new Handler(this,this.onConfigChange));
				//
				for(var key:String in re)
				{
					if(this.hasOwnProperty(key)){
						this[key] = re[key];
					}
				}
				if(re.hasOwnProperty("uid")){
					this.mUID = re.uid;
				}
				
				if(re.hasOwnProperty("hero")){
					this.checkHeros(this.hero);
				}
				if(re.hasOwnProperty("city_build")){
					ModelCityBuild.initCityBuild();
				}
				if(re.hasOwnProperty("records")){
					if(re.records.hasOwnProperty("redbag_num")){
						ModelManager.instance.modelClub.u_redbag_num=re.records.redbag_num;
					}
				}
				if(re.hasOwnProperty("country_club")){
					ModelManager.instance.modelClub.updateData(re.country_club);
				}
				
				re.auction && ModelAuction.instance.refreshGlobalData(re.auction); // 初始化拍卖数据
				re.legend && ModelLegend.instance.refreshData(re.legend); // 初始化传奇

				ModelPlayer.instance.setCurrZone(this.zone);
				ModelPlayer.instance.setZoneList();
				ModelPlayer.instance.setPlayerList();		
				//
				NetHttp.instance.send(NetMethodCfg.HTTP_USER_SET_ZONES,{uid:this.mUID_base,zone:this.zone,lv:this.getLv()});
				//
				this.property = re.prop;
				if(re.hasOwnProperty("prop")){
					ModelManager.instance.modelProp.getUserProp(re.prop);
				}
				this.pub_records=re.pub_records;

				if(!this.officeModel){
					this.officeModel = new ModelOffice(this.office>0?this.office+"":"");
				}
				//
				this.formate_cd_list();
				this.setGameStartTime();
				//
				ModelUser.checkRuneType();
				ModelUser.checkEquipType();

				//
				Trace.log(this.getGameSeason(),"-----------自己的数据--------------",re,this);
				
				ModelManager.instance.modelInside.setArmyCdObj(0);
				ModelManager.instance.modelChat.initLocalMsgTime();
				
				ModelFormation.initFormationObj();
				ModelOffice.setLocalRedPoint();
				
				ModelChat.initFaceObj();
				ModelChat.initFaceNameObj();
				if(re.hasOwnProperty("chat_cache")){
					ModelManager.instance.modelChat.getChatCache(re.chat_cache);
				}
				FilterManager.instance.decode();
				//
				ThirdRecording.setUid(this.mUID);

				ModelHero.setFestivalHids();
				ModelSalePay.initModels();
				
				re.legend_awaken && ModelLegendAwaken.instance.refreshData(re.legend_awaken); // 初始化传奇觉醒
				
				//登录成功后通知跑马灯开始
				ViewManager.instance.event(ViewManager.EVENT_SHOW_CAROUSE);
			//
			}
			this.mFunQueue.next();
		}
		private function onConfigChange():void {
			if(ConfigApp.isOldCfg){
				NetHttp.instance.send(NetMethodCfg.HTTP_SYS_CONFIG,{pf:ConfigApp.pf,lan:ConfigApp.lan()},Handler.create(this,function(data:Object):void{
					ConfigServer.formatTo(data,true);
					ConfigServer.initData();
					data.cfg && data.cfg.bless_hero && ModelBlessHero.instance.refreshTime();
				}),180);
			}
			else{
				NetHttp.instance.send(NetMethodCfg.HTTP_SYS_CONFIG_NEW,{pf:ConfigApp.pf,lan:ConfigApp.lan()},Handler.create(this,function(data:Object):void {
					var urls:Array = ObjectUtil.values(data.config_dict);
					LoadeManager.loadImg(urls, Handler.create(this, function():void {
						ConfigServer.updateConfig();
						ModelBlessHero.instance.active && ModelBlessHero.instance.refreshTime();
					}));
				}),180);
			}
		}
	
		/**
		 * 游戏启动后,在主场景之前的功能画面
		 */
		public function initSupporUI():void{
			if(!this.isLogin){
				if (ConfigApp.testFightType == 2){
					// if(ConfigApp.isTest){
						TestCopyright.sendInit();
						TestCopyrightData.init();
					// }
					ViewManager.instance.initCheckTired();
					
					ViewManager.instance.closeScenes(true);
					
					FightMain.startFight(null);
					//ViewManager.instance.showTipsTxt(Tools.getMsgById("pupil1"),5);
					return;
				}
				//
				ModelManager.instance.modelGame.checkRealNameTimeTips(this.online_time);//实名检测机制提醒
				ViewManager.instance.closeScenes(true);
				if(ModelUser.getCountryID()>-1){
					this.initModels(1);
				}
				else{
					//国家选择
					if(HelpConfig.type_app == HelpConfig.TYPE_WW){
						ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY_WW,Handler.create(this,this.initModels),{type:0});
					}else{
						if(ConfigApp.isPC){
							ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY_PC,Handler.create(this,this.initModels),{type:0});
						}else{
							ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY,Handler.create(this,this.initModels),{type:0});
						}
					}
					
				}	
			}		
		}	
		/**
		 * 各功能固定 model 初始化/数据处理/功能数据整理
		 */
		public function initModels(type:Number=0):void{
			Platform.uploadUserData(1,[type]);
			Trackingio.postReport(4,{uid:this.mUID});
			//
			LoadeManager.instance.showLoadPanel(0);
			// 初始化引导模型
			GuideChecker.instance.initGuide();	
			//			
			ModelManager.instance.modelInside.initCDlistener();//初始化建筑数据,和农民一起初始化
			//
			ModelManager.instance.modelProp.getPveGiftDict();
			// 初始化成就
			ModelAchievement.instance.initModelAchievement();
			// 初始化各个活动模型
			ModelActivities.instance.initModel();	
			//初始化任务模型
			TaskHelper.instance.initTaskModel();
			//军团
			ModelManager.instance.modelGame.getMyguildData();	
			//地图数据
			var _this:* = this;
			//
			MapModel.instance.initMap(new Handler(_this, function():void{
				LoadeManager.instance.onProgress(getInitLoadPer());
				Laya.timer.once(100,_this,_this.initTroopModel);
			}));
		}
		/**
		 * 初始化 部队信息
		 */
		private function initTroopModel():void {
			LoadeManager.instance.onProgress(getInitLoadPer());
			var _this:* = this;
			ModelManager.instance.modelTroopManager.init(Handler.create(_this, function():void{
				LoadeManager.instance.onProgress(getInitLoadPer());
				Laya.timer.once(100,_this,_this.initMainUI);
			}));
		}
		/**
		 * 主界面 初始化 UI
		 */
		public function initMainUI():void{
			//游戏UI初始化
			ViewManager.instance.initGame();
			//
			this.isLogin = true;//登录成功
			//
			this.loadWaitToEnd();
		}
		/**
		 * 强制 等待 初始各自数据
		 */
		private function loadWaitToEnd():void{
			Laya.timer.clear(this,this.loadWaitToEnd);
			if(sInitLoadMax<1 || !ModelOfficial.countries){
				LoadeManager.instance.onProgress(getInitLoadPer());
				Laya.timer.once(50,this,this.loadWaitToEnd);
			}
			else{
				LoadeManager.instance.onComplete();
				this.initQueue();
			}
		}
		/**
		 * 游戏启动后,各种功能显示
		 */
		public function initQueue():void{
			Trace.log("------游戏启动后,各种功能显示-------");
			//主界面各种menu功能
			ViewManager.instance.initMenuFunc();
			//系统提示
			//ViewManager.instance.event(ViewManager.EVENT_SHOW_CAROUSE);
			//活动弹板
			//ActivityHelper.checkPanelPop();	
			//谁是国王
			//ModelOfficial.checkCountryKingTips();
			
			Platform.bbsOther();//某些平台弹出的论坛

			QueueManager.instance.checkInitQueue();
			QueueManager.instance.showFirst();
			

			//引导开始
			GuideChecker.instance.startGuide();						
		}
		/**
		 * 更新已经改变的数据
		 */
		public function updateData(re:*):void{
			if(Tools.isNullObj(re)){return;}
			if(Tools.isNullObj(this.data)){return;}
			var userRe:Object = {};
			if(re.hasOwnProperty("user")){
				userRe = re.user;
			}
			if(Tools.isNullObj(userRe)){return;}
			var cb:Array = this.checkPayUpdate(userRe);
			this.checkFtaskUpdate(userRe);//民情
			this.checkBuyWeapon(userRe);//检查是否有购买武器活动
			var oldCoin:Number = this.coin;
			//
			var changeShogunValue:Boolean;
			if (userRe.hasOwnProperty("shogun_value")){
				//幕府效果值与当前不同，强制刷新所有战力
				if(!FightUtils.compareObj(this.shogun_value, userRe.shogun_value)){
					changeShogunValue = true;
				}
			}
			
			for(var key:String in userRe)
			{
				this.data[key] = userRe[key];
				if(key == "hero"){//英雄单独刷新 不全覆盖
					for(var hid:String in userRe[key]){
						this.hero[hid] = userRe[key][hid];
					}
					//trace("=========heros ",userRe[key]);
				}else if(key == "records"){//
					for(var record:String in userRe[key]){
						this.records[record] = userRe[key][record];
					}
					//trace("=========records ",userRe[key]);
				}else{
					if(this.hasOwnProperty(key)){
						this[key] = userRe[key];
					}
				}
			}
			var newCoin:Number = userRe.hasOwnProperty("coin")?userRe["coin"]:-1;
			if(newCoin>=0 && oldCoin!=newCoin){
				Platform.uploadUserData(4,[oldCoin,newCoin]);
			}
			//if(re.hasOwnProperty("guild")){
			//	ModelManager.instance.modelGuild.updateData(re.guild);
			//}
			if(re.hasOwnProperty("country_club")){
				ModelManager.instance.modelClub.updateData(re.country_club);
			}

			if(re.hasOwnProperty("country_data")){//国家上的数据
				var myCountry:Object=ModelOfficial.countries[ModelManager.instance.modelUser.country];
				var reCountry:Object=re["country_data"];
				for(var s:String in reCountry){
					if(myCountry.hasOwnProperty(s)){
						myCountry[s]=reCountry[s];
					}
				}
			}

			if(userRe.hasOwnProperty("alien_reward")){//异邦来访获得的盒子
				ModelManager.instance.modelClub.event(ModelClub.EVENT_COUNTRY_ALIEN_RED);
			}
			if(userRe.hasOwnProperty("hero")) { // 更新副将相关数据
				this.checkHeros(this.hero);
			}
			//全部item
			if(userRe.hasOwnProperty("prop")){
				this.property = userRe.prop;
				ModelManager.instance.modelProp.getUserProp(userRe.prop);
			}
			
			// 检查各种数据记录
			this.checkRecords(userRe);

			// 检查关注认证
			if(userRe.hasOwnProperty("records_360")){
				ModelActivities.instance.refreshLeftList();
			}

			//建筑升级cd
			if(userRe.hasOwnProperty("building_cd")){
				this.formate_cd_list();
			}
			//爵位
			if(userRe.hasOwnProperty("office")){
				if(this.officeModel){
					this.officeModel.initData(this.office+"");
				}
			}
			if(userRe.hasOwnProperty("hero_catch")){
				event(EventConstant.HERE_CATCH, Tools.getFullHourDis());
				this.event(ModelUser.EVENT_UPDATE_BTM_BTN);
			}
			if(userRe.hasOwnProperty("visit")){
				this.event(ModelUser.EVENT_UPDATE_BTM_BTN);
			}
			if(userRe.hasOwnProperty("estate")){
				this.event(ModelUser.EVENT_UPDATE_BTM_BTN);
			}
			if(userRe.hasOwnProperty("city_build")){
				this.event(ModelUser.EVENT_UPDATE_BTM_BTN);
			}
			if(userRe.hasOwnProperty("baggage")){
				if(ModelManager.instance.modelGame.isInside){
					ModelManager.instance.modelInside.getBuildingModel("building004").updateStatus();
				}
			}
			//任务
			if (userRe.hasOwnProperty("task")) {
				TaskHelper.instance.onTaskProgressChange(userRe['task']);
			}
			if (userRe.hasOwnProperty("gtask")) {
				TaskHelper.instance.event(TaskHelper.REFRESH_TASK_STORY);
			}
			//成就
			if (userRe.hasOwnProperty("effort")) {
				ModelAchievement.instance.refreshData(userRe['effort']);
			}
			//天下大势面板
			if (userRe.hasOwnProperty("milepost_reward") || userRe.hasOwnProperty("milepost_fight_reward")) {
				ModelManager.instance.modelGame.event(ModelOfficial.EVENT_UPDATE_ORDER_ICON);
			}
			// 探险
			if (userRe.hasOwnProperty("mining") || false) {
				ModelExplore.instance.refreshData(userRe);
			}
			// 拍卖
			if (userRe.hasOwnProperty("auction")) {
				ModelAuction.instance.refreshGlobalData(userRe.auction);
			}
			// 传奇
			if (userRe.hasOwnProperty("legend")) {
				ModelLegend.instance.refreshData(userRe.legend);
			}
			// 福将挑战
			if (userRe.hasOwnProperty("bless_hero")) {
				ModelBlessHero.instance.refreshData(userRe.bless_hero);
			}
			// 传奇觉醒
			if (userRe.hasOwnProperty("legend_awaken")) {
				ModelLegendAwaken.instance.refreshData(userRe.legend_awaken);
			}
			//异族入侵
			if (userRe.hasOwnProperty("pk_npc"))
			{
				ModelManager.instance.modelGame.checkPKnpcFightTimerStatus();
			}
			if(userRe.hasOwnProperty("star")){
				ModelUser.checkRuneType();
			}
			if(userRe.hasOwnProperty("equip")){
				ModelUser.checkEquipType();
			}
			//
			this.checkProIsChangePower(userRe, changeShogunValue);//
			//
			this.event(EVENT_USER_UPDATE,re);
			//
			if(cb.length!=0){
				this.event(EVENT_TOP_UPDATE,[cb]);
			}
			var ns:Number = Tools.gameDay0hourMs(ConfigServer.getServerTimer()); // 当前时间
			var st:Number = ns;
			var et:Number = ns+Tools.oneDayMilli;
			//trace("现在时间：",Tools.dateFormat(ConfigServer.getServerTimer()),"新的一天: ",Tools.dateFormat(et));

		}
		public static function checkRuneType():void{
			var id:String = "";
			rune_type_dic_sp = {};
			rune_type_dic=[];
			for(var key:String in ModelManager.instance.modelUser.star){
				id = key.split("|")[0];
				if(!rune_type_dic[ConfigServer.star[id].fix_type]){
					rune_type_dic[ConfigServer.star[id].fix_type] = {}
					rune_type_dic[ConfigServer.star[id].fix_type][key] = ModelManager.instance.modelUser.star[key];
				}
				else{
					rune_type_dic[ConfigServer.star[id].fix_type][key] = ModelManager.instance.modelUser.star[key];
				}
				if(ConfigServer.system_simple.fix_star_only.indexOf(id)>-1){
					if(ModelManager.instance.modelUser.star[key].hid){
						if(!rune_type_dic_sp.hasOwnProperty(id)){
							rune_type_dic_sp[id] = [];
						}
						if(rune_type_dic_sp[id].indexOf(ModelManager.instance.modelUser.star[key].hid)<0){
							rune_type_dic_sp[id].push(ModelManager.instance.modelUser.star[key].hid);
						}
					}
				}
			}
		}
		public static function checkEquipType():void{
			var id:String = "";
			for(var key:String in ModelManager.instance.modelUser.equip){
				// if(!ModelEquip.searchHero(key)){
					if(!equip_type_dic[ConfigServer.equip[key].type]){
						equip_type_dic[ConfigServer.equip[key].type] = {}
						equip_type_dic[ConfigServer.equip[key].type][key] = ModelManager.instance.modelUser.equip[key];
					}
					else{
						equip_type_dic[ConfigServer.equip[key].type][key] = ModelManager.instance.modelUser.equip[key];
					}
				// }
			}
		}		
		/**
		 * solo战斗刷新部队
		 */
		public function soloFightUpdateTroop(re:*):void
		{
			if(re.hasOwnProperty("pk_result")){
				var obj:Object=re.pk_result.userTroop;
				var hid:String="";
				var d:Object={};
				for(var s:String in obj){
					hid=s;
					d["army"]=obj[s];
					ModelManager.instance.modelTroopManager.setTroopData(EventConstant.TROOP_UPDATE,hid,d);
				}
			}
		}
		/**
		 * 检测 那些 属性变化 影响 总战力
		 */
		private function checkProIsChangePower(ud:Object, mustUpdate:Boolean = false):void
		{
			if (mustUpdate 
			    || ud.hasOwnProperty("hero") 
				|| ud.hasOwnProperty("science")
				|| ud.hasOwnProperty("equip")
				|| ud.hasOwnProperty("star")
				|| ud.hasOwnProperty("home")
				|| ud.hasOwnProperty("beast")
				//缺少 国王 称帝 的判断
			){
				this.getPower(true);
			}
		}
		private function checkPayUpdate(userRe:Object):Array{
			var updateNum:int = 0;
			var arr:Array = ["gold","food","wood","iron","coin","merit"];
			var arr_num:Array=[];
			var len:int = arr.length;
			var key:String;
			for(var i:int = 0; i < len; i++)
			{
				key = arr[i];
				if(userRe.hasOwnProperty(key)){
					if(userRe[key]<this[key]){
						//updateNum+=1;
						var o:Object={};
						o[key]=userRe[key]-this[key];
						arr_num.push(o);
					}
				}
			}
			//if(updateNum>0){
			//	return arr_num;
			//}
			return arr_num;
		}

		private function checkFtaskUpdate(userRe:Object):void{			
			if(userRe.ftask && this.ftask && Tools.getDictLength(this.ftask)!=0){
				//trace("检查是否有新民情");
				var obj:Object=Tools.copyObj(this.ftask);
				for(var s:String in userRe.ftask){
					if(!obj.hasOwnProperty(s)){
						this.ftask=userRe.ftask;
						ModelManager.instance.modelGame.addFtask(s);
					}
				}
			}
		}

		
		private function checkRecords(userRe:Object):void{
			var records:* = userRe.records;
			if (records) {
				ModelActivities.instance.refreshActivitiesData(records);
				records.pay_gtask_reward && this.checkGtaskReward(records.pay_gtask_reward);
				if(records.hasOwnProperty("redbag_num")){
					ModelManager.instance.modelClub.u_redbag_num=records.redbag_num;
				}
			}
			userRe.member && ModelMemberCard.instance.refreshData(userRe.member);
		}

		private function checkHeros(hero:Object):void
		{
            // 第一次遍历 记录拥有的副将
            for(var hid:String in hero)
            {
				var tempHero:Object = hero[hid];
                var adjutant:Array = tempHero['adjutant'];
				if (adjutant) {
					tempHero['isCommander'] = false; // 是否是主将
					if (adjutant[0]) {
						hero[adjutant[0]]['commander'] = hid; // 设置主将
						tempHero['isCommander'] = true;
					}
					if (adjutant[1]) {
						hero[adjutant[1]]['commander'] = hid; // 设置主将
						tempHero['isCommander'] = true;
					}
				}
				else {
					tempHero['isCommander'] = false;
					tempHero['adjutant'] = [null, null];
				}
				tempHero['commander'] || (tempHero['commander'] = '');

            }

			//兽灵处理
			if(this.beast){
				for(var beastId:String in this.beast){
					ModelBeast.getModel(Number(beastId)).hid = "";
					for(var heroId:String in this.hero){
						if(this.hero[heroId].beast_ids){
							for(var i:int=0;i<this.hero[heroId].beast_ids.length;i++){
								if(this.hero[heroId].beast_ids[i] && this.hero[heroId].beast_ids[i]==beastId){
									ModelBeast.getModel(Number(beastId)).hid = heroId;
								}
							}
							
						}
					}
					
				}
			}
		}

		/**
		 * 检查福利兑换
		 */
		public function checkFreeBuy(re:Object):void{
			var user:Object=re["user"];
			if(user && user.hasOwnProperty("records")){
				var free_buy:Object=user["records"].free_buy;
				if(free_buy){
					for(var s:String in free_buy){
					if(free_buy[s]!=null && this.records.free_buy[s]==null){
							free_buy_key=s;
							break;
						}
					}
				}
			}	

		}

		/**
		 * 检查是否有“购买武器”活动
		 */
		public function checkBuyWeapon(re:Object):void{
			if(re && re.hasOwnProperty("records")){
				var buy_weapon:Object=re["records"].buy_weapon;
				if(buy_weapon){
					var user:Object=this.records["buy_weapon"];
					for(var s:String in buy_weapon){
						if(user==null || !user.hasOwnProperty(s)){
							free_buy_key="buy_weapon_"+s;
							break;
						}
					}
					this.records["buy_weapon"]=re["records"].buy_weapon;
					ModelFreeBuy.instance.addData();
				}
				
			}
		}

		/**
		 * num 需要消耗的量
		 */
		public function checkPayMoneyAddArmy(num:int):Boolean{
			var system_simple:Object = ConfigServer.system_simple;
			var cost_type:String = system_simple.fast_train_type;
			return this[cost_type] >= num && pay_money >= system_simple.fast_train_pay && ModelGame.unlock(null, 'fast_train').visible;
		}
		/**
		 * 凤雏理政 充钱送居功至伟次数
		 */
		private function checkGtaskReward(pay_gtask_reward:Array):void{
			if (pay_gtask_reward[2] === 0 && pay_gtask_reward[3] === 0 && Tools.getRemainTime(pay_gtask_reward[1]) > 0) {
				if (ModelFreeBuy.instance.gtaskTime !== Tools.getTimeStamp(pay_gtask_reward[1])) {
					ModelFreeBuy.instance.gtaskTime = Tools.getTimeStamp(pay_gtask_reward[1]);
					free_buy_key = 'gtask';
				}
			}
		}

		public function formate_cd_list():void{
			this.building_cd_arr = [];
			for(var key:String in this.building_cd)
			{
				this.building_cd_arr.push({id:key,cd:Tools.getTimeStamp(this.building_cd[key])});
			}
		}
		public function getLocalCountry():void{
			
		}
		public function getLv():Number{
			return ModelManager.instance.modelInside.getBase().lv;
		}
		/**
		 * 称号集
		 */
		public function getMyTitle():Array{
			if(this.records.hasOwnProperty("title")){
				return this.records["title"];
			}
			return [];
		}
		public function getMyTitleCanSet():Boolean{
			var b:Boolean = false;
			var noUsed:Array = this.getMyTitle();
			var len:int = noUsed.length;
			var endMs:Number = 0;
			var now:Number = ConfigServer.getServerTimer();			
			for(var i:int = 0;i < len;i++){
				endMs = Tools.getTimeStamp(noUsed[i][1]);
				if(endMs>now){				
					b = true;
					break;
				}
			}			
			return b;
		}		
		public function getMyTitleAll():Array{
			var noUsed:Array = this.getMyTitle();
			var heros:Array = [];
			var endMs:Number = 0;
			var now:Number = ConfigServer.getServerTimer();
			var _sort1:Number=0;//是否安装
			var _sort2:Number=0;//品质
			var _sort3:Number=0;//id
			var tid:String="";
			for(var key:String in this.hero){
				if(this.hero[key]){
					if(this.hero[key]["title"]){
						tid=this.hero[key]["title"][0];
						endMs = Tools.getTimeStamp(this.hero[key]["title"][1]);
						_sort1=0;
						_sort2=10-ConfigServer.title[tid].rarity;
						_sort3=Number(tid.split('e')[1]);
						if(endMs>now){
							heros.push({data:this.hero[key]["title"],hid:key,index:-1,sort1:_sort1,sort2:_sort2,sort3:_sort3});
						}
					}
				}
			}
			var len:int = noUsed.length;
			for(var i:int = 0;i < len;i++){
				tid=noUsed[i][0];
				_sort1=1;
				_sort2=10-ConfigServer.title[tid].rarity;
				_sort3=Number(tid.split('e')[1]);
				endMs = Tools.getTimeStamp(noUsed[i][1]);
				if(endMs>now){				
					heros.push({data:noUsed[i],hid:"",index:i,sort1:_sort1,sort2:_sort2,sort3:_sort3});
				}
			}
			heros=ArrayUtils.sortOn(["sort1","sort2","sort3"],heros,true);
			return heros;
		}
		/**
		 * 获得 玩家 已有星辰 配置,先格式化 id
		 */
		public function getStarList():Array{
			var o:Array=[];
			var o1:Array=[];
			var o2:Array=[];
			var configData:Object=ConfigServer.star;
			for (var s:String in this.star)
			{
				var itemStar:Object={};
				var cid:String = s;
            	var temp:int = s.indexOf("|");
           	 	if(temp>-1){
                	cid = s.substring(0,temp);
            	}
				//var lv:String=star[s].lv;
				//if(lv.substr(0,1)=="0"){
				//	lv=lv.substr(1,lv.length-1);
				//}
				if(star[s].hid==null && configData.hasOwnProperty(cid)){
					itemStar=Tools.copyObj(configData[cid]);
					itemStar["id"]=cid;
					itemStar["cid"]=s;
					itemStar["lv"]=star[s].lv;
					itemStar["exp"]=star[s].exp;
					itemStar["sort"]=100-Number(itemStar["icon"]);
					itemStar["icon"]="star0"+itemStar["icon"]+".png";
					
					if(itemStar.fix_type>=4){
						o2.push(itemStar);
					}else{
						o1.push(itemStar);
					}
				}
			}
			ArrayUtils.sortOn(["sort","exp"],o1,true);
			ArrayUtils.sortOn(["sort","exp"],o2,true);
			o=[o1,o2];
			return o;
		}
		/**
		 * 获取 可以 编辑 部队 的英雄 id 数组
		 */
		public function getTroops():Array{
			var troopAll:Object = ModelManager.instance.modelTroopManager.troops;
			//this.uid + "&" + this.hero
			var tid:String = "";
			var arr:Array = [];
			var hmd:ModelHero;
			for(var key:String in hero)
			{
				tid = this.mUID+"&"+key;
				if(!troopAll.hasOwnProperty(tid)){
					hmd = ModelManager.instance.modelGame.getModelHero(key);
					
					if(this.getCommander(hmd.id)){
						continue;
					}
					hmd["sortPower"] = hmd.getPower();
					arr.push(hmd);
				}
			}
			return arr;
		}
		/**
		 * 查看 任何 用户信息,统一的ui
		 */
		public function selectUserInfo(id:*):void{
			if((Number(id)<0)) return;
			NetSocket.instance.send(NetMethodCfg.WS_SR_USER_INFO,{uid:Number(id)},Handler.create(this,this.ws_sr_user_info,[id]));
		}

		/**
		 * 调接口刷新用户数据
		 */
		public function checkUserData(arr:Array,fun:Function=null):void{
			var this2:*=this;
			if(arr==null || arr.length==0){
				return;
			}
			NetSocket.instance.send("update_user",{"key":arr},new Handler(this,function(np:NetPackage):void{
				updateData(np.receiveData);
				if(fun){
					if(fun is Handler){
						(fun as Handler).run();
					}
					else{
						var handler:Handler = Handler.create(this2,fun);
						handler && handler.run();
					}
				}
			}));
		}

		/**
		 * 查看玩家在线状态
		 */
		public function checkUserOnline(uids:Array,fun:*=null):void{
			var this2:*=this;
			NetSocket.instance.send("get_online",{"uids":uids},new Handler(this,function(np:NetPackage):void{
				if(fun){
					if(fun is Handler){
						(fun as Handler).runWith(np.receiveData);
					}
					else{
						var handler:Handler = Handler.create(this2,fun,[np.receiveData]);
						handler && handler.runWith(np.receiveData);
					}
				}
			}));
		}



        private function ws_sr_user_info(id:String,re:NetPackage):void{
			re.receiveData["id"]=id;
            ViewManager.instance.showView(ConfigClass.VIEW_USER_INFO,re.receiveData);
        }	

		/**
		 * 获取给定英雄的主将（可用来判断是否是副将）
		 * @param id 英雄id
		 * 
		 */
		public function getCommander(id:String):String
		{
			if (hero[id]) {
				return hero[id]['commander'];
			}
			return '';
		}

		/**
		 * 获取 自己 当前 全部已有英雄的 战力排序
		 * @param	filterAdjutant 是否过滤掉副将  默认不过滤
		 */
		public function getMyHeroArr(sortPower:Boolean = false,removeId:String = "",ext:Array = null, filterAdjutant = false):Array{
			var arr:Array = [];
            var hmd:ModelHero;
            for(var key:String in hero)
            {
				if (filterAdjutant && this.getCommander(key)) {
					continue;
				}
                hmd = ModelManager.instance.modelGame.getModelHero(key);
				if(sortPower){
					hmd["sortPower"] = hmd.getPower();
				}
				if(hmd.id != removeId){
					if(ext){
						if(ext.indexOf(hmd.id)<0){
							arr.push(hmd);
						}
					}
					else{
						arr.push(hmd);
					}
                	
				}
            }
			if(sortPower && arr.length>1){
				arr.sort(MathUtil.sortByKey("sortPower",true));
			}
			return arr;
		}




		/**
		 * 设置 游戏时间
		 */
		public function setGameStartTime():void{
			this.gameServerStartTimer = Tools.getGameServerStartTimer(this.zone);
			this.loginDateNum = this.getGameDate();
			//trace("开服天是",this.loginDateNum,Tools.dateFormat(this.gameServerStartTimer));
			//开服时间0点是
		}	
		/**
		 * 游戏内 度过的 天数（从1起）
		 */
		public function getGameDate(ms:Number=-1):Number{
			var s:Number = Math.ceil(this.getGameTime(ms)/Tools.oneDayMilli);
			// 开服时间第几天
			return s;
		}
		/**
		 * 游戏内 度过的 年数（从1起）
		 */
		public function getGameYear(ms:Number=-1):Number{
			var s:Number = getGameDate();
			// 开服时间第几天
			return Math.floor((s-1)/4);
		}
		/**
		 * 游戏内 度过的 时间戳 ms 包含偏移值了
		 */
		public function getGameTime(ms:Number=-1):Number{
			return ((ms>-1)?ms:ConfigServer.getServerTimer()) - this.gameServerStartTimer;	
		}
		/**
		 * 游戏内 度过的 季节
		 */
		public function getGameSeason():Number{
			return (this.getGameDate()-1)%4;
		}
		public static const season_name:Array = [
			Tools.getMsgById("_public149"),
			Tools.getMsgById("_public150"),
			Tools.getMsgById("_public151"),
			Tools.getMsgById("_public152")
		]
		/**
		 * 获得 游戏内 季节名称
		 */
		public function getSeasonName():String{
			return season_name[this.getGameSeason()];
		}
		/**
		 * 自己的 最高 战力
		 */
		public function getPower(changeClip:Boolean = false,heroNum:Number = -1):Number{
			if(this.myPowerTemp>0 && !changeClip && heroNum<0){

				return this.myPowerTemp;
			}
			var arr:Array = ConfigServer.system_simple.power_herocount;
			var lv:int = this.getLv();
			var len:int = arr.length;
			var index:int = -1;
			var i:int = 0;
			for(i=0; i < len; i++)
			{
				if(lv<=arr[i][0]){
					index = i;
					break;
				}
			}
			index = (index<0)?(arr.length-1):index;
			//
			len = arr[index][1];
			//
			var md:ModelHero;
			var arrMd:Array = [];
			for(var key:String in this.hero)
			{
				md = ModelManager.instance.modelGame.getModelHero(key);
				
				arrMd.push({num:md.getPower(md.getPrepare(true))});
			}
			
			if(arrMd.length>0){
				arrMd.sort(MathUtil.sortByKey("num",true));
			}
			len = (len>arrMd.length)?arrMd.length:len;
			if(heroNum>-1){
				len = (heroNum>len)?len:heroNum;
			}
			var power:Number = 0;
			for(i=0;i<len;i++){
				power += arrMd[i].num;
			}
			Trace.log("检查 我的 power = ",len,power);
			if(power!=this.myPowerTemp){
				if(this.myPowerTemp>0 && changeClip){
					this.myPowerChangeNum+=(power-this.myPowerTemp);
					//ViewManager.instance.clearViewEffectSpecial("_power_change_");
					Laya.timer.clear(this,this.powerTipsClip);
					Laya.timer.once(1000,this,this.powerTipsClip,[this.myPowerChangeNum]);
				}
				this.myPowerTemp = power;
				this.event(EVENT_USER_UPDATE_POWER,power);
				ModelHero.setBestHid();
			}
			return power;
		}
		private function powerTipsClip(des:Number):void
		{
			if(des)
				ViewManager.instance.showViewEffect(UserPowerChange.getEffect(des),0,null,false,true,"_power_change_");
		}

		/**
		 * 获得头像(英雄id)
		 */
		public function getHead(type:int=0):String{
			var s:String=getUserHead(this.head);
			if(type==1)
				if(s.indexOf('_')!=-1)
					s = s.split('_')[0];
			return s;
		}
		public static function getUserHead(head:*):String{
			if(head) return head;
			return ConfigServer.system_simple["init_user"]["head"];		
		}

		/**
		 * 是否可进行酒馆招募
		 */
		public function isPubOpen():Boolean{
			var pub:Object=ConfigServer.pub;
			var t:Number=pub_records.free_times;
			if(Tools.isNewDay(pub_records.free_time)){
				t=0;
			}
			if(t<pub.hero_box1.free){
				return true;
			}
			var prop1:Array=pub.hero_box2.prop_cost;
			if(ModelManager.instance.modelProp.isHaveItemProp(prop1[0],prop1[1])){
				return true;
			}
			var prop2:Array=pub.hero_box3.prop_cost;
			if(ModelManager.instance.modelProp.isHaveItemProp(prop2[0],prop2[1])){
				return true;
			}

			return false;
		}



		public function removeChatData(str:String):void{
			var localData:Object=SaveLocal.getValue(SaveLocal.KEY_CHAT+this.mUID);
			for (var s:String in localData)
			{
				if(s==str){
					delete localData[s];
				}
			}
			SaveLocal.save(SaveLocal.KEY_CHAT+this.mUID,localData,true);
		}


		public function clearChatData():void{
			var localData:Object=SaveLocal.getValue(SaveLocal.KEY_CHAT+this.mUID,true);
			for (var s:String in localData)
			{
				var o:Object=localData[s];
				if(o["content"].length==0){
					delete localData[s];
				}
			}
			SaveLocal.save(SaveLocal.KEY_CHAT+this.mUID,localData,true);
		}

		public function getChatArr():Array{
			var localData:Object=SaveLocal.getValue(SaveLocal.KEY_CHAT+this.mUID,true);
			var listData:Array=[];
			for (var s:String in localData)
			{
				var o:Object=localData[s];
				listData.push(o);
			}
			listData.sort(MathUtil.sortByKey("time",true,false));
			return listData;
		}
		
		public function getChatDataById(id:String):Object{
			var localData:Object=SaveLocal.getValue(SaveLocal.KEY_CHAT+this.mUID,true);
			if(localData && localData.hasOwnProperty(id)){
				return localData[id];
			}else{
				return null;
			}
		}

		public function initChatData():void{
			
		}

		public function setChatData(usr:Array):void{
			var localData:Object=SaveLocal.getValue(SaveLocal.KEY_CHAT+this.mUID,true);
			for(var i:int=0;i<usr.length;i++){
				var a:Array=usr[i];
				var o:Object=a[0];
				var text:String=a[1];
				var time:Number=a[2] is Number? a[2]:Tools.getTimeStamp(a[2]);
				var me:Boolean= a.length==4 && a[3];
				if(me==false){
					o["read"]=false;
				}
				if(localData && localData.hasOwnProperty(o.uid+"")){//修改
					var d:Object=localData[o.uid];
					d["data"]=o;
					d["text"]=text;
					d["time"]=time;
					d["uid"]=o.uid+"";
					var c:Array=d["content"];
					c.push({"text":text,"time":time,"me":me,"uid":o.uid});

					if(c.length > 50){//私聊条数
						c.shift();
					}
				}else{//新建
					if(!localData){
						localData={};
					}
					var n:Object={};
					n["uid"]=o.uid+"";
					n["data"]=o;//对方的资料
					n["content"]=text==""?[]:[{"text":text,"time":time,"me":me,"uid":o.uid}];//聊天记录
					n["time"]=time;//最近的时间
					n["text"]=text;//最近的消息
					localData[o.uid+""]=n;
				}
			}
			SaveLocal.save(SaveLocal.KEY_CHAT+this.mUID,localData,true);
			Trace.log('私聊数据: ',localData);
		}

		/**
		 * 获得战功进度
		 */
		public function getCreditArr():Array{
			var cur_num:Number=this.year_credit;
			var cur_lv:Number=this.credit_lv;
			var c_credit:Object=this.isMerge ? ConfigServer.credit['merge_'+ModelManager.instance.modelUser.mergeNum] : ConfigServer.credit;
			var is_add:Boolean=cur_num>=c_credit.clv_up[cur_lv];
			var max_num:Number=0;
			var min_num:Number=0;
			var arr:Array=[];
			var num:Number=0;
			var last_max:Number=0;
			if(!is_add){
				
				arr=c_credit.clv_first_ratio;
				num=c_credit.clv_first[cur_lv];
				last_max=arr[arr.length-1]*num;
				if(cur_num>=last_max){
					max_num=c_credit.clv_up[cur_lv];
					min_num=last_max;
					//return [cur_num,c_credit.clv_up[cur_lv]];
				}
			}else{
				arr=c_credit.clv_added_ratio;
				num=c_credit.clv_added[cur_lv];
				last_max=arr[arr.length-1]*num;
				if(cur_num>=last_max){
					//return Tools.getMsgById("_public153");//战功已满
					var config_rool:Number=c_credit.clv_rool_reward[cur_lv][1];
					var rool:Number=Math.floor((cur_num-last_max)/config_rool);
					min_num=last_max+rool*config_rool;
					max_num=last_max+(rool+1)*config_rool;
					//return [-1,-1,-1];
				}
			}
			for(var i:int=arr.length-1;i>=0;i--){
				var n:Number=num*arr[i];
				if(cur_num<n){
					max_num=n;
					min_num=i==0?0:num*arr[i-1];
				}else{
					break;
				}
			}
			//return cur_num+"/"+Math.round(max_num);
			return [Math.round(min_num),cur_num,Math.round(max_num)];
		}


		/**
		 * 返回可收割的列表
		 */
		public function getEstateHarverst():Array{
			var arr:Array=[];
			var config_harvest_time:Number=ConfigServer.estate.harvest_time*Tools.oneMinuteMilli;
			var now:Number=ConfigServer.getServerTimer();
			for(var i:int=0;i<this.estate.length;i++){
				var o:Object=this.estate[i];
				var t:Number=Tools.getTimeStamp(o.harvest_time);
				if(now-t>config_harvest_time){
					arr.push(i);
				}
			}
			return arr;
		}

		/**
		 * 英雄管理列表
		 */
		public function getEstateManagerArr():Array{
			var arr:Array=[];			
			var now:Number=ConfigServer.getServerTimer();
			//var hmd:ModelHero;
			
			for(var i:int=0;i<this.estate.length;i++){
				var o:Object=this.estate[i];
				if(o.active_hid){
					//hmd=ModelManager.instance.modelGame.getModelHero(o.active_hid);
					var e_time:Number=Tools.getTimeStamp(o.active_harvest_time);
					var obj:Object={};
					obj["hid"]=o.active_hid;
					//var eid:int=o.estate_id;
					//var config_active_time:Number=ConfigServer.estate.estate[eid].active_time*Tools.oneMinuteMilli;
					obj["estateFinish"]=now>=e_time;
					obj["sortTime"]=(now-e_time);
					obj["sortEvent"]=o.event?1:0;
					obj["estate_index"]=i;
					obj["event_id"]=o.event?o.event:"";//ModelHero.getEventById(hmd.id)==""?0:Number(ModelHero.getEventById(hmd.id));
					arr.push(obj);
				}
			}
			for(var key:String in this.visit){
				var a:Array= this.visit[key];
				var v_time:Number=Tools.getTimeStamp(a[2]);
				//hmd=ModelManager.instance.modelGame.getModelHero(a[0]);
				if(a[0]){
					var obj1:Object={};
					obj1["hid"]=a[0];
					obj1["estateFinish"]=now>=v_time;
					obj1["sortTime"]=(now-v_time);
					obj1["sortEvent"]=a[3]?1:0;
					obj1["visit_obj"]={"cid":key,"hid":a[0],"o_hid":a[1]};
					obj1["event_id"]=a[3]?a[3]:"";// ModelHero.getEventById(hmd.id)==""?0:Number(ModelHero.getEventById(hmd.id));
					//hmd["estate_index"]=7;
					if(a[2]!=null){
						arr.push(obj1);
					}
				}			
			}
			
			for(var ckey:String in this.city_build){
				var city_obj:Object=this.city_build[ckey];
				for(var bkey:String in city_obj){
					var b_arr:Array=city_obj[bkey];
					var b_time:Number=Tools.getTimeStamp(b_arr[1]);
					//hmd=ModelManager.instance.modelGame.getModelHero(b_arr[0]);
					var obj2:Object={};
					obj2["hid"]=b_arr[0];
					obj2["estateFinish"]=now>=b_time;
					obj2["sortTime"]=(now-b_time);
					obj2["sortEvent"]=b_arr[2]?1:0;
					obj2["cb_obj"]={"cid":ckey,"bid":bkey};
					obj2["event_id"]=b_arr[2]?b_arr[2]:"";//ModelHero.getEventById(hmd.id)==""?0:Number(ModelHero.getEventById(hmd.id));				
					arr.push(obj2);
				}
			}
			
			ArrayUtils.sortOn(["sortEvent","sortTime"],arr,true);
			return arr;
		}

		/**
		 * 产业or拜访派出英雄列表
		 */
		public function getMyEstateHeroArr(work_index:int,prma:*=""):Array{

			var sid:String="";
			var hids:Array=[];	
			if(work_index==0){
				var config_estate:Object=ConfigServer.estate.estate[prma+""];
				var s:String=(config_estate.hero_debris==0)?config_estate.active_get:"hero";
				sid=ModelSkill.getEstateSID(s,prma+"");
				if(prma == 6){
					if(ModelManager.instance.modelUser.records.estate_6_hids){
					var a:Array=ModelManager.instance.modelUser.records.estate_6_hids;
						if(!Tools.isNewDay(a[0])){
							hids=a[1];
						}
					}
				}
			}else if(work_index==1){
				sid="skill287";
			}else if(work_index==2){
				sid="skill281";
			}

			var arr:Array=[];
			var hmd:ModelHero;
			var hmd2:ModelHero;
			var n:Number=0;
			var hid:String=(prma is String)?prma:"";
			if(hid!=""){
				hmd2=ModelManager.instance.modelGame.getModelHero(hid);
				n=hmd2.getTopDimensional()[2];
			}	
			
			for(var key:String in this.hero)
			{
				hmd = ModelManager.instance.modelGame.getModelHero(key);
				var o:Object={};

				//战斗力
				o["sortPower"] = hmd.getPower()?hmd.getPower():1;
				//相对应的技能等级
				o["sortSkill"] = sid==""?10000:ModelManager.instance.modelGame.getModelSkill(sid).getLv(hmd);
				//默认10 产业1-6 拜访7 建造8
				o["sortBusy"] = hmd.getHeroEstate().id;
				//是否宿命
				o["sortFate"] =hid!="" && hmd2.isMyFate(hmd.id)?1:0;
				//四维最高的一项
				o["sortDim"] = (hid=="")?1000:hmd.getOneDimensional(n);
				//是否是自己
				o["sortMe"] = (hid!="" && hid==key)?0:1;
				//狩猎每日一次是否已进行
				o["sortNot"] = hids.indexOf(key)==-1?1:0;

				o["hid"]=key;
				if(work_index==0 && prma+""=="6" && hmd.rarity==4){//牧场 传奇英雄
					continue;
				}
				arr.push(o);
			}
			if(work_index==0 || work_index==1){
				ArrayUtils.sortOn([ "sortNot",
								"sortBusy",
								"sortMe",
								"sortFate",
								"sortSkill",
								"sortDim",
								"sortPower"],arr,true);
			}else if(work_index==2){
				ArrayUtils.sortOn([
								"sortBusy",
								"sortSkill",
								"sortPower"],arr,true);
			}
			//trace("=======",arr);
			//if(arr.length>1){
			//	arr.sort(MathUtil.sortByKey("sortEstate",true,true));
			//}
			//for(var i:int=0;i<arr.length;i++){
				//trace("=================  ",arr[i].sortEstate2,arr[i].sortEstate);
			//}
			
			return arr;
		}



		/**
		 * 某个产业主动的增加百分比（科技、特权、技能、洗炼）
		 */
		public static function estate_active_add(estate_id:String,hmd:ModelHero):Number{
			var config_estate:Object=ConfigServer.estate.estate[estate_id];
			var n0:Number=0;//ModelScience.func_sum_type("estate_active",estate_id);//科技
			var n1:Number=0;//ModelOffice.func_estatetime(estate_id);//特权
			var n2:Number=0;//技能
			var sid:String=ModelSkill.getEstateSID(config_estate.active_get,estate_id);
			if(sid!=""){
				var smd:ModelSkill=ModelManager.instance.modelGame.getModelSkill(sid);
				var slv:int=smd.getLv(hmd);
				if(slv>0){
					var arr:Array=smd.estate_active[2];
					if(arr.length==1){
						n2=slv*arr[0];
					}else if(arr.length==2){
						n2=slv*arr[0]+arr[1];
					}
				}
			}
			var n3:Number=0;//洗炼
			var config_wash:Object=ConfigServer.equip_wash;
			var w_arr:Array=ModelEquip.getEstateWashId(config_estate.active_get,estate_id);
			if(w_arr.length!=0){
				var equip:Array=hmd.getEquip();
				for(var i:int=0;i<equip.length;i++){
					var wash:Array=ModelManager.instance.modelUser.equip[equip[0]].wash;
					for(var j:int=0;j<w_arr.length;j++){
						if(wash.indexOf(w_arr[j])!=-1){
							n3+=config_wash[w_arr[j]].estate_active[2];
						}
					}
				}
			}
			var n:Number=n0+n1+n2+n3;
			return n; 
		}


		/**
		 * 某个产业被动产出的增加百分比（科技和特权）
		 */
		public static function estate_produce_add(estate_id:String):Number{
			var n0:Number=ModelScience.func_sum_type("estate_produce",estate_id);
			var n1:Number=ModelOffice.func_syield();
			var n:Number=n0+n1;
			return n;
		}



		/**
		 * 该城市是否完成民情
		 */
		public function isFinishFtask(cid:String):Boolean{
			if(ConfigServer.city[cid].hasOwnProperty("pctask_id")){
				if(this.ftask){
					if(this.ftask.hasOwnProperty(cid)){
						if(this.ftask[cid][0]==-1){
							return true;
						}
					}
				}
			}else{
				Trace.log("这个城市没有民情");
				return true;
			}
			return false;
		}



		/**
		 * 是否显示异邦来访组队信息
		 */
		public function isShowGuildAlien():void{

		}

		/**
		 * 是否完成产业挂机
		 */
		public function isEstateFinish(index:int):Boolean{
			var e:Object=this.estate[index];
			if(e){
				var now:Number=ConfigServer.getServerTimer();
				var cd:Number=Tools.getTimeStamp(e.active_harvest_time);
				if(cd<=now){
					return true;
				}
			}
			return false;
		}

		/**
		 * 是否完成拜访
		 */
		public function isVisitFinish(cid:String):Boolean{
			var e:Object=this.visit[cid];
			if(e){
				var now:Number=ConfigServer.getServerTimer();
				var cd:Number=Tools.getTimeStamp(e[2]);
				if(cd<=now){
					return true;
				}
			}
			return false;
		}

		/**
		 * 是否完成建造
		 */
		public function isCityBuildFinish(user_cb_obj:Object):Boolean{
			var e:Object=this.city_build[user_cb_obj.cid][user_cb_obj.bid];
			if(e){
				var now:Number=ConfigServer.getServerTimer();
				var cd:Number=Tools.getTimeStamp(e[1]);
				if(cd<=now){
					return true;
				}
			}
			return false;

		}
        public static function getCountryID(countryID:* = ""):int
        {
			if (countryID is int){
				return countryID;
			}
            return (countryID == "")?ModelManager.instance.modelUser.country:parseInt(countryID);
        }
		/**
		 * 得到首都cid
		 */
		public static function getCaptainID(countryID:* = ""):int
        {
			var country:int = getCountryID((country < 0?(country + 3):country));
            return ConfigServer.country.country[country].capital;
        }
		/**
		 * 得到首都名字
		 */
		public static function getCaptainName(countryID:* = ""):String
        {
			var country:int = getCountryID((country < 0?(country + 3):country));
            return Tools.getMsgById(ConfigServer.city[ConfigServer.country.country[country].capital].name); 
        }
		/**
		 * 是否开启幕府
		 */
		public static function isOpenShogun():String{
			var open_lv:Number=ConfigServer.shogun.shogun_limit[0][0];
			return ModelManager.instance.modelUser.getLv()>=open_lv?"":Tools.getMsgById("_public58",[open_lv]);//"官邸等级到达"+open_lv+"级开启";
		}
		/**
		 * 是否开启幕府
		 */
		public function isCanLvUpShogun():Boolean{
			
			for(var i:int=0;i<this.shogun.length;i++){
				if(isCanLvUpShogunByIndex(i)){
					return true;
				}
			}
			return false;
		}

		public function isCanLvUpShogunByIndex(index:int):Boolean{
			var item_arr:Array=ConfigServer.shogun.shogun_book;
			if(index<this.shogun.length){
				var obj:Object=this.shogun[index];
				if(obj.lv >= ConfigServer.shogun.shogun_levelup.length){//满级
					return false;
				}
				var arr:Array=ConfigServer.shogun.shogun_levelup[obj.lv-1];
				if(arr[3]<=this.getLv()){
					if(ModelItem.getMyItemNum(item_arr[index])>=arr[0] && ModelItem.getMyItemNum("gold")>=arr[1]){
						return true;
					}else{
						//trace(item_arr[i]+"数量不够");
					}
				}else{
					//trace("官邸等级不够");
				}
			}
			return false;
		}

		/**
		 * 幕府里面是否有英雄
		 */
		public static function isShogunHasHero():Boolean{
			var arr:Array=ModelManager.instance.modelUser.shogun;
			for(var i:int=0;i<arr.length;i++){
				var o:Object=arr[i];
				if(o){
					for(var j:int=0;j<o.hids.length;j++){
						if(o.hids[j] && o.hids[j].indexOf("hero")!=-1){
							return true;
						}
					}	
				}
			}
			return false;
		}

		/**
		 * 获得沙盘演义次数
		 */
		public function pveTimes():Array{
			var arr:Array=[];
			var total_num:Number=ConfigServer.pve.combat_times + ModelScience.func_sum_type("pve_combat_times");
			if(Tools.isNewDay(this.pve_records["combat_time"])){
				//if(total_num<pve_records.combat_times){
				//	return [pve_records.combat_times,total_num];
				//}else{
					return [total_num,total_num];
				//}
			}else{
				var n:Number=ConfigServer.pve.combat_times_buy[0]*ModelManager.instance.modelUser.pve_records.buy_times;
				total_num+=n;
				return [pve_records.combat_times,total_num];
			}			
		}

		/**
		 * 获得pve购买次数的数据[购买几次,剩余购买次数,花费coin值]
		 */
		public function pveBuyArr():Array{
			var m:Number=this.pve_records.buy_times;
			var combat_times_buy:Array=ConfigServer.pve.combat_times_buy;
			var n:Number=(combat_times_buy.length-1)-m;
			if(Tools.isNewDay(this.pve_records.buy_time)){
				m=0;
				n=combat_times_buy.length-1;
			}
			if(n<0){
				n=0;
			}
			return [combat_times_buy[0],n,combat_times_buy[m+1]];
		}

		/**
		 * 酒馆是否可以招募
		 */
		public function isPubCanBuy(index:int,showText:Boolean=true):Boolean{
			var isNewDay:Boolean=Tools.isNewDay(Tools.getTimeStamp(this.pub_records.draw_time));
			var isNewFree:Boolean=Tools.isNewDay(Tools.getTimeStamp(this.pub_records.free_time));
			var draw_times:Number=ConfigServer.pub.draw_limit-this.pub_records.draw_times;
			if(!isNewDay && draw_times<=0){
				showText && ViewManager.instance.showTipsTxt(Tools.getMsgById("_pve_tips11"));//次数不足
				return false;
			}
			var data:Object=ConfigServer.pub["hero_box"+(index+1)];// listData[index];
			if(index!=0){
				var b:Boolean=ModelManager.instance.modelProp.isHaveItemProp(data.prop_cost[0],data.prop_cost[1]);
				if(!b){
					if(!Tools.isCanBuy(data.cost[0],data.cost[1],showText)){
						return false;
					}
				}
			}else{
				var n1:Number=data.free+ModelManager.instance.modelInside.getBuildingModel("building005").lv;
				var n2:Number=this.pub_records.free_times;
				if(isNewDay || isNewFree){
					n2=0;
				} 
				if(n2<n1){
					if(!Tools.isCanBuy(data.cost[0],data.cost[1],showText)){
						return false;
					}
				}else{
					showText && ViewManager.instance.showTipsTxt(Tools.getMsgById("_public42"));//今日次数用完
					return false;
				}
			}
			return true;
		}

		
		public function troop_que_max():Number
		{
			return ConfigServer.system_simple.troop_que + ModelOffice.func_addtroop();
		}


		/**
		 * 新的一年  手动重置战功
		 */
		public function resetCredit():void{
			if(this.getGameSeason()==0){
				var cfg:Object=this.isMerge ? ConfigServer.credit['merge_'+ModelManager.instance.modelUser.mergeNum] : ConfigServer.credit;
				var obj:Object={};
				obj.credit_get_gifts=[];
				obj.credit_year+=1;
				obj.credit_rool_gifts_num=0;
				obj.year_credit=0;

				obj.year_build=0;
				obj.year_dead_num=0;
				obj.year_kill_num=0;
				obj.year_kill_troop=0;

				if(cfg.clv_up.length==0){	
					//无法升级
					obj.credit_lv = 0;
				}else{
					var need_num:Number=cfg.clv_up[this.credit_lv];
					//判断是否升级
					obj.credit_lv = this.year_credit>=need_num ? this.credit_lv+1 : this.credit_lv;
					//判断满级
					obj.credit_lv = this.credit_lv==cfg.clv_up.length-1 ? this.credit_lv : obj.credit_lv;
				}
				//trace("新的一年 重置战功",obj);
				this.event(EVENT_UPDATE_CREDIT);
				updateData({"user":obj});
			}
		}

		/**
		 * 获得充值列表
		 */
		public function getPayList(all:Boolean = false):Array{
			var arr:Array=[];

			var salePayLock:Boolean = ModelGame.unlock(null,"sale_pay").stop;
			for(var v:String in ConfigServer.pay_config_pf){
				if(v.indexOf("pay")<0){
					continue;
				}
				var a:Array=ConfigServer.pay_config_pf[v];

				//充值礼包用的  实际不给元宝
				if(!all && a[1]==0){
					continue;
				}
				
				if(a[9]!=null){
					//不显示平台
					if(a[9] is Array && a[9].indexOf(ConfigApp.pf)!=-1){
						continue;
					}
					//全都不显示
					if(a[9]==0){
						continue;
					}
				}
				var o:Object={};
				o["id"]=v;                     //pay_id
				o["cost"]=getPayMoney(v,a[0]); //花费的钱
				o["cost_cfg"]=a[0];            //单笔充值档位
				o["get"]=a[1];                 //获得的黄金
				o["icon"]=a[2];                //图标
				o["redbag"]=[a[3],a[4]];       //赠送国家红包的范围
				o["text"]=a[5];                //好像没用了这个
				o["first"]=a[6];               //首充的话给这个黄金数
				o["salePayNum"] = !salePayLock ? ModelSalePay.getNumByPId(v) : 0;            //兑换券数量
				var maxSid:String = ModelSalePay.getMaxSaleByPId(v);
				o["salePayID"]  = !salePayLock ? (maxSid==v ? "" : maxSid) : "";       //当前使用的兑换券id
				
				arr.push(o);
			}
			arr.sort(MathUtil.sortByKey("cost",false));
			return arr;
		}

		public function getPayMoney(pid:String,base:*):String{
			if(ConfigServer.system_simple.pay_money){
				if(ConfigServer.system_simple.pay_money[ConfigApp.pf]){
					if(ConfigServer.system_simple.pay_money[ConfigApp.pf][pid]){
						return ConfigServer.system_simple.pay_money[ConfigApp.pf][pid];
					}
				}
			}
			return base;
		}

		public function get pay_money_daily ():int {
			if (records.pay_time && !Tools.isNewDay(records.pay_time)) {
				return records.pay_money_daily;
			}
			return 0;
		}

		public static function getPayMoneyStr(n:*):String{
			return Tools.getMsgById((ConfigApp.pf==ConfigApp.PF_and_google || ConfigApp.pf==ConfigApp.PF_ios_meng52_tw || ConfigApp.pf_channel == ConfigApp.PF_r2game_xm || ConfigApp.pf_channel == ConfigApp.PF_r2game_kr)?"_lht76":"193004",[n]);// "¥ "+o["cost"];
		}

		/**
		 * 根据配置的充值金额（充值配置数组第0位）获取pid
		 */
		public static function getPidByMoney(money:int):String {
			for(var pid:String in ConfigServer.pay_config_pf) {
				if(pid.indexOf("pay") < 0){
					continue;
				}
				var a:Array=ConfigServer.pay_config_pf[pid];
				if (a[0] === money) {
					return pid;
				}
			}
			return '';
		}

		/**
		 * 是否是新的一年
		 */
		public static function isNewYear():Boolean{
			var n:Number=ModelManager.instance.modelUser.getGameYear();
			var m:Number=ModelManager.instance.modelUser.credit_year;
			//trace("服务器",m,"本地",n);
			if(n>m){
				return true;
			}
			return false;
		}

		/**
		 * 检查bug反馈红点  每次登录检查
		 */
		public function checkBugMsgRedPoint():void{
			var sendData:Object={"uid":ModelManager.instance.modelUser.mUID,
														"sessionid":ModelManager.instance.modelUser.mSessionid,
														"zone":ModelManager.instance.modelUser.zone};
				NetHttp.instance.send("bug_msg.get_bug_msg",sendData,Handler.create(this,function(obj:Object):void{
					
					
					
				}));

			//ModelManager.instance.modelChat.isNewBugMSG=true;
			//ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_UPDATE,[{"user":""},true]);//通知红点刷新
			//event(ModelGame.EVENT_UPDAET_BUG_MSG);
		}

		public function recruit_hero_cb(re:NetPackage):void {
			ModelManager.instance.modelUser.updateData(re.receiveData);
			var hid:String = re.sendData.hid;
			SaveLocal.savaArr(SaveLocal.KEY_NEW_HERO+ModelManager.instance.modelUser.mUID,"heros", hid, true);
			ViewManager.instance.showView(ConfigClass.VIEW_HERO_GET_NEW, hid);
		}

		/**
		 * 获得护国军出发时间
		 */
		public static function getCountryArmyAriseTime():Object{
			var o:Object;
			if(ModelOfficial.cities==null){
				return null;
			}
			
			if(ConfigServer.country_army && ConfigServer.country_army.arise_time && ConfigServer.country_army.arise_time.length>0){
				var now:Number = ConfigServer.getServerTimer();
				var dt:Date = new Date(now);
				
				var n:Number = dt.getHours()*60 + dt.getMinutes();
				var arr:Array = [];
				for(var i:int=0;i<ConfigServer.country_army.arise_time.length;i++){
					var a:Array = ConfigServer.country_army.arise_time[i];
					arr.push(a[0]*60+a[1]);
				}
				var cid:String;
				//var citys:Array = [];//满足条件的城市
				var citys:Object = {};//{"cid":time}
				var cfgCitys:Array = ConfigServer.country_army[ModelManager.instance.modelUser.country].target_city;

				for(var k:int=0;k<cfgCitys.length;k++){
					cid = cfgCitys[k][cfgCitys[k].length-1];
					var n0:Number = ModelOfficial.cities[cid].not_belong_country[ModelManager.instance.modelUser.country];
					var n1:Number = n0 ? n0*1000 : 0;
					var n2:Number = ConfigServer.getServerTimer();
					var n3:Number = ConfigServer.country_army.reaction_time * 1000;
					//if(n1+n3<=n2){
						//citys.push(cid);
					//}
					citys[cid] = (n1==0 || n1+n3<=n2) ? 0 : n3 - (n2 - n1);
				}
				

				var troopCitys:Array = [];//部队还存在的城市
				for(var s:String in CountryArmy.map){
					var ca:CountryArmy = CountryArmy.map[s] as CountryArmy;
					if(ca.country == ModelManager.instance.modelUser.country && troopCitys.indexOf(ca.targetCity.cityId+"")==-1){
						troopCitys.push(ca.targetCity.cityId + "");
					}
					
				} 

				var small:Number = arr[0];
				var big:Number = arr[arr.length-1];
				var aa:Array = [];//部队存在
				var bb:Array = [];//部队不存在
				
				
				for(var c:String in citys){
					if(o==null) o = {};
					var nn:Number = citys[c] == 0 ? n : n + (citys[c]/Tools.oneMinuteMilli);

					if(nn>=big){
						aa = ConfigServer.country_army.arise_time[arr.length-1];
						bb = ConfigServer.country_army.arise_time[0];
						if(bb[2] != null) bb[2] = 1;
						else bb.push(1);
					}else if(nn<small){
						bb = ConfigServer.country_army.arise_time[0];
						aa = ConfigServer.country_army.arise_time[arr.length-1];
						if(aa[2] != null) aa[2] = -1;
						else aa.push(-1);
					}else{
						for(var j:int=0;j<arr.length;j++){
							if(nn>=arr[j] && nn<arr[j+1]){
								aa = ConfigServer.country_army.arise_time[j];
								bb = ConfigServer.country_army.arise_time[j+1];
								if(bb[2] != null) bb[2] = 0;
								else bb.push(0);

								if(aa[2] != null) aa[2] = 0;
								else aa.push(0);
								break;
							}
						}
					}
					o[c] = (troopCitys.indexOf(c)==-1) ? bb : aa;	
				}
				
			}
			return o;
		}

		/**
		 * 是否应该有护国军
		 */
		public static function isHaveCountryArmy():Boolean{
			var config:Object = ConfigServer.country_army;
            if(config==null){
                return false;
            }

			//开服的前几天不显示
            var isMerge:Boolean = ModelManager.instance.modelUser.isMerge;
            var loginNum:Number = ModelManager.instance.modelUser.loginDateNum;
            if(!isMerge && loginNum < config.expand_day[0])
                return false;

            if(isMerge  && loginNum < config.expand_day[1]) 
                return false;
            
            var dt:Date = new Date(ConfigServer.getServerTimer());
            var dtn:Number = dt.getHours()*60 + dt.getMinutes();
            var armistice:Array = ConfigServer.country_army.armistice;
            
            //襄阳战当天的 armistice之前  &&  襄阳战期间 不显示
            if(ModelManager.instance.modelCountryPvp.mIsToday){
                if(dtn < (armistice[0]*60+armistice)){
                    return false;
                }
                if(ModelManager.instance.modelCountryPvp.checkActive()){
                    return false;
                }
            }

			return true;
		}


	}
}