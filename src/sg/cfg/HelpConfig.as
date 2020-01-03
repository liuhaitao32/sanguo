package sg.cfg {
	
	/**
	 * ...
	 * @author Thor
	 */
    public class HelpConfig {
		public static const TYPE_SG:String = "type_sg";
		public static const TYPE_WW:String = "type_ww";

		public static const type_app:String = TYPE_SG; // 项目类型

		public static const CC_test:Object = { // 本地开发测试用
			http_url: 'http://192.168.1.116:8888/gateway/',
			// http_url: 'http://sg3sh.ptkill.com/gateway/', // 简体审核
			// http_url: 'http://qh.ptkill.com/gateway/',
			//  area_check:"http://gw.niuwank.com/ccc/"
			//http_url: 'http://res-kol.r2game.com/gateway/'
			// http_url: 'http://sg3.ptkill.com/gateway/',
			// http_url: 'http://hk.ptkill.com/gateway/',
			// http_url:'http://52.78.62.195/gateway/'
			// assets_base_url:"http://d25tqlozljq1fr.cloudfront.net/static/h5/tw_hk/",
			// assets_version_url:"http://d25tqlozljq1fr.cloudfront.net/static/h5/tw_hk/"
			// net_cfg_url:"http://sg.ptkill.com/static/h5/"
			"copyright":"抵制不良游戏,拒绝盗版游戏。注意自我保护,谨防受骗上当。\n适度游戏益脑,沉迷游戏伤身。合理安排时间,享受健康生活。\n备案号：文网游备字〔2016〕M-RPG 1486,软著登字第0670060号,出版单位：江苏凤凰电子音像出版有限公司,批准文号：新广出审[2014]1242号,出版物号：ISBN 978-7-89400-204-4",
			'des':"测试配置"
		};
		public static const CC_test_local:Object = { // 本地开发测试手机版本配置
			http_url: 'http://192.168.1.116:8888/gateway/',
			//  area_check:"http://gw.niuwank.com/ccc/"
			//http_url: 'http://res-kol.r2game.com/gateway/'
			// http_url: 'http://sg3.ptkill.com/gateway/'
			// http_url: 'http://hk.ptkill.com/gateway/',
			// http_url:'http://52.78.62.195/gateway/'
			assets_base_url:"http://192.168.1.66/release/test/",
			assets_version_url:"http://192.168.1.66/release/test/",
			// net_cfg_url:"http://sg.ptkill.com/static/h5/"
			'des':"测试配置"
		};
		public static const CC_server:Object = {
			// http_url: 'http://192.168.1.128:8888/gateway/',		//龚子敬的服务器
			// http_url: 'http://192.168.1.116:8888/gateway/',
			// http_url: 'http://sg3.ptkill.com/gateway/',
			// http_url: 'http://hk.ptkill.com/gateway/',
			// assets_base_url:"http://192.168.1.66/bin/h5/",
			// assets_version_url:"http://d25tqlozljq1fr.cloudfront.net/static/h5/tw_hk/"
			net_cfg_url:"http://sg.ptkill.com/static/h5/",
			// http_url:'http://52.78.62.195/gateway/'
			'des':"标准配置"
		};
		public static const CC_server_kr:Object = {
			// http_url: 'http://192.168.1.116:8888/gateway/',
			net_cfg_url:"http://res-kol.r2game.com/static/h5/",
			// http_url: 'http://res-kol.r2game.com/gateway/'
			'des':"标准配置-韩国"
		}
		public static const CC_server_jp:Object = {
			// http_url: 'http://192.168.1.116:8888/gateway/',
			net_cfg_url:"http://d1l35hvbbwyxur.cloudfront.net/static/h5/",
			// http_url: 'http://res-kol.r2game.com/gateway/'
			'des':"标准配置-日本"
		}
		public static const CC_server_mj1:Object = {
			net_cfg_url:"http://cdn.niuwank.com/static/h5/",
			// http_url: 'http://res-kol.r2game.com/gateway/'
			'des':"标准配置-mj1"
		}
    }
}
	//area_check:""
	// CC_test
	// public static var http_url:String = "http://192.168.1.116:8888/gateway/";
	// public static var http_url:String = "http://v1.laohuk.com:8001/gateway/";
	// public static var http_url:String = "http://52.78.62.195/gateway/";韩国
	//v1.laohuk.com
	// public static var http_url:String = "http://v1.laohuk.com/gateway/";
	// public static var assets_base_url:String = "http://hk.ptkill.com/static/h5/tw_hk/";
	// public static var assets_version_url:String = "http://hk.ptkill.com/static/h5/tw_hk/";
	// public static var http_url:String = "http://sg2.ptkill.com/gateway/";
	// public static var http_url:String = "http://sg3.ptkill.com/gateway/";
	// public static var http_url:String = "http://hk.ptkill.com/gateway/"; 
	// public static var assets_base_url:String = "http://sg.ptkill.com/static/h5/djcy/";
	// public static var assets_version_url:String = "http://sg.ptkill.com/static/h5/djcy/";
	// public static var net_cfg_url:String = "http://sg.ptkill.com/static/h5/";
	// public static var net_cfg_url:String = "http://192.168.1.66/release/web66/"
	// public static var copyright:String = "抵制不良游戏,拒绝盗版游戏。注意自我保护,谨防受骗上当。\n适度游戏益脑,沉迷游戏伤身。合理安排时间,享受健康生活。\n备案号：京网游备字〔2016〕M-RPG 1486,游戏著作权人：北京萌我爱网络技术有限公司,出版单位：江苏凤凰电子音像出版有限公司,批准文号：新广出审[2014]1242号,出版物号：ISBN 978-7-89400-204-4";	

	//"https://sg.ptkill.com/static/h5/review/"
	//d25tqlozljq1fr.cloudfront.net
	
	// CC_server
	// public static var http_url:String = "http://192.168.1.116:8888/gateway/";
	// public static var http_url:String = "http://sg2.ptkill.com/gateway/";
	// public static var http_url:String = "http://sg3.ptkill.com/gateway/";
	// public static var http_url:String = "http://hk.ptkill.com/gateway/";
	// public static var http_url:String = "http://v1.laohuk.com:8001/gateway/";
	// public static var assets_base_url:String = "http://hk.ptkill.com/static/h5/tw_hk/";
	// public static var assets_version_url:String = "http://hk.ptkill.com/static/h5/tw_hk/";
	// public static var net_cfg_url:String = "http://sg.ptkill.com/static/h5/";
	// public static var net_cfg_url:String = "http://v1.laohuk.com/static/h5/";
	// public static var net_cfg_url:String = "http://192.168.1.32:8900/release/web/";
	// public static var copyright:String = "抵制不良游戏,拒绝盗版游戏。注意自我保护,谨防受骗上当。\n适度游戏益脑,沉迷游戏伤身。合理安排时间,享受健康生活。\n备案号：京网游备字〔2016〕M-RPG 1486 号,游戏著作权人：北京通广互动网络技术有限公司,出版单位：江苏凤凰电子音像出版有限公司,批准文号：新广出审[2016]3726号,出版物号：ISBN 978-7-89988-852-5";