package {

	import laya.renders.Render;
	import laya.utils.Stat;
	import laya.display.Stage;
	import sg.cfg.ConfigAssets;
	import laya.utils.Handler;
	import sg.manager.ViewManager;
	import sg.manager.ModelManager;
	import sg.net.NetSocket;
	import sg.cfg.ConfigClass;
	import laya.webgl.WebGL;
	import laya.utils.Browser;
	import laya.ui.Image;
	import sg.cfg.ConfigApp;
	import laya.utils.Log;
	import sg.utils.Tools;
	import laya.display.css.Font;
	import laya.html.dom.HTMLIframeElement;
	import laya.net.Loader;
	import laya.resource.ResourceManager;
	import sg.manager.AssetsManager;
	import laya.resource.Texture;
	import laya.net.ResourceVersion;
	import laya.events.Event;
	import laya.maths.MathUtil;
	import laya.net.URL;
	import laya.wx.mini.MiniAdpter;
	import laya.net.URL;
	import sg.view.loading.LoadingPanel;
	import sg.map.utils.TestUtils;
	import sg.manager.LoadeManager;
	import sg.utils.SaveLocal;
	import sg.net.NetHttp;
	import sg.net.NetMethodCfg;
	import laya.ui.View;
	import laya.qq.mini.QQMiniAdapter;
	import laya.ui.Label;
	public class LayaSample {
		private var mBg:Image;
		private var mLoadingView:*;
		private var initVersionCfg:Boolean = false;
		private var initLoadVersionCfg:Boolean = false;
		private var isPcRbig:Boolean = false;
		private var loadTxt:Label;
		public function LayaSample() {
			//微信开启
			if(ConfigApp.releaseWeiXin()){
				MiniAdpter.init();//微信开启
			} else if (ConfigApp.releaseQQ()) {
				QQMiniAdapter.init();
			}

			//微信开启
			Loader.maxTimeOut = 500;
			//
			ConfigApp.thisPackageType = Tools.getURLexp("ptype");//
			ConfigApp.wsSSL = Tools.getURLexp("mssl");//
			ConfigApp.netCfgPfUrl = Tools.getURLexp("ncpurl");//
			ConfigApp.changeZonePf = Tools.getURLexp("czpf");//
			ConfigApp.otherLogoPngImg = Tools.getURLexp("mlogo");//
			ConfigApp.indexLoadingImg = Tools.getURLexp("ilimg");//
			ConfigApp.pcbgImg = Tools.getURLexp("pcbg");//
			ConfigApp.pcLogoImg = Tools.getURLexp("pclogo");//
			ConfigApp.loginBgImg = Tools.getURLexp("lbimg");//
			ConfigApp.myServerUrl = Tools.getURLexp("msurl");//
			ConfigApp.myPackagePf = Tools.getURLexp("mppf");//
			ConfigApp.disloading = Tools.getURLexp("disloading");//
			ConfigApp.auser = Tools.getURLexp("auser");//
			ConfigApp.lclip1 = Tools.getURLexp("lclip1");//
			ConfigApp.lclip2 = Tools.getURLexp("lclip2");//
			ConfigApp.chmj = Tools.getURLexp("chmj");//
			ConfigApp.loadtxt = Tools.getURLexp("loadtxt");//
			ConfigApp.midfa = Tools.getURLexp("idfa");//
			ConfigApp.opudid = Tools.getURLexp("opudid");//
			ConfigApp.mdevice = Tools.getURLexp("device");//
			ConfigApp.cfgvers = Tools.getURLexp("cfgvers");//
			ConfigApp.mLanguage = Tools.getURLexp("mlan");
			ConfigApp.mpc = Tools.getURLexp('mpc');
			ConfigApp.plocal=Tools.getURLexp('plocal');
			ConfigApp.bagname=Tools.getURLexp('bagname');
			ConfigApp.oldcfg=Tools.getURLexp('oldcfg');
			ConfigApp.mVsdebug=Tools.getURLexp('vsdebug');
			ConfigApp.httpSSL=Tools.getURLexp('ussl');
			//
			if(ConfigApp.myPackagePf && ConfigApp.myPackagePf.length>0){
				ConfigApp.pf = ConfigApp.myPackagePf;
			}
			//
			ConfigApp.setWH(Browser.width,Browser.height);
			// 
			if(ConfigApp.isPC){
				// var pcr0:Number = 1920/1080;
				// var pcr1:Number = Browser.width/Browser.height;
				// trace(pcr1,pcr0,pcr1>pcr0);
				// this.isPcRbig = pcr1>pcr0;
				Laya.init(1920,1010,WebGL);
			}else{
				Laya.init(640,1138,WebGL);
			}
			if(ConfigApp.mVsdebug){
				Stat.show(0,0);
			}
			//安卓初始化
			ToJava.init(); 
			ToIOS.init();
			ConfigApp.initH5sdk(); // SDK初始化
			Platform.initMiniGame();
			// Trackingio.postReport(2);
			//
			Platform.phoneInfoOnCheck = Tools.isNullObj(SaveLocal.getValue(SaveLocal.KEY_USER));//
			//
			ViewManager.sLaya = this;	
			// 
			if(ConfigApp.lan()=="kr"){
				Font.defaultFamily = "SunBatang-Light";
			}
			if(ConfigApp.isPC){
				Font.defaultFamily = "Microsoft-Yahei";
				if(ConfigApp.pf == ConfigApp.PF_Y5_h5 || ConfigApp.pf == ConfigApp.PF_wakool_h5){
					Font.defaultFamily = "Noto Sans";
				}
			}
			
			//			
			this.checkVH();
			//
			this.init();
		}
		private function test1(callback:Handler):void{
			callback.runWith([1,2]);
		}
		public function checkVH():void{
			//
			Laya.stage.frameRate = Stage.FRAME_FAST;
			Laya.stage.bgColor = "#000000";
			Laya.stage.screenMode = ConfigApp.isPC ? Stage.SCREEN_HORIZONTAL : Stage.SCREEN_VERTICAL;
			//
			Laya.stage.alignH = Stage.ALIGN_CENTER;	
			Laya.stage.alignV = Stage.ALIGN_MIDDLE;		
			//
			if(ConfigApp.isPC){
				// if(this.isPcRbig){
					// if(Browser.height<960){
						Laya.stage.scaleMode = Stage.SCALE_SHOWALL;
					// }
					// else{
						// Laya.stage.scaleMode = Stage.SCALE_FIXED_WIDTH;
				// 	}
				// }
				// else{
				// 	Laya.stage.scaleMode = Stage.SCALE_SHOWALL;
				// }
			}
			else{
				if(ConfigApp.releaseWeiXin() || ConfigApp.releaseQQ()){//如果是微信,并且是 ios系统,用特殊适配
					Laya.stage.scaleMode = Stage.SCALE_FIXED_WIDTH;
				}
				else{
					if(ConfigApp.ratio>ConfigApp.ratio_base){
						// if(ConfigApp.releaseWeiXin()){//如果是微信,并且是 ios系统,用特殊适配
						// 	Laya.stage.scaleMode = Stage.SCALE_FIXED_WIDTH;
						// }
						// else{
							Laya.stage.scaleMode = Stage.SCALE_SHOWALL;////Stage.SCALE_FIXED_WIDTH;
						// }
					}
					else if(ConfigApp.ratio <= ConfigApp.ratio_base && ConfigApp.ratio>=ConfigApp.ratio_base2){
						Laya.stage.scaleMode = Stage.SCALE_FIXED_WIDTH;
					}
					else{
						Laya.stage.scaleMode = Stage.SCALE_SHOWALL;
					}
				}
			}
		}
		public function init():void{
			// var img:Image = new Image();
			// img.skin = "ad/actPay1_1.webp";
			// Laya.stage.addChild(img);
			// return;
			if(ConfigApp.releaseWeiXin() || ConfigApp.releaseQQ()){
				loadTxt = new Label();
				loadTxt.text = "游戏加载中,请稍等...";
				loadTxt.fontSize = 30;
				loadTxt.color = "#FFFFFF";
				loadTxt.centerX = 0;
				loadTxt.centerY = 0;
				loadTxt.align = "center";
				loadTxt.width = 640;
				Laya.stage.addChild(loadTxt);
			}
			this.initVersionCfg = false;
			this.initLoadVersionCfg = false;
			//
			ViewManager.sViewManager = null;
			ModelManager.instance.init();
			ViewManager.instance.init();
			// 
			ConfigApp.isFirstInstall = (SaveLocal.getValue(SaveLocal.KEY_USER)?false:true);
			//
			Platform.getPhoneID();			
			//外部文件配置,网络地址
			if(ConfigApp.cfgvers && ConfigApp.cfgvers!=""){
				this.initLoadVersion(null);
				return;
			}
			//
			Platform.checkGameStatus(100);
			//
			var url:String = ConfigApp.get_NET_CFG_URL();
			if(url){
				Laya.loader.on(Event.ERROR,this,this.error_net_cfg);
				LoadeManager.loadImg(ConfigApp.get_NET_CFG_URL()+"net_cfg.json?v="+(new Date().getTime()),Handler.create(this,this.initLoadVersion));
			}
			else{
				this.initLoadVersion(null);
			}
		}
		private function error_net_cfg():void
		{
			this.initLoadVersion(null);
		}
		private var idfa103:Boolean = false;
		private function initLoadVersion(reObj:*):void{
			Laya.loader.off(Event.ERROR,this,this.error_net_cfg);
			// 
			HtmlLoadClip.setLoadValue(1);
			//
			Platform.checkGameStatus(101);
			//
			ConfigApp.sNetCfg = reObj;
			// 
			if(!idfa103){
				idfa103 = true;
				Platform.checkGameStatus(103);
			}
			//这里需要判断 是否是微信
			ResourceVersion.type = ResourceVersion.FILENAME_VERSION;
			if(ConfigApp.cfgvers && ConfigApp.cfgvers!=""){
				//加载版本信息文件
				ResourceVersion.enable(ConfigApp.cfgvers+".json?v="+(new Date().getTime()), Handler.create(this, this.initVersion));
				return;
			}
			var url:String = ConfigApp.get_ASSETS_VERSION_URL();
			// if(url){
				//加载版本信息文件
				ResourceVersion.enable(ConfigApp.get_ASSETS_VERSION_URL()+"version.json?v="+(new Date().getTime()), Handler.create(this, this.initVersion));			
			// }
			// else{
			// 	this.initVersion();
			// }
		}
		private function initVersion():void{
			HtmlLoadClip.setLoadValue(2);
			// 
			var _this:* = this;
			if(this.initVersionCfg){
				return;
			}
			this.initVersionCfg = true;
			//
			Platform.checkGameStatus(102);
			//
			URL.basePath = ConfigApp.get_ASSETS_BASE_URL();
			// 
			// if(ConfigApp.releaseWeiXin()){
				//微信忽略清理资源
				// MiniFileMgr.ignoreList = ConfigAssets.checkWXignoreList();
			// }
			//
			Platform.initSDK();
			//
			// var YYB2_LOGIN:String = "yyb2_login";
			//
			// if(ConfigApp.pf == ConfigApp.PF_yyb2){
			// 	var yyb2_use_login:* = SaveLocal.getValue(YYB2_LOGIN);
			// 	if(yyb2_use_login){
			// 		//
			// 		ConfigApp.loginSelfForce = (yyb2_use_login==1);
			// 		this.initAssets();
			// 	}
			// 	else{
			// 		NetHttp.instance.send(NetMethodCfg.HTTP_USER_YYB2_LOGIN_TYPEY,{},Handler.create(_this,function(re:Object):void{
			// 			var type:Number = 0;
			// 			if(re && re.install_from && re.install_from == "yyb"){
			// 				type = 0;
			// 			}
			// 			else{
			// 				type = 1;
			// 			}
			// 			SaveLocal.save(YYB2_LOGIN,type);
			// 			ConfigApp.loginSelfForce = (type==1);
			// 			_this.initAssets();
			// 		}));
			// 	}
			// }
			// else{
				this.initAssets();
			// }
		}
		private function initAssets():void {
			var assets:Array = [];
			assets = assets.concat(ConfigAssets.AssetsInitLogin).concat(ConfigAssets.loadingMask).concat(ConfigAssets.AssetsCounry).concat(ConfigAssets.setLoadingAssets());//.concat(ConfigAssets.AssetsInit);
			LoadeManager.loadImg(assets,Handler.create(this,this.onComplete),Handler.create(this,this.onProgress));
		}
		private function onProgress(pro:Number):void{
			HtmlLoadClip.setLoadValue(3,pro);
		}
		private function onComplete(texture:Texture):void {	
			this.onInitAssetsEnd();
		}
		private function onInitAssetsEnd():void{
			var helpDict:Object = Laya.loader.getRes('ad/help.json');
			View.uiMap = Laya.loader.getRes('uiExportCfg.json');
			LoadingPanel.instance.x = 0;
			// 
			Tools.sMsgLocalDic = helpDict?helpDict.msg[ConfigApp.lan()]:{};
			//初始化加载界面
			if(ConfigApp.releaseWeiXin() || ConfigApp.releaseQQ()){
				if(loadTxt){
					loadTxt.removeSelf();
					loadTxt = null;
				}
			}
			ViewManager.instance.showView(ConfigClass.VIEW_LOAD,null,{type:0});
		}		
	}
}