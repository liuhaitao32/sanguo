package sg.net
{
    /**
     * 服务器 消息 名称 配置
     */
    public class NetMethodCfg{
        public static const HTTP_SYS_CONFIG:String = "sys.get_config";
        public static const HTTP_SYS_CONFIG_NEW:String = "sys.new_get_config";
        public static const HTTP_USER_LOGIN:String = "user_zone.login";
        public static const HTTP_USER_REGISTER:String = "user_zone.register";
        public static const HTTP_USER_REGISTER_FAST:String = "user_zone.register_fast";
        public static const HTTP_USER_SEND_SIGN_LOGIN:String = "user_zone.send_login_sign";
        public static const HTTP_USER_SET_ZONES:String = "user_zone.set_zones";
        public static const HTTP_USER_XH_SIGN:String = "user_zone.get_xh_sign";
        public static const HTTP_USER_H5_BG_SIGN:String = "user_zone.get_h5_bg_sign";
        public static const HTTP_USER_HW_SIGN:String = "user_zone.get_hw_sign";
        public static const HTTP_USER_HW_TW_SIGN:String = "user_zone.get_hw_tw_sign";
        public static const HTTP_USER_37_SIGN:String = "user_zone.get_h5_37_sign";
        public static const HTTP_USER_IOS_37_SIGN:String = "user_zone.get_ios_37_sign";
        public static const HTTP_USER_7K_SIGN:String = "user_zone.get_h5_7k_sign";
        public static const HTTP_USER_360_SIGN:String = "user_zone.get_h5_360_sign";
        public static const HTTP_USER_360_2_SIGN:String = "user_zone.get_h5_360_2_sign";
        public static const HTTP_USER_360_3_SIGN:String = "user_zone.get_h5_360_3_sign";
        public static const HTTP_USER_MUZHI_SIGN:String = "user_zone.get_h5_muzhi_sign";
        public static const HTTP_USER_MUZHI2_SIGN:String = "user_zone.get_h5_muzhi2_sign";
        // public static const HTTP_USER_PANBAO_ATOKEN:String = "user_zone.get_h5_panbao_access_token";
        // public static const HTTP_USER_PANBAO_PAY_SIGN:String = "user_zone.get_h5_panbao_pay_sign";
        public static const HTTP_USER_JJ_37_SIGN:String = "user_zone.get_jj_h5_37_sign";
        public static const HTTP_USER_SG_WENDE_PAY:String = "user_zone.get_h5_wende_sign";
        public static const HTTP_USER_SG_7477_SIGN:String = "user_zone.get_h5_7477_sign";
        public static const HTTP_USER_H5_ZFB_PAY:String = "user_zone.zfb_h5_pay";
        public static const HTTP_FB_GOOGLE_BING:String = "user_zone.fb_google_bing";
        public static const HTTP_USER_VALIDATE_USER_CODE:String = "user_zone.validate_user_code";
        public static const HTTP_USER_PAY:String = "user_zone.pay";
        public static const HTTP_USER_WX_APP_PAY:String = "user_zone.weixin_app_pay";
        public static const HTTP_USER_WX_h5_PAY:String = "user_zone.weixin_h5_pay";
        public static const HTTP_USER_SELF_H5_WX_PAY:String = "user_zone.wx_h5_pay";
        public static const HTTP_USER_YYB_PAY:String = "user_zone.yyb_pay";
        public static const HTTP_USER_YYB2_LOGIN_TYPEY:String = "user_zone.yyb_install_from";
        public static const HTTP_USER_YYB_PAY_FROM:String = "user_zone.yyb_pay_from";
        public static const HTTP_USER_VIVO_SIGN:String = "user_zone.get_vivo_sign";
        public static const HTTP_USER_OPPO_SIGN:String = "user_zone.get_oppo_sign";
        public static const HTTP_USER_MEIZU_SIGN:String = "user_zone.get_mz_sign";
        public static const HTTP_USER_UC_SIGN:String = "user_zone.get_uc_sign";
        public static const HTTP_GG_CALLBACK:String = "user_zone.gg_callback";
        public static const HTTP_USER_37_IOS_SIGN:String = "user_zone.get_37_ios_sign";
        public static const HTTP_USER_CHECK_GAME_INDEX:String = "user_zone.check_game_index";
        public static const HTTP_USER_YYJH_SIGN:String = "user_zone.get_yyjh_pay_sign";
        public static const HTTP_USER_YYJH2_SIGN:String = "user_zone.get_yyjh2_pay_sign";
        public static const HTTP_USER_JJ_YYJH_SIGN:String = "user_zone.get_jj_yyjh_pay_sign";
        public static const HTTP_USER_JJ_7K_SIGN:String = "user_zone.get_jj_h5_7k_sign";
		//——————————————————————————————————————————地图协议————————————————————————————————————————————————————————
		
		public static const WS_SR_GET_INFO:String = "w.get_info";
		public static const WS_SR_GET_COUNTRY_INFO:String = "w.get_country_info";//国家信息
		
		//——————————————————————————————————————————————————————————————————————————————————————————————————————————
		
        //
        public static const WS_SR_LOGIN:String = "login";
        public static const WS_SR_GET_COIN:String = "get_coin";
        public static const WS_SR_SYNC_CONFIG:String = "sync_configs";
        public static const WS_SR_BUILDING_LV_UP:String = "building_lvup";//建筑升级
        public static const WS_SR_KILL_BUILDING_CD:String = "kill_building_cd";//秒建筑升级的cd
        public static const WS_SR_GET_BUILDING_MATERIAL:String = "get_building_material";//收割建筑产出
        //
        public static const WS_SR_RECRUIT_HERO:String = "recruit_hero";//招募英雄
        public static const WS_SR_HERO_STAR_UP:String = "hero_star_up";//英雄升星
        public static const WS_SR_HERO_LV_UP:String = "hero_lv_up";//英雄升级
        public static const WS_SR_HERO_ARMY_LV_UP:String = "hero_army_lv_up";//英雄升阶
        public static const WS_SR_HERO_SKILL_LV_UP:String = "hero_skill_lv_up";//英雄技能升级
        public static const WS_SR_HERO_SKILL_FORGET:String = "hero_skill_forget";//英雄技能遗忘
        public static const WS_SR_HERO_FATE:String = "hero_fate";//英雄宿命激活
        //
        public static const WS_SR_EQUIP_MAKE:String = "equip_make";//宝物锻造
        public static const WS_SR_EQUIP_UPGRADE:String = "equip_upgrade";//宝物升级
        public static const WS_SR_KILL_EQUIP_CD:String = "kill_equip_cd";//宝物 cd
        public static const WS_SR_GET_EQUIP_CD:String = "get_equip_cd";//宝物 收获
        public static const WS_SR_HERO_EQUIP_INSTALL:String = "hero_equip_install";//宝物 安装
        public static const WS_SR_HERO_EQUIP_UNINSTALL:String = "hero_equip_uninstall";//宝物 卸载
        public static const WS_SR_HERO_STAR_INSTALL:String = "hero_star_install";//星辰 安装
        public static const WS_SR_HERO_STAR_UNINSTALL:String = "hero_star_uninstall";//星辰 卸载
        public static const WS_SR_STAR_LV_UP:String = "star_lv_up";//星辰 升级
        public static const WS_SR_BUILDING_MAKE_ARMY:String = "building_make_army";//兵营 训练
        public static const WS_SR_GET_BUILDING_ARMY:String = "get_building_army";//兵营 训练
        public static const WS_SR_KILL_ARMY_CD:String = "kill_army_cd";//兵营 秒cd
        public static const WS_SR_CLIMB:String = "climb";//过关斩将,战斗
        public static const WS_SR_GET_CLIMB_RANK:String = "get_climb_rank";//过关斩将,排行
        public static const WS_SR_CHOOSE_COUNTRY:String = "choose_country";//国家
        public static const WS_SR_USER_INFO:String = "user_info";//玩家信息
        public static const WS_SR_OFFICE_LV_UP:String = "office_lv_up";//爵位 ,升级
        public static const WS_SR_OFFICE_RIGHT_UNBLOCK:String = "office_right_unblock";//爵位 ,特权,解锁
        public static const WS_SR_GET_RANDOM_UNAME:String = "get_random_uname";//获取随名字
        public static const WS_SR_CHANGE_UNAME:String = "change_uname";//修改名字
		public static const WS_SR_CHANGE_POWER:String = "change_power";//修改战力
        public static const WS_SR_GET_PK_USER:String = "get_pk_user";//pk 挑战用户列表
        public static const WS_SR_PK_USER:String = "pk_user";//pk 战斗开始
        public static const WS_SR_GET_PK_RANK:String = "get_pk_rank";//pk 排行榜查看
        public static const WS_SR_BUY_PK_TIMES:String = "buy_pk_times";//pk 购买次数
        public static const WS_SR_GET_PK_COUNTRY_FIRST:String = "get_pk_country_first";//pk 国家排行
        public static const WS_SR_GET_CLIMB_ARMY_TYPE:String = "get_climb_army_type";//climb 过关斩将 前后军
        public static const WS_SR_BUY_CLIMB_TIMES:String = "buy_climb_times";//climb 购买次数
        public static const WS_SR_GET_CLIMB_REWARD:String = "get_climb_reward";//climb 获得奖励
        public static const WS_SR_JOIN_PK_YARD:String = "join_pk_yard";//比武大会 报名
        public static const WS_SR_GET_PK_YARD_LOG:String = "get_pk_yard_log";//比武大会 log
        public static const WS_SR_PK_YARD_WORSHIP:String = "pk_yard_worship";//比武大会 膜拜
        public static const WS_SR_GET_MY_PK_YARD_HIDS:String = "get_my_pk_yard_hids";//比武大会 ,我的队伍
        public static const WS_SR_PK_YARD_GAMBLE:String = "pk_yard_gamble";//比武大会 ,下注
        public static const WS_SR_GET_PK_YARD_GAMBLE:String = "get_pk_yard_gamble";//比武大会 ,下注数据
        public static const WS_SR_HERO_INSTALL_TITLE:String = "hero_install_title";//安装称号
        //
        public static const WS_SR_GET_CITIZEN:String = "w.get_citizen";//获得条件公民
        public static const WS_SR_SET_OFFICIAL:String = "w.set_official";//任命 官职
        public static const WS_SR_SET_MAYOR:String = "w.set_mayor";//任命 太守
        public static const WS_SR_GET_MAYOR_LIST:String = "w.get_mayor_list";//获取 准备太守 list
        public static const WS_SR_GET_USERS:String = "w.get_users";//国家公民排行
        public static const WS_SR_GIVE_TEAM_AWARD:String = "w.give_team_award";//国家封赏
        public static const WS_SR_GET_MILEPOST_REWARD:String = "w.get_milepost_reward";//天下大势 领奖 平分
        public static const WS_SR_GET_MILEPOST_FIGHT_REWARD:String = "w.get_milepost_fight_reward";//天下大势 领奖
        public static const WS_SR_CREATE_BUFF:String = "w.create_buff";//传令
        //
        public static const WS_SR_GET_CITY_INFO:String = "w.get_city_info";//城市信息
        //
        public static const WS_SR_GET_GUILD_LIST:String = "get_guild_list";//各军团 列表
        //
        public static const WS_SR_SCIENCE_LVUP:String = "science_lvup";//科技 升级
        public static const WS_SR_GET_SCIENCE:String = "get_science";//科技 激活
        public static const WS_SR_KILL_SCIENCE_CD:String = "kill_science_cd";//科技 cd
        public static const WS_SR_GET_SCIENCE_REWARD:String = "get_science_reward";//科技 day get
        //
        public static const WS_SR_GET_GTASK:String = "get_gtask";//政务
        public static const WS_SR_REFRESH_GTASK:String = "refresh_gtask";//刷新政务
        public static const WS_SR_BUY_GTASK_TIMES:String = "buy_gtask_times";//购买政务
        public static const WS_SR_RECEIVE_GTASK:String = "receive_gtask";//购买政务
        public static const WS_SR_DROP_GTASK:String = "drop_gtask";//放弃政务
        public static const WS_SR_DO_GTASK:String = "do_gtask";//做政务
        public static const WS_SR_GET_GTASK_REWARD:String = "get_gtask_reward";//领取政务奖励
        //
        //
        public static const WS_SR_GET_PK_NPC:String = "get_pk_npc";//异族入侵
        public static const WS_SR_PK_NPC_FIGHT:String = "pk_npc_fight";//异族入侵打架
        public static const WS_SR_GET_PK_NPC_REWARD:String = "get_pk_npc_reward";//异族入侵领奖
        public static const WS_SR_PK_NPC_CAPTAIN_FIGHT:String = "pk_npc_captain_fight";//异族入侵,名将来袭打架
        public static const WS_SR_GET_PK_NPC_CAPTAIN_REWARD:String = "get_pk_npc_captain_reward";//异族入侵,领奖
        public static const WS_SR_GET_WORLD_LV:String = "get_world_lv";//获得世界等级
		
		//———————————————————————————————————————————————————————————副将————————————————————————————————————————————————————————
        public static const WS_SR_INSTALL_ADJUTANT:String = "hero_install_adjutant"; // 任命副将
        public static const WS_SR_UNINSTALL_ADJUTANT:String = "hero_uninstall_adjutant"; // 卸任副将
		
		//———————————————————————————————————————————————————————————任务————————————————————————————————————————————————————————
        public static const WS_SR_GET_TASK:String = "get_task";
        public static const WS_SR_GET_TASK_REWARD:String = "get_task_reward";
		
		//———————————————————————————————————————————————————————————成就————————————————————————————————————————————————————————
        public static const WS_SR_GET_EFFORT_REWARD:String = "get_effort_reward";

		//——————————————————————————————————————————————————————————— 精彩活动 ————————————————————————————————————————————————————
        public static const WS_SR_GET_ONLINE_REWARD:String = "get_online_reward"; // 在线奖励

        public static const WS_SR_SET_WISH_REWARD:String = "set_wish_reward"; // 许愿奖励
        public static const WS_SR_GET_WISH_REWARD:String = "get_wish_reward";
        public static const WS_SR_GET_LOGIN_REWARD:String = "get_login_reward";

        public static const WS_SR_GET_PAY_REWARD:String = "get_pay_reward"; // 充值领奖

        public static const WS_SR_GET_OFFICE_REWARD:String = "get_office_reward"; // 爵位升级领奖

        public static const WS_SR_GET_PAY_PLOY_REWARD:String = "get_pay_ploy_reward"; // 单充累充领奖

        public static const WS_SR_GET_MEMBER_CARD_REWARD:String = "get_member_reward"; // 永久卡领奖

        public static const WS_SR_GET_WEEK_CARD_GIFT:String = "get_week_card_gift"; // 周卡活动领奖

        public static const WS_SR_BUY_FUND:String = "buy_fund"; // 超级基金
        public static const WS_SR_GET_FUND_GIFT:String = "get_fund_gift";

        public static const WS_SR_BUY_SALE_SHOP:String = "buy_sale_shop"; // 折扣商店

        public static const WS_SR_GET_PAY_CHOOSE_REWARD:String = "get_pay_choose_reward"; // 充值自选

        public static const WS_SR_GET_EXCHANGE_REWARD:String = "get_exchange_reward"; // 兑换商店

		//———————————————————————————————————————————————————————————获取记录数据————————————————————————————————————————————————
        public static const WS_SR_GET_RECORDS:String = "get_records";

		//———————————————————————————————————————————————————————————累计消费领奖————————————————————————————————————————————————
        public static const WS_SR_GET_CONSUME_REWARD:String = "get_coin_consume_reward";

		//———————————————————————————————————————————————————————————官邸升级充值领奖————————————————————————————————————————————
        public static const WS_SR_GET_LVUP_REWARD:String = "get_lvup_reward";

		//———————————————————————————————————————————————————————————  限时免单  ————————————————————————————————————————————————
        public static const WS_SR_BUY_LIMIT_FREE:String = "buy_limit_free"; // 购买商品
        public static const WS_SR_BUY_LIMIT_FREE_TIMES:String = "buy_limit_free_times"; // 购买限时免单购买次数
        public static const WS_SR_GET_LIMIT_FREE_COUNT_REWARD:String = "get_limit_free_count_reward"; // 限时免单领奖

		//———————————————————————————————————————————————————————————  引导进度记录  ————————————————————————————————————————————
        public static const WS_SR_DO_GUIDE:String = "do_guide";
        public static const WS_SR_JUMP_GUIDE:String = "jump_guide";

		//———————————————————————————————————————————————————————————     探险       ————————————————————————————————————————————
        public static const WS_SR_START_MININE:String   = "start_minine";   // 蓬莱寻宝     开始采集
        public static const WS_SR_HARV_MININEE:String   = "harv_mining";    // 蓬莱寻宝     收获
        public static const WS_SR_GET_MAGIC:String      = "get_magic";      // 蓬莱寻宝     卜卦
        public static const WS_SR_GET_GRAB_USER:String  = "get_grab_user";  // 蓬莱寻宝     获取抢夺的用户
        public static const WS_SR_GET_GRAB_MINING:String= "grab_mining";    // 蓬莱寻宝     抢夺资源
        public static const WS_SR_GET_GRAB_LOG:String   = "get_grab_log";   // 蓬莱寻宝     获取战报

		//———————————————————————————————————————————————————————————     见证传奇       ————————————————————————————————————————
        public static const WS_SR_GET_LEGEND_BUY_TIMES:String   = "buy_legend_combat_times";// 购买次数
        public static const WS_SR_GET_LEGEND_REWARD:String      = "get_legend_reward";      // 传奇之路 领奖
        public static const WS_SR_GET_LEGEND_COMBAT:String      = "legend_combat";          // 英雄历练 挑战
		
		//———————————————————————————————————————————————————————————     节日       ————————————————————————————————————————————
        public static const WS_SR_FESTIVAL_LOGIN_REWARD:String  = "get_festival_login_reward";      // 登陆活动领奖
        public static const WS_SR_FESTIVAL_ONCE_REWARD:String   = "get_festival_once_pay_reward";   // 单充领奖
        public static const WS_SR_FESTIVAL_ADDUP_REWARD:String  = "get_festival_addup_reward";      // 累充领奖
        public static const WS_SR_FESTIVAL_PITUP_REWARD:String  = "get_festival_pitup_reward";      // 单日累充领奖
        public static const WS_SR_FESTIVAL_EXCHANGE:String      = "get_festival_exchange_reward";   // 兑换物品
        public static const WS_SR_FESTIVAL_LUCKSHOP:String      = "get_festival_luckshop_reward";   // 幸运商店购买物品
        public static const WS_SR_REFRESH_LUCKSHOP:String       = "cost_refresh_festival_luckshop"; // 手动刷新幸运商店
		
		//———————————————————————————————————————————————————————————     拍卖       ————————————————————————————————————————————
        public static const WS_SR_GET_AUCTION:String    = "get_auction";    // 获取拍卖信息
        public static const WS_SR_COST_AUCTION:String   = "cost_auction";   // 出价
        public static const WS_SR_BUY_AUCTION:String    = "buy_auction";    // 拍卖结束直接购买
		
		//———————————————————————————————————————————————————————————     消费榜       ————————————————————————————————————————————
        public static const WS_SR_GET_PAY_INFO:String           = "get_pay_info";           // 刷新排行
        public static const WS_SR_GET_PAY_RANK_REWARD:String    = "get_pay_rank_reward";    // 领取排行奖励
        public static const WS_SR_GET_PAY_POINT_REWARD:String   = "get_pay_point_reward";   // 领取积分奖励
        public static const WS_SR_GET_FIGHT_LOG:String          = "get_fight_log";
		
		//———————————————————————————————————————————————————————————     国战任务       ————————————————————————————————————————————
        public static const WS_SR_GET_FIGHT_TASK:String     = "get_fight_task";
		
		//———————————————————————————————————————————————————————————     福将挑战       ————————————————————————————————————————————
        public static const WS_SR_PK_BLESS:String           = "pk_bless";
        public static const WS_SR_GET_BLESS_GIFT:String     = "get_bless_gift";
        public static const WS_SR_GET_BLESS_RANK:String     = "get_bless_rank";
		
		//———————————————————————————————————————————————————————————360平台的关注、认证—————————————————————————————————————————————————
        public static const WS_SR_GET_360_REWARD:String = "get_360_reward"; // 关注
		
		//——————————————————————————————————————————————————————————— 传奇觉醒 —————————————————————————————————————————————————
        public static const WS_SR_DRAW_LEGEND_AWAKEN:String = "draw_legend_awaken";
        public static const WS_SR_LEGEND_AWAKEN_REWARD:String = "legend_awaken_reward";
		
		//——————————————————————————————————————————————————————————— 节日转盘 —————————————————————————————————————————————————
        public static const WS_SR_CHOOSE_FESTIVAL_DIAL:String = "choose_festival_dial"; // 选定转盘抽奖内容
        public static const WS_SR_RANDOM_FESTIVAL_DIAL:String = "random_festival_dial"; // 转盘抽奖

		//——————————————————————————————————————————————————————————— 节日珍宝 —————————————————————————————————————————————————
        public static const WS_SR_RANDOM_FESTIVAL_TREASURE:String = "random_festival_treasure"; // 节日珍宝随即奖励
        public static const WS_SR_FESTIVAL_TREASURE_SHOP:String = "festival_treasure_shop";     // 节日珍宝商店购买

        public static const WS_SR_FESTIVAL_PAY_AGAIN:String = "buy_festival_pay_again";         // 节日
    }
}