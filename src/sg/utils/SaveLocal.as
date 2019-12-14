package sg.utils
{
    import laya.net.LocalStorage;
    import laya.utils.Browser;
    import sg.manager.ModelManager;
    import sg.cfg.ConfigApp;
    import laya.qq.mini.QQMiniAdapter;

    public class SaveLocal{

        public static const KEY_USER:String                    = "local_save_key_user";
        public static const KEY_USER_LIST:String               = "local_save_key_user_list";

        public static const KEY_WASH_EQUIP:String              = "local_save_key_wash_equip";
        public static const KEY_CHAT:String                    = "local_save_key_chat";
        public static const KEY_PVE_HERO:String                = "local_save_key_pve_hero";
        public static const KEY_HAPPY_SPARTA:String            = "local_save_key_happy_sparta";
        public static const KEY_CREDIT_RESULT:String           = "local_save_key_credit_result";
        public static const KEY_SERVER_CFG:String              = "local_save_key_server_cfg";
        public static const KEY_SERVER_CFG_VERSION:String      = "local_save_key_server_cfg_version";

        public static const KEY_HERO_SKILL_SPECIAL:String      = "key_hero_skill_special";
        public static const KEY_GUIDE:String                   = "sg_local_save_key_guide"; // 条件引导数据
        public static const KEY_SETTINGS:String                = "sg_local_save_key_settings"; // 设置数据
        //
        public static const KEY_COUNTRY_KING:String            = "_key_country_king";
        public static const KEY_COUNTRY_KING_EVERY_TIPS:String = "_key_country_king_every_tips";
        public static const KEY_ACT:String                     = "local_save_key_act_"; // 活动是否点击过
        public static const KEY_REPEAT_ALERT:String            = "local_save_key_repeat_alert_";//提示弹窗是否可重复弹出
        public static const KEY_NEW_HERO:String                = "local_save_key_new_hero_";//新招募英雄
        public static const KEY_XYZ_BEGIN:String               = "local_save_key_xyz_begin_";//襄阳战开始
        public static const KEY_COUNTRY_TRUBUTR:String         = "local_save_key_country_tribute_";//进贡
        public static const KEY_YYB_LOGIN:String               = "login_pf_yyb";
        public static const KEY_GG_FB_LOGIN:String             = "login_pf_gg_fb";
        public static const KEY_VISITOR_USER_DATA:String       = "visitor_user_data";

        public static const KEY_EMPEROR_TIPS_TIME:String       = "emperor_tips_time_";//弹出“君临天下”面板的时间
        public static const KEY_SEE_RANK_WORLD:String          = "see_rank_world_";//已看过排行榜中的世界榜
        public static const KEY_SEE_OFFICE_MAIN:String         = "see_rank_office_main_";//爵位是否查看过

        public static const KEY_LOCAL_CHAT_CHANNEL:String      = "key_local_chat_channel_";//本地记录聊天频道
        public static const KEY_LOCAL_RANK_TAB:String          = "key_local_rank_tab_";//本地记录排行榜页签
        public static const KEY_LOCAL_APP_IDFA:String          = "key_local_app_idfa";//
        public static const KEY_INSTALL_REPORT:String          = "key_install_report";//

        public static const KEY_CITY_BUILD_GEAR:String         = "key_city_build_gear";//建设档位默认值

        public static function getValue(id:String,otherZone:Boolean=false):Object{
            // if(Browser.onMiniGame){
            //     return Browser.window.wx.getStorageSync(id);
            // }
            var s:String=otherZone ? id+"_"+ModelManager.instance.modelUser.zone : id;
            if (ConfigApp.releaseQQ()) {
                return QQMiniAdapter.window.qq.getStorageSync(s);
            } else {
                return LocalStorage.getJSON(s);
            }
        }
        public static function save(id:String,obj:Object,otherZone:Boolean=false):void{
            // if(Browser.onMiniGame){
            //     Browser.window.wx.setStorageSync(id,obj);
            //     return;
            // }
            var s:String=otherZone ? id+"_"+ModelManager.instance.modelUser.zone : id;
            if (ConfigApp.releaseQQ()) {
                QQMiniAdapter.window.qq.setStorageSync(s, obj);
            } else {
                LocalStorage.setJSON(s,obj);
            }
        }
        public static function deleteObj(id:String,otherZone:Boolean=false):void{
            // if(Browser.onMiniGame){
            //     Browser.window.wx.removeStorageSync(id);
            //     return;
            // }     
            var s:String=otherZone ? id+"_"+ModelManager.instance.modelUser.zone : id;   
            if (ConfigApp.releaseQQ()) {
                QQMiniAdapter.window.qq.removeStorageSync(s);
            } else {
                LocalStorage.removeItem(s);
            }     
        }

        /**
         * 存成一个数组 往数组里添加元素
         */
        public static function savaArr(id:String,key:String,obj:*,otherZone:Boolean=false):void{
            var o:Object=SaveLocal.getValue(id,otherZone);
            if(o){
                var arr:Array=o[key];
                if(arr.indexOf(obj)==-1){
                    arr.push(obj);
                }
            }else{
                o={};
                o[key]=[obj];
            }
            SaveLocal.save(id,o,otherZone);
        }

        /**
         * 数组里删除元素
         */
        public static function deleteArr(id:String,key:String,obj:*,otherZone:Boolean=false):void{
             var o:Object=SaveLocal.getValue(id,otherZone);
            if(o){
                var arr:Array=o[key];
                if(arr.indexOf(obj)!=-1){
                    arr.splice(arr.indexOf(obj),1);
                    SaveLocal.save(id,o,otherZone);
                }
            }
        }

        public static function clearAll():void{
            // if(Browser.onMiniGame){
            //     Browser.window.wx.clearStorageSync();
            //     return;
            // }  
            if (ConfigApp.releaseQQ()) {
                QQMiniAdapter.window.qq.clearStorageSync();
            } else {
                LocalStorage.clear();
            }             
        }
    }
}