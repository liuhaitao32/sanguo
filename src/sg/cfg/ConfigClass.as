package sg.cfg
{
	import laya.ui.Component;
	import sg.map.view.GoldCityPanel;
	import sg.outline.view.ui.MiniMapTop2;
	import sg.test.testpakcage.TestPackage;
	import ui.mapScene.GoldCityPanelUI;

	import sg.achievement.view.ViewAchievement;
	import sg.achievement.view.ViewAchievementDetail;
	import sg.activities.view.ViewActivities;
	import sg.activities.view.ViewBaseLevelUp;
	import sg.activities.view.ViewOnlineRewardPanel;
	import sg.activities.view.ViewPayment;
	import sg.activities.view.WishChoosePanel;
	import sg.guide.view.ViewGuideImage;
	import sg.map.view.ViewTestFight;
	import sg.outline.view.ui.MiniMapTop;
	import sg.view.bag.ViewBagItemChoose;
	import sg.view.bag.ViewBagItemInfo;
	import sg.view.bag.ViewBagItemTips;
	import sg.view.bag.ViewBagItemUse;
	import sg.view.bag.ViewBagMain;
	import sg.view.bag.ViewGetReward;
	import sg.view.bag.ViewbagItemSource;
	import sg.view.fight.ChampionMatchInfo;
	import sg.view.fight.ChampionMatchInfo8;
	import sg.view.fight.ViewChampionBet;
	import sg.view.fight.ViewChampionBetEdit;
	import sg.view.fight.ViewChampionHeroEdit;
	import sg.view.fight.ViewChampionMain;
	import sg.view.fight.ViewChampionRank;
	import sg.view.fight.ViewChampionTroop;
	import sg.view.fight.ViewClimbMain;
	import sg.view.fight.ViewClimbRank;
	import sg.view.fight.ViewClimbTroop;
	import sg.view.fight.ViewMenu;
	import sg.view.fight.ViewPKDeploy;
	import sg.view.fight.ViewPKMain;
	import sg.view.fight.ViewPKRank;
	import sg.view.fight.ViewPKReport;
	import sg.view.fight.ViewPKtroop;
	import sg.view.guild.ViewCreatGuild;
	import sg.view.guild.ViewGuildMain;
	import sg.view.guild.ViewGuildTroop;
	import sg.view.guild.ViewGuildTroopInfo;
	import sg.view.hero.ViewHeroEquipList;
	import sg.view.hero.ViewHeroFeatures;
	import sg.view.hero.ViewHeroGetNew;
	import sg.view.hero.ViewHeroInfoTips;
	import sg.view.hero.ViewHeroMain;
	import sg.view.hero.ViewHeroRuneSet;
	import sg.view.hero.ViewHeroRuneUpgrade;
	import sg.view.hero.ViewHeroTalentInfo;
	import sg.view.hero.ViewHeroTitle;
	import sg.view.hero.ViewLvUpgrade;
	import sg.view.hero.ViewProNormalItem;
	import sg.view.hero.ViewSkillDelete;
	import sg.view.hero.ViewSkillUpgrade;
	import sg.view.hero.ViewStarUpgrade;
	import sg.view.init.VIewChangeName;
	import sg.view.init.ViewChangeHead;
	import sg.view.init.ViewCode;
	import sg.view.init.ViewCountry;
	import sg.view.init.ViewFreeBuy;
	import sg.view.init.ViewLoad;
	import sg.view.init.ViewLogin;
	import sg.view.init.ViewServerList;
	import sg.view.init.ViewTimer;
	import sg.view.init.ViewUnlock;
	import sg.view.inside.ViewArmyMake;
	import sg.view.inside.ViewArmyQuickly;
	import sg.view.inside.ViewArmyUpgrade;
	import sg.view.inside.ViewArmyUpgradeAlert;
	import sg.view.inside.ViewBaggageMain;
	import sg.view.inside.ViewBuildingInfo;
	import sg.view.inside.ViewBuildingQuickly;
	import sg.view.inside.ViewBuildingUpgrade;
	import sg.view.inside.ViewEquipMake;
	import sg.view.inside.ViewEquipMakeInfo;
	import sg.view.inside.ViewEquipQuickly;
	import sg.view.inside.ViewEquipUpgrade;
	import sg.view.inside.ViewEquipWash;
	import sg.view.inside.ViewEquipWashGF;
	import sg.view.inside.ViewOfficeActivation;
	import sg.view.inside.ViewOfficeMain;
	import sg.view.inside.ViewPVEInfo;
	import sg.view.inside.ViewPVEMain;
	import sg.view.inside.ViewPropResolve;
	import sg.view.inside.ViewPropResolveCheck;
	import sg.view.inside.ViewPubMain;
	import sg.view.inside.ViewPubShowHero;
	import sg.view.inside.ViewScienceMain;
	import sg.view.inside.ViewScienceQuickly;
	import sg.view.inside.ViewScienceUpgrade;
	import sg.view.inside.ViewShogunChoose;
	import sg.view.inside.ViewShogunHero;
	import sg.view.inside.ViewShogunLvUp;
	import sg.view.inside.ViewShogunMain;
	import sg.view.inside.ViewShowProbability;
	import sg.view.inside.ViewStarGet;
	import sg.view.inside.ViewStarResolve;
	import sg.view.inside.ViewStarResolveQuick;
	import sg.view.mail.ViewAddChat;
	import sg.view.mail.ViewMailContent;
	import sg.view.mail.ViewMailMain;
	import sg.view.mail.ViewMailPersonal;
	import sg.view.map.VIewEstateHero;
	import sg.view.map.ViewAlienHeroSend;
	import sg.view.map.ViewAlienMain;
	import sg.view.map.ViewCaptainMain;
	import sg.view.map.ViewCityBuildMain;
	import sg.view.map.ViewCityInfo;
	import sg.view.map.ViewCityInfoList;
	import sg.view.map.ViewCitySend;
	import sg.view.map.ViewCountryInvadeMain;
	import sg.view.map.ViewCountryMain;
	import sg.view.map.ViewCountryMayorList;
	import sg.view.map.ViewCountryOfficerInfo;
	import sg.view.map.ViewCountryOfficerList;
	import sg.view.map.ViewCountryOfficerTips;
	import sg.view.map.ViewCountryStoreList;
	import sg.view.map.ViewCreditGift;
	import sg.view.map.ViewCreditMain;
	import sg.view.map.ViewEstateDetails;
	import sg.view.map.ViewEstateHeroInfo;
	import sg.view.map.ViewEstateMain;
	import sg.view.map.ViewEstateTask;
	import sg.view.map.ViewEventTalk;
	import sg.view.map.ViewHeroCatch;
	import sg.view.map.ViewHeroInfo;
	import sg.view.map.ViewHeroSend;
	import sg.view.map.ViewOfficerOrderA;
	import sg.view.map.ViewOfficerOrderB;
	import sg.view.map.ViewTroopEdit;
	import sg.view.map.ViewTroopQuickly;
	import sg.view.map.ViewVisitFinish;
	import sg.view.map.ViewWorkHeroSend;
	import sg.view.menu.ViewMenuBottom;
	import sg.view.menu.ViewMenuMain;
	import sg.view.menu.ViewMenuTop;
	import sg.view.menu.ViewMenuUser;
	import sg.view.menu.ViewPayTest;
	import sg.view.menu.ViewUserInfo;
	import sg.view.more.ViewFightLog;
	import sg.view.more.ViewFightLogInfo;
	import sg.view.more.ViewMoreMain;
	import sg.view.more.ViewMoreRankMain;
	import sg.view.more.ViewNpcInfo;
	import sg.view.more.ViewTipsInfo;
	import sg.view.shop.ViewShopHeroTips;
	import sg.view.shop.ViewShopMain;
	import sg.view.shop.ViewShopSkillTips;
	import sg.view.task.ViewFTaskMain;
	import sg.view.task.ViewTaskMain;
	import sg.view.task.ViewWorkAssess;
	import sg.view.task.ViewWorkConquest;
	import sg.view.task.ViewWorkDonation;
	import sg.view.more.ViewOverlord;
	import sg.view.more.ViewHeroChoose;
	import sg.view.map.ViewCountryKingTips;
	import sg.view.map.ViewCountryTipsOrder;
	import sg.activities.view.ViewRewardPreview;
	import sg.activities.view.ViewWeekcardRewardPanel;
	import sg.view.more.ViewSettings;
	import sg.view.init.ViewAffiche;
	import sg.view.shop.ViewShopEquipTips;
	import sg.activities.view.ViewFreeBill;
	import sg.activities.view.ViewFreeBillRecord;
	import sg.activities.view.ViewFreeBillReward;
	import sg.view.hero.ViewHeroCommission;
	import sg.view.init.ViewPaySelf;
	import sg.view.init.ViewPhone;
	import sg.explore.view.ViewTreasureHunting;
	import sg.explore.view.ViewHuntPrayPanel;
	import sg.explore.view.ViewFightReportPanel;
	import sg.explore.view.ViewHuntDetail;
	import sg.explore.view.ViewPKHunt;
	import sg.explore.view.ViewExploreTroop;
	import sg.view.map.ViewCreditResult;
	import sg.view.init.ViewNoticePicture;
	import sg.guide.view.ViewGuideSkip;
	import sg.view.country.ViewImpeach;
	import sg.explore.view.ViewChangeHero;
	import sg.view.map.ViewTroopCoinFill;
	import sg.view.init.ViewLoginChoose;
	import sg.festival.view.ViewFestival;
	import sg.activities.view.ViewAuction;
	import sg.activities.view.AuctionBid;
	import sg.view.hero.ViewAwakenHero;
	import sg.altar.legend.view.ViewLegend;
	import sg.altar.legend.view.ViewLegendRoad;
	import sg.altar.legend.view.ViewLegendExperience;
	import sg.altar.legend.view.ViewLegendTroop;
	import sg.view.countryPvp.ViewCountryPvpTips;
	import sg.view.countryPvp.ViewCountryTributaryTips;
	import sg.activities.view.ViewPayRank;
	import sg.activities.view.ViewPayRankReward;
	import sg.activities.view.ViewAfficheMerge;
	import sg.activities.view.ViewPayRankTips;
	import sg.view.countryPvp.ViewCountryEmperorTips;
	import sg.view.menu.ViewCZ1;
	import sg.view.equip.ViewEquipMain;
	import sg.view.map.ViewFightTask;
	import sg.activities.view.ViewEquipBox;
	import sg.activities.view.ViewSurpriseGift;
	import sg.view.map.ViewBlessHero;
	import sg.view.map.ViewBlessHeroRank;
	import sg.view.map.ViewPVETroop;
	import sg.activities.view.ViewMemberRewardPanel;
	import sg.altar.legendAwaken.view.ViewLegendAwaken;
	import sg.altar.legendAwaken.view.ViewLegendAwakenShop;
	import sg.view.init.ViewCountryPC;
	import sg.view.newtask.ViewNewTaskMain;
	import sg.view.init.ViewCountryWW;
	import sg.activities.view.ViewSalePayAlert;
	/**
	 * 显示场景、面板配置
	 * @author
	 */
	public class ConfigClass{
		public static const LAYER_MAP:Array = ["layer_map",Component];
		public static const LAYER_SCENES:Array = ["layer_scenes",Component];
		public static const LAYER_PANEL:Array = ["layer_panel",Component];
		public static const LAYER_MENU:Array = ["layer_menu",Component];
		public static const LAYER_DIALOG:Array = ["layer_dialog",Component];
		public static const LAYER_TIPS_TXT:Array = ["layer_tips_txt",Component];
		//
		public static const VIEW_LOGIN_CHOOSE:Array = ["ViewLoginChoose",ViewLoginChoose];
		public static const VIEW_LOGIN:Array = ["ViewLogin",ViewLogin];
		public static const VIEW_LOAD:Array = ["ViewLoad",ViewLoad];
		public static const VIEW_AFFICHE:Array = ["ViewAffiche",ViewAffiche]; // 公告
		public static const VIEW_AFFICHE_MERGE:Array = ["ViewAfficheMerge",ViewAfficheMerge]; // 合服公告
		public static const VIEW_PHONE:Array = ["ViewPhone",ViewPhone]; // 手机绑定
		public static const VIEW_COUNTRY:Array = ["ViewCountry",ViewCountry];//国家选择
		public static const VIEW_COUNTRY_PC:Array = ["ViewCountryPC",ViewCountryPC];//国家选择
		public static const VIEW_COUNTRY_WW:Array = ["ViewCountryWW",ViewCountryWW];//国家选择
		public static const VIEW_SERVER_LIST:Array = ["ViewServerList",ViewServerList];//服务器选择
		//------------------英雄功能
		public static const VIEW_HERO_MAIN:Array = ["ViewHeroMain",ViewHeroMain];//英雄
		public static const VIEW_HERO_FEATURES:Array = ["ViewHeroFeatures",ViewHeroFeatures];//英雄功能主界面
		public static const VIEW_STAR_UPGRADE:Array = ["ViewStarUpgrade",ViewStarUpgrade];//英雄功能,升级星星
		public static const VIEW_LV_UPGRADE:Array = ["ViewLvUpgrade",ViewLvUpgrade];//英雄功能,升级等级
		public static const VIEW_PRO_NORMAL_ITEM:Array = ["ViewProNormalItem",ViewProNormalItem];//英雄功能,升阶,通用道具
		public static const VIEW_SKILL_UPGRADE:Array = ["ViewSkillUpgrade",ViewSkillUpgrade];//英雄功能,技能,升级
		public static const VIEW_SKILL_DELETE:Array = ["ViewSkillDelete",ViewSkillDelete];//英雄功能,技能,遗忘
		public static const VIEW_HERO_EQUIP_LIST:Array = ["ViewHeroEquipList",ViewHeroEquipList];//英雄功能,宝物,列表
		public static const VIEW_HERO_RUNE_SET:Array = ["ViewHeroRuneSet",ViewHeroRuneSet];//英雄功能,星辰,装配,列表
		public static const VIEW_HERO_RUNE_UPGRADE:Array = ["ViewHeroRuneUpgrade",ViewHeroRuneUpgrade];//英雄功能,星辰,升级
		public static const VIEW_HERO_TITLE:Array = ["ViewHeroTitle",ViewHeroTitle];//英雄功能,称号
		public static const VIEW_HERO_GET_NEW:Array = ["ViewHeroGetNew",ViewHeroGetNew];//英雄,获得新的
		public static const VIEW_HERO_INFO_TIPS:Array = ["ViewHeroInfoTips",ViewHeroInfoTips];//英雄,信息 tips
		public static const VIEW_HERO_TALENT_INFO:Array = ["ViewHeroTalentInfo",ViewHeroTalentInfo];//英雄,天赋 信息 tips
		public static const VIEW_HERO_COMMISSION:Array = ["ViewHeroCommission",ViewHeroCommission];//英雄任命面板
		public static const VIEW_TESTPACKAGE:Array = ["TestPackage",TestPackage];//英雄任命面板
		//
		public static const VIEW_SHOP_MAIN:Array = ["ViewShopMain",ViewShopMain];//商店
		//
		public static const VIEW_GUILD_MAIN:Array = ["ViewGuildMain",ViewGuildMain];//军团
		public static const VIEW_PAY_SELF:Array = ["ViewPaySelf",ViewPaySelf];//特殊支付选择
		//
		public static const VIEW_BAG_MAIN:Array = ["ViewBagMain",ViewBagMain];//仓库背包

		public static const VIEW_PUB_MAIN:Array=["ViewPubMain",ViewPubMain];//酒馆主页
		public static const VIEW_PUB_SHOW_HERO:Array=["ViewPubShowHero",ViewPubShowHero];//酒馆显示英雄
		public static const VIEW_BAGAGAGE_MAIN:Array=["ViewBaggageMain",ViewBaggageMain];
		public static const VIEW_STAR_GET:Array=["ViewStarGet",ViewStarGet];
		public static const VIEW_STAR_RESOLVE:Array=["ViewStarResolve",ViewStarResolve];
		public static const VIEW_PROP_RESOLVE:Array=["ViewPropResolve",ViewPropResolve];
		//------------------各种pvp,pve战斗
		public static const VIEW_FIGHT_MENU:Array=["ViewMenu",ViewMenu];//征战,菜单主页面
		public static const VIEW_CLIMB_MAIN:Array=["ViewClimbMain",ViewClimbMain];//climb 主页面
		public static const VIEW_CLIMB_RANK:Array=["ViewClimbRank",ViewClimbRank];//climb 排行
		public static const VIEW_CLIMB_TROOP:Array=["ViewClimbTroop",ViewClimbTroop];//climb 队伍选择
		public static const VIEW_CITY_INFO:Array=["ViewCityInfo",ViewCityInfo];//城市信息
		public static const VIEW_CITY_INFO_LIST:Array = ["ViewCityInfoList", ViewCityInfoList];//城市详细列表
		public static const VIEW_CITY_BUILD_MAIN:Array = ["ViewCityBuildMain", ViewCityBuildMain];//城市建筑面板
		public static const VIEW_USER_INFO:Array = ["ViewUserInfo", ViewUserInfo];//玩家信息面板

		//
		public static const VIEW_PK_MAIN:Array=["ViewPKMain",ViewPKMain];//pk群雄逐鹿,main
		public static const VIEW_PK_REPORT:Array=["ViewPKReport",ViewPKReport];//pk群雄逐鹿,战报
		public static const VIEW_PK_RANK:Array=["ViewPKRank",ViewPKRank];//pk群雄逐鹿,排行
		public static const VIEW_PK_DEPLOY:Array=["ViewPKDeploy",ViewPKDeploy];//pk群雄逐鹿,布阵
		public static const VIEW_PK_TROOP:Array=["ViewPKtroop",ViewPKtroop];//pk群雄逐鹿,选择上阵
		//
		public static const VIEW_CHAMPION_MAIN:Array=["ViewChampionMain",ViewChampionMain];//比武
		public static const VIEW_CHAMPION_BET:Array=["ViewChampionBet",ViewChampionBet];//比武 , 押注
		public static const VIEW_CHAMPION_HERO_EDIT:Array=["ViewChampionHeroEdit",ViewChampionHeroEdit];//比武 , 编队
		public static const VIEW_CHAMPION_RANK:Array=["ViewChampionRank",ViewChampionRank];//比武 , 奖励
		public static const VIEW_CHAMPION_MATCH_INFO:Array=["ChampionMatchInfo",ChampionMatchInfo];//比武 , 战况
		public static const VIEW_CHAMPION_MATCH_INFO8:Array=["ChampionMatchInfo8",ChampionMatchInfo8];//比武 , 战况8
		public static const VIEW_CHAMPION_BET_EDIT:Array=["ViewChampionBetEdit",ViewChampionBetEdit];//比武 , 押注用
		public static const VIEW_CHAMPION_TROOP:Array=["ViewChampionTroop",ViewChampionTroop];//比武 , 编队
		//
		public static const VIEW_PVE_MAIN:Array=["ViewPVEMain",ViewPVEMain];//沙盘演义
		public static const VIEW_PVE_INFO:Array=["ViewPVEInfo",ViewPVEInfo];
		//public static const VIEW_PVE_READY:Array=["ViewPVEReady",ViewPVEReady];
		public static const VIEW_LEGEND:Array=["ViewLegend",ViewLegend]; // 见证传奇
		public static const VIEW_LEGEND_ROAD:Array=["ViewLegendRoad",ViewLegendRoad]; // 传奇之路
		public static const VIEW_LEGEND_EXPERIENCE:Array=["ViewLegendExperience",ViewLegendExperience]; // 传奇历练
		public static const VIEW_LEGEND_TROOP:Array=["ViewLegendTroop", ViewLegendTroop]; // 传奇选择队伍面板
		
		public static const VIEW_LEGEND_AWAKEN:Array=["ViewLegendAwaken", ViewLegendAwaken]; // 传奇觉醒面板
		public static const VIEW_LEGEND_AWAKEN_SHOP:Array=["ViewLegendAwakenShop", ViewLegendAwakenShop]; // 传奇觉醒商店
		
		//------------------科技
		public static const VIEW_ARMY_UPGRADE:Array=["ViewArmyUpgrade",ViewArmyUpgrade];//兵种科技
		public static const VIEW_ARMY_UPGRADE_ALERT:Array=["ViewArmyUpgradeAlert",ViewArmyUpgradeAlert];//

		//------------------建筑上功能
		public static const VIEW_EQUIP_MAKE:Array = ["ViewEquipMake",ViewEquipMake];//建筑\宝物产出
		public static const VIEW_EQUIP_UPGRADE:Array = ["ViewEquipUpgrade",ViewEquipUpgrade];//建筑\宝物升级
		public static const VIEW_EQUIP_QUICKLY:Array = ["ViewEquipQuickly",ViewEquipQuickly];//建筑\宝物\秒cd
		public static const VIEW_EQUIP_MAKE_INFO:Array = ["ViewEquipMakeInfo",ViewEquipMakeInfo];//宝物 信息
		//
		public static const VIEW_OFFICE_MAIN:Array = ["ViewOfficeMain",ViewOfficeMain];//官邸,爵位
		public static const VIEW_OFFICE_ACTIVATION:Array = ["ViewOfficeActivation",ViewOfficeActivation];//官邸,激活
		//
		public static const VIEW_BUILDING_UPGRADE:Array = ["ViewBuildingUpgrade",ViewBuildingUpgrade];//内城是否升级建筑
		public static const VIEW_BUILDING_QUICKLY:Array = ["ViewBuildingQuickly",ViewBuildingQuickly];//建筑加速
		public static const VIEW_BUILDING_INFO:Array = ["ViewBuildingInfo",ViewBuildingInfo];//建筑详细信息
		public static const VIEW_ARMY_MAKE:Array = ["ViewArmyMake",ViewArmyMake];//兵营建筑,产出兵
		public static const VIEW_ARMY_QUICKLY:Array = ["ViewArmyQuickly",ViewArmyQuickly];//兵营建筑,产兵,秒cd
		public static const VIEW_SCIENCE_MAIN:Array = ["ViewScienceMain",ViewScienceMain];//科技
		public static const VIEW_SCIENCE_UPGRADE:Array = ["ViewScienceUpgrade",ViewScienceUpgrade];//科技 升级
		public static const VIEW_SCIENCE_QUICKLY:Array = ["ViewScienceQuickly",ViewScienceQuickly];//科技 秒cd

		//------------------道具功能
		public static const VIEW_BAG_INFO:Array=["ViewBagItemInfo",ViewBagItemInfo];//道具详情
		public static const VIEW_BAG_USE:Array=["ViewBagItemUse",ViewBagItemUse];//使用道具
		public static const VIEW_BAG_CHOOSE:Array=["ViewBagItemChoose",ViewBagItemChoose];//道具选择
		public static const VIEW_GET_REWARD:Array=["ViewGetReward",ViewGetReward];//获得奖励
		public static const VIEW_BAG_SOURSE:Array=["ViewbagItemSource",ViewbagItemSource];//道具来源
		public static const VIEW_SHOP_HERO_TIPS:Array=["ViewShopHeroTips",ViewShopHeroTips];
		public static const VIEW_SHOP_SKILL_TIPS:Array=["ViewShopSkillTips",ViewShopSkillTips];
		public static const VIEW_BAG_ITEM_TIPS:Array=["ViewBagItemTips",ViewBagItemTips];
		public static const VIEW_SHOP_EQUIP_TIPS:Array=["ViewShopEquipTips",ViewShopEquipTips];
		public static const VIEW_PROP_CHECK:Array=["ViewPropResolveCheck",ViewPropResolveCheck];
		public static const VIEW_STAR_RESOLVE_QUICK:Array=["ViewStarResolveQuick",ViewStarResolveQuick];
		public static const VIEW_CREAT_TEAM:Array=["ViewCreatGuild",ViewCreatGuild];
		public static const VIEW_GUILD_TROOP:Array=["ViewGuildTroop",ViewGuildTroop];
		public static const VIEW_GUILD_TROOP_INFO:Array=["ViewGuildTroopInfo",ViewGuildTroopInfo];
		public static const VIEW_FREE_BUY:Array=["ViewFreeBuy",ViewFreeBuy];
		//------------------大地图上的功能
		public static const VIEW_TROOP_EDIT:Array=["ViewTroopEdit",ViewTroopEdit];//编辑、部队、补兵、加速
		public static const VIEW_HERO_SEND:Array = ["ViewHeroSend", ViewHeroSend];//编辑出征部队
		public static const VIEW_TEST_FIGHT:Array=["ViewTestFight",ViewTestFight];//测试输入战斗
		public static const VIEW_PAY_TEST:Array=["ViewPayTest",ViewPayTest];
		public static const VIEW_PAY_TEST2:Array=["ViewPayTest2",ViewCZ1];
		public static const VIEW_HERO_CATCH:Array=["ViewHeroCatch",ViewHeroCatch];
		public static const VIEW_HERO_INFO:Array=["ViewHeroInfo",ViewHeroInfo];
		public static const VIEW_ESTATE_MAIN:Array=["ViewEstateMain",ViewEstateMain];
		public static const VIEW_ESTATE_HERO:Array=["VIewEstateHero",VIewEstateHero];
		public static const VIEW_ESTATE_TASK:Array=["ViewEstateTask",ViewEstateTask];
		public static const VIEW_ESTATE_DETAILS:Array=["ViewEstateDetails",ViewEstateDetails];
		public static const VIEW_CREDIT_GIFT:Array=["ViewCreditGift",ViewCreditGift];
		public static const VIEW_VISIT_FINISH:Array=["ViewVisitFinish",ViewVisitFinish];
		public static const VIEW_ALIEN_HERO_SEND:Array=["ViewAlienHeroSend",ViewAlienHeroSend];
		public static const VIEW_WORK_HERO_SEND:Array=["ViewWorkHeroSend",ViewWorkHeroSend];
		public static const VIEW_EVENT_TALK:Array=["ViewEventTalk",ViewEventTalk];
		public static const VIEW_ESTATE_HERO_INFO:Array=["ViewEstateHeroInfo",ViewEstateHeroInfo];
		public static const VIEW_FTASK_MAIN:Array = ["ViewFTaskMain", ViewFTaskMain];
		public static const VIEW_CITY_SEND:Array = ["ViewCitySend", ViewCitySend];//编辑突破、撤军城市
		public static const VIEW_TROOP_QUICKLY:Array = ["ViewTroopQuickly", ViewTroopQuickly];//行军加速
		public static const GOLD_CITY_PANEL:Array = ["GoldCityPanelUI", GoldCityPanel];//行军加速

		//------------------主按钮更多组功能
		public static const VIEW_CHANGE_NAME:Array=["VIewChangeName",VIewChangeName];
		public static const VIEW_CHANGE_HEAD:Array=["VIewChangeHead",ViewChangeHead];
		public static const VIEW_MAIL_MAIN:Array=["ViewMailMain",ViewMailMain];
		public static const VIEW_ADD_CHAT:Array=["ViewAddChat",ViewAddChat];
		public static const VIEW_MAIL_CONTENT:Array=["ViewMailContent",ViewMailContent];
		public static const VIEW_MAIL_PERSONAL:Array=["ViewMailPersonal",ViewMailPersonal];
		public static const VIEW_SHOW_PROBABILITY:Array=["ViewShowProbability",ViewShowProbability];
		public static const VIEW_MORE_MAIN:Array=["ViewMoreMain",ViewMoreMain];
		public static const VIEW_CODE:Array=["ViewCode",ViewCode];
		public static const VIEW_SHOGUN_LVUP:Array=["ViewShogunLvUp",ViewShogunLvUp];
		public static const VIEW_SHOGUN_HERO:Array=["ViewShogunHero",ViewShogunHero];
		public static const VIEW_SHOGUN_MAIN:Array=["ViewShogunMain",ViewShogunMain];
		public static const VIEW_SHOGUN_CHOOSE:Array=["ViewShogunChoose",ViewShogunChoose];
		public static const VIEW_UNLOCK:Array=["ViewUnlock",ViewUnlock];
		public static const VIEW_TIMER:Array=["ViewTimer",ViewTimer];
		public static const VIEW_CREDIT_MAIN:Array=["ViewCreditMain",ViewCreditMain];
		public static const VIEW_EQUIP_WASH:Array=["ViewEquipWash",ViewEquipWash];
		public static const VIEW_EQUIP_WASH_GF:Array=["ViewEquipWashGF",ViewEquipWashGF];
		public static const VIEW_TIPS_INFO:Array=["ViewTipsInfo",ViewTipsInfo];
		public static const VIEW_SETTINGS:Array=["ViewSettings",ViewSettings];
		//------------------国家功能组
		public static const VIEW_COUNTRY_MAIN:Array=["ViewCountryMain",ViewCountryMain];
		public static const VIEW_COUNTRY_OFFICER_INFO:Array=["ViewCountryOfficerInfo",ViewCountryOfficerInfo];
		public static const VIEW_COUNTRY_OFFICER_LIST:Array=["ViewCountryOfficerList",ViewCountryOfficerList];
		public static const VIEW_COUNTRY_OFFICER_TIPS:Array=["ViewCountryOfficerTips",ViewCountryOfficerTips];
		public static const VIEW_COUNTRY_STORE_LIST:Array=["ViewCountryStoreList",ViewCountryStoreList];
		public static const VIEW_COUNTRY_MAYOR_LIST:Array=["ViewCountryMayorList",ViewCountryMayorList];
		public static const VIEW_COUNTRY_INVADE_MAIN:Array=["ViewCountryInvadeMain",ViewCountryInvadeMain];
		public static const VIEW_OFFICER_ORDER_A:Array=["ViewOfficerOrderA",ViewOfficerOrderA];
		public static const VIEW_OFFICER_ORDER_B:Array=["ViewOfficerOrderB",ViewOfficerOrderB];
		public static const VIEW_COUNTRY_KING_TIPS:Array=["ViewCountryKingTips",ViewCountryKingTips];
		public static const VIEW_COUNTRY_TIPS_ORDER:Array=["ViewCountryTipsOrder",ViewCountryTipsOrder];
		public static const VIEW_COUNTRY_IMPEACH:Array=["ViewImpeach",ViewImpeach];
		//------------------任务
		public static const VIEW_TASK_MAIN:Array=["ViewTaskMain",ViewTaskMain];
		public static const VIEW_WORK_ASSESS:Array=["ViewWorkAssess",ViewWorkAssess];
		public static const VIEW_WORK_DONATION:Array=["ViewWorkDonation",ViewWorkDonation];
		public static const VIEW_WORK_CONQUEST:Array=["ViewWorkConquest",ViewWorkConquest];
		//------------------成就
		public static const VIEW_ACHIEVEMENT:Array = ["ViewAchievement",ViewAchievement];
		public static const VIEW_ACHIEVEMENT_DETAIL:Array = ["ViewAchievementDetail",ViewAchievementDetail];
		//------------------在线奖励
		public static const VIEW_ONLINE_REWARD_PANEL:Array = ["ViewOnlineRewardPanel",ViewOnlineRewardPanel];
		//------------------精彩活动
		public static const VIEW_ACTIVITIES:Array = ["ViewActivities",ViewActivities];
		public static const WISH_CHOOSE_PANEL:Array = ["WishChoosePanel",WishChoosePanel];
		public static const VIEW_REWARD_PREVIEW:Array = ["ViewRewardPreview", ViewRewardPreview];
		public static const VIEW_MEMBER_CARD:Array = ["ViewMemberRewardPanel", ViewMemberRewardPanel];
		public static const VIEW_WEEK_CARD:Array = ["ViewWeekcardRewardPanel", ViewWeekcardRewardPanel];
		//------------------限时免单
		public static const VIEW_FREE_BILL:Array = ["ViewFreeBill", ViewFreeBill];
		public static const VIEW_FREE_BILL_Record:Array = ["ViewFreeBillRecord", ViewFreeBillRecord];
		public static const VIEW_FREE_BILL_Reward:Array = ["ViewFreeBillReward", ViewFreeBillReward];
		//------------------充值
		public static const VIEW_PAYMENT:Array = ["ViewPayment", ViewPayment];
		//------------------官邸升级领奖
		public static const VIEW_BASE_LEVEL_UP:Array = ["ViewBaseLevelUp", ViewBaseLevelUp];
		//------------------图文介绍(引导)
		public static const VIEW_GUIDE_IMAGE:Array = ["ViewGuideImage", ViewGuideImage];
		public static const VIEW_GUIDE_SKIP:Array = ["ViewGuideSkip", ViewGuideSkip];
		//------------------入侵
		public static const VIEW_ALIEN_MAIN:Array=["ViewAlienMain",ViewAlienMain];
		public static const VIEW_CAPTAIN_MAIN:Array=["ViewCaptainMain",ViewCaptainMain];
		public static const VIEW_NPC_INFO:Array=["ViewNpcInfo",ViewNpcInfo];
		//
		public static const VIEW_MORE_RANK_MAIN:Array=["ViewMoreRankMain",ViewMoreRankMain];
		//主按钮,扩展功能
		public static const MENU_MAIN:Array = ["ViewMenuMain",ViewMenuMain];
		public static const MENU_BOTTOM:Array = ["ViewMenuBottom",ViewMenuBottom];
		public static const MENU_TOP:Array = ["ViewMenuTop",ViewMenuTop];
		public static const MENU_USER:Array = ["ViewMenuUser",ViewMenuUser];
		//------------------特殊,共用
		
		public static const MINI_MAPTOP:Array = ["MiniMapTop", MiniMapTop];
		public static const MINI_MAPTOP2:Array = ["MiniMapTop2", MiniMapTop2];
		public static const VIEW_FIGHT_LOG:Array = ["ViewFightLog", ViewFightLog];
		public static const VIEW_FIGHT_LOG_INFO:Array = ["ViewFightLogInfo", ViewFightLogInfo];
		public static const VIEW_OVERLORD:Array = ["ViewOverlord", ViewOverlord];
		public static const VIEW_HERO_CHOOSE:Array = ["ViewHeroChoose", ViewHeroChoose];

		//------------------蓬莱寻宝
		public static const VIEW_TREASURE_HUNTING:Array=["ViewTreasureHunting", ViewTreasureHunting]; // 蓬莱寻宝
		public static const VIEW_HUNT_DETAIL:Array=["ViewHuntDetail", ViewHuntDetail]; // 详情
		public static const VIEW_HUNT_PRAY_PANEL:Array=["ViewHuntPrayPanel", ViewHuntPrayPanel]; // 卜卦
		public static const VIEW_FIGHT_REPORT_PANEL:Array=["ViewFightReportPanel", ViewFightReportPanel]; // 战报
		public static const VIEW_EXPLORE_TROOP:Array=["ViewExploreTroop", ViewExploreTroop]; // 选择队伍面板
		public static const VIEW_PK_HUNT:Array=["ViewPKHunt", ViewPKHunt]; // 编辑队伍面板
		public static const VIEW_CHANGE_HERO:Array=["ViewChangeHero", ViewChangeHero]; // 切换英雄面板

		//------------------节日活动
		public static const VIEW_FESTIVAL:Array=["ViewFestival", ViewFestival];

		//------------------拍卖活动
		public static const VIEW_AUCTION:Array=["ViewAuction", ViewAuction];
		public static const AUCTION_BID:Array=["AuctionBid", AuctionBid]; // 出价面板
		public static const VIEW_AWAKEN_HERO:Array=["ViewAwakenHero", ViewAwakenHero]; // 英雄觉醒
		
		//------------------消费榜
		public static const VIEW_PAY_RANK:Array=["ViewPayRank", ViewPayRank];
		public static const VIEW_PAY_RANK_REWARD:Array=["ViewPayRankReward", ViewPayRankReward];
		public static const VIEW_PAY_RANK_TIPS:Array=["ViewPayRankTips", ViewPayRankTips];

		//------------------国战任务
		public static const VIEW_FIGHT_TASK:Array=["ViewFightTask", ViewFightTask];

		//------------------一键补兵
		public static const VIEW_TROOP_COIN_FILL:Array=["ViewTroopCoinFill", ViewTroopCoinFill];

		//------------------一登录就要弹出的面板
		public static const VIEW_CREDITRESULT:Array=["ViewCreditResult", ViewCreditResult]; //战功结算

		public static const VIEW_NOTICE_PICTURE:Array=["ViewNoticePicture",ViewNoticePicture];//

		public static const VIEW_COUNTRY_PVP_TIPS:Array=["ViewCountryPvpTips",ViewCountryPvpTips];//

		public static const VIEW_COUNTRY_TRIBUTARY_TIPS:Array=["ViewCountryTributaryTips",ViewCountryTributaryTips];//

		public static const VIEW_EMPEROR_TIPS:Array=["ViewCountryEmperorTips",ViewCountryEmperorTips];

		public static const VIEW_EQUIP_MAIN:Array = ["ViewEquipMain",ViewEquipMain];

		public static const VIEW_EQUIP_BOX:Array = ["ViewEquipBox",ViewEquipBox];

		//------------------惊喜礼包
		public static const VIEW_SURPRISE_GIFT:Array = ["ViewSurpriseGift",ViewSurpriseGift];

		//------------------福将挑战
		public static const VIEW_BLESS_HERO:Array = ["ViewBlessHero",ViewBlessHero];
		public static const VIEW_BLESS_HERO_RANK:Array = ["ViewBlessHeroRank",ViewBlessHeroRank];
		public static const VIEW_PVE_TROOP:Array=["ViewPVETroop", ViewPVETroop]; // PVE选择队伍面板

		public static const VIEW_NEW_TASK_MAIN:Array = ["ViewNewTaskMain",ViewNewTaskMain];

		public static const VIEW_SALE_PAY_ALERT:Array = ["ViewSalePayAlert",ViewSalePayAlert];
	}

}