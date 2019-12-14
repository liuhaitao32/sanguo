package sg.guide.view
{
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.ui.List;
	import laya.utils.Handler;
	import sg.boundFor.GotoManager;
	import sg.cfg.ConfigClass;
	import sg.guide.model.ModelGuide;
	import sg.guide.view.ClickContainer;
	import sg.guide.view.GuideArrow;
	import sg.guide.view.MaskContainer;
	import sg.home.model.HomeModel;
	import sg.home.view.HomeViewMain;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.map.model.entitys.EntityHeroCatch;
	import sg.map.model.entitys.EntityMonster;
	import sg.map.view.MapViewMain;
	import sg.map.view.entity.CityClip;
	import sg.model.ModelGame;
	import sg.model.ModelHero;
	import sg.net.NetMethodCfg;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.scene.SceneMain;
	import sg.scene.constant.EventConstant;
	import sg.scene.model.MapGridManager;
	import sg.scene.model.entitys.EntityBase;
	import sg.scene.view.entity.EntityClip;
	import sg.scene.view.ui.Bubble;
	import sg.utils.ArrayUtil;
	import sg.utils.ObjectUtil;
	import sg.view.ViewBase;
	import sg.view.ViewPanel;
	import sg.view.ViewScenes;
	import sg.view.effect.EffectUIBase;
	import sg.view.menu.ViewMenuMain;
	import ui.home.HomeMenuItemUI;
	
	/**
	 * 引导视图
	 * @author jiaxuyang
	 */
	public class ViewGuide extends ViewBase
	{				
		private var maskContainer:MaskContainer;
		private var clickContainer:ClickContainer;
		private var arrow:GuideArrow;// 提示箭头
		
		private var model:ModelGuide = ModelGuide.instance;
		private var mapViewMain:SceneMain = null;
		private var homeViewMain:SceneMain = null;
		private var currentView:Sprite = null;
		private var rect:Rectangle = null;
		private var _finding:Boolean = false;	// 正在查询点击对象
		private var _findingPanel:Boolean = false;	// 正在查询点击对象
		private var guideConfig:Object = null;	// 当前点击引导配置文件
		private var _currentButton:Sprite = null;	// 当前点击引导配置文件
		private var _removeEvents:Array = null;	// 移除速度事件
		public function ViewGuide()
		{
			instance = this;
			
			// 创建遮罩所在容器
			this.maskContainer = new MaskContainer();
			
			// 创建点击区域
			this.clickContainer = new ClickContainer();
			
			//创建箭头
			this.arrow = new GuideArrow();
			this.mouseThrough = true;
			this.addChildren(this.maskContainer, this.arrow, this.clickContainer);
			this.model.on(ModelGuide.TYPE_GOTO, this, this.gotoSomeWhere);
			this.model.on(ModelGuide.TYPE_IMAGE, this, this.showImage);
			this.model.on(ModelGuide.TYPE_TALK, this, this.showTalk);
			this.model.on(ModelGuide.TYPE_CLICK, this, this.hintClick);
			this.model.on(ModelGuide.TYPE_RECRUIT, this, this.recruitHero);
			this.model.on(ModelGuide.TYPE_ALIEN, this, this.nextStep);
			this.model.on(ModelGuide.TYPE_BATTLE, this, this._inBattle);
			this.model.on(ModelGuide.LOCK_SCREEN, this, this._lockScreen);
			this.model.on(ModelGuide.ALL_OVER, this, this.removeGuide);
			Laya.timer.frameLoop(1, this, this._onFrameLoop);
			this.init();
			this.setBounds(new Rectangle(0, 0, Laya.stage.width, Laya.stage.height));
		}

		private function _onFrameLoop():void
		{
			if (this._finding && this.guideConfig) {
				this.getClickSprite(this.guideConfig.type, this.guideConfig.objName);
			}
			else if (this._findingPanel) {
				this.findPanel();
			}
		}

		/**
		 * 根据索引展示引导
		 */
		private function _lockScreen(lock:Boolean):void
		{
			this.hide();
			lock && this.clickContainer.show(Rectangle.TEMP.setTo(0, 0, 0, 0));
			lock || this.clickContainer.hide();
			// lock && // console.log('%c 锁定屏幕','color:red;font-size:16px');
			// lock || // console.log('%c 解锁屏幕','color:green;font-size:16px');
			lock || ModelGame.stageLockOrUnlock("do_guide",false,true);
		}

		/**
		 * 前往城市
		 */
		private function gotoSomeWhere(cfg:Object):void
		{
			delete cfg['state'];
			delete cfg['secondMenu'];
			this.arrow.reset();
			GotoManager.boundFor(cfg, Handler.create(this, this.nextStep), 300);
		}
		
		/**
		 * 提示点击
		 */
		private function hintClick(cfg:Object):void
		{
			this._lockScreen(true);
			if (ObjectUtil.keys(cfg).length === 0) { //click: {}
				this._findingPanel = true;
				this.arrow.reset();
				// console.info('开始查找面板');
				return;
			}
			this.guideConfig = cfg;
			cfg['arrow'] || this.arrow.reset();
			var delay:int = 1;
			if (cfg.type === 'city' || cfg.type === 'building')	delay = 20; // 等待地图移动
			if (cfg.objName && (/btn/.test(cfg.objName))) delay = 20; // 等待Laya UI 的重新布局
			Laya.timer.frameOnce(delay, this, function():void {this._finding = true;});
			// console.info('开始查找按钮');
		}

		private function _hintRect(rect:Rectangle, showRect:Boolean = true, shield:Boolean = true, shade:Boolean = false, showArrow:Boolean = false, waitTime:Number = 100):void
		{
			Laya.timer.once(waitTime, this, this._hintRect2, [rect, showRect, shield, shade, showArrow]);
		}

		private function _hintRect2(rect:Rectangle, showRect:Boolean = true, shield:Boolean = true, shade:Boolean = false, showArrow:Boolean = false):void
		{
			this.clickContainer.hide();
			showRect && GuideFocus.focusIn(null, rect, false); // 提示框
			shield && this.clickContainer.show(rect); // 屏蔽其他点击
			shade && this.maskContainer.show(rect); // 遮黑
			if (showArrow) { //设置箭头位置
				if (rect.y > 100)	
					this.arrow.show(rect.x + rect.width * 0.5, rect.y, 90);
				else if (rect.x > 100)	
					this.arrow.show(rect.x, rect.y + rect.height * 0.5);
				else	
					this.arrow.show(rect.x + rect.width, rect.y + rect.height * 0.5, 180);
			}		
		}
		
		/**
		 * 展示图文
		 */
		private function showImage(cfg:Object):void
		{
			this._lockScreen(false);
			this.arrow.reset();
			ViewManager.instance.showView(ConfigClass.VIEW_GUIDE_IMAGE, cfg);
		}

		/**
		 * 展示对话
		 */
		private function showTalk():void
		{
			this.arrow.reset();
			this._lockScreen(false);
		}

		private function recruitHero(id:String):void
		{
			this.arrow.reset();
			NetSocket.instance.send(NetMethodCfg.WS_SR_RECRUIT_HERO,{hid:id},Handler.create(this, function (re:NetPackage):void{
				var md:ModelHero = ModelManager.instance.modelGame.getModelHero(re.sendData.hid);
				ModelManager.instance.modelUser.updateData(re.receiveData);
				ViewManager.instance.showView(ConfigClass.VIEW_HERO_GET_NEW,md.id);
				this.nextStep();
			}));
		}

		/**
		 * 执行下一步
		 */
		private function nextStep():void
		{
			this.hide();
			this.model.nextStep();
		}

		private function _inBattle():void
		{
			// console.info('进入战斗');
			this.arrow.reset();
			this._lockScreen(false);
		}

		/**
		 * 获取需要点击的对象
		 */
		private function getClickSprite(type:String, objName:String):Boolean
		{
			var sp:Sprite = null;
			switch(type)
			{
				case 'ui':
					sp = ViewMenuMain.getButton(objName);
					break;
				case 'scene':
					var scene:ViewScenes = ViewManager.instance.getCurrentScene();
					if (!scene) return false;
					sp = scene.getSpriteByName(objName);
					break;
				case 'panel':
					var panel:ViewPanel = ViewManager.instance.getCurrentPanel();
					if (!panel) return false;
					sp = panel.getSpriteByName(objName);
					break;
				case 'city':
					if (objName is Array) {
						sp = this.getViewByCityID(parseInt(objName[this.model.country]));
					}
					else sp = this.getViewByCityType(parseInt(objName));
					break;
				case 'building':
					if (objName.indexOf('building') != -1) {
						sp = this.getViewByBuildingID(objName);
					}
					else sp = this.getViewByBuildType(parseInt(objName));
					break;
				case 'hero_list':
					sp = ViewMenuMain.getTroop(parseInt(objName));
					break;
				default:
					break;
			}
			if (sp && sp.visible) {
				this._finding = false;
				// console.info('按钮已锁定');
				var rect:Rectangle = this.getClickRect(type, sp);
				var cfg:Object = this.guideConfig;
				this._hintRect(rect, cfg.rect, cfg.shield, cfg.shade, cfg.arrow, cfg.waitTime);
				return true;
			}
			return false;
		}

		private function getClickRect(type:String, sp:Sprite):Rectangle
		{
			var pos:Point = new Point(sp.x, sp.y);
			var oriX:Number = 0;
			var oriY:Number = 0;
			var w:Number = 0;
			var h:Number = 0;
			var mapGrid:MapGridManager = MapModel.instance.mapGrid;
			var parent:Sprite = sp.parent as Sprite;
			parent.localToGlobal(pos);
			oriX = pos.x;
			oriY = pos.y;
			if (sp is HomeMenuItemUI) { // 菜单
				w = 58;
				h = 58;
				oriX -= w * 0.5;
				oriY -= h * 0.5;
			}
			else if (type === 'city') {
				if (sp is Bubble) { // 气泡
					w = 80;
					h = 90;
					oriX = oriX - w * 0.5;
					oriY = oriY - h;
				}
				else if (sp is EntityCity){
					w = sp['entity'].width;
					h = sp['entity'].height;
				}
				else if (sp is EntityClip){
					var ratio:Number = 0.5;
					w = mapGrid.gridW * ratio;
					h = mapGrid.gridH * ratio;
					oriX = oriX + (mapGrid.gridW - w) * 0.5;
					oriY = oriY + (mapGrid.gridH - h) * 0.5;
				}
			}
			else if (type === 'building') {
				if (sp is EntityClip) { // 建筑
					w = 80;
					h = 60;
					oriX -= w * 0.5;
					oriY -= h * 0.5;
				}
			}
			else { // 按钮等显示对象
				w = sp.width * sp.scaleX;
				h = sp.height * sp.scaleY;
				if (sp['anchorX'])	(oriX -= w * sp['anchorX']);
				if (sp['anchorY'])	(oriY -= h * sp['anchorY']);
			}
			this.rect = new Rectangle(oriX + 3, oriY + 3, w - 6, h - 6);
			this.currentView || this.addEventToButton(sp);
			return this.rect;
		}

		private function addEventToButton(sp:Sprite):void
		{
			// TODO 把銷毀的事件添加回去
			var parent:Sprite = sp.parent as Sprite;
			if (parent && parent.parent && parent.parent is List) {
				parent.offAll();
			}
			this._currentButton = sp;
			var eventStr:String = Event.CLICK;
			if (sp.name.match(/book_\d/)) {
				eventStr = Event.MOUSE_DOWN;
			}
			sp.once(eventStr, this, this._onClickButton);
			var arr:Array = sp.getEvents()[eventStr];
			if (arr is Array) {
				var handler:* = arr.pop();
				arr.splice(0, 0, handler);
			}
			else {
				// console.warn(this.guideConfig['objName'] + '只有一个点击事件！！！');
			}
			
		}

		private function getViewByCityID(cityID:int):Sprite
		{
			var view:EntityClip = EntityBase(MapModel.instance.citys[cityID]).view as EntityClip;
			this.currentView = view;
			return view;
		}

		private function showCityView(parameters):void
		{
			
		}

		private function getViewByBuildingID(buildingID:String):Sprite
		{
			var view:EntityClip = EntityBase(HomeModel.instance.builds[buildingID]).view as EntityClip;
			this.currentView = view;
			return view;
		}

		private function getViewByCityType(type:int):Sprite
		{
			var view:Sprite = null;
			var cityID:int = this.model.cityID;
			var entityCity:EntityCity = MapModel.instance.citys[cityID];
			var cityClip:CityClip = entityCity.view as CityClip;
			var menuItem:Sprite = ArrayUtil.find(cityClip.scene.mapLayer.menu.menus, function(item:Sprite):Boolean{return item.name == type + '';});
			if (menuItem) return menuItem;
			switch(type)
			{
				case 0:	// 民情气泡
					view = cityClip._bubble;
					break;
				case 1:	// 政务气泡
					view = cityClip._bubble;
					break;
				case 2:	// 民情山贼 或政务山贼
					if (entityCity.ftaskEntity.view) {
						view = entityCity.ftaskEntity.view;
					}
					else if(entityCity.gtask.view) {
						view = entityCity.gtask.view;
					}
					else {
						// console.error('cityID: ' + cityID + '   type: ' + type); 
					}
					break;
				case 3:	// 叛军
					view = entityCity.ftaskEntity.view;
					break;
				case 4:	// 切磋
					var heroCatch:EntityHeroCatch = ArrayUtil.find(MapModel.instance.heroCatch, function(item:EntityHeroCatch):Boolean{return item.city == entityCity;});
					heroCatch && (view = heroCatch.view);
					break;
				case 5:	// 异族入侵
					var monster:EntityMonster = MapModel.instance.monsters[cityID];
					monster || (monster = MapModel.instance.monsters['capital']);
					monster && (view = monster.view);
					break;
				case 61:	// 产业
				case 62:	// 产业
				case 63:	// 产业
				case 64:	// 产业
				case 65:	// 产业
				case 66:	// 产业
					view = MapViewMain.instance.estateViews[cityID+ "_" + (type % 10)];
					break;
					break;
				default:
					break;
			}
			this.currentView = view;
			return view;
		}

		private function getViewByBuildType(type:int):Sprite {
			var view:Sprite = null;
			var buildingID:String = this.model.buildingID;
			var base:EntityBase = HomeModel.instance.builds[buildingID];
			var clip:EntityClip = base.view as EntityClip;
			var menuItem:Sprite = ArrayUtil.find(clip.scene.mapLayer.menu.menus, function(item:Sprite):Boolean{return item.name == type + '';});
			if (menuItem) {
				return menuItem;
			}
			else {
				// console.error('menuItem not founf !  type： ' + type);
				return null;
			}
		}

		private function _onClickView(view:Sprite):void
		{
			if (view === this.currentView) {
				this.currentView = null;
				this.nextStep();
			}
		}

		private function _beforeMove():void
		{
			GuideFocus.focusOut();
		}

		private function _onClickButton():void
		{
			this._lockScreen(true);
			if (this._currentButton) {
				this._currentButton = null;
				this.nextStep();
			}
			else { //部分面板有200毫秒的淡出动画
				Laya.timer.once(250, this, this.nextStep);
			}
		}

		override public function onAddedBase():void{
			super.onAddedBase();
			this.cacheAs = "normal";
			ViewManager.instance.on(ViewManager.EVENT_MAP_IN_OUT, this, this.getSceneMain);
			this.getSceneMain();
		}
		override public function onRemovedBase():void{
			this.removeSceneMainEvents();
			this.cacheAs = "none";
			super.onRemovedBase();
		}

		private function getSceneMain():void
		{
			this.removeSceneMainEvents();
			if (MapViewMain.instance) {
				this.mapViewMain = MapViewMain.instance;
				this.mapViewMain.on(EventConstant.CLICK_CLIP, this, this._onClickView);
				this.mapViewMain.on(EventConstant.CLICK_BUBBLE, this, this._onClickView);
				this.mapViewMain.on(EventConstant.BEFORE_MOVE, this, this._beforeMove);
			}

			if (HomeViewMain.instance) {
				this.homeViewMain = HomeViewMain.instance;
				this.homeViewMain.on(EventConstant.CLICK_CLIP, this, this._onClickView);
				this.homeViewMain.on(EventConstant.CLICK_BUBBLE, this, this._onClickView);
				this.homeViewMain.on(EventConstant.BEFORE_MOVE, this, this._beforeMove);
			}
		}

		private function removeSceneMainEvents():void
		{
			this.mapViewMain && this.mapViewMain.off(EventConstant.CLICK_CLIP, this, this._onClickView);
			this.mapViewMain && this.mapViewMain.off(EventConstant.CLICK_BUBBLE, this, this._onClickView);
			this.mapViewMain && this.mapViewMain.off(EventConstant.BEFORE_MOVE, this, this._beforeMove);
			this.homeViewMain && this.homeViewMain.off(EventConstant.CLICK_CLIP, this, this._onClickView);
			this.homeViewMain && this.homeViewMain.off(EventConstant.CLICK_BUBBLE, this, this._onClickView);
			this.homeViewMain && this.homeViewMain.off(EventConstant.BEFORE_MOVE, this, this._beforeMove);
			this.mapViewMain = null;
			this.homeViewMain = null;			
		}

		private function findPanel():Boolean
		{
			var flag:Boolean = false;

			var panel:Sprite = ViewManager.instance.getCurrentPanel();
			if (panel) {
				var className:String = ObjectUtil.className(panel);
				switch(className)
				{
					case 'ViewHeroTalk':
					case 'ViewHeroGetNew':
					case 'ViewGuideImage':
					case 'ViewGetReward':
					case 'ViewFTaskOpen':
						flag = true;
						break;
					default:
						break;
				}
			}
			else {
				panel = ViewManager.instance.getCurrentEffect();
				if (panel is EffectUIBase && panel.name === '') {
					flag = true;
				}
			}

			if (flag) {
				// console.info('面板已锁定');
				this._findingPanel = false;
				this.hide();
				panel.once(Event.CLICK, this, this._onClickButton);
				var arr:Array = panel.getEvents()['click'];
				if (arr is Array) {
					var handler:* = arr.pop();
					arr.splice(0, 0, handler);
				}
			}
			return flag;
		}

		private function removeGuide():void
		{
			this.hide();
			this.arrow.hide();
		}

		private function hide():void
		{
			this.maskContainer.hide();
			this.clickContainer.hide();
			GuideFocus.focusOut();		
		}
		
		public static var instance:ViewGuide;
		
		/**
		 * 提示点击某个对象
		 * @param	sp 需要点击的对象
		 * @param	showRect 是否展示提示框
		 * @param	shield 是否屏蔽其他事件
		 * @param	shade 是否遮黑其他区域
		 * @param	showArrow 是否展示提示箭头
		 * @param	waitTime 锁屏等待时间（毫秒）
		 */
		public static function hintSprite(sp:Sprite, showRect:Boolean = true, shield:Boolean = true, shade:Boolean = false, showArrow:Boolean = false, waitTime:Number = 0):void {
			var rect:Rectangle;
			var pos:Point = Point.TEMP.setTo(sp.x, sp.y);
			(sp.parent as Sprite).localToGlobal(pos);
			var w:Number = sp.width;
			var h:Number = sp.height;
			if (sp['anchorX'])	(pos.x -= w * sp['anchorX']);
			if (sp['anchorY'])	(pos.y -= h * sp['anchorY']);
			rect = Rectangle.TEMP.setTo(pos.x, pos.y, w, h);
			instance._hintRect(rect, showRect, shield, shade, showArrow, waitTime);
		}

		/**
		 * 移除点击提示
		 */
		public static function removeHint():void
		{
			instance.hide();
		}
	}
}