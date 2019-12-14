package sg.scene.view
{
	import laya.display.Animation;
	import laya.display.Node;
	import laya.display.Sprite;
	import laya.display.Stage;
	import laya.display.Text;
	import laya.events.Event;
	import laya.events.Keyboard;
	import laya.html.dom.HTMLDivElement;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Browser;
	import laya.utils.Handler;
	import laya.utils.HitArea;
	import laya.utils.Stat;
	import sg.cfg.ConfigClass;
	import sg.fight.FightMain;
	import sg.fight.logic.utils.FightPrint;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	import sg.manager.LoadeManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.model.MapModel;
	import sg.map.utils.TestUtils;
	import sg.map.view.MapViewMain;
	import sg.model.ModelGame;
	import sg.net.NetSocket;
	import sg.utils.MusicManager;
	import sg.utils.ObjectUtil;
	import sg.view.effect.UserPowerChange;
	import ui.test.TestButonUI;
	import sg.cfg.ConfigApp;
	import sg.utils.Tools;
	import sg.model.ModelUser;
	
	/**
	 * ...
	 * @author light
	 */
	public class TestButton extends TestButonUI
	{
		
		public var index:int = 0;
		
		
		
		private static var _instance:TestButton;
		
		private static var _logs:Array = [];
		
		public static function init():void
		{
			if (!TestUtils.isTestShow) return;
			if (_instance == null)
			{
				_instance = new TestButton();
				_instance.initTest();
			}
			if (Tools.isNullObj(Tools.getURLexp("lc")))
			{
				Laya.stage.addChild(_instance);
			}
		
		}
		
		public function TestButton()
		{
			// this.initTest();
		}
		
		public function mouseOver():void
		{
			this.alpha = 1;
			this.once(Event.MOUSE_OUT, this, this.mouseOut);
		}
		
		public function mouseOut():void
		{
			this.alpha = 0.5;
			this.off(Event.MOUSE_OUT, this, this.mouseOut);
		}
		
		public function keyPress(e:Event):void
		{
			var str:String;
			trace("键盘事件=keyCode=" + e.keyCode);
			if (e.keyCode == Keyboard.ENTER)
			{
				this.lookBtn();
			}
			else if (e.keyCode == 43)
			{
				//小键盘+
				//str = '当前观看的战斗城池：' + FightMain.getCurrCityId();
				//str = '当前观看的战斗城池：' + FightMain.getCurrCityId();
				ViewManager.instance.showViewEffect(UserPowerChange.getEffect(Math.floor(Math.random()*1112-555)),0,null,false,true,"_power_change_");
				//LoadeManager.fakeLoad(2);
				//str = '开服天数：' + ModelManager.instance.modelUser.getGameDate();
				//this.alpha = 1 - this.alpha;
				//ModelGame.stageLockOrUnlock('test', this.alpha<1);
			}
			else if (e.keyCode == 45)
			{
				///小键盘-
				//str = '当前观看的战斗城池：' + FightMain.getCurrCityId();
				TestUtils.isTestShow = TestUtils.isTestShow?0:1;
				this.alpha = TestUtils.isTestShow?1:0;
			}
			else if (e.keyCode == 42)
			{
				///小键盘*
				//开关帧频内存等显示
				if (Browser.window && Browser.window.conch == null)
				{
					if(Stat._show)
						Stat.hide();
					else
						Stat.show();
				}
			}
			else if (e.keyCode == 92)
			{
				//\
				//ViewManager.clear();
			}
			// if(str)
				// trace(str);
		}
		
		
		private var _point:Point = new Point();
		private var _rect:Rectangle = new Rectangle();
		/**
		 * 刺探到点击对象坐标内的最上层的特定类型对象，只需要该对象显示，无需可点击
		 */
		public function getTopSpr(spr:Sprite,mouseX:Number,mouseY:Number,classArr:Array):Sprite
		{
			if(!(spr is Stage)){
				this._point.setTo(mouseX,mouseY);
				spr.fromParentPoint(this._point);
				mouseX=this._point.x;
				mouseY = this._point.y;
			}
			
			var scrollRect:Rectangle=spr.scrollRect;
			if (scrollRect){
				this._rect.setTo(scrollRect.x,scrollRect.y,scrollRect.width,scrollRect.height);
				if (!this._rect.contains(mouseX, mouseY))
					return null;
			}
			
			if (spr.hitTestPrior && !spr.mouseThrough && !this.hitTest(spr, mouseX, mouseY)) {
				return null;
			}
			var i:int;
			var len:int;
			for (i=spr._childs.length-1;i >-1;i--){
				var child:Sprite=spr._childs[i];
				if (!child.destroyed && child.visible){
					var reSpr:Sprite = this.getTopSpr(child, mouseX, mouseY, classArr);
					if (reSpr)return reSpr;
				}
			}
			//ObjectUtil.className(spr)
			//className 
			
			var isHit:Boolean = (spr.hitTestPrior && !spr.mouseThrough) ? true : this.hitTest(spr, mouseX, mouseY);
			if (isHit) {
				if(!classArr)
					return spr;
				len = classArr.length;
				for (i=0;i <len;i++){
					var c:Class = classArr[i];
					//spr.alpha = 0.9;
					if (spr is c){
						return spr;
					}
				}
			}
			//return spr;
			return null;
		}
		private function hitTest(spr:Sprite, mouseX:Number, mouseY:Number):Boolean {
			var isHit:Boolean = false;
			if (spr.scrollRect) {
				mouseX -= spr.scrollRect.x;
				mouseY -= spr.scrollRect.y;
			}
			if (spr.hitArea is HitArea) {
				return spr.hitArea.isHit(mouseX, mouseY);
			}
			if (spr.width > 0 && spr.height > 0 || spr.mouseThrough || spr.hitArea) {
				//判断是否在矩形区域内
				if (!spr.mouseThrough) {
					var hitRect:Rectangle = this._rect;
					if (spr.hitArea) hitRect = spr.hitArea;
					else hitRect.setTo(0, 0, spr.width, spr.height);
					isHit = hitRect.contains(mouseX, mouseY);
				} else {
					//如果可穿透，则根据子对象实际大小进行碰撞
					isHit = spr.getGraphicBounds().contains(mouseX, mouseY);
				}
				return isHit;
			}
			else{
				return isHit;
			}
			return isHit;
		}
		

		/**
		 * 右键点击对象事件
		 */
		public function rightClick(e:Event):void
		{
			var spr:Sprite = e.target;
			//spr.alpha = 0.5;
			trace("右键点击响应对象:" + FightPrint.getPathStr(spr));	
			

			//TestUtils.downLoadTxt(JSON.stringify(MapModel.instance.testMap), "ccc");
			MapViewMain.instance.checkTopVisible();
			//EffectManager.createIconFlight(AssetsManager.getAssetsUI(AssetsManager.IMG_FOOD), this.stage.mouseX, this.stage.mouseY, 100, 20, 1, 20, this.stage);
			//var ani:Animation = EffectManager.popAnimation('glow011', this.stage.mouseX, this.stage.mouseY, this.stage);
			//ani.scale(0.6, 0.6);

			//ViewManager.instance.showIcon({'item002':22},  this.stage.mouseX,  this.stage.mouseY, false);
			//MusicManager.playMusic(MusicManager.BG_FIGHT_1);
			//MusicManager.playMusic(MusicManager.BG_FIGHT_2);
			
			
			//刺探最顶上的文本对象，适配字号
			spr = this.getTopSpr(Laya.stage, e.stageX, e.stageY, [Label, Button, HTMLDivElement]);
			if (spr){
				trace("右键点击文本对象:" + FightPrint.getPathStr(spr));	
				//spr.scale(1.2, 1.2);
				//spr.alpha = 0.8;
				Tools.textScale(spr);
				if (spr is Label){
					var label:Label = spr as Label;
					if (label.wordWrap || label.height >= label.fontSize*2){
						Tools.textFitFontSize2(label,label.text+'文本');
					}else{
						Tools.textFitFontSize(label,label.text+'文本');
					}
				}else if (spr is Button){
					var btn:Button = spr as Button;
					Tools.textFitFontSize2(btn,btn.text.text+'按钮');
				}
				else if (spr is HTMLDivElement){
					Tools.textFitFontSize2(spr,'<Font color="#FFA500">HTML文本</Font><Font color="#CCCCCC">就是这么拉风</Font><br/><Font color="#FF22FF">HTMLDivElement</Font><br/><Font color="#2222FF">HTMLDivElement</Font>');
				}
			}
			
			
			
			//var s1:String=StringUtil.htmlFontColor(Tools.getMsgById("country_"+0),ConfigColor.COUNTRY_COLORS[0]);
			//var s2:String="啦啦啦"
			
			//MapViewMain.instance["onShowBallistaMsg"](0, s1, s2);
			//MapModel.instance.reload();
			//this.testhandler();
			return;
			for (var i:int = 0, len:int = 100; i < len; i++) {
				//Laya.timer.once(Math.random() * 2000, this, function():void {
					//var ani:Animation = EffectManager.loadAnimation("building_do", "", 1);				
					//Laya.stage.addChild(ani);
					//ani.x = Laya.stage.width * Math.random();
					//ani.y = Laya.stage.height * Math.random();
					//
				//})
				
				var sp:Sprite = new Sprite();
				sp.texture = Laya.loader.getRes("home/bg1.jpg");
				
				Laya.stage.addChild(sp);
				sp.x = Laya.stage.width * Math.random();
				sp.y = Laya.stage.height * Math.random();
				
				
				Laya.loader.clearTextureRes("home/bg1.jpg");
				this.aa.push(sp);
				
			}
			
			
			Laya.timer.once(Math.random() * 2000, this, function():void {
				
				
				for (var j:int = 0, len2:int = aa.length; j < len2; j++) {
					aa[j].visible = false;
				}
				
				Laya.loader.clearTextureRes("home/bg1.jpg")
			})
			
			
			TestUtils.downLoadTxt(JSON.stringify(MapModel.instance.testMap), "ccc");
			return;
			//右键点击的对象，令其显形
			//spr.alpha = 0.5;
			//trace("右键点击" + FightPrint.getPathStr(spr));			
			//MapViewMain.instance.checkTopVisible();
			//EffectManager.createIconFlight(AssetsManager.getAssetsUI(AssetsManager.IMG_FOOD), this.stage.mouseX, this.stage.mouseY, 100, 20, 1, 20, this.stage);
			//var ani:Animation = EffectManager.popAnimation('glow011', this.stage.mouseX, this.stage.mouseY, this.stage);
			//ani.scale(0.6, 0.6);

			//ViewManager.instance.showIcon({'item002':22},  this.stage.mouseX,  this.stage.mouseY, false);
			//MusicManager.playMusic(MusicManager.BG_FIGHT_1);
			//MusicManager.playMusic(MusicManager.BG_FIGHT_2);
			var text:Text = new Text();
			text.text = "cccc";
			var aaa:Number = text.textWidth;
			text.text = "ddddd";
		}
		
		
		
		
		private function checkaaa():void {			
		}
		
		
		private var btnTypes:Object = {};
		public static var test:Boolean = false;
		
		public var content:Sprite = new Sprite();
		public function loadAll():void {
			
			var sp:Sprite = new Sprite();
			sp.texture = Laya.loader.getRes("comp/bar_18.png");
			if (sp.texture == null) {
				throw new Error("1111111111");
			}
			content.addChild(sp);
			
			
			sp = new Sprite();
			sp.texture = Laya.loader.getRes("fight/bg_bash.png");
			if (sp.texture == null) {
				throw new Error("1111111111");
			}			
			content.addChild(sp);
			
			
			sp = new Sprite();
			sp.texture = Laya.loader.getRes("icon/adjutantA0.png");
			if (sp.texture == null) {
				throw new Error("1111111111");
			}			
			content.addChild(sp);
			
			sp = new Sprite();
			sp.texture = Laya.loader.getRes("map2/big.png");
			if (sp.texture == null) {
				throw new Error("1111111111");
			}			
			content.addChild(sp);
			
			
			sp = new Sprite();
			sp.texture = Laya.loader.getRes("science/kj001.png");
			if (sp.texture == null) {
				throw new Error("1111111111");
			}			
			content.addChild(sp);
			
			
			stage.addChild(content);
			
			this.timerOnce(1000, this, function():void {
				content.removeSelf();
			})
		}
		
		
		
		private function onEventHandler(type:String):void {
			if (!(type in btnTypes)) btnTypes[type] = true;
			
			btnTypes[type] = !btnTypes[type];
			var str:String  = "hero702"
			switch(type) {
				case "main":					
					trace(Image.cacheImages);
					break;
				case "查看包":					
					
					ViewManager.instance.showView(ConfigClass.VIEW_TESTPACKAGE);
					break;
				case "bubble":					
					//TestButton.test = !TestButton.test;	
					//for (var j:int = 0, len:int = this.aa.length; j < len; j++) {
						//Sprite(this.aa[j]).removeSelf();
					//}
					//Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas(str));
					LoadeManager.clearHeroIcon();					
					break;
				case "infoHead":	
					for (var i:int = 0, len:int = this.aa.length; i < len; i++) {
						this.aa[i].destroy();
					}
					break;
				case "infoqizi"://大包
					for (i = 0, len = 5000; i < len; i++) {
						var sp:Sprite = new Sprite();
						sp.texture = Laya.loader.getRes("test1/test" + (i % 4 + 1) + ".png");
						this.addChildAt(sp, 0);
						
						sp.x = Math.random() * Laya.stage.width;
						sp.y = Math.random() * Laya.stage.height;
						this.aa.push(sp);
					}					
					break;
				case "infoBuild"://不打包
					//for (var i:int = 0, len:int = 5000; i < len; i++) {
						//var sp:Sprite = new Sprite();
						//sp.texture = Laya.loader.getRes("test2/test" + (i % 4 + 1) + ".png");
						//this.addChildAt(sp, 0);
						//
						//sp.x = Math.random() * Laya.stage.width;
						//sp.y = Math.random() * Laya.stage.height;
						//this.aa.push(sp);
					//}
					//this.aaaa(MapViewMain.instance.tMap.mapSprite());
					TestButton.test = !TestButton.test;
					
					
					break;
				case "matrix":		
					//this.loadAll();
					NetSocket.instance.event(NetSocket.EVENT_SOCKET_RELOAD);
					
					
					
					
					
				//var sp:Sprite = new Sprite();
				//sp.texture = Laya.loader.getRes("home/bg1.jpg");
				//
				
				//sp.x = Laya.stage.width * Math.random();
				//sp.y = Laya.stage.height * Math.random();
				//
				//
				//Laya.loader.clearTextureRes("home/bg1.jpg");
				//this.aa.push(sp);
				
			
			
			//Laya.timer.once(Math.random() * 2000, this, function():void {
				//
				//
				//for (var j:int = 0, len2:int = aa.length; j < len2; j++) {
					//aa[j].visible = false;
				//}
				//
				//Laya.loader.clearTextureRes("home/bg1.jpg")
			//})				
					break;
			}
		}
		private var aaaaaaaa:int = 0;
		private function aaaa(contener:Sprite):void {
			for (var i:int = 0, len:int = contener.numChildren; i < len; i++) {
				if(contener.getChildAt(i) is Sprite) this.aaaa(contener.getChildAt(i) as Sprite);
			}
			aaaaaaaa += (len);
		}
		
		
		private var sp:Sprite = new Sprite();
		
		private var aa:Array = [];
		private function testhandler():void {
			//new GuaJiMain().init();
		}
		
		
		
		public function initTest():void
		{
			this.alpha = 0.5;
			this.on(Event.MOUSE_OVER, this, this.mouseOver);
			this.stage.on(Event.KEY_PRESS, this, this.keyPress);
			this.stage.on(Event.RIGHT_CLICK, this, this.rightClick);
			
			var arr:Array = [0, 1, 2];
			
			this.change_shoudu_btn.clickHandler = new Handler(this, function():void
			{
				index++;
				if (index >= arr.length)
				{
					index = 0;
				}
				MapCamera.lookAtCity(MapModel.instance.getCapital(arr[index]).cityId, 500);
			});
			this.index = arr.indexOf(ModelUser.getCountryID());
			
			this.test_btn.clickHandler = new Handler(this, function():void
			{
				var num:int = 10000;
				var sp2:Sprite = new Sprite();
				for (var i:int = 0, len:int = num; i < len; i++)
				{
					//var sp:Sprite = new Sprite();
					//sp2.texture = Laya.loader.getRes("map/city1.png");
					//sp2.addChild(sp)
					sp2.graphics.drawTexture(Laya.loader.getRes("map/city1.png"));
				}
				sp2.x = 200;
				sp2.y = 200;
				sp2.cacheAsBitmap = true;
				this.addChild(sp2);
			})
			
			this.x = 75;
			this.y = 125;
			
			this.look_btn.clickHandler = new Handler(this, this.lookBtn);
			this.log_list.renderHandler = new Handler(this, function(box:Box, index:int):void {
				Label(box.getChildByName("name")).text = _logs[index][0] + _logs[index][2].toLocaleString();
				Label(box.getChildByName("name")).color = ["#FFFFFF", "#ffd914", "#70ff00", "#FFFFFF"][_logs[index][1]];
			});
			this.log_btn.clickHandler = new Handler(this, function():void {
				this.log_list.visible = !this.log_list.visible;
			});
			this.log_list.dataSource = _logs;
			this.log_list.visible = false;
			this.scrollBottom();
			
			for (var j:int = 0, len2:int = 100; j < len2; j++) {
				var bName:String = "btn_" + j;
				if (bName in this) {
					Button(this[bName]).clickHandler = new Handler(this, function(b:Button):void {
						event(b.label);
						onEventHandler(b.label);
					}, [this[bName]]);
				}
			}
		}
		
		public function lookBtn():void
		{
			var lookText:String = look_txt.text;
			switch (look_com.selectedIndex)
			{
			case 0: 
				var aaa:Array = lookText.replace("，", ",").replace(" ", "").split(",");
				MapCamera.lookAtGrid(MapModel.instance.mapGrid.getGrid(aaa[0], aaa[1]));
				break;
			case 1: 
				lookText = lookText.replace(" ", "");
				MapCamera.lookAtCity(parseInt(lookText));
				break;
			}
		}
		
		public function scrollBottom():void {			
			this.log_list.dataSource = _logs;
			if(this.log_list.scrollBar.max - this.log_list.scrollBar.value <= 50) this.log_list.scrollTo(this.log_list.array.length - 1);
		}
		
		
		static public function get instance():TestButton 
		{
			return _instance ||= new TestButton();
		}
		
		public static function log(data:*, level:int = 0):void {
			if (data is Array) {
				data = data.join(",");
			} else {
				data = data.toString();
			}
			_logs.push([data, level, new Date()]);
			if (_instance) _instance.scrollBottom();
		}
	
	}

}