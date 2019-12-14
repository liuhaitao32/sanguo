package laya.wx.mini {
	import laya.events.Event;
	import laya.events.EventDispatcher;
	import laya.media.Sound;
	import laya.media.SoundManager;
	import laya.net.Loader;
	import laya.net.URL;
	import laya.utils.Handler;
	import laya.utils.Utils;
	
	
	/** @private **/
	public class MiniLoader  extends EventDispatcher  {
		/**@private 加载文件列表**/
		private static var _fileTypeArr:Array = ['png', 'jpg', 'bmp', 'jpeg', 'gif'];
		
		public function MiniLoader() {
		}
		
		/**
		 * @private 
		 * @param url
		 * @param type
		 * @param cache
		 * @param group
		 * @param ignoreCache
		 */
		private function load(url:String, type:String = null, cache:Boolean = true, group:String = null, ignoreCache:Boolean = false):void {
			var thisLoader:* = this;
			thisLoader._url = url;
			if (url.indexOf("data:image") === 0) thisLoader._type = type = Loader.IMAGE;
			else {
				thisLoader._type = type || (type = thisLoader.getTypeFromUrl(url));
			}
			thisLoader._cache = cache;
			thisLoader._data = null;
			
			if (!ignoreCache && Loader.loadedMap[URL.formatURL(url)]) {
				thisLoader._data = Loader.loadedMap[URL.formatURL(url)];
				event(Event.PROGRESS, 1);
				event(Event.COMPLETE, thisLoader._data);
				return;
			}
			
			//如果自定义了解析器，则自己解析
			if (Loader.parserMap[type] != null) {
				thisLoader._customParse = true;
				if (Loader.parserMap[type] is Handler) Loader.parserMap[type].runWith(this);
				else Loader.parserMap[type].call(null, this);
				return;
			}
			var encoding:String = MiniAdpter.getUrlEncode(url,type);
			var urlType:String = Utils.getFileExtension(url);
			if ((_fileTypeArr.indexOf(urlType) != -1) || type == Loader.IMAGE) {
				//图片通过miniImage去加载
				MiniAdpter.EnvConfig.load.call(this, url, type, cache, group, ignoreCache);
			} else {
				//如果是子域,并且资源单独的图集列表文件里不存在当前路径的数据信息，这时需要针对url进行一次转义
				if(MiniAdpter.isZiYu && !MiniFileMgr.ziyuFileData[url])
				{
					url = URL.formatURL(url);
				}
				if(MiniAdpter.isZiYu && MiniFileMgr.ziyuFileData[url])
				{
					var tempData:Object = MiniFileMgr.ziyuFileData[url];
					thisLoader.onLoaded(tempData);
					return;
				}
				if (!MiniFileMgr.getFileInfo(url)) {
					if (MiniFileMgr.isLocalNativeFile(url)) {
						if (MiniAdpter.subNativeFiles && MiniAdpter.subNativeheads.length == 0)
						{
							for (var key:* in MiniAdpter.subNativeFiles)
							{
								var tempArr:Array = MiniAdpter.subNativeFiles[key];
								MiniAdpter.subNativeheads = MiniAdpter.subNativeheads.concat(tempArr);
								for (var aa:int = 0; aa < tempArr.length;aa++)
								{
									MiniAdpter.subMaps[tempArr[aa]] = key + "/" + tempArr[aa];
								}
							}
						}
						//判断当前的url是否为分包映射路径
						if(MiniAdpter.subNativeFiles && url.indexOf("/") != -1)
						{
							var curfileHead:String = url.split("/")[0]  +"/";//文件头
							if(curfileHead && MiniAdpter.subNativeheads.indexOf(curfileHead) != -1)
							{
								var newfileHead:String = MiniAdpter.subMaps[curfileHead];
								url = url.replace(curfileHead,newfileHead);
							}
						}
						
						//临时，因为微信不支持以下文件格式
						//直接读取本地，非网络加载缓存的资源
						if(type == Loader.SOUND)
						{
							thisLoader._loadSound(url);
						}else
						{
							MiniFileMgr.read(url,encoding,new Handler(MiniLoader, onReadNativeCallBack, [encoding, url, type, cache, group, ignoreCache, thisLoader]));
						}
						return;
					}
					var tempUrl:String = url;
					url = URL.formatURL(url);
					if (url.indexOf("http://") != -1 || url.indexOf("https://") != -1 && !MiniAdpter.AutoCacheDownFile) {
						if(type == Loader.SOUND)
						{
							//声音加载处理
							thisLoader._loadSound(url);
						}else
						{
							//远端文件加载走xmlhttprequest
							MiniAdpter.EnvConfig.load.call(thisLoader, tempUrl, type, cache, group, ignoreCache);
						}
					} else {
						//读取本地磁盘非写入的文件，只是检测文件是否需要本地读取还是外围加载
						fileObj = MiniFileMgr.getFileInfo(url);
						if(fileObj)
						{
							fileObj.encoding = fileObj.encoding == null ? "utf8" : fileObj.encoding;
							MiniFileMgr.readFile(fileObj.url, encoding, new Handler(MiniLoader, onReadNativeCallBack, [encoding, url, type, cache, group, ignoreCache, thisLoader]), url);
						} else if (thisLoader.type == "image" || thisLoader.type == "htmlimage")
						{
							MiniAdpter.EnvConfig.load.call(thisLoader, url, type, cache, group, ignoreCache);
						}
						else
						{
							url = URL.formatURL(url);
							if(type != Loader.IMAGE && ((url.indexOf("http://") == -1 && url.indexOf("https://") == -1) || MiniFileMgr.isLocalNativeFile(url)))
							{
								MiniFileMgr.readFile(url, encoding, new Handler(MiniLoader, onReadNativeCallBack, [encoding, url, type, cache, group, ignoreCache, thisLoader]), url);
							}else
							{
								MiniFileMgr.downFiles(url, encoding, new Handler(MiniLoader, onReadNativeCallBack, [encoding, url, type, cache, group, ignoreCache, thisLoader]), url,true);
							}
						}
					}
				} else {
					//读取本地磁盘非写入的文件，只是检测文件是否需要本地读取还是外围加载
					var fileObj:Object = MiniFileMgr.getFileInfo(url);
					fileObj.encoding = fileObj.encoding == null ? "utf8" : fileObj.encoding;
					//如果缓存的文件路径跟传入的路径相等，就直接读取本地缓存
					MiniFileMgr.readFile(url, fileObj.encoding, new Handler(MiniLoader, onReadNativeCallBack, [encoding, url, type, cache, group, ignoreCache, thisLoader]), url);
				}
			}
		}
		
		/**
		 * private
		 * @param url
		 **/ 
		public  function _loadSound(url:String):void
		{
			var thisLoader:Object = this;
			var fileNativeUrl:String;
			if (MiniFileMgr.isLocalNativeFile(url)) {
				var tempStr:Object = URL.rootPath != "" ? URL.rootPath : URL.basePath;
				var tempUrl:String = url;
				if(tempStr != "" && (url.indexOf("http://") != -1 || url.indexOf("https://") != -1))
					fileNativeUrl = url.split(tempStr)[1];//去掉http头
				if(!fileNativeUrl)
				{
					fileNativeUrl = tempUrl;
				}
				MiniLoader.onDownLoadCallBack(url,thisLoader,0);//直接创建声音实例
			}else
			{
				var tempurl:String = URL.formatURL(url);
				if (!MiniFileMgr.isLocalNativeFile(url) &&  (tempurl.indexOf("http://") == -1 && tempurl.indexOf("https://") == -1) || (tempurl.indexOf(MiniAdpter.window.wx.env.USER_DATA_PATH) != -1)) 
				{
					MiniLoader.onDownLoadCallBack(url,thisLoader, 0);
				}else
				{
					MiniFileMgr.downOtherFiles(encodeURI(tempurl), Handler.create(MiniLoader, MiniLoader.onDownLoadCallBack, [tempurl,thisLoader]), tempurl);
				}
			}
		}
		
		/**
		 * private
		 * @param sourceUrl
		 * @param errorCode
		 * @param tempFilePath
		 * 
		 **/
		private static function onDownLoadCallBack(sourceUrl:String,thisLoader:Object,errorCode:Number,tempFilePath:String = null):void
		{
			if (!errorCode)
			{
				var fileNativeUrl:String;
				if(MiniAdpter.autoCacheFile)
				{
					if(!tempFilePath){
						if (MiniFileMgr.isLocalNativeFile(sourceUrl)) {
							var tempStr:Object = URL.rootPath != "" ? URL.rootPath : URL.basePath;
							var tempUrl:String = sourceUrl;
							if(tempStr != "" && (sourceUrl.indexOf("http://") != -1 || sourceUrl.indexOf("https://") != -1))
								fileNativeUrl = sourceUrl.split(tempStr)[1];//去掉http头
							if(!fileNativeUrl)
							{
								fileNativeUrl = tempUrl;
							}
						}else
						{
							var fileObj:Object = MiniFileMgr.getFileInfo(sourceUrl);
							if(fileObj && fileObj.md5)
							{
								var fileMd5Name:String = fileObj.md5;
								fileNativeUrl = MiniFileMgr.getFileNativePath(fileMd5Name);
							}else
							{
								fileNativeUrl = sourceUrl;
							}
						}
					}else{
						fileNativeUrl = tempFilePath;
					}
				}
				sourceUrl = fileNativeUrl;
				//需要测试这个方式是否可行
				var sound: Sound = new SoundManager._soundClass();
				sound.load(encodeURI(sourceUrl));
				thisLoader.onLoaded(sound);
			}else
			{
					thisLoader.event(Event.ERROR,"Load sound failed");
			}
			}
					
		
		/**
		 * @private 
		 * @param url
		 * @param thisLoader
		 * @param errorCode
		 * @param data
		 *
		 */
		private static function onReadNativeCallBack(encoding:String, url:String, type:String = null, cache:Boolean = true, group:String = null, ignoreCache:Boolean = false, thisLoader:* = null, errorCode:int = 0, data:Object = null):void {
			if (!errorCode) {
				//文本文件读取本地存在
				var tempData:Object;
				if (type == Loader.JSON || type == Loader.ATLAS) {
					tempData = MiniAdpter.getJson(data.data);
				} else if (type == Loader.XML) {
					tempData = Utils.parseXMLFromString(data.data);
				} else {
					tempData = data.data;
				}
				//主域向子域派发数据
				if(!MiniAdpter.isZiYu &&MiniAdpter.isPosMsgYu && type  != Loader.BUFFER && MiniAdpter.window.wx)
				{
					MiniAdpter.window.wx.postMessage({url:url,data:tempData,isLoad:"filedata"});
				}
				thisLoader.onLoaded(tempData);
			} else if (errorCode == 1) {
				//远端文件加载走xmlhttprequest
				trace("-----------本地加载失败，尝试外网加载----url:" + url);
				MiniAdpter.EnvConfig.load.call(thisLoader, url, type, cache, group, ignoreCache);
			}
		}
	}
}