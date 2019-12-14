package sg.manager
{
	import laya.display.Node;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.events.EventDispatcher;
	import laya.maths.Rectangle;
	import laya.ui.Box;
	import laya.ui.Component;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.fight.FightMain;
	import sg.fight.client.ClientBattle;
	import sg.guide.view.GuideFocus;
	import sg.guide.view.ViewGuide;
	import sg.map.utils.TestUtils;
	import sg.utils.MusicManager;
	import ui.mapScene.MiniMapTopUI;

	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import sg.home.view.HomeViewMain;
	import sg.map.view.MapViewMain;
	import sg.model.ModelAlert;
	import sg.model.ModelBuiding;
	import sg.model.ModelEquip;
	import sg.model.ModelGame;
	import sg.model.ModelItem;
	import sg.model.ModelRune;
	import sg.model.ModelUser;
	import sg.net.NetMethodCfg;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.scene.SceneMain;
	import sg.utils.ObjectSingle;
	import sg.utils.Tools;
	import sg.view.BaseSprite;
	import sg.view.ViewBase;
	import sg.view.ViewPanel;
	import sg.view.ViewScenes;
	import sg.view.effect.EffectUIBase;
	import sg.view.init.ViewAlert;
	import sg.view.init.ViewHeroTalk;
	import sg.view.map.ViewInsideTest;
	import sg.view.menu.ItemTroop;
	import sg.view.menu.ViewMenuMain;
	import ui.bag.bagItemUI;
	import sg.guide.model.ModelGuide;
	import sg.task.TaskHelper;
	import sg.view.map.ViewCreditResult;
	import laya.display.Animation;
	import sg.activities.model.ModelFreeBuy;
	import sg.view.more.ViewNotice;
	import laya.utils.Browser;
	import sg.utils.StringUtil;
	import sg.fight.logic.utils.PassiveStrUtils;
	import sg.model.ModelHero;
	import sg.model.ModelClimb;
	import laya.html.dom.HTMLDivElement;
	import sg.boundFor.GotoManager;
	import sg.view.more.ViewCarouse;
	import sg.view.init.ViewAlert2;
	import sg.view.hero.ViewHeroTitle;
	import sg.view.init.ViewHintPanel;
	import laya.utils.Timer;
	import sg.utils.SaveLocal;
	import sg.utils.ThirdRecording;
	import sg.activities.model.ModelPhone;
	import sg.model.ModelClub;
	import sg.view.menu.ComChat;


	/**
	 * ...
	 * @author 
	 */
	public class ViewManager extends EventDispatcher{
		
		//
		public static const EVENT_MAP_IN_OUT:String = "event_map_in_out";
		public static const EVENT_SHOW_CAROUSE:String = "event_show_carouse";
		///当前移除了最后一个面板
		public static const EVENT_PANEL_CLEAR:String = "event_panel_clear";

		//通知关闭英雄说话面板
		public static const EVENT_CLOSE_HERO_TALK:String = "event_close_hero_talk";
		public var carouse_count:Number=0;
		//
		public static var sViewManager:ViewManager = null;
		public static var sLaya:LayaSample = null;
		public var pos_dict_pos:Object={};

		public static var isLoadView:Boolean = true;//是否登录界面
		public function ViewManager(){
		}
		public static function get instance():ViewManager{
			return sViewManager ||= new ViewManager();
		}
		//
		public var mLayerMap:Component;
		//
		//scene的父级 pc适配用的
		private var mLayerSceneParent:Component;
		private var mSceneBlack:*;
		public var mSceneBg:*;

		private var mLayerScenes:Component;
		private var mLayerPanel:Component;
		public var mLayerMenu:ViewMenuMain;
		public var mLayerGuide:Component;	// 引导层
		public var mLayerLoading:Component;	// 加载层
		private var mLayerViewEffect:Component;//ui界面动画层
		public var mLayerEffect:Component;//顶层动画层，动画需无点击事件且自身回收
		private var mLayerStageDisabled:Component;//屏蔽层
		private var mDisabledSpr:Sprite;//屏蔽层动画容器，延迟0.5秒后显现
		private var mDisabledAnimation:Animation;//屏蔽层动画容器，延迟0.5秒后显现
		//private var mDisabledLabel:Label;//屏蔽层动画容器，延迟0.5秒后显现
		private var mStageDisabledTween:Tween;
		private var mLayerWarn:Sprite;
		//
		public var mLayerClip:Sprite;
		public var mLayerFight:Sprite;
		private var mLayerNotice:ViewNotice;//通知层
		private var mLayerCarouse:ViewCarouse;//系统跑马灯
		
		//
		private var mLayerTxtTips:Component;
		private var mLayerTouchClip:Component;
		//
		public var mScenesArr:Array;
		private var mScenesShow:ViewScenes;
		//
		private var mPanelArr:Object;
		private var mPanelShow:ViewPanel;
		//
		private var mHomeViewMain:HomeViewMain;
		private var mMapViewMain:MapViewMain;
		private var mViewInsideTest:ViewInsideTest;
		private var mSceneMain:SceneMain;
		//检查主界面按钮组合功能是否开启
		private var checkMenuFun:Boolean = false;
		//

		public function init():void{		
			this.checkMenuFun = false;
			this.mPanelArr = {};
			MusicManager.init();
			//
			this.mLayerMap = ObjectSingle.getObjectByArr(ConfigClass.LAYER_MAP);
			this.mLayerMap.visible = false;
			Laya.stage.addChild(this.mLayerMap);
			//
			this.mLayerScenes = ObjectSingle.getObjectByArr(ConfigClass.LAYER_SCENES);
			this.mScenesArr = [];
			if(ConfigApp.isPC){
				this.mLayerScenes.centerX = 0;
				this.mLayerSceneParent = new Component();
				this.mLayerSceneParent.top = this.mLayerSceneParent.bottom = this.mLayerSceneParent.left = this.mLayerSceneParent.right = 0;
				this.mLayerSceneParent.cacheAs = "normal";
				
				mSceneBlack = new Image();
				mSceneBlack.skin = "comp/blank_bg.png";
				mSceneBlack.alpha = 1;
				mSceneBlack.visible = true;
				mSceneBlack.on(Event.CLICK,this,function():void{
					if(ViewManager.isLoadView){
						return;
					}
					ViewManager.instance.closeScenes();
				});
				this.mSceneBlack.top = this.mSceneBlack.bottom = this.mSceneBlack.left = this.mSceneBlack.right = 0;
				//通用背景图
				//mSceneBg = new Image();
				//mSceneBg.skin = "ad/bg_pc.jpg";
				//this.mSceneBg.top = this.mSceneBg.bottom = this.mSceneBg.left = this.mSceneBg.right = 0;

				this.mLayerSceneParent.addChild(mSceneBlack);
				//this.mLayerSceneParent.addChild(mSceneBg);

				this.mLayerSceneParent.addChild(mLayerScenes);
				Laya.stage.addChild(this.mLayerSceneParent);
			}else{
				Laya.stage.addChild(this.mLayerScenes);
			}
			
			//
			this.mLayerMenu = ObjectSingle.getObjectByArr(ConfigClass.MENU_MAIN);
			Laya.stage.addChild(this.mLayerMenu);
			//
			this.mLayerFight = new Sprite();
			Laya.stage.addChild(this.mLayerFight);			
			//
			this.mLayerPanel = ObjectSingle.getObjectByArr(ConfigClass.LAYER_PANEL);
			Laya.stage.addChild(this.mLayerPanel);
			//
			this.mLayerNotice = new ViewNotice();
			Laya.stage.addChild(this.mLayerNotice);

			this.mLayerCarouse = new ViewCarouse();
			Laya.stage.addChild(this.mLayerCarouse);
			//
			this.mLayerViewEffect = new Component();
			Laya.stage.addChild(this.mLayerViewEffect);
			
			this.mLayerEffect = new Component();
			this.mLayerEffect.mouseEnabled = false;
			this.mLayerEffect.top = this.mLayerEffect.bottom = this.mLayerEffect.left = this.mLayerEffect.right = 0;
			Laya.stage.addChild(this.mLayerEffect);
			//
			this.mLayerClip = new Sprite();
			this.mLayerClip.mouseThrough = true;
			this.mLayerClip.mouseEnabled = false;
			this.mLayerClip.cacheAs = "normal";
			Laya.stage.addChild(this.mLayerClip);
			
			// 引导界面
			this.mLayerGuide = new Component();
			this.mLayerGuide.mouseThrough = true;
			Laya.stage.addChild(this.mLayerGuide);
			// 加载面板
			this.mLayerLoading = new Component();
			Laya.stage.addChild(this.mLayerLoading);
			
			//
			this.mLayerTxtTips = ObjectSingle.getObjectByArr(ConfigClass.LAYER_TIPS_TXT);
			this.mLayerTxtTips.mouseEnabled = false;
			this.mLayerTxtTips.mouseThrough = true;
			Laya.stage.addChild(this.mLayerTxtTips);
			//
			this.mLayerTouchClip = new Component();
			this.mLayerTouchClip.mouseEnabled = false;
			this.mLayerTouchClip.mouseThrough = true;
			Laya.stage.addChild(this.mLayerTouchClip);
			//
			this.mLayerStageDisabled = new Component();
			this.mLayerStageDisabled.top = this.mLayerStageDisabled.bottom = this.mLayerStageDisabled.left = this.mLayerStageDisabled.right = 0;
			//this.mLayerStageDisabled.graphics.drawRect(0,0,Laya.stage.width,Laya.stage.height,"#000000");
			//this.mLayerStageDisabled.hitArea = new Rectangle(0,0,Laya.stage.width,Laya.stage.height);
			this.mLayerStageDisabled.mouseEnabled = true;
			this.mLayerStageDisabled.mouseThrough = false;
			//this.mLayerStageDisabled.alpha = 0;	
			this.mLayerStageDisabled.visible = false;	
			Laya.stage.addChild(this.mLayerStageDisabled);
			//
			this.mLayerWarn = new Sprite();
			Laya.stage.addChild(this.mLayerWarn);	

			if(ConfigApp.isPC){
				this.mLayerPanel.centerX = 0;
				this.mLayerMenu.centerX = 0;
				this.mLayerLoading.centerX = 0;
				this.mLayerCarouse.centerX = 0;
				this.mLayerClip.width = Laya.stage.width;
				this.mLayerClip.height = Laya.stage.height;
			}

			//
			var ay:Number = 30+ConfigApp.topVal;
			var n:Number = ConfigApp.isPC ? (Laya.stage.width - 640)/2 + 15 :15;
			pos_dict_pos["merit"] = [150 + n, ay];
			pos_dict_pos["gold"]  = [248 + n, ay];
			pos_dict_pos["food"]  = [346 + n, ay];
			pos_dict_pos["wood"]  = [444 + n, ay];
			pos_dict_pos["iron"]  = [542 + n, ay];
			pos_dict_pos["coin"]  = [10 + n, ay];
			
			this.off(EVENT_SHOW_CAROUSE,this,this.showCarouse);
			this.on(EVENT_SHOW_CAROUSE,this,this.showCarouse);
			//
			this.off(EVENT_MAP_IN_OUT,this,this.event_map_in_out);
			this.on(EVENT_MAP_IN_OUT,this,this.event_map_in_out);
			//
			NetSocket.instance.off(NetSocket.EVENT_SOCKET_SEND_TO,this,this.event_socket_send_and_receive);
			NetSocket.instance.on(NetSocket.EVENT_SOCKET_SEND_TO,this,this.event_socket_send_and_receive);
			//
			NetSocket.instance.off(NetSocket.EVENT_SOCKET_RECEIVE_FROM,this,this.event_socket_send_and_receive);
			NetSocket.instance.on(NetSocket.EVENT_SOCKET_RECEIVE_FROM,this,this.event_socket_send_and_receive);
			//
			NetSocket.instance.off(NetSocket.EVENT_SOCKET_CLOSE,this,this.event_socket_close_and_error);
			NetSocket.instance.on(NetSocket.EVENT_SOCKET_CLOSE,this,this.event_socket_close_and_error);
			//
			NetSocket.instance.off(NetSocket.EVENT_SOCKET_ERROR,this,this.event_socket_close_and_error);
			NetSocket.instance.on(NetSocket.EVENT_SOCKET_ERROR,this,this.event_socket_close_and_error);
			//
			NetSocket.instance.off(NetSocket.EVENT_SOCKET_OPENED,this,this.event_socket_opened);
			NetSocket.instance.on(NetSocket.EVENT_SOCKET_OPENED,this,this.event_socket_opened);
			//
			NetSocket.instance.registerHandler(NetMethodCfg.WS_SR_GET_COIN,new Handler(this,this.getCoin));
			//
			Laya.stage.off(Event.CLICK,this,this.click_stage);
			Laya.stage.on(Event.CLICK,this,this.click_stage);
			Laya.stage.off(Event.MOUSE_DOWN,this,this.click_stage_down);
			Laya.stage.on(Event.MOUSE_DOWN,this,this.click_stage_down);		
			//
			NetSocket.instance.off(NetSocket.EVENT_SOCKET_RE_CODE_ERROR,this,this.event_socket_re_code_error);
			NetSocket.instance.on(NetSocket.EVENT_SOCKET_RE_CODE_ERROR,this,this.event_socket_re_code_error);	
			//
			if(!ConfigApp.testFightType){
				ModelManager.instance.modelGame.on(ModelGame.EVENT_STAGE_LOCK_UNLOCK, this, this.checkStageDis);
			}
			this.initOnPC();
			//
			Laya.stage.off(Event.VISIBILITY_CHANGE,this,this.visibility_change);
			Laya.stage.on(Event.VISIBILITY_CHANGE,this,this.visibility_change);
			//
		}

		private function visibility_change():void
		{
			trace("---切换到前后台---");
		}
		/**
		 * PC特殊初始化
		 */
		private function initOnPC():void
		{
			//if(Browser.onPC){
			if (Browser.window && Browser.window.location && Browser.window.location.search){
				//特殊浏览器测试
				var temp:*;
				temp = Tools.getURLexp('test');
				if (temp != null){
					ConfigApp.isTest = parseInt(temp);
				}
				temp = Tools.getURLexp('testShow');
				if (temp != null){
					TestUtils.isTestShow = parseInt(temp);
				}
				temp = Tools.getURLexp('testMsg');
				if (temp != null){
					TestUtils.isTestMsg = parseInt(temp);
				}
				temp = Tools.getURLexp('sgDebug');
				if (temp != null){
					TestUtils.sgDebug = parseInt(temp);
				}
				
				//MusicManager.soundMuted = true;
				//MusicManager.musicMuted = true;
			}
		}
		private function event_socket_opened():void
		{
			ModelGame.stageLockOrUnlock("",false,true);
		}
		private function getCoin(re:NetPackage):void
		{
			ModelManager.instance.modelUser.updateData(re.receiveData);
			var money:Number = (re.receiveData.gift_dict.coin/10);
			Platform.uploadUserData(5,[money]);
			Trackingio.postReport(5,{"money":money,"pay_ids":ModelManager.instance.modelUser.records.pay_ids,"uid":ModelManager.instance.modelUser.mUID});
			this.showRewardPanel(re.receiveData.gift_dict,function():void{
				if(ModelPhone.instance.isOpenView()){
					GotoManager.boundForPanel(GotoManager.VIEW_PHONE);  
				}
			});

			//刷新国家红包数据
			NetSocket.instance.send("get_club_redbag",{},Handler.create(this,function(nnp:NetPackage):void{
				ModelManager.instance.modelUser.updateData(nnp.receiveData);
				ModelManager.instance.modelClub.event(ModelClub.EVENT_COUNTRY_REDBAG);
				ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_UPDATE,[{"country_club":""},true]);//通知红点刷新
			}));
			
			this.showTipsTxt(Tools.getMsgById("_public115"));
			ModelManager.instance.modelUser.event(ModelUser.EVENT_PAY_SUCCESS);
			Platform.payClose();
			//
			ThirdRecording.setPay(Platform.recodrd_pay_info);
		}
		private function event_socket_send_and_receive(method:String,b:Boolean, timeout:Boolean):void{
			ModelGame.stageLockOrUnlock(method,b);
		}
		private function event_socket_close_and_error(force:Boolean,data:Object,restart:Boolean = true):void
		{
			ModelGame.stageLockOrUnlock("",false,true);
			//
			if(force){
				//
				var msg:String = Tools.getMsgById("_lht34");
				if(data && data["msg"]){
					msg = data["msg"];
				}
				this.showWarnAlert(msg,restart?Handler.create(this,this.forceRestartGame):null);
			}
		}
		public static function clear():void{
			NetSocket.instance.clear();
			NetSocket.instance.clearEvents();
			ObjectSingle.clear();
			for each(var value:* in Laya.timer._handlers)
			{
				if(value && value["caller"] && value["caller"]["__className"]){
					var str:String = value["caller"]["__className"];
					if(str.indexOf("sg.")>-1){
						trace(value["caller"]["__className"]);
						Laya.timer.clearAll(value["caller"]);
					}
				}
			}
			// trace(Laya.timer._handlers);
			Laya.stage.clearEvents();
			Laya.stage.destroyChildren();
			ModelManager.clear();
			//
			ViewManager.sLaya.init();
		}		
		private function forceRestartGame(type:Number):void
		{
			// Laya.stage.removeChildren();
			// ModelManager.instance.modelUser.clear_uid_sessionid();
			// this.init();
			// this.showView(ConfigClass.VIEW_LOAD,null,{type:0});			
			if(type==0){
				Platform.restart();
			}
		}
		/**
		 * 锁屏的显示对象判断
		 */
		private function checkStageDis(lockDic:Object):void
		{
			if(ConfigApp.lclip1 && ConfigApp.lclip1 == "yes"){
				return;
			}
			var b:Boolean = Tools.getDictLength(lockDic)>0;
			Trace.log("---现在还有谁在锁住屏幕--",b,lockDic);
			this.mLayerStageDisabled.visible = b;
			if (b){
				if(!ModelGame.isShowLoadingAni)
					return;
				//动画容器
				if(!this.mDisabledSpr){
					this.mDisabledSpr = new Sprite();
					this.mDisabledSpr.alpha = 0;
					this.mDisabledSpr.x = this.mLayerStageDisabled.width * 0.5;
					this.mDisabledSpr.y = this.mLayerStageDisabled.height * 0.4;
					
					this.mDisabledAnimation = EffectManager.getAnimation('glow503');
					this.mDisabledSpr.addChild(this.mDisabledAnimation );
					
					var label:Label = new Label(Tools.getMsgById('_public185'));
					label.width = 200;
					label.x = -label.width*0.5;
					label.y = 30;
					label.color = '#66EEFF';
					label.stroke = 2;
					label.strokeColor = '#2244EE';
					label.fontSize = 18;
					label.align = 'center';
					this.mDisabledSpr.addChild(label);
					
					this.mLayerStageDisabled.addChild(this.mDisabledSpr);
				}
				Tween.clearTween(this.mDisabledSpr);
				this.mDisabledAnimation.play();
				Tween.to(this.mDisabledSpr, {alpha:1}, 100, null, null, ConfigServer.system_simple.wait_time);
			}else{
				if (this.mDisabledSpr){
					Tween.clearTween(this.mDisabledSpr);
					this.mDisabledAnimation.stop();
					this.mDisabledSpr.alpha = 0;
				}
			}
		}
		
		private function event_map_in_out(change:Boolean,inside:int = -1):void{
			if(change){
				ModelManager.instance.modelGame.isInside = !ModelManager.instance.modelGame.isInside;
			}
			var reV:Boolean = false;
			if(inside>-1){
				var rb:Boolean = (inside==1);
				if(ModelManager.instance.modelGame.isInside != rb){
					reV = true;
					ModelManager.instance.modelGame.isInside = rb;
				}
			}
			else{
				reV = true;
			}
			if(!reV){
				return;
			}
			if(this.mSceneMain){
				this.mSceneMain.destroy();
				this.mSceneMain = null;//
			}
			this.mLayerMap.destroyChildren();
			//
			var _this:* = this;
			//
			if(ModelManager.instance.modelGame.isInside){
				this.mSceneMain = this.getHomeView();
			}else{
				this.mSceneMain = this.getMapView();
			}
			this.checkMenu(ModelManager.instance.modelGame.getMapType());
			this.mLayerMap.addChild(this.mSceneMain);
			//
		}
		private function getHomeView():HomeViewMain{
			return new HomeViewMain(); 
		}
		private function getMapView():MapViewMain{
			return new MapViewMain(); 
		}
		private function getInsideView():ViewInsideTest{
			return this.mViewInsideTest ||= new ViewInsideTest(); 
		}		
		//
		public function initMap():void{
			this.event_map_in_out(false);
		}
		//		
		public function initGame():void{
			this.mLayerGuide.addChild(new ViewGuide());		
			//
			this.initCheckTired();
			//
			this.closeView(true);
			//
			if(this.mLayerMenu){
				this.mLayerMenu.init();
			}			
		}
		public function initMenuFunc():void{
			this.checkMenuFun = true;			
			if(this.mLayerMenu){
				this.mLayerMenu.initFunc();
			}
		}
		/**
		 * 初始化 疲劳 检测 事件
		 */
		public function initCheckTired():void{
			ModelManager.instance.modelGame.off(ModelGame.EVENT_REAL_NAME_CHECK_TIRED_TIME,this,this.event_real_name_check_tired_time);
			ModelManager.instance.modelGame.on(ModelGame.EVENT_REAL_NAME_CHECK_TIRED_TIME,this,this.event_real_name_check_tired_time);
		}
		private function event_real_name_check_tired_time(len:Number,tips:*):void
		{
			this.showTipsTxt(Tools.getMsgById(tips),5);
		}
		/**
		 * stage,全局点击,检查编辑部队,第一次选中操作
		 */
		private function click_stage(e:Event):void
		{	
			//
			if(e.target is ItemTroop){
				return;
			}
			ModelManager.instance.modelGame.event(ModelGame.EVENT_TROOP_SELECT_TRUE);
		}
		private function click_stage_down(event:Event):void
		{
			if(this.mLayerTouchClip.numChildren>0){
				this.mLayerTouchClip.destroyChildren();
			}
			var tclip:Animation = EffectManager.loadAnimation("touch_sc","",1);
			tclip.mouseEnabled = false;
			tclip.mouseThrough = true;
			tclip.x = Laya.stage.mouseX;
			tclip.y = Laya.stage.mouseY;
			MusicManager.playSoundUI(MusicManager.SOUND_CLICK);
			this.mLayerTouchClip.addChild(tclip);
			return;			
		}
		public function checkMenu(type:int):void{
			if(this.mLayerMenu && this.checkMenuFun){
				this.mLayerMenu.onChange(type);
			}
		}
		/**
		 * 显示 viewPanel or viewScenes
		 * cfg 类配置
		 * arg 附加参数
		 * other 特殊显示配置{type:基本显示样式,child:是否全部清理}
		 */
		public function showView(cfg:*,arg:* = null,other:Object = null):* {
			//cfg:*,arg:* = null,visibleBg:int = 1,child:* = null
			if(other === 0){
				other = {type:0};
			}
			var param:Object = other?other:{type:1,child:null};
			var type:int = 1;
			var child:* = null;
			if(param.hasOwnProperty("type")){
				type = param.type;
			}
			if(param.hasOwnProperty("child")){
				child = param.child;
			}			
			var view:* = ObjectSingle.getObjectByArr(cfg);
			if(view is ViewScenes){
				this.showScenes(cfg,arg,type,Tools.isNullObj(child)?false:child);
			}
			else{
				this.showPanel(cfg,arg,type,child);
			}
			Tools.resetHelpData();
			return view;
		}
		public function closeView(all:Boolean):void
		{
			this.closePanel();
			this.closeScenes(all);
			if(QueueManager.instance.mIsOver){//一系列弹窗结束之后
				if(ModelManager.instance.modelUser.credit_settle && ModelManager.instance.modelUser.credit_settle.length!=0){
					if(ModelGuide.forceGuide()){
						return;
					}
					Laya.timer.clear(this,showCreditResult);
					Laya.timer.once(500,this,showCreditResult);
				}
			}
		
		}

		private function showCreditResult():void{
			ViewManager.instance.showView(["ViewCreditResult",ViewCreditResult]);
		}
		/**
		 * 场景级别面板,arg = 附加的参数
		 * 
		 * child 在已有场景基础上再 显示 场景
		 */
		private function showScenes(cfg:*,arg:* = null,bgStyle:int = 1,child:Boolean = false):void{
			//
			this.checkMenu(3);
			//
			if(!cfg){
				
			}
			else{
				if(child){
					this.savePanelsByScenceArr(this.mScenesShow.id);
					this.mLayerScenes.removeChild(this.mScenesShow as ViewScenes);
				}
				//
				this.mScenesShow = this.checkArr(this.mScenesArr,ObjectSingle.getObjectByArr(cfg)) as ViewScenes;
				//
				this.mScenesShow.id = cfg[0];
				//
				this.mScenesShow.currArg = arg;
				//
				this.mScenesShow.checkBg(bgStyle);
			}
			this.mScenesShow.init();
			//
			this.mLayerScenes.addChild(this.mScenesShow);
			//
			this.mLayerMap.visible = false;
			//
			if(!cfg){
				this.openPanelsByScenceArr(this.mScenesShow.id);
			}else{
				if(arg){
					ObjectSingle.getObjectByArr(cfg).event("changeTab",arg);
				}
			}

			if(mLayerSceneParent){
				this.mLayerMap.visible = true;
				mLayerSceneParent.visible = mScenesArr.length!=0;
			}
		}
		private function checkArr(arr:Array,obj:*):*{
			var b:Boolean = false;
			var index:int = -1;
			if(arr){
				for(var i:int = 0;i<arr.length;i++){
					if(arr[i] == obj){
						b = true;
						index = i;
						break;
					}
				}
				if(!b){
					arr.unshift(obj);
				}
				else{
					var find:* = arr[index];
					arr[index] = arr[0];
					arr[0] = find;
				}
			}
			return arr[0];
		}
		public function closeScenes(all:Boolean = false):void{
			this.closeScenesFunc(all);
			if(mLayerSceneParent){
				mLayerSceneParent.visible = mScenesArr.length!=0;
			}
		}
		private function closeScenesFunc(all:Boolean = false):void{			
			if(all){
				this.mScenesArr = [];
			}
			else{
				if(this.mScenesArr.length>0){
					this.mLayerScenes.removeChild(this.mScenesArr.shift() as ViewScenes);
				}
			}
			if(this.mScenesArr.length<=0){
				AssetsManager.clearTempAll();
			}
			//
			if(this.mScenesArr.length>0){
				this.mScenesShow = this.mScenesArr[0] as ViewScenes;
				this.showScenes(null,this.mScenesShow.currArg,this.mScenesShow.mBgType);
			}
			else{
				this.mLayerScenes.removeChildren();
				this.mScenesShow = null;
				this.mLayerMap.visible = true;
				this.checkMenu(ModelManager.instance.modelGame.getMapType());
			}	
			if(!QueueManager.instance.mIsOver){
				this.event(ViewManager.EVENT_PANEL_CLEAR);
				QueueManager.instance.event(QueueManager.EVENT_CLOSE_PANEL,"");
			}
			
			if(this.mScenesArr.length<=0){
				this.showFreeBuy();
			}
			Tools.resetHelpData();		
		}

		/**
		 * 购买资源面板
		 */
		public function showFreeBuy():void{
			//不开充值就不执行
			if(ModelGame.unlock(null,"pay").stop){
				return;
			}

			if(ModelManager.instance.modelUser.free_buy_key=="" || ModelGuide.forceGuide()){
				return;
			}
			ModelFreeBuy.instance.checkData();
			if(this.mScenesArr.length==0 && ModelFreeBuy.instance.mData.length>0){
				ViewManager.instance.showView(ConfigClass.VIEW_FREE_BUY);
				//ModelManager.instance.modelUser.free_buy_key="";
			}
		}

		/**
		 * 警告面板
		 * @param	text 文字1
		 * @param	fun 关闭回调
		 * @param	cost_arr 花费资源和数量  可缺省
		 * @param	text 花费文字提示  可缺省
		 * @param	only 确定/确定和取消
		 * @param	force_btn 是否可以强制关闭
		 * @param	repeat_key 勾选不再提示的key
		 */
		public function showAlert(text:String,fun:*,cost_arr:Array=null,text2:String="",only:Boolean = false,force_btn:Boolean = false,repeat_key:String=""):void{
			var mdl:ModelAlert=ModelManager.instance.modelAlert;
			mdl.only = only;
			mdl.force_btn = force_btn;
			mdl.text=text;
			mdl.fun=fun;
			mdl.cost_arr=cost_arr;
			mdl.text2=text2;
			mdl.isWarn=false;
			mdl.repeat_key=repeat_key;
			if(Tools.checkAlertIsDel(repeat_key)){
				mdl.execute(0);						
				return;
			}
			this.showView(["ViewAlert",ViewAlert]);
		}
		public function showWarnAlert(msg,fun):void{
			this.showWarn(msg,fun,null,"",true,true);
		}
		public function showWarn(text:String,fun:*,cost_arr:Array=null,text2:String="",only:Boolean = false,force_btn:Boolean = false):void{
			if(this.mLayerWarn && this.mLayerWarn.visible && this.mLayerWarn["showTxt"]){
				if(this.mLayerWarn["showTxt"] == text){
					return;
				}
			}
			var mdl:ModelAlert=ModelManager.instance.modelAlert;
			mdl.only = only;
			mdl.force_btn = force_btn;
			mdl.text=text;
			mdl.fun=fun;
			mdl.cost_arr=cost_arr;
			mdl.text2=text2;	
			mdl.isWarn=true;	
			//
			
			//
			var view:* = null;

			if(only && force_btn){
				view = new ViewAlert2();	
				view.id = "ViewAlert";	
				view.checkBg(1);
				view.init();
			}
			else{
				view = new ViewAlert();	
				view.id = "ViewAlert";
				view.checkBg(1);			
				view.init();					
			}
			this.mLayerWarn.visible = true;
			this.mLayerWarn["showTxt"] = text;
			this.mLayerWarn.destroyChildren();
			this.mLayerWarn.addChild(view);
		}
		public function clearWarn():void{
			this.mLayerWarn.destroyChildren();
			this.mLayerWarn.visible = false;
		}

		/**
		 * 购买次数面板  //type 购买的次数,剩余购买次数,花费的coin值
		 */
		public function showBuyTimes(type:int,buy_times:Number,remain_num:Number,cost_num:Number):void{
			var socketName:String="";
			//var txt_goods:String = Tools.getMsgById("_public146");//"挑战次数";
			var txt_title:String = Tools.getMsgById("_buy_times_0",[buy_times]);
			var txt_tips:String = Tools.getMsgById("_public148",[remain_num, Tools.getTimeStyle(ConfigServer.system_simple.deviation*Tools.oneMinuteMilli,3)]);
			switch(type){
				case 0://climb
					socketName = NetMethodCfg.WS_SR_BUY_CLIMB_TIMES;
					break;
				case 1://pk
					socketName = NetMethodCfg.WS_SR_BUY_PK_TIMES;
					break;
				case 2://pve
					socketName = "buy_pve_times";
					break;
				case 3://hero_chatch
					socketName = "buy_hero_catch_pk_times";
					//txt_goods = Tools.getMsgById("task066_name");//"切磋次数";
					txt_title = Tools.getMsgById("_buy_times_1",[buy_times]);
					break;
				case 4: // 限时免单
					socketName = NetMethodCfg.WS_SR_BUY_LIMIT_FREE_TIMES;
					//txt_goods = Tools.getMsgById("_jia0066");//"购买次数";
					txt_title = Tools.getMsgById("_buy_times_2",[buy_times]);
					txt_tips = Tools.getMsgById("_jia0068", [remain_num]);// 剩余购买次数：{0}次
					break;
				case 5://arena
					socketName = "buy_arena_times";
					txt_tips = "";
					break;
				case 6://beast_bag
					//txt_goods = Tools.getMsgById('_beast_text37');//"背包格子"
					socketName = "buy_beast_times";
					txt_title = Tools.getMsgById("_buy_times_3",[buy_times]);
					txt_tips = "";
					break;
			}
			//var txt_title:String = Tools.getMsgById("_public147",[buy_times, txt_goods]);
			var _this:* = this;
			this.showAlert(txt_title,Handler.create(this,function(type:int):void{
				if(type==0){
					if(!Tools.isCanBuy("coin",cost_num)){
						return;
					}
					NetSocket.instance.send(socketName, {}, Handler.create(_this,_this.buyTimesRe));
				}
			}),["coin", cost_num], txt_tips);
		}
		private function buyTimesRe(re:NetPackage):void{
            ModelManager.instance.modelUser.updateData(re.receiveData);
            ModelManager.instance.modelGame.event(ModelGame.EVENT_PK_TIMES_CHANGE);
			ViewManager.instance.showTipsTxt(Tools.getMsgById("_public194"));
        }
		/**
		 * 普通弹出面板,arg = 附加的参数
		 */
		private function showPanel(cfg:*,arg:* = null,visibleBg:int = 1,child:* = null):void{
			if(cfg){
				this.mPanelShow = ObjectSingle.getObjectByArr(cfg) as ViewPanel;
				this.mPanelShow.id = cfg[0];
				this.mPanelShow.currArg = arg;
				this.mPanelShow.checkBg(visibleBg);
			}
			else{
				this.mPanelShow = child;
			}
			this.mPanelShow.init();
			//
			this.mLayerPanel.addChild(this.mPanelShow);
			//
		}
		private function openPanelsByScenceArr(id:String):void{
			var panelArr:Array = this.mPanelArr[id];
			if(panelArr){
				var len:int = panelArr.length
				for(var i:int = 0; i < len; i++)
				{
					this.showPanel(null,null,1,panelArr[i]);
				}
				delete this.mPanelArr[id];
				// Trace.log("---- openPanelsByScenceArr ----",id,this.mPanelArr);
			}
		}
		public function isNoPanel():Boolean{
			if (this.mLayerPanel.numChildren <= 0){
				return true;
			}
			return false;
		}

		public function isNoScence():Boolean{
			if (this.mLayerScenes.numChildren <= 0){
				return true;
			}
			return false;
		}
		
		private function savePanelsByScenceArr(id:String):void{
			var i:int=0;
			//
			var panelArr:Array = [];
			if(this.mLayerPanel.numChildren>0){
				for(i=0;i<this.mLayerPanel.numChildren;i++){
					panelArr.push(this.mLayerPanel.getChildAt(i));
				}
				this.mPanelArr[id]=panelArr;
			}
			// Trace.log("---- savePanelsByScenceArr ----",id,this.mPanelArr);
			//
			this.closePanel();
		}
		public function closePanel(child:* = null):void{
			if(child == null){
				this.mLayerPanel.removeChildren();
				this.mPanelShow = null;
			}
			else{
				this.mLayerPanel.removeChild(child as ViewBase);
				if(this.mLayerPanel.numChildren>0){
					this.mPanelShow = this.mLayerPanel.getChildAt(this.mLayerPanel.numChildren-1) as ViewPanel;
				}
				else{
					this.mPanelShow = null;
					if(!QueueManager.instance.mIsOver){
						this.event(ViewManager.EVENT_PANEL_CLEAR);
						QueueManager.instance.event(QueueManager.EVENT_CLOSE_PANEL,child.id);
					}
				}
			}
			if(this.mScenesArr.length<=0){
				this.showFreeBuy();
			}	
			Tools.resetHelpData();
		}
		private function event_socket_re_code_error(re:Object):void{
			if(re.data.msg){
				//this.showTipsTxt("服务器:"+re.data.msg);
				this.showTipsTxt(re.data.msg);
			}
		}

		/**
		 * 文本提升面板
		 * style = {iColor:"",tColor:""};
		 */
		public function showTipsPanel(str:String,w:Number = 0,title:String = "",style:Object = null):void
		{
			this.showView(ConfigClass.VIEW_TIPS_INFO,[str,w,title,style]);
		}
		/**
		 * 场景中间显示的,文字提示
		 * timeMax == 秒
		 */
		public function showTipsTxt(str:String,timeMax:Number = 2,parentComponent:Component = null):void{
			if(Tools.isNullString(str)){
				Trace.log("show tips txt 没有文字配置");
				return;
			}
			// if(this.mLayerTxtTips.numChildren>0){
			// 	return;
			// }
			this.closeTipsTxt();
			//
			var box:Box = new Box();
			// var bg:Sprite = new Sprite();
			var bg:Image = new Image();
			// bg.graphics.drawRect(0,0,Laya.stage.width,50,"#000000");
			// bg.alpha = 0;
			bg.skin = AssetsManager.getAssetsUI("icon_war007.png");
			bg.width = 750;
			bg.height = 80;
			bg.alpha = 0;
			box.addChild(bg);
			//
			//var txt:Label = new Label();
			var txt:HTMLDivElement=new HTMLDivElement();
			txt.style.color = "#ffa627";
			txt.style.align = "center";
			txt.style.valign = "middle";
			txt.style.fontSize = 18;
			txt.style.leading = 6;
			txt.style.wordWrap = true;
			txt.innerHTML = str;			
			txt.width = 600;
			// txt.height = 80;
			box.addChild(txt);
			txt.x = (750 - 600)*0.5;
			txt.y = (80-txt.contextHeight)*0.5;
			box.width = bg.width;
			box.height = 80;
			box.x = 0;
			box.y = 0;
			txt.alpha = 0;
			//
			Tween.to(bg,{alpha:1},300);
			Tween.to(txt,{alpha:1},300,null,null,150);
			//
			// Laya.timer.once(2000,this,this.closeTipsTxt);

			if (!parentComponent){
				parentComponent = this.mLayerTxtTips;
				Tween.to(box, {alpha:0, y: -30}, 300, null, Handler.create(this, this.closeTipsTxt), timeMax * Tools.oneMillis);
			}else{
				Tween.to(box, {alpha:0, y: -30}, 300, null, Handler.create(box, box.destroy), timeMax * Tools.oneMillis);
			}
			parentComponent.centerX = 0;
			parentComponent.centerY = -100;
			
			parentComponent.addChild(box);
		}
		private function closeTipsTxt():void{
			this.mLayerTxtTips.destroyChildren();
		}
		
		/**
		 * 展示提示面板
		 * @param	content 提示内容（支持html文本）
		 * @param	title 标题（支持html文本）
		 * @param	dataArr 按钮数据（支持一个或两个按钮）[{name:Tools.getMsgById("_public183"), fun:Handler.create(this,this.doSth)}, {name:Tools.getMsgById("_shogun_text03")}]
		 * 点击任意一个按钮都会关闭面板，如果有绑定的方法则会执行对应的方法
		 */
		public function showHintPanel(content:String, title:String = null, dataArr:Array = null):void {
			this.showView(["ViewHintPanel",ViewHintPanel], {
				'content': content,
				'title': title,
				'dataArr': dataArr
			});
		}

		/**
		 * 展示奖励面板
		 */
		public function showRewardPanel(gift_dict:*,fun:*=null,is_preview:Boolean=false):void{
			if(gift_dict==null){
				return;
			}
			if(gift_dict is Array){
				if(gift_dict.length!=0){
					var b:Boolean=false;
					for(var i:int=0;i<gift_dict.length;i++){
						if(Tools.getDictLength(gift_dict[i])!=0){
							b=true;
							break;
						}	
					}
					if(b==false){
						return;
					}
				}else{
					return;
				}
			}else{
				if(Tools.getDictLength(gift_dict)==0){
					return;
				}
			}
			
			
			this.showView(ConfigClass.VIEW_GET_REWARD,[fun,is_preview,gift_dict]);
		}

		/**
		 * 钱粮木铁、道具飞行动画
		 */
		public function showIcon(gift_dict:Object,posX:Number,posY:Number,only:Boolean=false,showText:String="",hasBag:Boolean = true,scaleNum:Number = 0.8):void{
			posX=posX<20 ? 20 : posX;
			posX=posX>=Laya.stage.width?Laya.stage.width-20:posX;			

			for(var s:String in gift_dict)
			{
				// if(s=="gold"|| s=="coin"|| s=="wood" ||  s=="food" || s=="iron"){
				if(ModelBuiding.material_type.indexOf(s)>-1)
				{
					var a:Array=pos_dict_pos[s];
					EffectManager.createIconFlight(AssetsManager.getAssetItemOrPayByID(s), posX, posY, a[0],a[1],1,20,this.mLayerClip);
					EffectManager.textFlight(gift_dict[s], showText, posX, posY,this.mLayerClip);
					ModelManager.instance.modelUser.event(ModelUser.EVENT_TOP_UPDATE,[[gift_dict]]);
				}else{
					if(!only){

						var _posX:Number = Laya.stage.width / 2 + 80;
						if(ConfigApp.isPC){
							_posX = Laya.stage.width - (140 + 200);
						}
						var _posY:Number = Laya.stage.height - 50;
						var com:bagItemUI=new bagItemUI();
						if(s=="title" || s=="equip"){
							var arr:Array=gift_dict[s];
							for(var i:int=0;i<arr.length;i++){
								com.setData(arr[i],1,-1);
								break;
							}
						}else if(s=="credit"){
							com.setData("item041",gift_dict[s],-1);		
						}else{
							com.setData(s,gift_dict[s],-1);
						}
						if(s.indexOf("sale")!=-1){
							_posX = pos_dict_pos["coin"][0];
							_posY = pos_dict_pos["coin"][1];
						}
						/*
						//var d:Object={};
						if(s.indexOf("star")!=-1){
							var rmd:ModelRune=ModelManager.instance.modelGame.getModelRune(s);
							com.setData(rmd.getImgName(),0,"","1");														
						}else if(s.indexOf("item")!=-1){
							var imd:ModelItem =ModelManager.instance.modelProp.getItemProp(s);
							com.setData(imd.icon,imd.ratity,"",gift_dict[s]+"",imd.type);
						}else if(s.indexOf("equip")!=-1){
							var emd:ModelEquip=ModelManager.instance.modelGame.getModelEquip(s);
							com.setData(ModelEquip.getIcon(s),0,"","");		
						}else if(s.indexOf("title")!=-1){
							com.setData(s,0,"","");		
						}*/
						com.x = posX;
						com.y = posY;
						com.scale(scaleNum,scaleNum);

						EffectManager.itemFlight(com, _posX, _posY, this.mLayerClip, hasBag);
					}
				}
			}					
		}

		/**
		 * 展示道具飞行动画
		 * isShow 是否显示动画  否的话 top栏直接刷新数据
		 */
		public function showReward(obj:Object,isShow:Boolean=true):void{
			if(isShow){
				this.showIcon(obj,Laya.stage.width/2,Laya.stage.height/2);
			}else{
				ModelManager.instance.modelProp.getRewardProp(obj,true);
				ModelManager.instance.modelUser.event(ModelUser.EVENT_TOP_UPDATE,[[obj]]);
			}
		}

		public function clearViewEffectSpecial(specialName:String):void{
			// var len:int = this.mLayerViewEffect.numChildren;
			var efb:EffectUIBase;
			// for(var i:int = 0;i < len;i++){
				efb = this.mLayerViewEffect.getChildByName(specialName) as EffectUIBase;
				if(efb){
					efb.destroy(true);
				}
			// }
		}
		/**
		 * 特殊动画层级
		 */
		public function showViewEffect(effect:Component,alpha:Number = 0.5,callback:Handler = null,onlyOne:Boolean = false,through:Boolean = false,specialName:String = ""):void{
			if(onlyOne){
				this.mLayerViewEffect.destroyChildren();
			}
			var eff:EffectUIBase = new EffectUIBase(alpha,callback,through);
			if(specialName!=""){
				eff.name = specialName;
			}
			eff.width = Laya.stage.width;
			eff.height = Laya.stage.height;
			eff.y=0;
			eff.init();
			if(effect){
				effect.mouseEnabled = false;
				effect.mouseThrough = true;
				effect.centerY=0;
				// (effect as BaseSprite).test_clip_int(0);
				eff.addChild(effect);
			}
			this.mLayerViewEffect.mouseThrough = through;
			this.mLayerViewEffect.addChild(eff);
		}
		/**
		 * 顶层动画层，动画需无点击事件且自身回收
		 */
		public function showEffect(effect:Sprite, center:Boolean = true):void{
			if (center)
			{
				effect.x = Laya.stage.width * 0.5;
				effect.y = Laya.stage.height * 0.5;
			}
			this.mLayerEffect.addChild(effect);
		}
		
		private function visibleLayers(b:Boolean):void{
			this.mLayerMap.visible = b;
			this.mLayerMenu.visible = b;
			this.mLayerScenes.visible = b;
			// this.mLayerPanel.visible = b;
		}
		/**
		 * 战斗加载完成，显示战斗画面，隐藏其他
		 */
		public function showFightScenes(sp:Sprite):void{
			this.mLayerFight.addChild(sp);
			this.visibleLayers(false);
			GuideFocus.focusOut();
			var client:ClientBattle = FightMain.instance.client;
			if(client){
				client.playBGM();
			}
		}
		public function closeFightScenes():void{
			this.visibleLayers(true);
			this.mLayerFight.destroyChildren();
			MusicManager.playBackMusic();
			ModelGuide.battleOver();
		}		

		/**
		 * 英雄对话面板 
		 */
		public function showHeroTalk(talk_arr:Array,fun:* = null):void{
			//talk_arr=[["hid","hname"("1"就找hid的名字),"content"],]
			this.event(EVENT_CLOSE_HERO_TALK);
			ViewManager.instance.showView(["ViewHeroTalk",ViewHeroTalk],[talk_arr,fun]);
		}
		public function showNotice(data:Object):void
		{
			if(ModelGame.unlock(null,"army_push").stop){
				return
			}
			if(this.mLayerNotice){
				this.mLayerNotice.input(data);
			}
		}

		public function showCarouse():void{
			carouse_count++;
			var cfg:Object = ConfigServer.notice.carouse_notice;
			if(cfg==null) return;

			var _zone:String = ModelManager.instance.modelUser.zone;
			var _merge_zone:String = ModelManager.instance.modelUser.mergeZone;
			var _pf:String = ConfigApp.pf;

			var _content:Array = [];
			var b:Boolean = false;
			var arr:Array = [];
			if(cfg.pf){
				if(cfg.pf[0].length==0 && cfg.pf[1].length==0){
					b = true;
				}else if(cfg.pf[0].length!=0){
					//可见的平台
					if(cfg.pf[0].indexOf(_pf)!=-1) b = true;
				}else if(cfg.pf[1].length!=0){
					//不可见的平台
					if(cfg.pf[1].indexOf(_pf)==-1) b = true;
				}
			}else{
				b = true;
			}
			if(b){
				arr = cfg.content ? cfg.content : [];
				for(var i:int=0;i<arr.length;i++){
					_content.push(arr[i]);
				}
				arr = [];
			}
			
			if(cfg.zone_content){
				if(cfg.zone_content[_merge_zone]){
					arr = cfg.zone_content[_merge_zone];	
				}else if(cfg.zone_content[_zone]){
					arr = cfg.zone_content[_zone];	
				}
				for(var j:int=0;j<arr.length;j++){
					_content.push(arr[j]);
				}
				arr = [];
			}

			if(cfg.pf_content){
				if(cfg.pf_content[_pf]){
					arr = cfg.pf_content[_pf]
				}
				for(var k:int=0;k<arr.length;k++){
					_content.push(arr[k]);
				}
				arr = [];
			}
			trace("=========轮播公告",_content);
			if(carouse_count < 2 || _content.length==0){
				this.mLayerCarouse.visible=false;
				this.mLayerCarouse.clerMyTimer();
				return;
			}
			if(this.mLayerCarouse){
				this.mLayerCarouse.visible=true;
				if(this.mLayerCarouse.getChildByName("carouse")){
					this.mLayerCarouse.removeChildByName("carouse");
				}

				for(var l:int=0;l<_content.length;l++){
					if(ConfigServer.notice.notice_cn[_content[l]]){
						arr.push(ConfigServer.notice.notice_cn[_content[l]]);
					}
				}
				if(arr.length>0){
					this.mLayerCarouse.input(
					{"interval_time":ConfigServer.notice.carouse_notice.interval_time,
						"content":arr});
				}
			}
		}
		/**
		 * 显示道具小提示
		 * @param id 现在只支持item和equip和钱粮木铁功勋
		 * @param 是否分类显示 否的话只显示统一样式  是的话分别英雄和技能显示
		 */
		public function showItemTips(id:String,_num:Number=-1,isItem:Boolean=false):void{
			if(id.indexOf("equip")!=-1){
				//ViewManager.instance.showView(ConfigClass.VIEW_BAG_ITEM_TIPS,[id,_num]);
				ViewManager.instance.showView(ConfigClass.VIEW_EQUIP_MAKE_INFO,ModelManager.instance.modelGame.getModelEquip(id));
			}else if(id.indexOf("star")!=-1){
				ViewManager.instance.showView(ConfigClass.VIEW_BAG_ITEM_TIPS,[id,ModelRune.getNum(id)]);
			}else if(id.indexOf("title")!=-1){
				//var num:Number = ModelClimb.formatRankAward(id).length;
				// trace(tid,arr);
				
				var tid:String = (id.indexOf("_0")!=-1) ? id.split('_')[0] : id;
				var passive:Object = ConfigServer.title[tid].passive;
				var html:String = (id.indexOf("_0")!=-1) ? Tools.getMsgById("titleinfo_random") : PassiveStrUtils.translatePassiveInfo(passive, false, false, 3);
				var str:String = StringUtil.htmlFontColor(ModelHero.getTitleInfo(tid),"#ffffff")+"<br/><br/>"+html;
				ViewManager.instance.showTipsPanel(str,0,ModelHero.getTitleName(tid),{iColor:"#ff9519"});				
			}else if(id.indexOf("skill")!=-1){
				ViewManager.instance.showView(ConfigClass.VIEW_SHOP_SKILL_TIPS,id);		
			}else if(id.indexOf("hero")!=-1){//显示觉醒英雄信息
				if(ConfigServer.hero.hasOwnProperty(id)){
					var hmd:ModelHero=new ModelHero(true);
					var c:Object=ConfigServer.hero[id];
					c["awaken"]=1;
					c["hid"]=id;
					hmd.setData(c);
					ViewManager.instance.showView(ConfigClass.VIEW_HERO_TALENT_INFO,hmd);		
				}
				
			}else if(id.indexOf("sale")!=-1){
				ViewManager.instance.showView(ConfigClass.VIEW_BAG_ITEM_TIPS,[id]);
			}else{
				if(id=="item041"){//战功
					ViewManager.instance.showView(ConfigClass.VIEW_BAG_ITEM_TIPS,[id,ModelManager.instance.modelUser.year_credit]);
				}else{
					var it:ModelItem=ModelManager.instance.modelProp.getItemProp(id);
					if(it){
						if(isItem && it.type!=7){
							ViewManager.instance.showView(ConfigClass.VIEW_BAG_ITEM_TIPS,[id,_num]);
						}else{
							if(it.type==7){//英雄碎片
								ViewManager.instance.showView(ConfigClass.VIEW_SHOP_HERO_TIPS,id);
							}else if(it.type==2){//技能碎片
								ViewManager.instance.showView(ConfigClass.VIEW_SHOP_SKILL_TIPS,id);
							}else if(it.equip_info && it.equip_info.length==1){//宝物碎片
								ViewManager.instance.showView(ConfigClass.VIEW_SHOP_EQUIP_TIPS,id);
							}else{
								ViewManager.instance.showView(ConfigClass.VIEW_BAG_ITEM_TIPS,[id,_num]);
							}
						}
						
					}
				}
				
			}
		}
		
		/**
		 * 获取当前展示的场景（在引导中使用）
		 */
		public function getCurrentScene():ViewScenes
		{
			return this.mScenesShow;
		}
		
		/**
		 * 获取当前展示的面板（在引导中使用）
		 */
		public function getCurrentPanel():ViewPanel
		{
			return this.mPanelShow;
		}

		/**
		 * 获取当前展示的面板（在引导中使用）
		 */
		public function getCurrentEffect():Sprite
		{
			return this.mLayerViewEffect.getChildAt(0) as Sprite;
		}
	}

}