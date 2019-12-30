package sg.boundFor 
{
	import laya.maths.Point;
	import laya.utils.Handler;
	import sg.outline.view.ui.MiniMapTop;
	import sg.utils.ObjectSingle;

	import sg.activities.model.ModelOnlineReward;
	import sg.activities.view.ViewActivitiesShare;
	import sg.activities.view.ViewHappyMain;
	import sg.activities.view.ViewOnlineRewardTip;
	import sg.cfg.ConfigClass;
	import sg.guide.model.ModelGuide;
	import sg.guide.view.GuideFocus;
	import sg.home.model.HomeModel;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.map.model.entitys.EntityHeroCatch;
	import sg.map.view.MapViewMain;
	import sg.model.ModelGame;
	import sg.net.NetMethodCfg;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.scene.model.entitys.EntityBase;
	import sg.scene.view.MapCamera;
	import sg.scene.view.entity.EntityClip;
	import sg.utils.Tools;
	import sg.view.init.ViewPhone;
	import sg.map.view.EstateClip;
	import sg.model.ModelUser;
	import sg.utils.ObjectUtil;
	import sg.utils.ArrayUtil;
	import sg.model.ModelSkill;
	import sg.view.hero.ViewSuperHeroInfo;
	import sg.fight.FightMain;
	import sg.model.ModelAlert;
	import sg.activities.model.ModelHappy;
	import sg.view.countryPvp.ViewCountryPvpMain;
	import sg.activities.model.ModelPhone;
	import sg.view.init.ViewBinding;
	import laya.utils.Browser;
	import sg.cfg.ConfigApp;
	import sg.altar.legendAwaken.model.ModelLegendAwaken;
	
	/**
	 * ...
	 * @author jiaxuyang
	 */
	public class GotoManager 
	{
		/**@public 任务视图。*/
		public static const VIEW_TASK:String 					= 'task';
		/**@public 英雄视图。*/
		public static const VIEW_HERO:String 					= 'hero';
		/**@public 征战视图。*/
		public static const VIEW_BATTLE:String 					= 'battle';
		/**@public 仓库视图。*/
		public static const VIEW_BAG:String 					= 'bag';
		/**@public 商店视图。*/
		public static const VIEW_SHOP:String 					= 'shop';
		/**@public 军团视图。*/
		public static const VIEW_GUILD:String 					= 'guild';
		/**@public 爵位视图。*/
		public static const VIEW_OFFICE_MAIN:String 			= 'office';
		/**@public 国家视图。*/
		public static const VIEW_COUNTRY_MAIN:String 			= 'country';
		/**@public 奖励视图。*/
		public static const VIEW_CREDIT:String 					= 'credit';
		/**@public 沙盘演义视图。*/
		public static const VIEW_PVE:String 					= 'pve';
		/**@public 见证传奇视图。*/
		public static const VIEW_LEGEND:String 					= 'legend';
		/**@public 传奇之路视图。*/
		public static const VIEW_LEGEND_ROAD:String 			= 'legend_road';
		/**@public 传奇历练视图。*/
		public static const VIEW_LEGEND_EXPERIENCE:String 		= 'legend_experience';
		/**@public 传奇觉醒*/
		public static const VIEW_LEGEND_AWAKEN:String        	= 'legend_awaken';
		/**@public 传奇觉醒商店*/
		public static const VIEW_LEGEND_AWAKEN_SHOP:String    	= 'legend_awaken_shop';
		/**@public 群雄逐鹿视图。*/
		public static const VIEW_PK:String 						= 'pk';
		/**@public 过关斩将视图。*/
		public static const VIEW_CLIMB:String 					= 'VIEW_CLIMB_MAIN';
		/**@public 过关斩将视图。*/
		public static const VIEW_CLIMB2:String 					= 'climb';
		/**@public 比武大会视图。*/
		public static const VIEW_PK_YARD:String 				= 'pk_yard';
		/**@public 比武大会视图。*/
		public static const VIEW_TREASURE_HUNTING:String 		= 'mining';
		/**@public 问道视图。*/
		public static const VIEW_PROP_RESOLVE:String			= 'prop_resolve';
		/**@public 酒馆视图。*/
		public static const VIEW_PUB:String 					= 'pub';
		/**@public 辎重站视图。*/
		public static const VIEW_BAGAGAGE:String 				= 'bagagage';
		/**@public 酒馆 英雄。*/
		public static const VIEW_PUB_SHOW_HERO:String 			= 'pub_hero';
		/**@public 英雄详情*/
		public static const VIEW_HERO_FEATURES:String 			= 'hero_features';
		/**@public 幕府 英雄*/
		public static const VIEW_SHOGUN_HERO:String 			= 'shogun_hero';
		/**@public achievement 成就*/
		public static const VIEW_ACHIEVEMENT:String 			= 'achievement';	
		/**@public achievement 成就的详细描述*/
		public static const VIEW_ACHIEVEMENT_DETAIL:String 		= 'achievement_detail';	
		/**@public 幕府*/
		public static const VIEW_SHOGUN_MAIN:String 			= 'shogun_main';
		/**@public 观星*/
		public static const VIEW_STAR_GET:String 				= 'star_get';		
		/**@public 在线奖励*/
		public static const VIEW_ONLINE_REWARD_PANEL:String 	= 'online_reward';	
		/**@public 充值面板*/
		public static const VIEW_PAY_TEST:String 				= 'pay_test';
		public static const VIEW_PAY_TEST2:String 				= 'pay_test2';
		/**@public 精彩活动*/
		public static const VIEW_ACTIVITIES:String 				= 'activities';
		/**@public 福利兑换*/
		public static const VIEW_FREE_BUY:String 				= 'free_buy';
		/**@public 首充续充*/
		public static const VIEW_PAYMENT:String 				= 'independ_buy';
		/**@public 官邸升级领奖*/
		public static const VIEW_BASE_LEVEL_UP:String 			= 'act_base_up';
		/**@public 建筑升级。*/
		public static const VIEW_BUILDING_UPGRADE:String 		= 'ViewBuildingUpgrade';
		/**@public 各种令。*/
		public static const VIEW_COUNTRY_OFFICER_TIPS:String 	= 'view_country_officer_tips';
		public static const VIEW_COUNTRY_TIPS_ORDER:String   	= 'view_country_tips_order';
		/**@public 活动奖励预览*/
		public static const VIEW_REWARD_PREVIEW:String   	    = 'view_reward_preview';
		/**@public 活动奖励预览*/
		public static const VIEW_ACTIVITIES_SHARE:String 		= 'view_activities_share';
		/**@public 七日嘉年华*/
		public static const VIEW_HAPPY_BUY:String        		= 'happy_buy';
		/**@public 限时免单*/
		public static const VIEW_LIMIT_FREE:String        		= 'limit_free';
		public static const VIEW_PHONE:String        			= 'view_phone';
		public static const VIEW_ESTATE_MAIN:String        		= 'ViewEstateMain';

		public static const VIEW_COUNTRY_PVP_MAIN:String       	= 'country_pvp';

		/**@public 循环充值*/
		public static const VIEW_SUPER_INFO:String        		= 'rool_pay';
		public static const VIEW_EQUIP_MAKE:String        		= 'view_equip_make';
		public static const VIEW_EQUIP_WASH:String        		= 'view_equip_wash';
		public static const VIEW_EQUIP_UPGRADE:String        	= 'view_equip_upgrade';
		public static const VIEW_EQUIP_MAIN:String        	    = 'view_equip_main';

		/**@public 节日活动*/
		public static const VIEW_FESTIVAL:String        		= 'festival';
		/**@public 拍卖活动*/
		public static const VIEW_AUCTION:String        			= 'auction';
		/**@public 消费榜*/
		public static const VIEW_PAY_RANK:String        		= 'pay_rank';
		/**@public 轩辕铸宝*/
		public static const VIEW_EQUIP_BOX:String        		= 'equip_box';
		/**@public 惊喜礼包*/
		public static const VIEW_SURPRISE_GIFT:String        	= 'surprise_gift';
		/**@public 福将挑战*/
		public static const VIEW_BLESS_HERO:String        		= 'bless_hero';	
		/**@public 充值福利*/
		public static const VIEW_FESTIVAL_PAYAGAIN:String       = 'pay_again';	

		public static const VIEW_NEW_TASK:String        		= 'new_task';	
			
		public static const TYPE_MAP:int = 1;
		public static const TYPE_HOME:int = 2;
		
		// 单例
		private static var sGotoManager:GotoManager = null;
		private var _viewKeys:Array;
		public static function get instance():GotoManager
		{
			return sGotoManager ||= new GotoManager();
		}
        public function GotoManager(){
			_viewKeys = ObjectUtil.keys(ConfigClass);
        }
		
		/**
		 * 前往
		 * 前往配置
		 * type: 切换地图和封底（1：地图、2：封地） 不需要跳转的话可缺省
		 * cityID:		城市ID，当type为1时生效 作用是移动到某个城市
		 * buildingID:	建筑ID，当type为2时生效 作用是移动到某个建筑
		 * state:		当存在type时生效 state为1时触发点击效果（打开并提示菜单） state为0时提示点击城市或建筑
		 * panelID:		面板ID，用于打开某个场景或面板（eg：'country' 国家场景、'pay_test' 充值面板）
		 * secondMenu:	二级菜单，用于打开某个场景的子标签（比如去商店里面的将魂商店）
		 * @param	cfg 前往的配置数据
		 */
		public static function boundFor(cfg:*, handler:Handler = null, duration:Number = 0):void {
			var type:int = cfg['type'],
				cityID:* = cfg['cityID'],
				estateID:int = cfg['estateID'],
				heroCatch:int = cfg['heroCatch'],
				buildingID:String = cfg['buildingID'],
				state:int = cfg['state'],
				panelID:String = cfg['panelID'],
				secondMenu:String = cfg['secondMenu'],
				viewParam:Object=cfg['viewParam']?cfg['viewParam']:null;
			
			state = panelID ? -1 : state;
			if (cityID is Array) {
				if (cityID.length === 3) (cityID = cityID[ModelUser.getCountryID()]);
				else cityID = cityID[0];
			}
			cityID = parseInt(cityID);
			if (type === TYPE_HOME)	GotoManager.instance.boundForHome(buildingID, state, secondMenu, handler, duration);
			else if (type === TYPE_MAP) {
				if (estateID)	{
					var arr:Array = null;
					if (GotoChecker.checkEstate(estateID)) arr = GotoManager.instance.findMaxLevelEstate(estateID);
					else arr = GotoManager.instance.findEstate(cityID, estateID);
					GotoManager.instance.boundForEstate(arr[0], arr[1], 0);
				}
				else GotoManager.instance.boundForMap(cityID, state, secondMenu, handler, duration);
			}
			else if(heroCatch === 1)	GotoManager.instance.boundForHeroCatche();
			panelID && GotoChecker.checkDestination(secondMenu) && GotoManager.boundForPanel(panelID, secondMenu,viewParam);
		}
		
		/**
		 * 打开UI的某个功能(任务、商店等)
		 * @param	panelID
		 * @param	secondMenu
		 * @param   viewParam = 任何类型参数给面板场景,多个用[]或{}
		 * @param   viewStyle = 面板样式 type:1 默认,child:true 返回打开原来面板,lock=未解锁功能特殊提升
		 */
		public static function boundForPanel(panelID:String, secondMenu:String = '',viewParam:Object = null, viewStyle:Object = null):void {

			var _this:GotoManager = GotoManager.instance;
			var method:String = '', sendData:Object = {}, otherData:* = {}, handler:Handler = Handler.create(_this, _this.ws_sr_get_view_type);
			//
			var styleParam:Object = viewStyle?viewStyle:{child:null};
			if(!styleParam.hasOwnProperty("type")){
				styleParam["type"] = 1;
			}
			var isNewPlayerGuide:Boolean = ModelGuide.forceGuide();
			var isNewPlayerGuideCheck:Boolean = false;
			otherData["style_param"] = styleParam;
			//
			otherData["curr_arg"] = viewParam;
			//
			var lockFuncKey:String = "";//配置屏蔽功能
			var lock_tips:Boolean = false;
			if(viewStyle && viewStyle.hasOwnProperty("lock")){
				lock_tips = true;
			}
			switch (panelID) {
				case GotoManager.VIEW_TASK:
					otherData['curr_arg'] = secondMenu;
					otherData['class_cfg'] = ConfigClass.VIEW_TASK_MAIN;
					break;
				case GotoManager.VIEW_HERO:
					otherData['class_cfg'] = ConfigClass.VIEW_HERO_MAIN;
					break;
				case GotoManager.VIEW_BATTLE:
					otherData['class_cfg'] = ConfigClass.VIEW_FIGHT_MENU;
					break;
				case GotoManager.VIEW_BAG:
					otherData['class_cfg'] = ConfigClass.VIEW_BAG_MAIN;
					break;
				case GotoManager.VIEW_SHOP:
					method = "get_shop";	
					sendData["shop_id"] = otherData['curr_arg'] = (secondMenu=="") ? "hero_shop" : secondMenu;					
					lockFuncKey = sendData["shop_id"];
					lock_tips = true;
					otherData['class_cfg'] = ConfigClass.VIEW_SHOP_MAIN;
					break;
				case GotoManager.VIEW_GUILD:
					lockFuncKey = "guild_main";
					lock_tips = true;
					otherData['class_cfg'] = ConfigClass.VIEW_GUILD_MAIN;
					otherData["curr_arg"] = 5;//参数传5就是异邦来访
					break;
				case GotoManager.VIEW_OFFICE_MAIN:
					lockFuncKey = "more_office";
					otherData['class_cfg'] = ConfigClass.VIEW_OFFICE_MAIN;
					otherData['curr_arg'] = secondMenu;
					break;
				case GotoManager.VIEW_COUNTRY_MAIN:
					lockFuncKey = "more_country";
					lock_tips = true;
					otherData['curr_arg'] = secondMenu=="" ? 0 : Number(secondMenu);
					otherData['class_cfg'] = ConfigClass.VIEW_COUNTRY_MAIN;
					break;
				case GotoManager.VIEW_CREDIT:
					otherData['class_cfg'] = ConfigClass.VIEW_CREDIT_MAIN;					
					break;
				case GotoManager.VIEW_PVE:
					lockFuncKey = "pve_pve";
					lock_tips = true;
					otherData['class_cfg'] = ConfigClass.VIEW_PVE_MAIN;
					break;
				case GotoManager.VIEW_LEGEND:
					otherData['class_cfg'] = ConfigClass.VIEW_LEGEND;					
					break;
				case GotoManager.VIEW_LEGEND_ROAD:
					otherData['class_cfg'] = ConfigClass.VIEW_LEGEND_ROAD;					
					break;
				case GotoManager.VIEW_LEGEND_EXPERIENCE:
					otherData['class_cfg'] = ConfigClass.VIEW_LEGEND_EXPERIENCE;					
					break;
				case GotoManager.VIEW_LEGEND_AWAKEN:
					otherData['class_cfg'] = ConfigClass.VIEW_LEGEND_AWAKEN;					
					break;
				case GotoManager.VIEW_LEGEND_AWAKEN_SHOP:
					otherData['class_cfg'] = ConfigClass.VIEW_LEGEND_AWAKEN_SHOP;					
					break;
				case GotoManager.VIEW_PK:
					lockFuncKey = "pvp_pk";
					lock_tips = true;
					method = NetMethodCfg.WS_SR_GET_PK_COUNTRY_FIRST;
					otherData['class_cfg'] = ConfigClass.VIEW_PK_MAIN;
					break;
				case GotoManager.VIEW_CLIMB:
					lockFuncKey = "pve_climb";
					lock_tips = true;
					method = NetMethodCfg.WS_SR_GET_CLIMB_ARMY_TYPE;
					otherData['class_cfg'] = ConfigClass.VIEW_CLIMB_MAIN;
					break;
				case GotoManager.VIEW_CLIMB2://为了容错加的 跟上面这个case一模一样
					lockFuncKey = "pve_climb";
					lock_tips = true;
					method = NetMethodCfg.WS_SR_GET_CLIMB_ARMY_TYPE;
					otherData['class_cfg'] = ConfigClass.VIEW_CLIMB_MAIN;
					break;
				case GotoManager.VIEW_PK_YARD:
					lockFuncKey = "pvp_champion";
					lock_tips = true;
					otherData['class_cfg'] = ConfigClass.VIEW_CHAMPION_MAIN;
					break;
				case GotoManager.VIEW_PROP_RESOLVE:
					if(secondMenu){
						if(ModelSkill.isCanResolve(secondMenu)==""){
							ViewManager.instance.showTipsTxt(Tools.getMsgById("_skill21"));
							return;	
						}
					}
					lockFuncKey = "prop_resolve";
					lock_tips = true;					
					otherData['curr_arg'] = secondMenu;
					otherData['class_cfg'] = ConfigClass.VIEW_PROP_RESOLVE;
					break;
				case GotoManager.VIEW_PUB:
					otherData['class_cfg'] = ConfigClass.VIEW_PUB_MAIN;
					break;
				case GotoManager.VIEW_BAGAGAGE:
					otherData['class_cfg'] = ConfigClass.VIEW_BAGAGAGE_MAIN;
					break;
				//case GotoManager.VIEW_PUB_SHOW_HERO:
				//	otherData['class_cfg'] = ConfigClass.VIEW_PUB_SHOW_HERO;
				//	break;	
				case GotoManager.VIEW_HERO_FEATURES:
					otherData['class_cfg'] = ConfigClass.VIEW_HERO_FEATURES;
					break;
				case GotoManager.VIEW_SHOGUN_HERO:
					otherData['class_cfg'] = ConfigClass.VIEW_SHOGUN_HERO;
					break;
				case GotoManager.VIEW_ACHIEVEMENT:
					otherData['class_cfg'] = ConfigClass.VIEW_ACHIEVEMENT;
					break;
				case GotoManager.VIEW_ACHIEVEMENT_DETAIL:
					otherData['class_cfg'] = ConfigClass.VIEW_ACHIEVEMENT_DETAIL;
					break;
				case GotoManager.VIEW_SHOGUN_MAIN:
					lockFuncKey = "shogun";
					lock_tips = true;
					otherData['class_cfg'] = ConfigClass.VIEW_SHOGUN_MAIN;
					break;	
				case GotoManager.VIEW_STAR_GET:
					lockFuncKey = "star_get";
					lock_tips = true;
					otherData['class_cfg'] = ConfigClass.VIEW_STAR_GET;
					break;								
				case GotoManager.VIEW_ONLINE_REWARD_PANEL:
					otherData['class_cfg'] = ConfigClass.VIEW_ONLINE_REWARD_PANEL;
					break;
				case GotoManager.VIEW_ACTIVITIES:
					var tempObj:Object = otherData['curr_arg'];
					if (tempObj==null || !(tempObj is Object)) tempObj = {};
					tempObj.type = secondMenu;
					otherData['curr_arg'] = tempObj;
					otherData['class_cfg'] = ConfigClass.VIEW_ACTIVITIES;	
					break;
				case GotoManager.VIEW_FREE_BUY:
					otherData['curr_arg'] = '';
					otherData['class_cfg'] = ConfigClass.VIEW_FREE_BUY;	
					break;
				case GotoManager.VIEW_LIMIT_FREE:
					otherData['class_cfg'] = ConfigClass.VIEW_FREE_BILL;	
					break;
				case GotoManager.VIEW_PAYMENT:
					otherData['class_cfg'] = ConfigClass.VIEW_PAYMENT;	
					break;
				case GotoManager.VIEW_BASE_LEVEL_UP:
					otherData['curr_arg'] = secondMenu;
					otherData['class_cfg'] = ConfigClass.VIEW_BASE_LEVEL_UP;	
					break;
				case GotoManager.VIEW_PAY_TEST:
					lockFuncKey = "pay";
					lock_tips = true;
					otherData['class_cfg'] = ConfigClass.VIEW_PAY_TEST;
					if (!ModelManager.instance.modelUser.canPay) {
						return;
					} else if (ConfigApp.pf == ConfigApp.PF_r2game_kr_h5) {
						ModelGame.toPay('pay1');
						return;
					}
					break;
				case GotoManager.VIEW_PAY_TEST2:
					lockFuncKey = "pay";
					lock_tips = true;
					otherData['class_cfg'] = ConfigClass.VIEW_PAY_TEST2;
					break;						
				case GotoManager.VIEW_BUILDING_UPGRADE:
					// var bmd:ModelBuiding = otherData["curr_arg"];
					// if(bmd.checkIsMaxLv(bmd.lvNext())){
					// 	ViewManager.instance.showTipsTxt(Tools.getMsgById("_public12"));
					// 	return;
					// }
					otherData['class_cfg'] = ConfigClass.VIEW_BUILDING_UPGRADE;
					break;	
				case GotoManager.VIEW_COUNTRY_OFFICER_TIPS:
					isNewPlayerGuideCheck = true;
					otherData['class_cfg'] = ConfigClass.VIEW_COUNTRY_OFFICER_TIPS;
					break;
				case GotoManager.VIEW_COUNTRY_TIPS_ORDER:
					isNewPlayerGuideCheck = true;
					otherData['class_cfg'] = ConfigClass.VIEW_COUNTRY_TIPS_ORDER;				
					break;												
				case GotoManager.VIEW_REWARD_PREVIEW:
					otherData['class_cfg'] = ConfigClass.VIEW_REWARD_PREVIEW;				
					break;	
				case GotoManager.VIEW_ACTIVITIES_SHARE:
					otherData['class_cfg'] = ["ViewActivitiesShare",ViewActivitiesShare];				
					break;	
				case GotoManager.VIEW_HAPPY_BUY:
					otherData['class_cfg'] = ["ViewHappyMain",ViewHappyMain];	
					otherData["curr_arg"] = secondMenu;	
					if(ModelHappy.instance.checkActive()==false){
						trace("七日嘉年华已结束");
						return;
					}		
					break;
				case GotoManager.VIEW_PHONE:
				    if(ModelPhone.instance.isSpecialPf()){
						otherData['class_cfg'] = ["ViewBinding",ViewBinding];
					}
					else{
						otherData['class_cfg'] = ["ViewPhone",ViewPhone];
					}
					break;
				case GotoManager.VIEW_ESTATE_MAIN:
					lockFuncKey = "estate";			
					otherData['class_cfg'] = ConfigClass.VIEW_ESTATE_MAIN;
					break;
				case GotoManager.VIEW_SUPER_INFO:		
					otherData['class_cfg'] = ["ViewSuperHeroInfo",ViewSuperHeroInfo];
					break;
				case GotoManager.VIEW_EQUIP_MAKE:		
					otherData['class_cfg'] = ConfigClass.VIEW_EQUIP_MAKE;
					break;
				case GotoManager.VIEW_EQUIP_WASH:		
					otherData['class_cfg'] = ConfigClass.VIEW_EQUIP_WASH;
					break;	
				case GotoManager.VIEW_EQUIP_UPGRADE:		
					otherData['class_cfg'] = ConfigClass.VIEW_EQUIP_UPGRADE;
					break;	
				case GotoManager.VIEW_EQUIP_MAIN:		
					otherData['class_cfg'] = ConfigClass.VIEW_EQUIP_MAIN;
					break;																			
				case GotoManager.VIEW_TREASURE_HUNTING:		
					lockFuncKey = panelID;			
					otherData['class_cfg'] = ConfigClass.VIEW_TREASURE_HUNTING;
					break;
				case GotoManager.VIEW_COUNTRY_PVP_MAIN:					
					otherData['class_cfg'] = ["ViewCountryPvpMain",ViewCountryPvpMain];
					break;																				
				case GotoManager.VIEW_FESTIVAL:
					otherData['class_cfg'] = ConfigClass.VIEW_FESTIVAL;
					break;
				case GotoManager.VIEW_AUCTION:
					otherData['class_cfg'] = ConfigClass.VIEW_AUCTION;
					break;
				case GotoManager.VIEW_PAY_RANK:
					otherData['class_cfg'] = ConfigClass.VIEW_PAY_RANK;
					break;
				case GotoManager.VIEW_EQUIP_BOX:
					otherData['class_cfg'] = ConfigClass.VIEW_EQUIP_BOX;
					break;
				case GotoManager.VIEW_SURPRISE_GIFT:
					otherData['class_cfg'] = ConfigClass.VIEW_SURPRISE_GIFT;
					break;
				case GotoManager.VIEW_BLESS_HERO:
					otherData['class_cfg'] = ConfigClass.VIEW_BLESS_HERO;
					break;
				case GotoManager.VIEW_FESTIVAL_PAYAGAIN:
					otherData['class_cfg'] = ConfigClass.VIEW_FESTIVAL_PAYAGAIN;
					break;
				case GotoManager.VIEW_NEW_TASK:
					lockFuncKey = "new_task";	
					otherData['class_cfg'] = ConfigClass.VIEW_NEW_TASK_MAIN;
					break;
				default:
					var clsArr:Array = ConfigClass[panelID];
					if (clsArr is Array) otherData['class_cfg'] = clsArr;
					break;
			}
			if(isNewPlayerGuide && isNewPlayerGuideCheck){
				return;
			}			
			if(lockFuncKey!="" && ModelGame.unlock(null,lockFuncKey,lock_tips).stop){
				return;
			}
			if(Tools.isNullString(method)){
				ViewManager.instance.showView(otherData['class_cfg'],otherData["curr_arg"],otherData["style_param"]);
			}
			else{
				NetSocket.instance.send(method, sendData, handler, otherData);
			}
		}
		
		/**
		 * 前往封地
		 * @param	buildingID
		 * @param	menuName
		 * @param	open
		 */
		public function boundForHome(buildingID:String = '', open:int = 0, secondMenu:String = '', handler:Handler = null, duration:Number = 0):void {
			if(FightMain.inFight){
				FightMain.instance.exit();
			}
			ViewManager.instance.closeView(true);
			ModelManager.instance.modelGame.event(ModelGame.EVENT_TASK_WORK_CONQUEST_OPEN_INSIDE);
			if (buildingID)	{
				MapCamera.lookAtBuild(buildingID, duration, false, Handler.create(this, function():void {
					var view:EntityClip = EntityBase(HomeModel.instance.builds[buildingID]).view as EntityClip;
					open === 1 && GuideFocus.focusInMenu(view, secondMenu);
					open === 0 && GuideFocus.focusInBuild(view);
					handler && handler.run();
				}));
			} else if (ModelLegendAwaken.instance.needGuide) { // 检测
				ModelGuide.executeGuide('legend_guide');
			} else if (ModelOnlineReward.haveReward()) { // 检测在线奖励
				MapCamera.lookAtDisplay(ViewOnlineRewardTip.instance);
			}
		}
		
		
		/**
		 * 前往世界
		 * @param	cityID 城市ID
		 * @param	menuName 二级菜单名字 #0:详情  #1:前往 #2:攻城 #3:建造 #4:编组 #5:/拜访 #61:政务上缴 #62:政务打仗 #7:战况
		 * @param	open 是否打开面板（默认打开，值为false则提示点击）
		 */
		public function boundForMap(cityID:* = null, open:int = 0, secondMenu:String = '', handler:Handler = null, duration:Number = 0):void {
			if(FightMain.inFight){
				FightMain.instance.exit();
			}
			ViewManager.instance.closeView(true);
			ModelManager.instance.modelGame.event(ModelGame.EVENT_TASK_WORK_CONQUEST_OPEN_MAP);
			//临时打一个补丁 在大地图
			if (ObjectSingle.sDic[ConfigClass.MINI_MAPTOP[0]]) {
				MiniMapTop(ObjectSingle.sDic[ConfigClass.MINI_MAPTOP[0]]).click_closeScenes();
			}
			cityID = parseInt(cityID);
			if (cityID is int){
				MapCamera.lookAtCity(cityID, duration, Handler.create(this, function():void {
					var view:EntityClip = EntityBase(MapModel.instance.citys[cityID]).view as EntityClip;
					open === 1 && GuideFocus.focusInMenu(view, secondMenu);
					open === 0 && GuideFocus.focusInCity(view);
					handler && handler.run();
				}));
			}
		}
		/**
		 * 前往产业
		 * @param	cityID
		 * @param	estate_index 产业位置
		 * @param	maxLevel 前往已拥有的最高等级的该产业
		 */
		public function boundForEstate(cityID:*, estate_index:int, duration:Number = 0, handler:Handler = null):void {
			if (GotoChecker.checkDestination('estate') === false)	return;
			ViewManager.instance.closeView(true);
			ModelManager.instance.modelGame.event(ModelGame.EVENT_TASK_WORK_CONQUEST_OPEN_MAP);
			MapCamera.lookAtEstate(cityID, estate_index, duration, Handler.create(this, function():void {
				GuideFocus.focusInEstate(MapViewMain.instance.estateViews[cityID + "_" + estate_index]);
				handler && handler.run();
			}));
		}

		private function findEstate(cityID:*, estate_id:int):Array {
			var city:EntityCity = MapModel.instance.citys[cityID];
			var cfgArr:Array = city.getParamConfig('estate');
            var estate:Array = ModelManager.instance.modelUser.estate;
			var flag:Boolean = GotoChecker.checkEstate(estate_id);
			var index:int = -1;
			var lv:int = 99;

			for(var i:int = 0, len:int = cfgArr.length; i < len; i++)
			{
				var temp:Array = cfgArr[i];
				if (temp[0] != estate_id) continue;
				if (temp[1] < lv) {
					lv = temp[1];
					index = i;
				}
			}
			return [cityID, index];
		}

		private function findMaxLevelEstate(estate_id:int):Array
		{
            var estate:Array = ModelManager.instance.modelUser.estate.filter(function(item:Object):Boolean {return item['estate_id'] == estate_id;}, this);
			var arr:Array = null;
			var capital:EntityCity = MapModel.instance.myCapital;
			var lv:int = 0;
			var distance:Number = 0;
			for(var i:int = 0, len:int = estate.length; i < len; i++)
			{
				var data:Object = estate[i];
				var city:EntityCity = MapModel.instance.citys[data['city_id']];
				var pos:Point = Point.TEMP.setTo(city.x, city.y);
				if (data['lv'] > lv){
					arr = [data['city_id'], data['estate_index']];
					lv = data['lv'];
					distance = Math.sqrt(Math.pow(pos.x - capital.x, 2) + Math.pow(pos.y - capital.y, 2));
				}
				else if (data['lv'] === lv) {
					// 比较距离首都的距离
					var distance2:Number = Math.sqrt(Math.pow(pos.x - capital.x, 2) + Math.pow(pos.y - capital.y, 2));
					if (distance2 < distance) {
						distance = distance2;
						arr = [data['city_id'], data['estate_index']];
					}
				}
			}
			return arr;
		}
		
		/**
		 * 前往切磋
		 */
		public function boundForHeroCatche():void {
			if (GotoChecker.checkDestination('catch_hero') === false)	return;
			var distance:Number = 0;
			var heroCatchs:Array = MapModel.instance.heroCatch;
			var heroCatch:EntityHeroCatch = null;
			var capital:EntityCity = MapModel.instance.myCapital;
			if (heroCatchs.length === 0) {
				this.boundForMap(capital.cityId);
			}
			for (var i:int = 0, len:int = heroCatchs.length; i < len; ++i) {
				var obj:EntityHeroCatch = heroCatchs[i];
				if (obj && obj.enabled) {
					var pos:Point = Point.TEMP.setTo(obj.city.x, obj.city.y);
					var distance2:Number = Math.sqrt(Math.pow(pos.x - capital.x, 2) + Math.pow(pos.y - capital.y, 2));
					if (i === 0 || distance2 < distance) {
						distance = distance2;
						heroCatch = obj;
					}
				}
			}
			this.boundForMap();
			heroCatch && MapCamera.lookAtGrid(heroCatch.mapGrid);
			heroCatch && GuideFocus.focusInCity(heroCatch.view);
		}

		/**
		 * 从服务器获取视图数据
		 * @param	np 网络返回包
		 */
		private function ws_sr_get_view_type(np:NetPackage):void {
			ModelManager.instance.modelUser.updateData(np.receiveData);
			
			var classCfg:Array = np.otherData['class_cfg'];
			np.otherData['receive_data'] = np.receiveData;
            ViewManager.instance.showView(classCfg, np.otherData,np.otherData.style_param);
		}

		/**
		 * GotoManager.showView(ConfigClass.VIEW_TREASURE_HUNTING);
		 * TODO 这是一个偷懒的做法(用的时候测一下会不会报错)
		 */
		public static function showView(clsArr:Array):void {
			var viewId:String = ArrayUtil.find(GotoManager.instance._viewKeys, function(key:String):Boolean{ return ConfigClass[key] === clsArr });
			if (viewId) boundForPanel(viewId);
			else console.error('can not find View ID in ConfigClass! error ID: ' + viewId);
		}
		
	}

}