package sg.manager 
{
	import laya.events.EventDispatcher;
	import laya.ui.Image;
	import laya.utils.Browser;
	import laya.utils.Handler;
	// import laya.wx.mini.MiniFileMgr;

	import sg.utils.Tools;
	// import laya.net.URL;
	import sg.cfg.ConfigApp;
	/**
	 * ...
	 * @author jiaxuyang
	 */
	public class LoadeManager  extends EventDispatcher {
		private var complete:Handler = null;
		private var progress:Handler = null;
		
		public static const SHOW_PANEL:String = 'show_panel';
		public static const PROGRESS:String = 'progress';
		public static const REMOVE_SELF:String = 'remove_self';
		
		// 单例
		private static var sLoadeManager:LoadeManager = null;
		private static var tempDic:Array = [];
		private static var tempDic_hero_big:Object = {};
		public  static function get instance():LoadeManager{
			return sLoadeManager ||= new LoadeManager();
		}
		
		public function LoadeManager() 
		{
			this.progress = new Handler(this, this.onProgress);
		}
		
		/**
		 * 加载资源。
		 * @param	url			要加载的单个资源地址或资源信息数组。比如：简单数组：["a.png","b.png"]；复杂数组[{url:"a.png",type:Loader.IMAGE,size:100,priority:1},{url:"b.json",type:Loader.JSON,size:50,priority:1}]。
		 * @param	complete	加载结束回调。根据url类型不同分为2种情况：1. url为String类型，也就是单个资源地址，如果加载成功，则回调参数值为加载完成的资源，否则为null；2. url为数组类型，指定了一组要加载的资源，如果全部加载成功，则回调参数值为true，否则为false。
		 * @param	showLoadePanel	是否显示加载界面，默认不显示。
		 * @param	type		资源类型。比如：Loader.IMAGE。
		 * @param	cache		是否缓存加载结果。
		 * @param	group		分组，方便对资源进行管理。
		 * @param	ignoreCache	是否忽略缓存，强制重新加载。
		 */
		public static function load(url:*, complete:Handler = null, showLoadePanel:Boolean = false, type:String = null, cache:Boolean = true, group:String = null, ignoreCache:Boolean = false):void {
			var _this:LoadeManager = LoadeManager.instance;
			_this.complete = complete;
			complete = Handler.create(_this, _this.onComplete);
			loadImg(url, complete, _this.progress, type, 1, cache, group, ignoreCache);
			
			showLoadePanel && _this.showLoadPanel();
		}

		/**
		 * 加载资源（假的）
		 * @param	duration 持续时间（秒）
		 * @param	complete	加载结束回调。
		 */
		public static function fakeLoad(duration:Number, complete:Handler = null):void {
			var _this:LoadeManager = LoadeManager.instance;
			_this.complete = complete;
			complete = Handler.create(_this, _this.onComplete);

			var duration_int:int = Math.floor(1000 * duration);
			_this.showLoadPanel(duration_int);
			Laya.timer.once(duration_int, _this, _this.onComplete);
		}

		public static function loadImg(url:*, complete:Handler = null, progress:Handler = null, type:String = null, priority:int = 1, cache:Boolean = true, group:String = null, ignoreCache:Boolean = false):void{
			var catchB:Boolean = cache;
			var ignoreCacheB:Boolean = ignoreCache;
			if(ConfigApp.releaseWeiXin()){
				// var callers:* = complete?complete.caller:null;
				// var readyUrl:String = URL.formatURL(url);
				// MiniFileMgr.downOtherFiles(readyUrl,Handler.create(callers,function(wxurl:String,wxComplete:Handler = null):void{
				// 	// Laya.loader.load(wxurl, wxComplete);
				// 	Laya.loader.load(wxurl, wxComplete,progress,type,priority,catchB,group,ignoreCacheB);
				// },[url,complete]));

				// if((url is String) && !Tools.isNullString(url)){
				// 	if(url.indexOf(".json")>-1 || url.indexOf(".png")>-1 || url.indexOf(".jpg")>-1 || url.indexOf(".jpeg")>-1){
				// 		catchB = false;
				// 		ignoreCacheB = true;
				// 	}
				// }
			}
			Laya.loader.load(url, complete,progress,type,priority,catchB,group,ignoreCacheB);
		}
		/**
		 * 获取超512尺寸未打包的大图Image时使用, url参数需要预先处理（AssetsManager.getAssets...）
		 */
		public static function getLargeImage(url:*, img:Image = null):Image{
			if (!img)
				img = new Image();
			
			loadImg(url,Handler.create(LoadeManager.instance,function(curl:String,cimg:Image):void{
				if(cimg && !cimg.destroyed){
					cimg.skin = curl;
				}
			},[url,img]));
			return img;
		}
		public static function clearAll():void{
			Laya.loader.clearUnLoaded();
		}
		public static function clearRes(url:String, forceDispose:Boolean = false):void{
			Laya.loader.clearRes(url,forceDispose);
		}
		/**
		 * 调用超512尺寸未打包的大图时使用, url参数需要预先处理（AssetsManager.getAssets...）
		 */
		public static function loadTemp(loader:Image, url:*,func:Function = null):void
		{
			if(tempDic.indexOf(url)<0){
				tempDic.push(url);
			}
			loadImg(url,Handler.create(LoadeManager.instance,function(curl:String,cloader:Image):void{
				if(cloader && cloader.parent){
					cloader.skin = "";
					cloader.skin = curl;
					if(func){
						func();
					}
				}
			},[url,loader]));
		}
		public static function clearTemp():void
		{
			Trace.log("清理单独加载 ad 大图片",tempDic);
			var len:int = tempDic.length;
			for(var i:int = 0;i < len;i++){
				clearRes(tempDic[i],true);
			}
			Image.clearAllCache();
			//
			checkTempSize();
		}
		
		/**
		 * 清理所有英雄的大图中图
		 */
		public static function clearHeroIcon():void {			
			for (var name:String in tempDic_hero_big) {
				Laya.loader.clearTextureRes(name);
			}
			tempDic_hero_big = {};
		}
		
		public static function addTempHeroBigImg(url:*):void{			
			tempDic_hero_big[url] = 1;
		}
		public static function checkTempSize():Number{
			if(Browser.onMiniGame){
				// var sa:Number = MiniFileMgr.getCacheUseSize();
				// sa = sa/1024/1024;
				// trace("--微信缓存文件大小--",sa);
				// return sa;
			}
			return 0;
		}		
		
		/**
		 * 添加加载界面
		 */
		public function showLoadPanel(duration:Number = 0):void
		{
			this.event(LoadeManager.SHOW_PANEL, duration);			
		}

		/**
		 * 进度改变
		 * @param	precent
		 */
		public function onProgress(precent:Number):void {
			var p:Number = precent;
			// trace(p);
			this.event(LoadeManager.PROGRESS, p * 100);
		}
		
		/**
		 * 加载完成
		 */
		public function onComplete():void {
			this.event(LoadeManager.REMOVE_SELF);
			this.complete && this.complete.run();
		}
		//.png;.jpg;.txt;.json;.xml;.als;.atlas;.mp3;.ogg;.wav;.fnt
	}

}