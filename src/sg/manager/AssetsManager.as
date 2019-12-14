package sg.manager
{
	import laya.display.Animation;
	import laya.display.BitmapFont;
	import laya.display.Text;
	import laya.maths.MathUtil;
	import laya.net.Loader;
	import laya.utils.Handler;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigAssets;
	import sg.model.ModelItem;
	import sg.utils.SaveLocal;
	
	public class AssetsManager
	{
		public static const IMG_RES_UI:String = "ui/";
		public static const IMG_RES_COMP:String = "comp/";
		public static const IMG_RES_AD:String = "ad/";
		public static const IMG_RES_ICON:String = "icon/";
		public static const IMG_RES_HERO:String = "hero/";
		public static const IMG_RES_BUILD:String = "build/";
		public static const IMG_RES_ARMY:String = "army/";
		public static const IMG_RES_SCIENCE:String = "science/";
		public static const IMG_RES_FIGHT:String = "fight/";
		public static const IMG_RES_COUNTRY:String = "country/";
		public static const IMG_RES_LATER:String = "later/";
		//
		public static const IMG_GOLD:String = "img_icon_04.png";
		public static const IMG_FOOD:String = "img_icon_05.png";
		public static const IMG_WOOD:String = "img_icon_06.png";
		public static const IMG_IRON:String = "img_icon_07.png";
		public static const IMG_MERIT:String = "img_icon_08.png";
		public static const IMG_COIN:String = "img_icon_09.png";
		
		public static const FIGHT_FONT:String = "fightFont";
		public static const FIGHT_FONT_PATH:String = "bitmapFont/fightFont.fnt";
		
		public static const ATLAS_FOLDER:String = "res/atlas/clip/";
		public static const ANI_FOLDER:String = "clips/";
		public static const PARTICLE_FOLDER:String = "particle/";
		public static const SPINE_FOLDER:String = "spine/";
		
		public static const ATLAS_EXT:String = ".atlas";
		public static const ANI_EXT:String = ".ani";
		public static const PART_EXT:String = ".part";
		public static const SPINE_EXT:String = ".sk";
		public static const PNG_EXT:String = ".png";
		public static const JPG_EXT:String = ".jpg";
		
		public static const army_icon_building_ui:Array = ["home_20.png", "home_23.png", "home_21.png", "home_22.png"];
		public static const army_icon_building_ui2:Array = ["icon_paopao11.png", "icon_paopao13.png", "icon_paopao12.png", "icon_paopao14.png"];
		
		///记录动画素材的加载状况，使用较简洁的key，未加载无key，已开始加载指向资源地址，丢失素材时替换到默认资源地址
		public static var loadedAnimations:Object = {};
		public static var loadedParticles:Object = {};
		//
		public static var mHeroBigIconAssets:AssetsManager = new AssetsManager();
		public static var mHeroSmIconAssets:AssetsManager = new AssetsManager();
		public static var mArmyIconAssets:AssetsManager = new AssetsManager();
		public static var mBuildIconAssets:AssetsManager = new AssetsManager();
		public static function getVersionStr(url:String):String
		{
			return url;
		}
		//
		// private var img_url_dic:Object = {};//库存
		private var img_url_dic:Array = [];//库存
		private var storeMax:Number = 0;//存储缓存
		private var time_check:Number = 5000;//检测 间隔
		private var time_del:Number = 10000;//删除 间隔
		
		/**
		 * m = 存储上限
		 */
		public function checkAssetTempArr(url:String, m:Number):String
		{
			this.storeMax = m;
			//
			if(this.storeMax>0){
				//
				if(this.img_url_dic.indexOf(url)<0){
					this.img_url_dic.unshift(url);
				}
				var len:int = this.img_url_dic.length;
				if(len>this.storeMax){
					var curl:String = this.img_url_dic.pop();
					if(curl!=url){
						LoadeManager.clearRes(curl,true);
					}
				}
			}	
			return url;
		}
		public function clearAll():void
		{
			Trace.log("清理 big hero 大图片",this.img_url_dic);
			var len:int = this.img_url_dic.length;
			for(var i:int = 0;i < len;i++){
				Loader.clearRes(this.img_url_dic[i],true);
			}
			this.img_url_dic = [];
		}
		/**
		 * 清理临时单独加载大图片
		 */
		public static function clearTempAll():void{
			mHeroBigIconAssets.clearAll();
			LoadeManager.clearTemp();
		}
		public static function getAssetsHero(pathName:String, sm:Boolean):String
		{
			if (sm)
			{
				return mHeroSmIconAssets.checkAssetTempArr(getVersionStr(IMG_RES_HERO + pathName + "_m.png"),0);
			}
			return mHeroBigIconAssets.checkAssetTempArr(getVersionStr(IMG_RES_HERO + pathName + AssetsManager.PNG_EXT), 5);
		}
		public static function getAssetsCOMP(pathName:String):String
		{
			return getVersionStr(IMG_RES_COMP + pathName);
		}		
		public static function getAssetsUI(pathName:String):String
		{
			return getVersionStr(IMG_RES_UI + pathName);
		}
		public static function getAssetsCountry(pathName:String):String
		{
			return getVersionStr((ConfigApp.isPC ? "countryPC/":IMG_RES_COUNTRY) + pathName);
		}		
		public static function getAssetsAD(pathName:String):String
		{
			return getVersionStr(IMG_RES_AD + pathName);
		}		
		public static function getAssetsArmy(pathName:String):String
		{
			return mArmyIconAssets.checkAssetTempArr(getVersionStr(IMG_RES_ARMY + pathName + AssetsManager.PNG_EXT), 0);
		}
		public static function getAssetsFight(pathName:String, isPng:Boolean = true):String
		{
			return getVersionStr(IMG_RES_FIGHT + pathName + (isPng?AssetsManager.PNG_EXT:AssetsManager.JPG_EXT));
		}
		
		public static function getAssetsOther(png:String):String
		{
			return mBuildIconAssets.checkAssetTempArr(getVersionStr(IMG_RES_BUILD + png), 0);
		}
		public static function getAssetsScience(icon:String):String{
			return getVersionStr(IMG_RES_SCIENCE + icon);
		}
		public static function getAssetsICON(pathName:String, isUI:Boolean = false):String
		{
			if (isUI)
			{
				return getAssetsUI(pathName);
			}
			return getVersionStr(IMG_RES_ICON + pathName);
		}

		public static function getAssetLater(pathName:String):String{
			return getVersionStr(IMG_RES_LATER + pathName);
		}
		
		public static function getAssetItemOrPayByID(id:String):String
		{
			if (id == "")
				return "";
			var pathName:String = "img_icon_10.png";
			switch (id)
			{
			case "gold": 
				pathName = IMG_GOLD;
				break;
			case "food": 
				pathName = IMG_FOOD;
				break;
			case "wood": 
				pathName = IMG_WOOD;
				break;
			case "iron": 
				pathName = IMG_IRON;
				break;
			case "coin": 
				pathName = IMG_COIN;
				break;
			case "merit": 
				pathName = IMG_MERIT;
				break;
			default: 
				break;
			}
			if (id.indexOf("item") != -1)
			{
				return getAssetsICON(ModelItem.getItemIcon(id));
			}
			return getAssetsUI(pathName);
		}
		
		public static function getAssetPayIconBig(id:String):String
		{
			var s:String = "img_icon_04_big.png";
			switch (id)
			{
			case "coin": 
				s = "img_icon_09_big.png";
				break;
			case "gold": 
				s = "img_icon_04_big.png";
				break;
			case "food": 
				s = "img_icon_05_big.png";
				break;
			case "wood": 
				s = "img_icon_06_big.png";
				break;
			case "iron": 
				s = "img_icon_07_big.png";
				break;
			case "merit": 
				s = "img_icon_08_big.png";
				break;
			default: 
				break;
			}
			if (id.indexOf("item") != -1)
			{
				return getAssetsICON(ModelItem.getItemIcon(id));
			}
			return getAssetsUI(s);
		}
		
		public static function getUrlAtlas(pathName:String):String
		{
			return AssetsManager.ATLAS_FOLDER + pathName + AssetsManager.ATLAS_EXT;
		}
		
		public static function getUrlAnimation(pathName:String):String
		{
			return AssetsManager.ANI_FOLDER + pathName + AssetsManager.ANI_EXT;
		}
		
		public static function getUrlParticle(pathName:String):String
		{
			return AssetsManager.PARTICLE_FOLDER + pathName + AssetsManager.PART_EXT;
		}
		
		public static function getUrlSkeleton(pathName:String):String {
			return AssetsManager.SPINE_FOLDER + pathName + '/skeleton' + AssetsManager.SPINE_EXT;
		}
		
		/**
		 * 格式化资源数组，忽略已经调用过加载的内容（方便调用加载） type 类型0位图 1动画 2粒子
		 */
		public static function formatAssets(arr:Array, type:int, assets:Array = null):Array
		{
			if (assets == null)
			{
				assets = [];
			}
			var i:int;
			var len:int = arr.length;
			var key:String;
			for (i = 0; i < len; i++)
			{
				key = arr[i];
				if (type == 0)
				{
					assets.push({url: key, type: Loader.IMAGE});
				}
				else if (type == 1)
				{
					if (AssetsManager.loadedAnimations.hasOwnProperty(key))
					{
						continue;
					}
					else
					{
						AssetsManager.loadedAnimations[key] = key;
					}
					assets = AssetsManager.getAnimationAssets(key, assets);
				}
				else if (type == 2)
				{
					if (AssetsManager.loadedParticles.hasOwnProperty(key))
					{
						continue;
					}
					else
					{
						AssetsManager.loadedParticles[key] = key;
					}
					assets = AssetsManager.getParticleAssets(key, assets);
				}
			}
			return assets;
		}
		
		/**
		 * 得到动画名对应的资源加载数组
		 */
		public static function getAnimationAssets(pathName:String, assets:Array = null):Array
		{
			if (assets == null)
			{
				assets = [];
			}
			if (!ConfigAssets.noAtlasAnimations[pathName]){
				assets.push({url: AssetsManager.getUrlAtlas(pathName), type: Loader.ATLAS});
			}
			assets.push({url: AssetsManager.getUrlAnimation(pathName), type: Loader.JSON});
			return assets;
		}
		
		/**
		 * 得到粒子名对应的资源加载数组
		 */
		public static function getParticleAssets(pathName:String, assets:Array = null):Array
		{
			if (assets == null)
			{
				assets = [];
			}
			assets.push({url: AssetsManager.getUrlParticle(pathName), type: Loader.JSON});
			return assets;
		}
		
		/**
		 * 预加载若干资源，完成后调用方法
		 * @param	imgArr  位图资源列表
		 * @param	aniArr  动画资源列表
		 * @param	partArr  粒子资源列表
		 * @param	caller
		 * @param	onCompletefun
		 */
		public static function preLoadAssets(imgArr:Array, aniArr:Array, partArr:Array, caller:* = null, onCompletefun:Function = null, args:Array = null):void
		{
			var assets:Array = [];
			if (imgArr != null)
			{
				AssetsManager.formatAssets(imgArr, 0, assets);
			}
			if (aniArr != null)
			{
				AssetsManager.formatAssets(aniArr, 1, assets);
			}
			if (partArr != null)
			{
				AssetsManager.formatAssets(partArr, 2, assets);
			}
			
			if (assets.length > 0)
			{	
				LoadeManager.loadImg(assets, Handler.create(null, function():void
				{
					AssetsManager.createAnimationMap(aniArr);
					if (onCompletefun)
					{
						onCompletefun.apply(caller, args);
					}
				}));
			}
			else if (onCompletefun)
			{
				onCompletefun.apply(caller, args);
			}
		}
		
		/**
		 * 预加载动画资源后，主动创建动画模板
		 */
		public static function createAnimationMap(aniArr:Array):void
		{
			var ani:Animation;
			for (var i:int = aniArr.length - 1; i >= 0; i--)
			{
				var pathName:String = aniArr[i];
				//该资源未经替代，初始化
				if (pathName == AssetsManager.loadedAnimations[pathName])
				{
					var url:String = AssetsManager.getUrlAnimation(pathName);
					if (!Animation.framesMap[url + "#"])
					{
						if (ani == null)
						{
							ani = new Animation();
						}
						ani.loadAnimation(url);
					}
				}
			}
		}
		
		/**
		 * 预加载开始画面(欢迎屏幕)动画组
		 */
		public static function preloadWelcomeScreen(caller:* = null, onCompletefun:Function = null, args:Array = null):void
		{
			AssetsManager.preLoadAssets(ConfigAssets.WelcomeScreenImg, ConfigAssets.WelcomeScreenAni, null, caller, onCompletefun, args);
		}
		
		/**
		 * 释放开始画面(欢迎屏幕)相应素材,  暂未实现
		 */
		public static function unloadWelcomeScreen():void
		{
		
		}
		
		private static var m_caller:*;
		private static var m_method:Function;
		private static var m_args:Array;
		private static var m_nextArr:Array;
		private static var m_bitmapFont:BitmapFont;
		
		/**
		 * 特殊加载字体和动画
		 */
		public static function loadOthers(caller:*, method:Function, args:Array = null):void
		{
			AssetsManager.m_caller = caller;
			AssetsManager.m_method = method;
			AssetsManager.m_args = args;
			AssetsManager.m_nextArr = [AssetsManager.loadFonts, AssetsManager.initFonts, AssetsManager.loadAnimations];
			AssetsManager.nextLoad();
		}
		
		private static function nextLoad():void
		{
			if (AssetsManager.m_nextArr.length > 0)
			{
				var func:Function = AssetsManager.m_nextArr.shift();
				func();
			}else{
				AssetsManager.m_method.apply(AssetsManager.m_caller, AssetsManager.m_args);
			}
		}
		
		/**
		 * 初始化，加载位图字体
		 */
		private static function loadFonts():void
		{
			AssetsManager.m_bitmapFont = new BitmapFont();
			AssetsManager.m_bitmapFont.loadFont(AssetsManager.FIGHT_FONT_PATH, Handler.create(null, AssetsManager.nextLoad));
		}
		
		private static function initFonts():void
		{
			AssetsManager.m_bitmapFont.setSpaceWidth(40);
			Text.registerBitmapFont(AssetsManager.FIGHT_FONT, AssetsManager.m_bitmapFont);
			AssetsManager.nextLoad();
		}
		
		private static function loadAnimations():void
		{
			AssetsManager.preLoadAssets(null, ConfigAssets.InitAniArray, null, null, AssetsManager.nextLoad);
		}
		
		/**
		 * 分析加载错误后的路径，返回原始最简name（如果扩展名为atlas忽略）
		 */
		public static function getErrorSrcName(errUrl:String):String
		{
			var arr:Array = errUrl.split(".");
			var ext:String = arr[1];
			if (ext == "atlas")
			{
				return null;
			}
			
			var srcPath:String = arr[0];
			var srcArr:Array = srcPath.split("/");
			var srcName:String = srcArr[srcArr.length - 1];
			return srcName;
		}
	}
}