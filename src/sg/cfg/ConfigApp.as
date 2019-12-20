package sg.cfg
{
	import laya.utils.Browser;
	import laya.net.Loader;
	import sg.manager.AssetsManager;	
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import laya.renders.Render;
	import sg.sdks.H5sdk;
	import sg.sdks.H5JJ37;
	import sg.sdks.H5SGWende;
	import sg.sdks.H5SG7477;

	public class ConfigApp{
		///是否打开调试，允许账号输入
		private static var _isTest:int;
		///是否开启调试，只要设置过负值则不可再改变
		public static function get isTest():*{
			// return false;
			return ConfigApp._isTest > 0;
		}
		///是否开启调试，只要设置过负值则不可再改变
		public static function set isTest(value:*):void{
			if (ConfigApp._isTest >= 0){
				if (value < 0){
					ConfigApp._isTest = value;
				}
				else{
					ConfigApp._isTest = Math.max(ConfigApp._isTest, value);
				}
			}
		}
		public static var isUpdateApp:Number = -1;//更新安装包
		public static var updateAppURL:String = "";//更新安装包配置
		public static var isNewHome:Boolean = true;//使用新封地
		///快捷测试战斗模式类型 0不测试战斗 1测试基础战斗 2测试版号战斗
		public static var testFightType:int = 0;
		///测试运行时间效率
		public static var testTimeRate:int = 0;
		public static var hasDocument:Boolean = true;//
		public static var configTemp:Boolean = true;//本地cfg配置缓存功能
		public static var copyrightTime:int = 0;//6000;
		//
		public static var appVersion:String = "v_1_1_0";//发布版本,基本不变
		public static var appVersionTxt:String = "v_3_1";//显示版本
		public static var appFunVersion:String = "5";//对外发布修改调整小版本	
		public static var cfgVersion:Number = 0;//cfg配置初始版本
		public static var sNetCfg:Object = null;//外部网络地址配置json
		//
		public static var width:Number = 0;
		public static var height:Number = 0;
		public static var ratio:Number = 0;
		public static var ratio_21:Number = 1.8;
		public static var ratio_43:Number = 1.5;
		public static var ratio_base:Number = 1138/640;//最大
		public static var ratio_base2:Number = 960/640;//最小1
		public static var top:Number = 50;
		public static var topVal:Number = top;//顶部高度	
		/** ********************外部特殊配置通过get获取*********************** */
		public static var url_params:Array = ["ptype","ussl","ncpurl","czpf","mlogo"
								,"ilimg","lbimg","msurl","mppf","v","disloading","auser"
								,"lclip1","lclip2","chmj","loadtxt","idfa","opudid","device"
								,"cfgvers","mlan","mpc","plocal","bagname","oldcfg","vsdebug","mssl","pcbg"];
		public static var thisPackageType:String = null;//ptype=包区分
		public static var httpSSL:String = null;//ussl=强制屏蔽https
		public static var wsSSL:String = null;//mssl=强制屏蔽 wss
		public static var netCfgPfUrl:String = null;//ncpurl=根据外部类似pf配置改变net_cfg_url
		public static var changeZonePf:String = null;//czpf=根据区切换自己的pf,进行登录、注册
		public static var otherLogoPngImg:String = null;//mlogo=切换logo图片
		public static var indexLoadingImg:String = null;//ilimg=初始index加载过程的图片
		public static var pcbgImg:String = null;//pcbg=初始index加载过程的图片
		public static var loginBgImg:String = null;//lbimg=登录背景页面
		public static var myServerUrl:String = null;//msurl=目前只允许开发模式用,切换服务器地址
		public static var myPackagePf:String = null;//mppf=我的包的pf唯一的
		public static var disloading:String = null;//屏蔽loading动画
		public static var loginSelfForce:Boolean = false;//lsforce=强制用自己的登录
		public static var auser:String = null;//已有账号自动登录用
		public static var lclip1:String = null;//loading动画是否屏蔽1
		public static var lclip2:String = null;//loading动画是否屏蔽2
		public static var chmj:String = null;//草花平台专用分包处理参数config_type=1,2
		public static var loadtxt:String = null;//加载文字
		public static var midfa:String = null;//设备ID
		public static var opudid:String = null;//特殊登录uid
		public static var mdevice:String = null;//设备ID
		public static var cfgvers:String = null;//version.json指定配置
		public static var mLanguage:String = null;//游戏用的语言文本
		public static var mpc:String = null;//是否是在pc适配环境
		public static var plocal:String = null;//地点
		public static var bagname:String = null;//包
		public static var oldcfg:String = null;//接口获取配置==yes
		public static var isChina:String = null;//是否是中国
		public static var mVsdebug:String = null;//调试信息
		// 
		public static var isFirstInstall:Boolean = true;

		/** ********************这里是重点,看这里*********************** */
		public static const PF_test:String = "developer";//本地开发测试
		// 
		public static const PF_pc:String = "pc";//PC
		//
		public static const PF_WeiXin:String = "wx";//微信
		public static const PF_QQ:String = "h5_qq"; // QQ小游戏
		public static const PF_wx_changxiang:String = "h5_changxiang";
		public static const PF_dev:String = "dev";//线上调试版本
		public static const PF_dev_local:String = "dev_local";//线上调试版本
		public static const PF_dev_hk:String = "dev_hk";//HK繁体线上调试版本
		// public static const PF_dev_mj_ku:String = "dev_mj_ku";//马甲-kuku君海用
		//
		public static const PF_ios_meng52:String = "ios";//ios用
		public static const PF_ios_meng52_sh:String = "ios_sh";//ios用
		public static const PF_ios_meng52_sgzb:String = "ios_sgzb";//ios用
		public static const PF_ios_jj_cn:String = "jj_ios";//警戒ios用
		public static const PF_ios_jj_cn_mj1:String = "jj_ios_mjm1";//警戒ios用马甲
		public static const PF_ios_meng52_mjm1:String = "ios_mjm1";//ios用自己马甲--三国权谋
		public static const PF_ios_meng52_mjm2:String = "ios_mjm2";//ios用自己马甲--乐游给
		public static const PF_ios_meng52_mjm5:String = "ios_mjm5";//ios用自己马甲--买三国之群雄竞起
		// public static const PF_ios_meng52_mjm3:String = "ios_mjm3";//ios用自己马甲--unity测试
		// public static const PF_ios_meng52_mjm4:String = "ios_mjm4";//ios马甲 黑山团队用
		//
		public static const PF_ios_meng52_mj1:String = "ios_mj1";////给别人审核用的pf+IAP+过(sgtxc)
		public static const PF_ios_meng52_mj2:String = "ios_sg1";//自己审核用的pf+IAP
		// 
		public static const PF_ios_meng52_tw:String = "ios_tw";//ios港澳台用facebook
		public static const PF_ios_meng52_hk:String = "ios_hk";//ios港澳台自己登录	
		// 
		// public static const PF_juedi_ios:String = "juedi_ios";//绝地ios
		// public static const PF_37_ios:String = "37_ios";//37ios
		public static const PF_ios_37:String = "ios_37";
		public static const PF_wende_ios:String = "wende_ios";//文德ios
		public static const PF_yx7477:String = "yx7477";//7477
		public static const PF_yx7477_1:String = "yx7477_1";//7477_1
		public static const PF_7477_h5:String = "h5_7477";//7477 三国 h5
		//
		// public static const PF_xh_h5:String = "xh_h5";//星辉h5
		// public static const PF_wx_h5:String = "wx_h5";//微信h5
		public static const PF_37_h5:String = "h5_37";//37游戏h5版本
		public static const PF_kuku_h5:String = "h5_kuku";//君海游戏h5版本
		// public static const PF_9130_h5:String = "h5_9130";//9130 h5版本
		public static const PF_yyjh_h5:String = "h5_yyjh";//益游嘉和 h5版本
		public static const PF_yyjh2_h5:String = "h5_yyjh2";//益游嘉和 h5版本 tap
		public static const PF_caohua1_h5:String = "h5_ch";//草花 h5版本
		public static const PF_caohua2_h5:String = "h5_ch2";//草花 h5版本
		// public static const PF_bugu_h5:String = "h5_bg";//布谷h5版本
		public static const PF_tanwan_h5:String = "h5_twyx"; // 贪玩游戏
		public static const PF_tanwan2_h5:String = "h5_twyx2"; // 贪玩游戏
		public static const PF_tanwan3_h5:String = "h5_twyx3"; // 贪玩游戏
		public static const PF_tanwan4_h5:String = "h5_twyx4"; // 贪玩游戏 wzSDK 
		// public static const PF_yuncai_h5:String = "h5_yuncai"; // 蓝象
		public static const PF_7k_h5:String = "h5_7k"; // 7k7k 迦游
		public static const PF_leyou_h5:String = "h5_leyou"; //  乐游
		public static const PF_1377_h5:String = "h5_1377"; //  1377（赞钛）
		public static const PF_360_h5:String = "h5_360"; // 360
		public static const PF_360_2_h5:String = "h5_360_2"; // 360(阿拉丁)
		public static const PF_360_3_h5:String = "h5_360_3"; // 360(速易)
		public static const PF_360_ad:String = "ad_360"; // 360 安卓
		public static const PF_muzhi_h5:String = "h5_muzhi"; // 拇指游玩 安卓
		public static const PF_muzhi2_h5:String = "h5_muzhi2"; // 拇指游玩 IOS
		public static const PF_hutao_h5:String = "h5_hutao"; // 胡桃
		public static const PF_hutao2_h5:String = "h5_hutao2"; // 胡桃2
		public static const PF_changxiang_h5:String = "changxiang"; // 畅想
		public static const PF_qqdt_h5:String = "h5_qqdt"; // QQ游戏大厅
		public static const PF_6kw_h5:String = "h5_6kw"; // 6k玩
		// public static const PF_panbao_h5:String = "h5_panbao"; // 盼宝
		public static const PF_changwan_h5:String = "h5_changwan"; // 畅玩（草花子公司）
		public static const PF_shouqu_h5:String = "h5_shouqu"; // 手趣
		public static const PF_wende_h5:String = "h5_wende"; // 文德
		
		public static const PF_JJ_37_h5:String = "jj_h5_37"; 			// 警戒 h5 37
		public static const PF_JJ_tanwan_h5:String = "jj_h5_twyx"; 		// 警戒 h5 贪玩
		public static const PF_JJ_yyjh_h5:String = "jj_h5_yyjh";		// 警戒 h5 益游嘉和
		public static const PF_JJ_7k_h5:String = "jj_h5_7k";			// 警戒 h5 7k7k 迦游
		public static const PF_JJ_leyou_h5:String = "jj_h5_leyou";		// 警戒 h5 乐游
		//
		public static const PF_JJ_caohua_ad:String = "jj_ad_caohua";	// 警戒 安卓 草花
		//
		public static const PF_and_1:String = "test";//安卓公测用了,官网
		public static const PF_and_jj_meng52:String = "jj_ad";//警戒,官网
		// public static const PF_and_2:String = "sgqx";//安卓公测用了,官网sgqx
		// public static const PF_and_demo:String = "demo_test";//安卓的评审版本
		public static const PF_and_google:String = "google";//自己的谷歌
		// public static const PF_and_cn_gdzj:String = "cn_gdzj";//国家新闻出版广电总局
		// 
		public static const PF_huawei:String = "hw";//华为
		public static const PF_huawei_tw:String = "hw_tw";//华为2
		public static const PF_yyb:String = "yyb";//应用宝
		// public static const PF_yyb2:String = "yyb2";//应用宝2-切支付--弃用
		// public static const PF_yyb_gdt:String = "yyb_gdt";//应用宝广点通
		// public static const PF_gdt_1:String = "gdt_1";//广点通1
		// public static const PF_gdt_2:String = "gdt_2";//广点通2
		// public static const PF_gdt_3:String = "gdt_3";//广点通3
		// public static const PF_gdt_4:String = "gdt_4";//广点通4
		// public static const PF_gdt_5:String = "gdt_5";//广点通5
		// 
		// public static const PF_yyb_test:String = "test_yyb";//应用宝--弃用----
		public static const PF_juedi:String = "juedi";//绝地
		public static const PF_juedi_ad:String = "juedi_ad";//绝地2
		public static const PF_vivo:String = "vivo";//vivo
		// public static const PF_vivo_ad1:String = "vivo_ad1";//vivo1
		// public static const PF_vivo_ad2:String = "vivo_ad2";//vivo2
		public static const PF_oppo:String = "oppo";//oppo
		public static const PF_xiaomi:String = "mi";//xiaomi
		public static const PF_uc:String = "uc";//UC
		public static const PF_meizu:String = "mz";//魅族
		// public static const PF_yqwb:String = "yqwb";//yqwb一起玩吧
		// public static const PF_hf:String = "hf";//汉风
		public static const PF_caohua:String = "caohua";//草花
		// public static const PF_samsung:String = "sx";//三星
		public static const PF_wende:String = "wende_ad";//文德
		public static const PF_caohua_ios:String = "caohua_ios";//草花ios
		// 
		public static const PF_r2game_xm:String = "r2g_xm";//R2Game_新马泰
		public static const PF_r2game_xm_ad:String = "r2g_xm_ad";//R2Game_新马泰——安卓
		public static const PF_r2game_xm_ios:String = "r2g_xm_ios";//R2Game_新马泰——iOS
		public static const PF_r2game_kr:String = "r2g_kr";//R2Game_韩国
		public static const PF_r2game_kr_ad:String = "r2g_kr_ad";//R2Game_韩国——安卓
		public static const PF_r2game_kr_ios:String = "r2g_kr_ios"//R2Game_韩国——iOS
		public static const PF_r2game_kr_onestore:String = "r2g_kr_os"//R2Game_韩国——iOS
		public static const PF_r2game_kr_h5:String = "r2g_kr_h5"; // R2Game_韩国——H5
		//
		public static const PF_77you:String = "you77";//七七游ios
		public static const PF_77you_ios_tw:String = "you77_ios_tw";//七七游_港澳台——ios
		public static const PF_77you_ios_jp:String = "you77_ios_jp";//七七游_日本——ios
		public static const PF_77you_ad_tw:String = "you77_ad_tw";//七七游_港澳台——安卓
		public static const PF_77you_ad_jp:String = "you77_ad_jp";//七七游_日本——安卓
		//
		public static const PF_6kw_ad:String = "ad_6kw"; // HG6kwan 安卓
		// public static const PF_panbao_ad:String = "ad_panbao"; // 盼宝 安卓
		// public static const PF_panbao_ios:String = "ios_panbao"; // 盼宝 iOS
		//
		// public static const PF_efun_google:String = "e_g";//efun谷歌
		// public static const PF_efun_one:String = "e_o";//efun ONE
		// public static const PF_efun_ios:String = "e_i";//efun IOS
		//
		/**平台标识 */
		/**replaceA*/
		public static var pf:String = ConfigApp.PF_test;//平台唯一
		/**replaceB*/
		public static var pf_channel:String = ""; // 平台渠道唯一
		/** ********************这里是重点,看这里*********************** */
		/**微信平台必须开启true */
		public static function releaseWeiXin():Boolean{
			return (pf == PF_WeiXin) || (pf == PF_wx_changxiang);//是否发布成微信
		}
		public static function releaseQQ():Boolean{
			return pf == PF_QQ; // 是否发布成QQ小游戏
		}
		/**服务器功能地址 */
		public static function get_HTTP_URL():String{
			return checkPf("http_url");
		}
		/**资源文件地址 */
		public static function get_ASSETS_BASE_URL():String{
			return checkPf("assets_base_url");
		}
		/**支付回调地址 */
		public static function get_PAY_CALLBACK_URL():String{
			return checkPf("pay_callback");
		}		
		/**资源版本控制文件访问地址 == 主index.html == 主.js 地址 */
		public static function get_ASSETS_VERSION_URL():String{
			return checkPf("assets_version_url");
		}	
		/**外部地址配置文件加载地址net_cfg.json */
		public static function get_NET_CFG_URL():String{
			return checkPf("net_cfg_url");
		}
		/**版权文字 */
		public static function get_Copyright():String{
			return checkPf("copyright");
		}	
		public static function get_area_check():String{
			return checkPf("area_check");
		}
		public static function get_data_report():String{
			return checkPf("data_report");
		}		
		/**
		 * 如果对应平台配置类[有]对应的配置,直接用 [http_url,assets_base_url,assets_version_url,net_cfg_url]
		 * 如果对应平台配置类[无]对应的配置,直接找 sNetCfg[sNetCfg == net_cfg_url外部文件] 里面的配置
		 * net_cfg_url必须配置在[对应平台配置类]里面
		 */
		public static function checkPf(type:String):String{
			var cl:*;
			if(pf == ConfigApp.PF_test){
				cl = HelpConfig.CC_test;
			}else if(pf.indexOf(ConfigApp.PF_r2game_kr)>-1) {
				cl = HelpConfig.CC_server_kr;
			}
			else if(pf.indexOf(ConfigApp.PF_77you)>-1){
				cl = HelpConfig.CC_server_jp;
			}
			else if(pf == ConfigApp.PF_ios_meng52_mj1){
				cl = HelpConfig.CC_server_mj1;
			}
			else if(pf == ConfigApp.PF_dev_local){
				cl = HelpConfig.CC_test_local;
			}
			else{
				cl = HelpConfig.CC_server;
			}
			if(cl){//代码配置
				if(type == "http_url" && myServerUrl && myServerUrl.length>0 && pf == ConfigApp.PF_test){
					return getURLType(getNetCfg(type,myServerUrl));//文件配置
				}
				if(cl.hasOwnProperty(type)){
					return getURLType(cl[type]);
				}
			}
			return getURLType(getNetCfg(type,(netCfgPfUrl && netCfgPfUrl.length>0)?netCfgPfUrl:ConfigApp.pf));//文件配置
		}
		/**
		 * 检查,net_cfg.json 配置里面的信息 net_cfg_url必须要有
		 */
		public static function getNetCfg(type:String,otherPf:String):String{
			if(ConfigApp.sNetCfg){
				if(ConfigApp.sNetCfg.hasOwnProperty(otherPf)){
					if(ConfigApp.sNetCfg[otherPf].hasOwnProperty(appVersion)){
						if(ConfigApp.sNetCfg[otherPf][appVersion].hasOwnProperty(type)){
							return ConfigApp.sNetCfg[otherPf][appVersion][type];
						}
					}
				}
			}
			return "";
		}
		public static function getURLType(str:String):String{
			return (ConfigApp.httpSSL  && ConfigApp.httpSSL == "yes" && str)?str.replace("http://","https://"):str;
		}
		/**
		 * 强更配置获取+判断
		 */
		public static function getNetCfgOther(pfs:String):Object{
			if(ConfigApp.sNetCfg){
				if(ConfigApp.sNetCfg.hasOwnProperty("force_update") && ConfigApp.sNetCfg["force_update"][pfs]){
					return ConfigApp.sNetCfg["force_update"][pfs];
				}
			}
			return null;
		}
		public static function setWH(w:Number,h:Number):void{
			width = w;
			height = h;
			//
			ratio = h/w;
			//
			if(ratio>=ratio_21){
				if(ConfigApp.releaseWeiXin() || ConfigApp.releaseQQ()){//如果是微信,并且是 ios系统,用特殊适配
					topVal = top;
				}
				else{
					topVal = 0;//top;
				}
			}
			else{
				topVal = 0;
			}
			//topVal = 63;
		}
		// 是否属于安卓
		public static function onAndroid():Boolean{
			var b:Boolean = false;
			if(
				ConfigApp.pf == ConfigApp.PF_and_1 || 
				ConfigApp.pf == ConfigApp.PF_and_jj_meng52 || 
				// ConfigApp.pf == ConfigApp.PF_and_2 || 
				ConfigApp.pf == ConfigApp.PF_and_google || 
				// ConfigApp.pf == ConfigApp.PF_and_demo || 
				// ConfigApp.pf == ConfigApp.PF_and_cn_gdzj || 
				ConfigApp.pf == ConfigApp.PF_huawei || 
				ConfigApp.pf == ConfigApp.PF_huawei_tw || 
				ConfigApp.onAndroidYYB() || 
				ConfigApp.pf == ConfigApp.PF_vivo || 
				// ConfigApp.pf == ConfigApp.PF_vivo_ad1 || 
				// ConfigApp.pf == ConfigApp.PF_vivo_ad2 || 
				ConfigApp.pf == ConfigApp.PF_oppo || 
				ConfigApp.pf == ConfigApp.PF_yx7477 || 
				ConfigApp.pf == ConfigApp.PF_yx7477_1 || 
				ConfigApp.pf == ConfigApp.PF_xiaomi || 
				ConfigApp.pf == ConfigApp.PF_uc || 
				ConfigApp.pf == ConfigApp.PF_meizu || 
				ConfigApp.pf == ConfigApp.PF_caohua ||
				ConfigApp.pf == ConfigApp.PF_JJ_caohua_ad || 
				// ConfigApp.pf == ConfigApp.PF_yqwb || 
				// ConfigApp.pf == ConfigApp.PF_hf || 
				// ConfigApp.pf == ConfigApp.PF_juedi_ad || 
				ConfigApp.pf == ConfigApp.PF_wende || 
				ConfigApp.pf == ConfigApp.PF_juedi ||
				ConfigApp.pf == ConfigApp.PF_r2game_xm_ad ||
				ConfigApp.pf == ConfigApp.PF_r2game_kr_ad ||
				ConfigApp.pf == ConfigApp.PF_r2game_kr_onestore ||
				ConfigApp.pf == ConfigApp.PF_77you_ad_jp ||
				ConfigApp.pf == ConfigApp.PF_77you_ad_tw ||
				ConfigApp.pf == ConfigApp.PF_360_ad ||
				ConfigApp.pf == ConfigApp.PF_6kw_ad 
				// ConfigApp.pf == ConfigApp.PF_panbao_ad
				// ConfigApp.pf == ConfigApp.PF_samsung ||
				// ConfigApp.pf == ConfigApp.PF_efun_google ||
				// ConfigApp.pf == ConfigApp.PF_efun_one
				
			){
				b = true;
			}
			return Browser.onAndroid && b;
		}
		// 是否属于安卓YYB平台
		public static function onAndroidYYB(vpf:String = ""):Boolean{
			var mpf:String = (vpf!="")?vpf:ConfigApp.pf;
			if(				
				mpf == ConfigApp.PF_yyb
				// mpf == ConfigApp.PF_gdt_1 ||
				// mpf == ConfigApp.PF_gdt_2 ||
				// mpf == ConfigApp.PF_gdt_3 ||
				// mpf == ConfigApp.PF_gdt_4 ||
				// mpf == ConfigApp.PF_gdt_5 ||
				// mpf == ConfigApp.PF_yyb2 || 
				// mpf == ConfigApp.PF_yyb_gdt ||
				// mpf == ConfigApp.PF_yyb_test
			){
				return true;
			}
			return false;
		}
		// 是否属于 IOS
		public static function onIOS():Boolean{
			var b:Boolean = false;
			if(
				ConfigApp.pf == ConfigApp.PF_ios_meng52 ||		
				ConfigApp.pf == ConfigApp.PF_ios_meng52_sh ||		
				ConfigApp.pf == ConfigApp.PF_ios_meng52_sgzb ||		
				ConfigApp.pf == ConfigApp.PF_ios_jj_cn ||		
				ConfigApp.pf == ConfigApp.PF_ios_meng52_mj1 ||		
				ConfigApp.pf == ConfigApp.PF_ios_meng52_mj2 ||		
				ConfigApp.pf == ConfigApp.PF_ios_meng52_hk ||
				// ConfigApp.pf == ConfigApp.PF_juedi_ios ||
				ConfigApp.pf == ConfigApp.PF_r2game_xm_ios ||
				ConfigApp.pf == ConfigApp.PF_r2game_kr_ios ||
				// ConfigApp.pf == ConfigApp.PF_panbao_ios ||
				ConfigApp.pf == ConfigApp.PF_77you_ios_tw ||
				ConfigApp.pf == ConfigApp.PF_77you_ios_jp ||
				ConfigApp.pf == ConfigApp.PF_ios_meng52_tw ||
				ConfigApp.pf == ConfigApp.PF_wende_ios ||
				ConfigApp.pf == ConfigApp.PF_ios_37 ||
				ConfigApp.pf == ConfigApp.PF_caohua_ios 
				// ConfigApp.pf == ConfigApp.PF_37_ios
			){
				b = true;
			}
			return Browser.onIOS && b;
		}
		// 是否属于IOS特殊底层
		public static function onIOSlayaWK():Boolean{
			var b:Boolean = false;
			// if(
			// 	false
			// ){
			// 	b = true;
			// }
			return b;
		}
		public static function lan():String{
			var lan:String = "";
			if(ConfigApp.pf == ConfigApp.PF_ios_meng52_tw || ConfigApp.pf == PF_and_google || ConfigApp.pf == ConfigApp.PF_huawei_tw){
				lan = "tw";
			}else if(ConfigApp.pf == ConfigApp.PF_r2game_kr 
				|| ConfigApp.pf == ConfigApp.PF_r2game_kr_ad 
				|| ConfigApp.pf == ConfigApp.PF_r2game_kr_onestore 
				|| ConfigApp.pf == ConfigApp.PF_r2game_kr_ios){
				lan = "kr";
			}
			else{
				lan = "cn";
			}
			var s:String = ConfigApp.mLanguage ? ConfigApp.mLanguage: "";
			if(s=="en"){
				lan = "en";
			}else if(s=="tw"){
				lan = "tw"
			}else if(s=="kr"){
				lan = "kr";
			}
			else if(s=="ja"){
				lan = "ja";
			}
			return lan;
		}

		public static function get isPC():Boolean{
			if (ConfigApp.mpc){
				return parseInt(ConfigApp.mpc)==1;
			}
			return false;
		}
		public static function get isOldCfg():Boolean{
			if(ConfigApp.oldcfg && ConfigApp.oldcfg=="yes"){
				return true;
			}
			return false;
		}
		// 是否启用自己的登录
		public static function useMyLogin():Boolean{
			if(ConfigApp.loginSelfForce){
				return true;
			}
			var b:Boolean = true;
			if(//有sdk的登录
				(Platform.h5_sdk && Platform.h5_sdk.haveLogin) ||
				pf == PF_37_h5 ||
				// pf == PF_9130_h5 ||
				pf == PF_kuku_h5 ||
				pf == PF_yyjh_h5 ||
				pf == PF_yyjh2_h5 ||
				pf == PF_JJ_yyjh_h5 ||
				pf == PF_caohua1_h5 ||
				pf == PF_caohua2_h5 ||
				releaseWeiXin() ||
				releaseQQ() ||
				// pf == PF_xh_h5 || 
				// pf == PF_wx_h5 || 
				// pf == PF_bugu_h5 || 
				pf == PF_huawei || 
				pf == PF_huawei_tw || 
				ConfigApp.onAndroidYYB() || 
				pf == PF_vivo || 
				// pf == PF_vivo_ad1 || 
				// pf == PF_vivo_ad2 || 
				pf == PF_oppo || 
				pf == PF_yx7477 || 
				pf == PF_yx7477_1 || 
				pf == PF_xiaomi || 
				pf == PF_uc || 
				pf == PF_meizu || 
				pf == PF_caohua || 
				pf == PF_JJ_caohua_ad || 
				pf == PF_caohua_ios || 
				// pf == PF_yqwb || 
				// pf == PF_hf || 
				pf == PF_juedi || 
				// pf == PF_juedi_ad || 
				pf == PF_wende || 
				// pf == PF_efun_google || 
				// pf == PF_efun_one || 
				pf == PF_and_google || 
				// pf == PF_juedi_ios ||
				pf == PF_ios_meng52_tw ||
				pf == PF_r2game_xm_ad ||
				pf == PF_r2game_kr_ad ||
				pf == PF_r2game_kr_onestore ||
				pf == PF_r2game_xm_ios ||
				pf == PF_r2game_kr_ios ||
				pf == PF_r2game_kr_h5 ||
				// pf == PF_panbao_ios ||
				pf == PF_77you_ios_tw ||
				pf == PF_77you_ios_jp ||
				pf == PF_77you_ad_tw ||
				pf == PF_77you_ad_jp ||
				// pf == PF_ios_meng52_mj1 ||
				// pf == PF_37_ios ||
				pf == PF_wende_ios ||
				pf == PF_ios_37 ||
				// pf == PF_samsung ||
				pf == PF_JJ_tanwan_h5 ||
				pf == PF_tanwan_h5 ||
				pf == PF_tanwan2_h5 ||
				pf == PF_tanwan3_h5 ||
				pf == PF_tanwan4_h5 ||
				// pf == PF_yuncai_h5 ||
				pf == PF_7k_h5 ||
				pf == PF_JJ_7k_h5 ||
				pf == PF_360_h5 ||
				pf == PF_360_2_h5 ||
				pf == PF_360_3_h5 ||
				pf == PF_360_ad ||
				pf == PF_6kw_ad ||
				// pf == PF_panbao_ad ||
				pf == PF_1377_h5 ||
				pf == PF_leyou_h5 ||
				pf == PF_JJ_leyou_h5 ||
				pf == PF_muzhi_h5 ||
				pf == PF_muzhi2_h5 ||
				pf == PF_hutao_h5 ||
				pf == PF_hutao2_h5 ||
				pf == PF_changxiang_h5 ||
				pf == PF_6kw_h5 ||
				pf == PF_changwan_h5 ||
				// pf == PF_panbao_h5 ||
				pf == PF_shouqu_h5 ||
				pf == PF_qqdt_h5
			){
				b = false;
			}
			return b;
		}
		public static function useSSL():Boolean{
			//外部配置影响//默认test或不使用s的地方
			if(wsSSL && wsSSL=="yes"){
				return true;
			}
			return false;
		}
		/**
		 * logo图片切换用
		 */
		public static function logoUI():String{
			if(ConfigApp.otherLogoPngImg){
				//外部配置影响
				return AssetsManager.getAssetsAD(ConfigApp.otherLogoPngImg+".png");
			}
			// return AssetsManager.getAssetsAD("logo1.png");
			return '';
		}
		/**
		 * 是否使用自己的支付系统
		 */
		public static function payIsSelf():Boolean{
			var b:Boolean = false;
			if(ConfigServer.system_simple.pay_self_pf && ConfigServer.system_simple.pay_self_pf.indexOf(ConfigApp.pf)>-1){
				var areaURL:String = ConfigApp.get_area_check();
				if(areaURL && areaURL!=""){
				// if(ConfigApp.pf == ConfigApp.PF_ios_meng52_mj1){//马甲+iap支付+不能随便切换+根据国家
					var isCN:Boolean = (ConfigApp.isChina && (ConfigApp.isChina == "1"));
					if(isCN){
						b = true;
					}
					else{
						b = false;
					}
				}
				else{
					b = true;
				}
			}
			//ios下增加判断条件
			// if(ConfigApp.onIOS() && b){
			// 	b = false;
			// 	if(ModelManager.instance.modelUser.getLv()>=ConfigServer.system_simple.pay_self_lv){
			// 		if(ModelManager.instance.modelUser.pay_ip_check){
			// 			b = true;
			// 		}
			// 	}
			// }
			return b;
		}
		// 自己的H5支付配置判断
		public static function payIsSelfH5():Boolean{
			var b:Boolean = false;
			if(ConfigServer.system_simple.pay_self_h5_pf && ConfigServer.system_simple.pay_self_h5_pf.indexOf(ConfigApp.pf)>-1){
				b = true;
			}
			return b;
		}
		//特殊pf下自动登录后进入游戏
		public static function atOnceLoginToEnter():Boolean{
			var b:Boolean = false;
			if(ConfigApp.pf == ConfigApp.PF_360_h5 
				|| ConfigApp.pf == ConfigApp.PF_360_2_h5
				|| ConfigApp.pf == ConfigApp.PF_360_3_h5
			){
				b = true;
			}
			return b;
		}

		/**
		 * 初始化H5 SDK
		 */
		public static function initH5sdk():void {
			switch(pf) {
				case PF_JJ_37_h5:
					Platform.h5_sdk = new H5JJ37(pf, Tools.getURLexpToObj(ConfigApp.url_params)) as H5sdk;
					break;
				case PF_wende_h5:
					Platform.h5_sdk = new H5SGWende(pf, Tools.getURLexpToObj(ConfigApp.url_params)) as H5sdk;
					break;
				case PF_7477_h5:
					Platform.h5_sdk = new H5SG7477(pf, Tools.getURLexpToObj(ConfigApp.url_params)) as H5sdk;
					break;
			}
		}
	}
}