package sg.guide.model
{
	import laya.display.Sprite;
	import laya.events.EventDispatcher;
	import laya.utils.Handler;
	import sg.cfg.ConfigServer;
	import sg.manager.ViewManager;
	import sg.task.model.ModelTaskMain;
	import laya.net.Loader;
	import sg.model.ModelUser;
	import sg.net.NetSocket;
	import sg.net.NetMethodCfg;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.utils.ObjectUtil;
	import sg.cfg.ConfigClass;
	import sg.model.ModelHero;
	import sg.guide.view.ViewGuide;
	import sg.manager.LoadeManager;
	import sg.scene.view.InputManager;
	import sg.utils.MusicManager;
	
	/**
	 * ...
	 * @author jiaxuyang
	 */
	public class ModelGuide extends EventDispatcher
	{
		
		//引导类型
		public static const TYPE_GOTO:String = "goto";	// 跳转0
		public static const TYPE_CLICK:String = "click";// 点击型引导
		public static const TYPE_IMAGE:String = "image";// 图片型引导
		public static const TYPE_TALK:String = "talks";	// 对话型引导
		public static const TYPE_RECRUIT:String = "recruit_hero";	// 招募
		public static const TYPE_ALIEN:String = "alien_first";	// 首次刷异族
		public static const TYPE_SAVE:String = "save";	// 保存进度
		public static const TYPE_DELAY:String = "delay";	// 等待
		public static const TYPE_BATTLE:String = "in_battle";	// 进入战斗
		public static const TYPE_SOUND:String = "sound";	// 播放音效
		public static const LOCK_SCREEN:String = "lock_screen";	// 锁定屏幕

		public static const SINGLE_OVER:String = "single_over";	// 单个引导结束
		public static const ALL_OVER:String = "all_over";	// 单个引导结束
		// public static const BASE_READY:String = "base_ready";	// 显示对象准备好了

		public var inited:Boolean = false;	// 引导是否初始化
		public var country:int = 0;	// 国家
		private var cID:int;	// 城市ID
		private var bID:String;	// 建筑ID

		private var checker:GuideChecker = GuideChecker.instance;	// 引导进度检查器
		private var buildArray:Array = null;	// 补偿数组

		private var guideKeys:Array = null;	// 引导类型
		
		// 单例
		private static var sModel:ModelGuide = null;
		
		public static function get instance():ModelGuide
		{
			return sModel ||= new ModelGuide();
		}

		public function ModelGuide()
		{
			guideKeys = [TYPE_GOTO, TYPE_CLICK, TYPE_TALK, TYPE_SOUND, TYPE_SAVE, TYPE_DELAY, TYPE_BATTLE, TYPE_RECRUIT, TYPE_IMAGE, TYPE_ALIEN];
			this.checker.on(GuideChecker.DO_GUIDE, this, this.beforeDoGuide);
			this.checker.on(GuideChecker.ALL_OVER, this, this.guideOver);
		}

		private function beforeDoGuide():void
		{
			this.lockScreen = true;
			Laya.timer.once(50, this, this.doGuide);
		}

		/**
		 * 执行引导
		 */
		private function doGuide():void {
			this.country = ModelUser.getCountryID();
			InputManager.instance.canDrag = false;
			var cfg:Object = checker.getCurrentGuideData(); // 每一步引导的配置
			var keys:Array = ObjectUtil.keys(cfg);
			keys = guideKeys.filter(function(str:String):Boolean{ return keys.indexOf(str) !== -1 });
			keys = keys.reverse();
			for(var i:int = 0, len:int = keys.length; i < len; i++) {
				this.doGuideReal(keys[i], cfg);
			}
			// console.info('ID:' +  checker._guideID + '  引导类型' + key + '  点击对象: ' + (key === 'click' ? cfg[key].type: '') + '  子对象:' + (key === 'click' ? cfg[key].objName: ''));
		}

		private function doGuideReal(key:String, cfg:Object):void {
			switch(key)
			{
				case TYPE_GOTO:
					this.gotoSomeWhere(cfg[key]);
					break;
				case TYPE_CLICK:
					this.hintClick(cfg[key]);
					break;
				case TYPE_TALK:
					this.showTalk(cfg[key] as Array);
					break;
				case TYPE_SAVE:
					this.saveProgress();
					break;
				case TYPE_DELAY:
					this.waitASecond(cfg[key]);
					break;
				case TYPE_BATTLE:
					this.event(TYPE_BATTLE);
					break;
				case TYPE_RECRUIT:
					this.recruitHero(cfg);
					break;
				case TYPE_IMAGE:
					this.showImage(cfg[key]);
					break;
				case TYPE_ALIEN:
					this.firstAlien();
					break;
				case TYPE_SOUND:
					MusicManager.playSoundUI(cfg[key]);
					break;
			}
			
		}

		/**
		 * 前往
		 */
		private function gotoSomeWhere(cfg:Object):void {
			cfg = ObjectUtil.clone(cfg);
			var cityID:Array = cfg.cityID;
			var buildingID:String = cfg.buildingID;
			if (cityID is Array) {
				cityID.length === 3 && (cfg.cityID = this.cID = cityID[this.country]);
			}
			else if (buildingID is String) {
				buildingID.indexOf('building') !== -1 && (this.bID = buildingID);
			}
			this.event(TYPE_GOTO, [cfg]);
		}

		/**
		 * 展示图文
		 */
		private function showImage(cfg:Object):void {
			this.event(TYPE_IMAGE, [cfg]);	
		}
		
		/**
		 * 展示对话
		 */
		private function showTalk(talks:Array):void {
			this.event(TYPE_TALK);
			ViewManager.instance.showHeroTalk(talks, Handler.create(this, this.nextStep));	
		}
		
		/**
		 * 招募英雄
		 */
		private function recruitHero(cfg:Object):void {
			this.event(TYPE_RECRUIT, [cfg]);	
		}

		/**
		 * 提示点击
		 */
		private function hintClick(cfg:Object):void {
			this.event(TYPE_CLICK, [cfg]);
		}

		/**
		 * 刷异族
		 */
		private function firstAlien():void
		{
			ModelManager.instance.modelGame.checkPKnpcTimer(1000);//异族入侵
			this.nextStep();
		}
		/**
		 * 保存进度
		 */
		private function saveProgress():void
		{
			this.nextStep();
		}
		/**
		 * 等待一段时间
		 */
		private function waitASecond(duration:Number):void
		{
			var arrow:* = ViewGuide.instance['arrow'];
			duration > 100 && arrow && arrow.reset();
			Laya.timer.once(duration, this, this.nextStep);
		}

		/**
		 * 是否锁定屏幕
		 */
		public function set lockScreen(value:Boolean):void
		{
			this.event(LOCK_SCREEN, [value]);
		}
		
		/**
		 * 继续下一步
		 */
		public function nextStep():void
		{
			this.lockScreen = true;
			checker.continueGuide();
		}
		
		/**
		 * 引导结束之后调用
		 * @param	guideType
		 */
		public function guideOver():void
		{
			this.lockScreen = false;
			InputManager.instance.canDrag = true;
			this.event(ALL_OVER);
			// console.info('<<<<<<<<<<<<<<<<<<<<<   ALL Guide Over   >>>>>>>>>>>>>>>>>>>>>>');
		}
		
		/**
		 * 获取城市ID
		 */
		public function get cityID():int {
			return this.cID;
		}
		
		/**
		 * 获取建筑ID
		 */
		public function get buildingID():String {
			return this.bID;
		}

		/**
		 * 检测是否处于新手引导中
		 */
		public static function isNewPlayerGuide():Boolean
		{
			var checker:GuideChecker = instance.checker;
			if (checker && checker.canGuide) {
				// if (ModelManager.instance.modelUser.getLv() < 2)	return true;
				return instance.checker.guideType === GuideChecker.TYPE_MAIN;
			}
			return false;
		}

		/**
		 * 检查新手引导, 用于向服务器保存数据
		 */
		public static function checkNewPlayerGuideData(method:String):Object
		{
			if (ModelManager.instance.modelUser.isLogin && instance.checker) {
				return instance.checker.checkNewPlayerData(method);
			}
			return null; // 新手引导改为主动保存了
		}

		/**
		 * 检测是否是强制引导（强制引导包括新手引导）
		 */
		public static function forceGuide():Boolean
		{
			var checker:GuideChecker = instance.checker;
			return checker && checker.canGuide && checker.force;
		}

		/**
		 * 战斗结束
		 */
		public static function battleOver():void
		{
			if (forceGuide()) {
				instance.nextStep();
				// console.info('战斗结束');
			}
		}

		/**
		 * 检查引导是否执行过
		 */
		public static function checkGuideDataWithKey(key:String):Boolean
		{
			return GuideChecker.instance.canGuide && Boolean(instance.checker.checkGuideDataWithKey(key));
		}

		/**
		 * 执行条件引导
		 * @param	引导ID 
		 */
		public static function executeGuide(key:String = ''):void {
			var user:ModelUser = ModelManager.instance.modelUser;
			if (instance.checker.canGuide && user.getLv() >= 3) {
				if (key !== 'awaken_guide' && key !== 'animal_guide') {
					ViewManager.instance.closePanel();
				}
				instance.checker.initConditionGuide(key);
			}
		}

		/**
		 * 执行条件引导
		 * @param	引导ID 
		 */
		public static function executeWhenGuideOver(handler:Handler):void
		{
			instance.checker.once(GuideChecker.ALL_OVER, instance, function():void{handler.run()});
		}
	}

}