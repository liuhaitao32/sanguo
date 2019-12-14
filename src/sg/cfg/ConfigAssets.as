package sg.cfg
{
	import laya.net.ResourceVersion;
	import sg.manager.AssetsManager;

	/**
	 * ...
	 * @author
	 */
	public class ConfigAssets{

		public static var AssetsInitLogin:Array = [
			"uiExportCfg.json",
			"ad/help.json",
			"res/atlas/comp.atlas"
		]
		public static function get AssetsInit():Array {
			var result:Array = ConfigServer.system_simple.AssetsInit ||
								[
								"ad/lc_name.txt",
								"ad/lc_0.txt",
								"map/map.json",
								"home/home.json",			
								"map/mapData.json",				
								"outline/outline.json",			
								"res/atlas/comp.atlas",
								"res/atlas/ui.atlas",
								"res/atlas/face.atlas",
								//"res/atlas/science.atlas",
								//"res/atlas/icon.atlas",
								"res/atlas/clip/globle.atlas",
								// "res/atlas/country.atlas",
								"res/atlas/fight.atlas",
								"map/ground.png",
								"map/ground2.png",
								"map/road.png",
								"map/forest.png",
								"map/mountain.png",
								"map/mountain2.png",
								"map/surface.png",
								"home/bg1.jpg",
								"home/bg2.jpg",
								"home/bg3.jpg",
								"home/bg4.jpg",
								"outline/bg.jpg",
								"res/atlas/map2.atlas",
								//"testMap.json"
							];
							
			if(ConfigApp.pf == ConfigApp.PF_360_3_h5){
				result = [ConfigAssets.AssetsInitWord[1]].concat(result);
			}else if(ConfigApp.pf == ConfigApp.PF_360_2_h5){
				result = [ConfigAssets.AssetsInitWord[2]].concat(result);
			}else{
				result = [ConfigAssets.AssetsInitWord[0]].concat(result);
			}
			return result;
		}

		/**屏蔽字库 */
		public static var AssetsInitWord:Array = ["ad/lc_37.txt","ad/lc_iwy.txt","ad/lc_4399.txt"];
		public static var AssetsCounry:Array = [
			// "res/atlas/country.atlas"
		];
		public static function checkWXignoreList():Array{
			var arr:Array = [
				"res/atlas/comp.png",
				"res/atlas/ui.png",//4.8+2.9
				"res/atlas/ui1.png",//
				"res/atlas/icon.png",//5.8+1.8
				"res/atlas/icon1.png"//5.8+1.8
			];
			var re:Array = [];
			if(ResourceVersion.manifest){
				var len:int = arr.length;
				for(var i:int = 0; i < len; i++)
				{
					if(ResourceVersion.manifest[arr[i]]){
						re.push(ResourceVersion.manifest[arr[i]]);
					}
				}
			}
			return re;
		}
		/**
		 * 初次加载loading过程的显示图
		 * @return 
		 */
		public static function setLoadingAssets():Array{
			if(ConfigApp.indexLoadingImg){
				return [AssetsManager.getAssetsAD(ConfigApp.indexLoadingImg+".jpg")]
			}
			else{
				return [AssetsManager.getAssetsAD("bg_loading1.jpg")];
			}
		}
		///不需要贴图集 的动画，可忽略
		public static var noAtlasAnimations:Object = {};
		///欢迎屏幕画面动画，需要单独加载的几张大图，进入游戏后可以释放
		public static const loadingMask:Array = [
			//"ad/logo2.png",
			//"ad/logoblack2.png",
			"res/atlas/clip/loadingPanel.atlas"
		];
		public static const WelcomeScreenImg:Array = [
		    //"clip/glow500/glowwww.jpg",
			//"clip/glow501/01qian.png",
			//"clip/glow501/02qian.png",
			//"clip/glow501/03qian.png",
			//"clip/glow501/04qian.png"
			//"clip/glow502/logoblack.png",
			//"clip/glow502/logo.png"
		];		
		public static const WelcomeScreenAni:Array = [];//, "glow500"，"glow510", "glow502"
		public static const InitAniArray:Array = [
			DefaultHeroAniName,
			WorldWinAniName,
			WorldLoseAniName,
			WorldStartAniName,
			'glow503',
			'glow011',
		];
		
		public static const DefaultHeroAniName:String = "hero_01s";
		public static const WorldWinAniName:String = "world_win";
		public static const WorldLoseAniName:String = "world_lose";
		public static const WorldStartAniName:String = "world_start";
		
		///按前缀自动替换的动画资源，默认需要加载
		//public static const DEFAULT_ANIMATIONS:Object = {
			//'arm':"army00", 
			//'arm':"hero_01", 
			//"bullet102", 
			//"hit102", 
			//"bang238",
			//"fire225",
			//"stick216", 
			//"special222", 
			//"buff216"
			//
		//};
		
			////地图相关的
			//"res/atlas/eidtTest.atlas",
			//"edit.txt", 
			//"res/bg.jpg", 
			//"config.json", 
	}

}