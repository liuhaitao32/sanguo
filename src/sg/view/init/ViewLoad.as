package sg.view.init
{
	import laya.ui.Image;
	import sg.fight.FightMain;
	import sg.fight.test.TestCopyright;
	import sg.fight.test.TestCopyrightData;
	import sg.fight.test.TestFightData;
	import sg.manager.AssetsManager;
	import sg.map.model.MapModel;
	import sg.utils.MusicManager;
	import ui.init.viewLoadUI;
	import sg.cfg.ConfigAssets;
	import laya.utils.Handler;
	import laya.events.Event;
	import laya.resource.Texture;
	import sg.manager.ViewManager;
	import sg.net.NetHttp;
	import sg.net.NetMethodCfg;
	import sg.cfg.ConfigServer;
	import sg.utils.SaveLocal;
	import sg.cfg.ConfigApp;
	import sg.manager.ModelManager;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.utils.FunQueue;
	import laya.ui.ComboBox;
	import sg.cfg.ConfigClass;
	import laya.utils.Browser;
	import sg.utils.Tools;
	import sg.manager.EffectManager;
	import laya.display.Sprite;
	import sg.model.ModelGame;
	import laya.utils.Tween;
	import sg.model.ModelPlayer;
	import sg.model.ModelUser;
	import sg.manager.LoadeManager;
	import laya.display.Animation;
	import sg.manager.FilterManager;
	import sg.model.ModelPf;
	import laya.maths.MathUtil;
	import sg.utils.ThirdRecording;
	import sg.activities.model.ModelPhone;
	import laya.display.Node;
	import laya.maths.Rectangle;
	import laya.particle.Particle2D;
	import sg.utils.ObjectUtil;
	import sg.activities.model.ModelCostly;
	import sg.map.utils.TestUtils;
	import sg.cfg.HelpConfig;

	/**
	 * 自定义加载,登录,服务器获取配置,登陆http,登陆socket
	 * @author
	 */
	public class ViewLoad extends viewLoadUI{
		
		//初始进度 10%
		private var FAKE_PROGRESS:Number = 0.1;

		//配置加载完 进度到达50%
		private var CONFIG_PROGRESS:Number = 0.5;
		
		///资源额外加载进度
		private var extraProgress:Number = 0;
		///上次已加载进度
		private var mLastProgress:Number = 0;
		///当前已加载进度
		private var mProgress:Number = 0;
		///当前更新进度
		private var mUpdateProgress:Number = 0;
		///当前已加载完成
		private var isComplete:Boolean = false;
		///开始加载的时间
		private var mStartTime:Number = 0;
		///进度条动画
		private var progressAni:Animation;
		///进度条扫光
		private var progressImg:Image;
		///是否已经播放过鸽子动画
		private var mHasPlayBgClip:Boolean = false;
		
		
		private var mFunQueue:FunQueue;
		private var isAssets:Boolean = false;
		private var isServerCfg:Boolean = false;
		private var loginPa:Object;
		private var loginPaOtherPf:Object;
		private var mBgClip:Sprite;
		private var mBgImg:Image;
		private var httpStatus:Number = -1;
		private var isCheckLoginHttp:Boolean = false;
		private var loginStatus:Number;
		private var checkGameStatusIndex:Number = 0;
		private var isClickedLoginBtn:Boolean = false;
		private var isEnterGameUser:Boolean = false;
		private var mProwidth:Number = 0;
		//
		private var txtArr:Array = [];
		private var txtIndex:Number = 0;
		private var txtArrEd:Array;//已播过的索引列表
		private var txtStop:Boolean = false;
		private var config_error_times:Number = 0;
		private var gameReadyLogin:Boolean = false;
		private var new_version:Number = 0; // 游戏版本
		private var update_duration:Number = 0; // 更新需要的时间
		private var update_tips:String = ''; // 更新提示
		private var mPcLogo:Image;
		public function ViewLoad(){
			//
			// SaveLocal.clearAll();
			//
			this.test_clip_vis = false;
			//
			this.checkGameStatusIndex = 0;
			this.btn_affiche.visible = false; // 默认不显示公告按钮
			this.btn_server.on(Event.CLICK,this,this.click_server);
			this.btn_register.on(Event.CLICK,this,this.click_register);
			this.btn_tel.on(Event.CLICK,this,this.click_tel);
			//
			this.yybOut.on(Event.CLICK,this,this.click_logout);
			this.btnQQ.on(Event.CLICK,this,this.click_yyb,[1]);
			this.btnWX.on(Event.CLICK,this,this.click_yyb,[2]);
			this.btnFB.on(Event.CLICK,this,this.click_yyb,[3]);
			this.btnGG.on(Event.CLICK,this,this.click_yyb,[4]);
			this.btnReserve.on(Event.CLICK,this,this.click_yyb,[5]);
			this.twFB.on(Event.CLICK,this,this.click_yyb,[3]);
			this.twReserve.on(Event.CLICK,this,this.click_yyb,[5]);
			this.btn_clear1.on(Event.CLICK,this,function():void{
				SaveLocal.clearAll();
			});
			//
			ModelManager.instance.modelGame.on(ModelGame.EVENT_SERVER_SELECT_CHANGE, this, this.event_server_select_change);
			this.xuanqu.text = Tools.getMsgById("ViewLoad_1");

			if(this.img0) this.img0.visible = ConfigApp.isPC;
			if(this.img1) this.img1.visible = ConfigApp.isPC;
			// if(this.imgLogo) this.imgLogo.visible = ConfigApp.isPC && ConfigApp.pf != ConfigApp.PF_37_h5;

			mProwidth = this.proWidth.width;
			this.progressBox.width = 640;
			this.imgProgressBar.width = mProwidth;
			if(HelpConfig.type_app == HelpConfig.TYPE_SG){
				this.txtShow.color = '#eebb77';
				this.txtShow.strokeColor = '#332211';
				this.txtShow.stroke = 2;
			}
		}
		private function click_register():void
		{
			ViewManager.instance.showView(ConfigClass.VIEW_LOGIN,1);
		}
		private function click_affiche():void
		{
			ViewManager.instance.showView(ConfigClass.VIEW_AFFICHE);
		}
		private function click_tel():void{
			//
			ViewManager.instance.showView(ConfigClass.VIEW_PHONE,1);
		}

		private function event_server_select_change(id:String):void
		{
			ModelPlayer.recommendServer = id;
			//
			var s:String = ConfigServer.zone[ModelPlayer.recommendServer] ? ConfigServer.zone[ModelPlayer.recommendServer][0]+ConfigServer.checkServerIsMadeTxt(ModelPlayer.recommendServer) : id+"区没了";
			this.tZone.text = s;
		}
		private function click_server():void
		{
			ViewManager.instance.showView(ConfigClass.VIEW_SERVER_LIST);
		}
		override public function onRemoved():void{
			NetHttp.instance.off(NetHttp.EVENT_NET_ERROR,this,this.event_net_error);
			ModelPlayer.instance.off(ModelPlayer.EVENT_LOGIN_OK,this,this.loginAuto);
			Laya.loader.off(Event.ERROR, this, this.onError);
		}
		override public function initData():void{
			//
			Platform.checkPackage();
			Platform.getUserDataForIos(Handler.create(null,function(re:*):void{
				if(re){
					var js:Object = JSON.parse(decodeURI(re));
					// ToIOS.callFunc("logto",null,{logto:JSON.stringify(js)})
					ModelPlayer.userData = js.player;
					// ToIOS.callFunc("logto",null,{logto:JSON.stringify(ModelPlayer.userData)})
					ModelPlayer.userListData = js.list;
					// ToIOS.callFunc("logto",null,{logto:JSON.stringify(ModelPlayer.userListData)})
				}
			}));
			//
			ModelPlayer.instance.off(ModelPlayer.EVENT_LOGIN_OK,this,this.loginAuto);
			ModelPlayer.instance.on(ModelPlayer.EVENT_LOGIN_OK,this,this.loginAuto);
			//
			NetHttp.instance.off(NetHttp.EVENT_NET_ERROR,this,this.event_net_error);
			NetHttp.instance.on(NetHttp.EVENT_NET_ERROR,this,this.event_net_error);
			//
			
			if(ConfigApp.isPC){
				var bgImg:Image = new Image();
				if(ConfigApp.pcbgImg){
					LoadeManager.loadTemp(bgImg,AssetsManager.getAssetsAD(ConfigApp.pcbgImg+".jpg"),this.loadingImgSucc);
				}
				else{
					LoadeManager.loadTemp(bgImg,AssetsManager.getAssetsAD("bg_pc.jpg"),this.loadingImgSucc);
				}
				// bgImg.skin = "ad/bg_pc.jpg";
				// bgImg.x = -(Laya.stage.width - 640)/2;
				bgImg.centerY=0;
				bgImg.centerX=0;
				this.addChild(bgImg);
				bgImg.zOrder = -1;
				// 
				if(ConfigApp.pcLogoImg){
					mPcLogo = new Image();
					// logo.y = (1280 - Laya.stage.height) * 0.2;
					mPcLogo.pivotX = 0.5;
					mPcLogo.pivotY = 0.5;
					mPcLogo.centerX = 0;
					mPcLogo.centerY = -180;
					this.addChild(mPcLogo);
					LoadeManager.loadTemp(mPcLogo,AssetsManager.getAssetsAD(ConfigApp.pcLogoImg+".png"));
				}
			}
			else{
				if(ConfigApp.indexLoadingImg){
					LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsAD(ConfigApp.indexLoadingImg+".jpg"),this.loadingImgSucc);
				}
				else{
					LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsAD("bg_loading1.jpg"),this.loadingImgSucc);
				}
			}
			this.bgBox.removeChildren();
			this.bgBox.visible = false;
			//
			var logoUrl:String = ConfigApp.logoUI();
			if(logoUrl){
				var logo:Image = new Image();
				logo.skin = logoUrl
				// logo.y = (1280 - Laya.stage.height) * 0.2;
				logo.pivotX = 0.5;
				logo.pivotY = 0.5;
				logo.centerX = 0;
				logo.scale(0.9,0.9);
				logo.centerY = -280;
				this.bgBox.addChild(logo);
			}
			//
			if(ConfigApp.loginBgImg){
				this.mBgImg = new Image();
				this.mBgImg.top=0;
				this.mBgImg.bottom=0;
				this.mBgImg.left=0;
				this.mBgImg.right=0;
				this.bgBox.addChildAt(this.mBgImg,0);
				LoadeManager.loadTemp(this.mBgImg,AssetsManager.getAssetsAD(ConfigApp.loginBgImg+".jpg"));
			}
			//
			this.loginPaOtherPf = {};
			this.gameReadyLogin = false;
			//
			ModelPlayer.recommendServer = "";
			this.httpStatus = -1;
			this.yybOut.visible = false;//yyb & other
			this.yybBox.visible = false;//yyb 
			this.googleBox.visible = false;//google & facebook
			this.twBox.visible = false;
			this.combox.visible = false;
			this.progressBox.visible = true;
			// 
			//this.adImg.visible = true;
			this.adImg.visible = !ConfigApp.isPC;

			this.tCopyright.text = ConfigApp.get_Copyright();
			this.btn_register.visible = false;
			// 
			// this.btn_register.skin="comp/icon_81.png";
			if(ConfigApp.pf.indexOf("r2g")>-1){
				this.yybOut.skin = "comp/icon_80.png";
			}
			// 
			this.btn_tel.visible = false;
			//
			this.tVersion.text = (ConfigApp.appVersionTxt+"_"+ConfigApp.appFunVersion).replace(/\_/g,".");
			//
			if(ConfigApp.pf==ConfigApp.PF_360_2_h5){
				this.tVersion.text = "适龄提示:16岁以上";
				this.tVersion.color = "#FFFFFF";
			}
			//
			this.isAssets = false;
			this.isServerCfg = false;
			this.tuid.maxChars=8;
			//
			this.mFunQueue = new FunQueue();
			this.mFunQueue.init([
				Handler.create(this,this.initAssetsAndServerCfg),
				Handler.create(this, this.initLoginView)
				// Handler.create(this,this.initSocket),
				//Handler.create(this,this.testMap),
				// Handler.create(this,this.initLogin)
			]);
			this.txtArrEd=[];
			this.txtArr = Tools.sMsgLocalDic["loadingTxtArr"]
			this.txtIndex = Tools.getRandom(0,txtArr.length);//0;
			this.txtStop = false;
			//
			this.onTxtShow();
		}
		/**
		 * loading等待图加载完成后清理html上的过渡素材
		 */
		private function loadingImgSucc():void{
			Platform.showGameIndex();
		}
		private function onTxtShow():void
		{
			if(this.txtStop){
				return;
			}
			// 
			if(ConfigApp.loadtxt && ConfigApp.loadtxt=="yes"){
				this.txtShow.text = "需要加载网络资源,消耗少量流量";
			}
			else{
				this.txtShow.text = this.txtArr[this.txtIndex];
			}
			if(this.txtArrEd.indexOf(this.txtIndex)==-1){
				this.txtArrEd.push(this.txtIndex);
			}
			if(this.txtArrEd.length==this.txtArr.length){
				this.txtArrEd=[];
			}
			this.txtIndex=Tools.getRandom(0,this.txtArr.length,txtArrEd);
			this.timer.once(4000,this,this.onTxtShow);
		}
		public function initFightModel(caller:*,fun:Function):void{
			this.combox.visible = false;
			this.progressBox.visible = true;
			this.mFunQueue = new FunQueue();
			this.mFunQueue.init([
				Handler.create(this,this.initAssetsAndServerCfg),
				Handler.create(caller,fun),
			]);
		}
		/**
		 * 初始化加载条
		 */
		private function initLoadProgress():void{
			///开始加载时间
			this.mStartTime = new Date().getTime();
			this.progressAni = EffectManager.loadAnimation('loading_progress');
			this.progressImg = new Image(AssetsManager.getAssetsCOMP('glow.png'));
			
			this.progressAni.y = this.progressBar.y + 40;
			this.progressAni.blendMode = 'lighter';
			this.progressAni.scale(0.9, 0.9);
			
			this.progressImg.scale(1.8, 1.8);
			this.progressImg.y = 4;
			this.progressImg.blendMode = 'lighter';
			
			this.progressBar.addChild(this.progressImg);
			this.progressBar.parent.addChild(this.progressAni);
			if(ConfigApp.disloading && ConfigApp.disloading == "yes"){
				this.progressBarbg.alpha = 0;
				this.progressBar.alpha = 0;
				this.progressTxt.visible = false;
				if(ConfigApp.loadtxt && ConfigApp.loadtxt=="yes"){
					this.txtShow.text = "需要加载网络资源,消耗少量流量";
				}
				else{
					this.txtShow.visible = false;
				}
				this.progressImg.alpha = 0;
				this.progressAni.visible = false;
			}
			Laya.timer.frameLoop(1, this, this.onFrameLoop);
		}
		private function initAssetsAndServerCfg():void{
			this.initLoadProgress();
			this.initServerConfig();
		}
		
		/**
		 * 加载配置
		 */
		private function loadConfigs(urls:Array = null):void{
			MusicManager.playMusic(MusicManager.BG_LOGIN);
			this.mBgClip = EffectManager.loadWelcomeScreen();
			Laya.loader.on(Event.ERROR, this, this.onError);
			if (urls) {
				LoadeManager.loadImg(urls, Handler.create(this, this.onConfigComplete), Handler.create(this, this.onConfigProgress, null, false));
			} else {
				loadAssets();
			}
		}

		/**
		 * 加载游戏资源
		 */
		private function loadAssets():void{
			var arr:Array = [];
			if(ConfigApp.pf == ConfigApp.PF_360_3_h5){
				arr = [ConfigAssets.AssetsInitWord[1]].concat(ConfigAssets.AssetsInit);
			}else if(ConfigApp.pf == ConfigApp.PF_360_2_h5){
				arr = [ConfigAssets.AssetsInitWord[2]].concat(ConfigAssets.AssetsInit);
			}else{
				arr = [ConfigAssets.AssetsInitWord[0]].concat(ConfigAssets.AssetsInit);
			}
			LoadeManager.loadImg(arr, Handler.create(this, this.onOtherComplete), Handler.create(this, this.onOtherProgress, null, false));
		}
		/**
		 * 每帧自动调整显示加载条
		 */
		private function onFrameLoop():void
		{
			var speed:Number;
			if (this.mProgress == 0){ //有10%的假进度
				speed = 0.01;
				this.mLastProgress = Math.min(FAKE_PROGRESS,this.mLastProgress + speed);
				this.showProgressBar(this.mLastProgress);
			}
			else{				
				speed = this.mProgress - this.mLastProgress;
				//平滑速度
				if (speed >= 0.0001){
					speed = Math.max(0.0001,Math.min(0.3,0.1 * speed));
				}
				//速度倍率，标准按1000毫秒加完整条计算
				var speedRate:Number;
				if(this.mProgress < 1){
					speedRate = this.mProgress / ((new Date().getTime() - this.mStartTime)) * 1000;
					speedRate = Math.max(0.05,Math.min(1,speedRate));
				}
				else{
					speedRate = 2;
					speed += 0.02;
				}
				speed *= speedRate;
				this.mLastProgress = this.mLastProgress + speed;
				var currProgress:Number = Math.min(1, this.mLastProgress);
				this.showProgressBar(currProgress);

				if (this.mProgress >= 1 && currProgress>=1 && this.isComplete){
					this.tuid.text = "";
					// this.imgLogo.visible = false;
					Laya.timer.clear(this, this.onFrameLoop);
				
					// 检查版本更新
					if (newVersion) {
						this.loadNewVersion();
					} else {
						this.loadOthers();
					}
				}
			}
		}

		private function get newVersion():Boolean {
			var old_version:Number = (SaveLocal.getValue('new_version') as Number) || 0;
			var oldUser:Boolean = Boolean(SaveLocal.getValue('local_save_key_user'));
			var loading_show:Array = ConfigServer.system_simple.loading_show;
			if (loading_show is Array) {
				new_version = loading_show[0];
				update_duration = loading_show[1] / 1000;
				update_tips = Tools.getMsgById(loading_show[2]);
			}
			if (oldUser && new_version && old_version !== new_version) {
				return true;
			} else if (!old_version && new_version) {
				SaveLocal.save('new_version', new_version)
			}
			return false;
		}

		private function loadNewVersion():void {
			this.txtShow.text = update_tips;
			this.txtArrEd = [];
			this.txtIndex = 0;
			this.txtArr = [update_tips];
			this.showProgressBar(0);
			this.progressBar.blendMode = 'lighter';
			this.txtShow.color = '#33eeff';
			Laya.timer.frameLoop(1, this, this.onUpdating);
		}

		private function onUpdating():void {
			this.mUpdateProgress += 1 / (update_duration * 60); // FPS 60
			this.showProgressBar(this.mUpdateProgress);
			if (mUpdateProgress >= 1) {
				SaveLocal.save('new_version', new_version)
				Laya.timer.clear(this, this.onUpdating);
				this.loadOthers();
			}
		}

		private function loadOthers():void {
			var _this:ViewLoad = this;
			AssetsManager.loadOthers(this,function():void{
				_this.isAssets = true;
				_this.assetsAndServerCfgGet();	
			});
		}

		private function showProgressBar(v:Number):void
		{
			v += this.extraProgress;
			v = Math.min(v, 1);
			this.progressBar.width = v * mProwidth;
			this.progressTxt.text = Math.round(v * 100) + "%";
			var xx:Number = this.progressBar.width;
			this.progressAni.x = xx;
			
			xx += 200;
			//扫光
			if(this.progressImg.x<=0){
				this.progressImg.x += 15;
			}
			else if(this.progressImg.x<xx){
				this.progressImg.x += 10*(xx - this.progressImg.x) / (xx+200) + 5;
			}
			else{
				this.progressImg.x = -200;
			}
		}
		
		private function onConfigProgress(pro:Number):void {
			var step:Number = Math.floor(pro*10);
			this.mProgress = pro * (CONFIG_PROGRESS - FAKE_PROGRESS) + FAKE_PROGRESS;
		}
		
		private function onOtherProgress(pro:Number):void {
			var step:Number = Math.floor(pro*10);
			//
			// if(this.checkGameStatusIndex != step){
			// 	this.checkGameStatusIndex = step;
			// 	Platform.checkGameStatus(1000+this.checkGameStatusIndex);
			// }
			this.mProgress = pro * (1 - CONFIG_PROGRESS) + CONFIG_PROGRESS;
			// this.progress.value = pro;
			//
			//this.progressBar.width = 640*pro;
			//this.progressTxt.text = Math.floor(pro*100)+"%";
			// LoadeManager.instance.event(LoadeManager.PROGRESS, pro * 100);
		}
		private function onError(err:String):void {
			Trace.log(err);
		}
		
		private function onConfigComplete(texture:Texture):void {
			ConfigServer.updateConfig();
			this.loadAssets();
		}

		private function onOtherComplete(texture:Texture):void {
			Trace.log("ViewLoad onComplete");
			// this.progress.value = 1;
			this.mProgress = 1;
			//this.progressBar.width = 640;
			//this.tuid.text = "";
			//Laya.timer.clear(this, this.onFrameLoop);
			
			//var _this:ViewLoad = this;
			//AssetsManager.loadOthers(this,function():void{
				//_this.isAssets = true;
				//_this.assetsAndServerCfgGet();	
			//});
			this.isComplete = true;

			// 选服界面 上报数据
			if (ConfigApp.pf === ConfigApp.PF_shouqu_h5) {
				Platform.h5_sdk_obj.gameLoad('choose');
			}
		}
		private function initServerConfig():void{
			// ConfigApp.cfgVersion = ConfigServer.getLocalCfgVersion();//本地存储过的cfg版本
			// trace("--------本地配置版本--------",ConfigApp.cfgVersion);
			if(ConfigApp.isOldCfg){
				NetHttp.instance.send(NetMethodCfg.HTTP_SYS_CONFIG,{pf:ConfigApp.pf,lan:ConfigApp.lan()},Handler.create(this,http_sys_config),180);
			}else{
				NetHttp.instance.send(NetMethodCfg.HTTP_SYS_CONFIG_NEW, {pf:ConfigApp.pf,lan:ConfigApp.lan()}, Handler.create(this,http_sys_config_list),180);
			}

			// 开始加载
			if (ConfigApp.pf === ConfigApp.PF_shouqu_h5) {
				Platform.h5_sdk_obj.gameLoad('start'); // 游戏从开始加载
			}
		}
		private function http_sys_config_list(data:Object):void{
			this.httpStatus = Number(data["server_status"]);
			// 
			ConfigServer.config_dict = data.config_dict;
			var urls:Array = ObjectUtil.values(data.config_dict);
			this.isServerCfg = true;

			// 先加载各种配置
			this.loadConfigs(urls);
		}
		private function http_sys_config(data:Object):void{
			//
			this.httpStatus = Number(data["server_status"]);
			if(this.httpStatus == NetHttp.STATUS_SERVER_OK){
				ConfigServer.formatTo(data,false);
			}
			if(Platform.checkPackageAlert()){
				this.updateApp();
				return;
			}
			//
			this.isServerCfg = true;
			this.loadConfigs();
			// this.assetsAndServerCfgGet();			
		}
		private function updateApp():void{
			var _this:* = this;
			Browser.window.copytest1(ConfigApp.updateAppURL);
			ViewManager.instance.showWarnAlert(Tools.getMsgById("_lht71")+"\n sg.ptkill.com/www1/",Handler.create(this,function():void{
				ViewManager.instance.showTipsTxt("复制下载地址成功");
				Laya.timer.once(1000,_this,_this.updateApp);
			}));
		}
		private var error_times_login:Number = 0;
		private function event_net_error():void
		{
			Platform.checkGameStatus(500);
			if(this.gameReadyLogin){//短链登录错误
				this.error_times_login+=1;
				if(this.error_times_login<5){
					if(ConfigApp.useMyLogin()){
						ViewManager.instance.showView(ConfigClass.VIEW_LOGIN,-1);
					}
					else{
						this.checkPFLoginBySDK();
					}
				}
				else{
					ViewManager.instance.showWarnAlert(Tools.getMsgById("_lht59"),Handler.create(_this,function():void{
						Platform.restart();
					}));
				}
				return;
			}
			//config 获取错误,,尝试重新连接
			this.httpStatus = NetHttp.STATUS_SERVER_CLOSE;
			//
			if(this.config_error_times<2){
				this.config_error_times+=1;
				this.initServerConfig();
			}
			else{
				var _this:* = this;
				ViewManager.instance.showWarnAlert(Tools.getMsgById("_lht59"),Handler.create(_this,function():void{
					_this.initServerConfig();
				}));							
			}
		}
		private function assetsAndServerCfgGet():void{
			if(this.isAssets && this.isServerCfg){
				if(this.httpStatus == NetHttp.STATUS_SERVER_OK){
					ConfigServer.initData();
				}
				this.mFunQueue.next();
			}
		}
		/**
		 * 此时播放飞鸽子动画
		 */
		private function playBgClip():void {
			if (!this.mHasPlayBgClip && this.mBgClip){
				if (this.btn_server.visible && ViewManager.instance.isNoPanel()){
					this.mHasPlayBgClip = true;
					var ani:Animation = this.mBgClip.getChildByName('glow502') as Animation;
					if(ani){
						EffectManager.setAnimationQueue(ani, 'in|stand', 2);
					}
				}
				else{
					//延迟再次检测
					Laya.timer.once(1000, this, this.playBgClip);
				}
				//ViewManager.instance.off(ViewManager.EVENT_PANEL_CLEAR, this, this.playBgClip);
			}
		}
		/**
		 * 登陆 界面
		 */
		private function initLoginView():void {
			if(this.mPcLogo){
				this.mPcLogo.visible=false;
			}
			//
			FilterManager.instance.decode2();
			//
			if(!ConfigApp.loginBgImg){
				Tools.check1280Img(this.mBgClip,true);
				this.bgBox.addChildAt(this.mBgClip,0);
				if(this.mBgClip) this.mBgClip.x = (this.width - this.mBgClip.width)/2;
			}
			//
			this.txtStop = true;
			this.gameReadyLogin = true;
			//
			this.isCheckLoginHttp = false;
			this.bgBox.visible = true;
			//
			this.progressBox.visible = false;	
			this.adImg.visible = false;	

			txt_affiche.text = Tools.getMsgById('load_button_01');
			txt_register.text = Tools.getMsgById('load_button_02');
			txt_out.text = Tools.getMsgById('load_button_03');
			txt_tel.text = Tools.getMsgById('load_button_04');
			//
			ConfigApp.isTest = ConfigServer.system_simple.is_test;
			ConfigServer.checkIsChangeCurrPfTo();
			Trace.isOn = ConfigApp.isTest || TestUtils.sgDebug;
			//
			var useMyLogin:Boolean = ConfigApp.useMyLogin();
			//
			Platform.initShare();			
			//ViewManager.instance.showView(ConfigClass.VIEW_AFFICHE);
			//
			Trace.log("---是否是测试模式--m",ConfigApp.isTest);
			//
			this.btn_register.visible = useMyLogin;
			//
			this.combox.visible = true;
			//
			this.btn_login.off(Event.CLICK,this,this.onClick_login);
			//
			this.tuid.visible = ConfigApp.isTest;
			this.tAll.visible = ConfigApp.isTest;
			//
			this.btn_login.visible = false;
			this.btn_server.visible = false;
			//
			ModelPlayer.instance.updateAll(true);
			//
			this.tuid.text = ModelPlayer.instance.getUID();
			//
			this.isEnterGameUser = ModelPlayer.instance.isTempPlayer;
			var isTempData:Boolean = (ModelPlayer.instance.isTempPlayer && true);
			//
			ModelPlayer.instance.loginName = ModelPlayer.instance.getName();
			ModelPlayer.instance.loginPwd = ModelPlayer.instance.getPWD();
			//
			if(ConfigApp.isTest){
				//
				var key:String;
				//
				var uStr:String = "";
				if(ModelPlayer.instance.mPlayerList){
					for(key in ModelPlayer.instance.mPlayerList)
					{
						uStr+=ModelPlayer.instance.mPlayerList[key].uid+",";
					}
				}
				this.tAll.text = uStr;
				//
				this.btn_login.visible =true;
				this.btn_login.on(Event.CLICK,this,this.onClick_login,[200]);
				if(isTempData){
					this.loginAuto(200);
				}
			}
			else{
				this.btn_login.on(Event.CLICK,this,this.onClick_login,[100]);
				//
				if(ConfigApp.auser && ConfigApp.auser!=""){
					ModelPlayer.instance.loginName = ConfigApp.auser;
					ModelPlayer.instance.loginPwd = ConfigApp.auser;
					this.loginAuto(0);
				}
				else{
					//
					if(useMyLogin){
						if(isTempData){
							this.loginAuto(0);
						}
						else{
							if(ConfigServer.system_simple.is_fast_register && ConfigServer.system_simple.is_fast_register==1){
								NetHttp.instance.send(NetMethodCfg.HTTP_USER_REGISTER_FAST,{pf:ConfigApp.pf_channel},Handler.create(this,this.registFast));
							}else{
								ViewManager.instance.showView(ConfigClass.VIEW_LOGIN_CHOOSE);
								// ViewManager.instance.showView(ConfigClass.VIEW_LOGIN,1);
							}
						}
					}
					else{
						this.checkPFLoginBySDK();
					}
				}
			}
			//
			// this.playBgClip();
		}
		/*
		private function registFast(re:Object):void
        {
            Platform.checkGameStatus(501);
            ThirdRecording.setRegister();
            //username: "21b48dcc7", pwd: "253604
           ViewManager.instance.showView(["ViewRegistFast",ViewRegistFast],re); 
        }*/

		private function checkPFLoginBySDK():void
		{
			ModelPf.pf_login(this,ConfigApp.pf);
		}
		private function click_logout():void{
			var out:Boolean =false;
			if(ConfigApp.pf == ConfigApp.PF_and_google || ConfigApp.pf == ConfigApp.PF_ios_meng52_tw){
				var _this:* = this;
				var temp:Object = SaveLocal.getValue(SaveLocal.KEY_VISITOR_USER_DATA);
				if(temp){
					if(ModelPhone.isBindingFBorGG(temp.uid)){
						var pn:String = (temp.uid.indexOf("google")>-1)?"Google":"Facebook";
						ViewManager.instance.showAlert(Tools.getMsgById("_lht77",[pn,pn]),function(index:int):void{
							if(index==0){
								SaveLocal.deleteObj(SaveLocal.KEY_VISITOR_USER_DATA);
								ModelPf.pf_logout(_this,ConfigApp.pf);
							}
						});
					}
					else if(temp.uid == ModelPlayer.instance.loginName){
						ViewManager.instance.showAlert(Tools.getMsgById("_lht78"),function(index:int):void{
							if(index==0){
								ModelPf.pf_logout(_this,ConfigApp.pf);
							}
						});
					}
					else{
						out = true;
					}
				}
				else{
					out = true;
				}
			}
			else{
				out = true;
			}
			if(out){
				ModelPf.pf_logout(this,ConfigApp.pf);
			}
		}
		private function click_yyb(type:Number):void
		{
			ModelPf.pf_login(this,ConfigApp.pf,type);		
		}
		private function onClick_login(check:Number):void{
			this.isClickedLoginBtn = true;
			if(check==100){
				this.initSocket(true);
			}
			else{
				if(this.tuid.text!=ModelPlayer.instance.getUID()){
					this.isCheckLoginHttp = false;
				}
				this.loginAuto(check);
			}
		}
		private function loginAuto(check:Number):void{
			this.loginStatus = check;
			var _this:* = this;	
			//
			Platform.login(Handler.create(_this,function(status:Number,obj:Object):void{
				if(check==2){
					//手机号登录
					_this.loginByPhone();
					_this.initSocket(false);
				}
				else if(check==200){
					//测试开发才能用的uid登录
					_this.loginByUserName("uid");
					_this.initSocket(true);
				}
				else{
					//正常用户名秘密登录
					_this.loginByUserName("username");
					_this.initSocket(false);
				}
			}));			
		}

		/**
		 * 展示公告
		 */
		private function _showAffiche():void {
			var notices:Array = ConfigServer['notice'].notice;
			if (notices && notices.length) {
				var is_note:int = ConfigServer.system_simple.is_note;
				if (is_note > 0 && ViewAffiche.tabData.length) {
					this.btn_affiche.visible = true;
					this.btn_affiche.on(Event.CLICK,this,this.click_affiche);
					ModelGame.redCheckOnce(btn_affiche, ViewAffiche.redCheck());
					is_note === 1 && ViewManager.instance.showView(ConfigClass.VIEW_AFFICHE);
				}
			}
		}

		private function loginByUserName(type:String):void{
			this.loginPa = {uid:this.tuid.text,pf:ConfigApp.pf_channel,username:ModelPlayer.instance.loginName,pwd:ModelPlayer.instance.loginPwd};
			this.loginPa["utype"] = type;
			for(var key:String in this.loginPaOtherPf)
			{
				this.loginPa[key] = this.loginPaOtherPf[key];
			}
		}	
		private function loginByPf(isUP:Boolean = false):void
		{
			if(isUP){
				this.loginPa = {uid:"",pf:ConfigApp.pf,username:ModelPlayer.instance.loginName,pwd:ModelPlayer.instance.loginPwd};
				this.loginPa["utype"] = "username";
			}
			else{
				this.loginPa = {uid:this.tuid.text,pf:ConfigApp.pf_channel,username:ModelPlayer.instance.loginName,pwd:ModelPlayer.instance.loginPwd};

			}	
			for(var key:String in this.loginPaOtherPf)
			{
				this.loginPa[key] = this.loginPaOtherPf[key];
			}		
		}	
		private function loginByPhone():void
		{
			this.loginPa = {"utype":"tel_sign",pf:ConfigApp.pf_channel,tel:ModelPlayer.instance.getPhone(),sign:ModelPlayer.instance.getPhoneCode()};
			for(var key:String in this.loginPaOtherPf)
			{
				this.loginPa[key] = this.loginPaOtherPf[key];
			}			
		}
		private function initSocket(andSocket:Boolean):void{
			if(andSocket && this.isCheckLoginHttp){
				this.loginSocket();
				return;
			}
			ModelManager.instance.modelUser.isLoginHttp = false;
			ModelManager.instance.modelUser.initUserLogin(this.loginPa,Handler.create(this,this.httpLogin),andSocket);
		}
		private function httpLogin(andSocket:Boolean):void
		{
			// Trace.log("4准备注册的channel--:"+ConfigApp.pf_channel);
			NetHttp.instance.checkArea();
			//
			this.tuid.text = ModelPlayer.instance.getUID();			
			this.btn_login.visible = true;
			this.yybBox.visible = false;
			this.googleBox.visible = false;
			this.twBox.visible = false;
			//
			this.isCheckLoginHttp = true;
			//
			// if(ConfigServer.system_simple.phone_pf.indexOf(ConfigApp.pf)!=-1){
			// 	this.btn_tel.visible=true;
			// }
			//
			this.btn_server.visible = true;
			//
			var myZonesStr:String = ModelPlayer.instance.getServerZones();
			var myZones:Array = myZonesStr.split("|");//
			var oldUser:Boolean = true;
			var loginOK:Boolean =false;
			//
			if(myZones && myZones.length>0 && myZonesStr){
				var tz:String = null;
				var len:int = myZones.length;
				var zoneData:Object = null;
				for(var i:int = len; i > 0; i--)
				{
					zoneData = ConfigServer.zone[myZones[i-1]];
					if(zoneData){
						tz = myZones[i-1];
						break;
					}
				}
				if(tz){
					this.event_server_select_change(myZones[myZones.length-1]);
				}
				else{
					oldUser = false;
				}
			}
			else{
				oldUser = false;
			}
			if(!oldUser){
				//没有缓存的新用户
				ModelPlayer.instance.setCurrZone("");
				//
				var zoneId:String = ModelPlayer.instance.getCurrZone();
				if(Tools.isNullString(zoneId)){
					//没有开区
					this.btn_login.visible = false;
					this.btn_server.visible = false;
				}
				else{
					this.event_server_select_change(zoneId);
				}
			}
			//
			this.btn_login.label = Tools.getMsgById("_lht49");			
			if(this.loginStatus >=0){
				loginOK = true;
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_lht51"));
			}
			else if(this.loginStatus == -1){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_lht50"));
			}
			var _this:* = this;
			if(!this.isClickedLoginBtn && !this.isEnterGameUser && loginOK && ConfigApp.atOnceLoginToEnter()){	
				this.timer.once(100,null,function():void{
					_this.onClick_login(100);
				});
			}
			else{
				this._showAffiche();
			}
			
            if(ConfigApp.pf == ConfigApp.PF_hutao_h5 || ConfigApp.pf == ConfigApp.PF_hutao2_h5) {
				var accountId:Array = ModelManager.instance.modelUser.accountId as Array;
                Platform.h5_sdk_obj.float(accountId[0], accountId[1]);
                Platform.h5_sdk_obj.registerLogout(Platform.restart);
            }
		}
		private function loginSocket():void
		{
			var zoneCfg:Object = ConfigServer.zone[ModelPlayer.recommendServer];
			var zone:Array = zoneCfg[1];
			var now:Number = ConfigServer.getServerTimer();
			var openMs:Number = Tools.getTimeStamp(zoneCfg[2]);
			//
			if(now<openMs){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_lht54",[Tools.getTimeStyle(openMs-now)]));
				return;
			}
			//
			NetSocket.instance.off(NetSocket.EVENT_SOCKET_OPENED,this,this.event_socket_opened);
			NetSocket.instance.on(NetSocket.EVENT_SOCKET_OPENED,this,this.event_socket_opened);	
			// var ssl:Boolean = ConfigApp.useSSL();	
			// var c:String = zone[1];
			// if(ssl && zoneCfg[5]){
			// 	c = zoneCfg[5];
			// }
			NetSocket.setURLtoConnect(zone[0],zone[1],ConfigApp.useSSL());
			// NetSocket.setURLtoConnect("srv4.ptkill.com","17000",ConfigApp.useSSL());
			//
		}
		private function event_socket_opened():void
		{
			NetSocket.instance.off(NetSocket.EVENT_SOCKET_OPENED,this,this.event_socket_opened);
			ModelManager.instance.modelUser.loginSocket();
			//
			this.clear();
		}
		private function registUserFastByFirst():void{
			NetHttp.instance.send(NetMethodCfg.HTTP_USER_REGISTER_FAST,{pf:ConfigApp.pf_channel},Handler.create(this,this.registFast));
		}
        private function registFast(re:Object):void
        {
            Platform.checkGameStatus(201);
			Trackingio.postReport(3,re);
            ThirdRecording.setRegister();
			//
            // ModelPlayer.instance.setUID("ready");
            // ModelPlayer.instance.setName(re.username);
            // ModelPlayer.instance.setPWD(re.pwd);
            // ModelPlayer.instance.setPlayerList();  
			ModelPlayer.instance.loginName = re.username;                                
            ModelPlayer.instance.loginPwd = re.pwd;                                 
            ModelPlayer.instance.event(ModelPlayer.EVENT_LOGIN_OK,-1);			
        }	

		override public function clear():void{
			Trace.log("ViewLoad clear");
			this.visible = false;
			this.mBgClip.removeChildren();
			Laya.loader.off(Event.ERROR,this,this.onError);
			Laya.loader.off(Event.COMPLETE,this,this.onConfigComplete);
			Laya.loader.off(Event.PROGRESS, this, this.onConfigProgress);
			Laya.loader.off(Event.COMPLETE,this,this.onOtherComplete);
			Laya.loader.off(Event.PROGRESS, this, this.onOtherProgress);
			//ViewManager.instance.off(ViewManager.EVENT_PANEL_CLEAR, this, this.playBgClip);
			Laya.timer.clear(this, this.onFrameLoop);
			Laya.timer.clear(this, this.playBgClip);
			if (this.progressAni){
				this.progressAni.destroy();
				this.progressAni = null;
			}
			if (this.progressImg){
				this.progressImg.destroy();
				this.progressImg = null;
			}
			ViewManager.isLoadView = false;
			
		}
	}

}