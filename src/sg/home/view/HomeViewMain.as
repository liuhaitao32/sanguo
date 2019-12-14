package sg.home.view
{
	// import laya.debug.ui.debugui.ToolBarUI;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.resource.Texture;
	import laya.ui.Label;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigServer;
	import sg.home.model.HomeModel;
	import sg.home.model.entitys.EntityBuild;
	import sg.home.view.entity.BuildClip;
	import sg.home.view.entity.ShopClip;
	import sg.home.view.entity.LegendShopClip;
	import sg.manager.EffectManager;
	import sg.manager.LoadeManager;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.TestUtils;
	import sg.scene.SceneMain;
	import sg.scene.constant.ConfigConstant;
	import sg.scene.constant.EventConstant;
	import sg.scene.model.MapGrid;
	import sg.scene.view.MapCamera;
	import sg.scene.view.entity.EntityClip;
	import sg.manager.ModelManager;
	import sg.activities.view.ViewOnlineRewardTip;
	import sg.utils.MusicManager;
	import sg.utils.Tools;
	
	/**
	 * ...
	 * @author light
	 */
	public class HomeViewMain extends SceneMain
	{
		
		public static var instance:HomeViewMain;
		
		public function HomeViewMain()
		{			
			this.type = SceneMain.HOME;
			instance = this;
			super();
			this.minScale = 0.6;
			this.maxScale = 1;
			this.mapGrid = HomeModel.instance.mapGrid;
			HomeModel.instance.initHome();
			if (!ConfigApp.isPC) {
				this.tMap.limitRect.setTo(0, 60, 0, 80);
			} else {
				this.tMap.limitRect.setTo(0, 60 - 80, 0, 80 - 80);
				this.minScale = 0.7;
			}
			this.initScene("home/home");
		
		}
		
		override protected function initMap():void
		{
			super.initMap();
			var t1:Texture = Laya.loader.getRes("home/bg1.jpg");
			var t2:Texture = Laya.loader.getRes("home/bg2.jpg");
			var t3:Texture = Laya.loader.getRes("home/bg3.jpg");
			var t4:Texture = Laya.loader.getRes("home/bg4.jpg");
			var offsetX:Number = -this.tMap.tileWidth / 2;
			var offsetY:Number = -this.tMap.tileHeight / 2;
			this.mapLayer.floorLayer.graphics.drawTexture(t1, offsetX, offsetY);
			this.mapLayer.floorLayer.graphics.drawTexture(t2, t1.width + offsetX, offsetY);
			this.mapLayer.floorLayer.graphics.drawTexture(t3, offsetX, t1.height + offsetY);
			this.mapLayer.floorLayer.graphics.drawTexture(t4, t1.width + offsetX, t1.height + offsetY);
			//
			var sp:Sprite = new Sprite();
			var temp:Texture = Laya.loader.getRes("map2/homebg.png");
			var scale:Number = (t1.width + t2.width) / temp.width;
			this.mapLayer.floorLayer.alpha = 0;
			
			var fun:Function = function():void {
				if (this.mapLayer.floorLayer.alpha >= 1) {
					this.clearTimer(this, fun);
				}
				this.mapLayer.floorLayer.alpha += 0.2;
			}
			this.frameLoop(1, this, fun);
			
			
			
			//Tween.to(this.mapLayer.floorLayer, {alpha:1}, 200, null, null, 200);
			this.mapLayer.graphics.drawTexture(temp, 0, 0, temp.width * scale, temp.height * scale);
			
			
			for (var name:String in HomeModel.instance.builds)
			{
				var build:EntityBuild = HomeModel.instance.builds[name];
				var m:BuildClip = new BuildClip(this);
				build.view = m;
				m.entity = build;
				m.init();
			}
			//MapCamera.zoom(1);
			MapCamera.zoom(-0.2);
			//this.tMap.scale = 0.8;
			MapCamera.lookAtBuild(ModelManager.instance.modelInside.getBase().id, 0);

			this.initHomeEffects();

			
			this.initOtherBuild();
			
			if (TestUtils.isTestShow){
				this.on(Event.RIGHT_CLICK, this, this.rightMouseDown);
			}
			MusicManager.playMusic(MusicManager.BG_HOME);
		}
		
		private var shopClip:ShopClip;
		private var legendShopClip:LegendShopClip;
		
		private function initOtherBuild():void {
			// 在线奖励
			new ViewOnlineRewardTip(this);
			//商店。
			this.shopClip = new ShopClip(this);
			// 传奇觉醒商店
			this.legendShopClip = new LegendShopClip(this);
		}
		/**
		 * 测试右键点击
		 */
		protected function rightMouseDown(e:Event):void
		{
			//转换成地图坐标
			var tempX:Number = e.stageX;
			var tempY:Number = e.stageY;
			tempX = Math.round(tempX / this.tMap.scale - this.tMap.viewPortX);
			tempY = Math.round(tempY / this.tMap.scale - this.tMap.viewPortY);
			//var tempX:int = Math.round(this.mouseX / this.tMap.scale);
			//var tempY:int = Math.round(this.mouseY / this.tMap.scale);
			var spr:Sprite = new Sprite();
			spr.addChild(EffectManager.loadAnimation('glow011'));
			spr.x = tempX - HomeModel.instance.mapGrid.gridHalfW;
			spr.y = tempY - HomeModel.instance.mapGrid.gridHalfH;
			this.mapLayer.effectLayer.addChild(spr);
			
			var label:Label = new Label(tempX +',' + tempY);
			label.align = 'center';
			label.anchorX = 0.5;
			label.anchorY = 0.5;
			label.fontSize = 40;
			label.scale(2, 2);
			label.stroke = 4;
			label.strokeColor = '#FFFF00';
			Tween.to(label, {scaleX: 1, scaleY: 1}, 200, Ease.sineOut);
			
			spr.addChild(label);
			spr.scale(0.5, 0.5);
			//trace('右键点击了：' + tempX +',' + tempY);
		}
		
		protected static function getHomeEffects():Array
		{
			return ConfigApp.isNewHome? ConfigServer.effect.homeEffs : ConfigServer.effect.homeEffects;
		}
		
		/**
		 * 加上封地的小动画
		 */
		protected function initHomeEffects():void
		{
			var homeEffects:Array = getHomeEffects();
			for (var i:int = homeEffects.length - 1; i >= 0; i--)
			{
				var spr:Sprite = new Sprite();
				this.resetHomeEffect(spr, i);
			}
		}
		
		protected function resetHomeEffect(spr:Sprite, index:int, resetPos:Boolean = true):void
		{
			if (!spr || spr.destroyed)
				return;
			var homeEffects:Array = getHomeEffects();
			var obj:Object = homeEffects[index];
			var pathArr:Array = obj.path;
			if (pathArr)
			{
				pathArr = pathArr.concat();
			}
			if (resetPos)
			{
				var posArr:Array = obj.pos;
				var pos:Array = ArrayUtils.getRandomValue(posArr);
				var tempX:Number = pos[0];
				var tempY:Number = pos[1];
				if (ConfigApp.isNewHome){
					tempX -= HomeModel.instance.mapGrid.gridHalfW;
					tempY -= HomeModel.instance.mapGrid.gridHalfH;
				}
				spr.pos(tempX, tempY);
			}
			
			if (spr.name != "home")
			{
				spr.name = "home";
				var testRes:String = ConfigServer.effect.homeEffectTest;
				if (testRes)
				{
					spr.addChild(EffectManager.loadAnimation(testRes));
				}
				var ani:Animation = new Animation();
				ani.name = "ani";
				var res:String = obj.res;
				var frame:int = obj.frame ? obj.frame: 0;
				var state:String = obj.state?obj.state:'';
				if (frame || state)
				{
					ani = EffectManager.loadAnimationAndCall(res, null, EffectManager.playAnimation, [res, state, frame, ani], ani);
				}
				else if (pathArr)
				{
					ani = EffectManager.loadAnimationAndCall(res, this, this.startPath, [res, ani, spr, pathArr, index], ani);
				}
				else
				{
					ani = EffectManager.loadAnimation(res, '', 0, ani);
				}
				spr.addChild(ani);
				if (obj.top)
				{
					this.mapLayer.effectLayer.addChild(spr);
				}
				else
				{
					this.mapLayer.topLayer.addChild(spr);
				}
				if (obj.scale)
				{
					ani.scale(obj.scale, obj.scale);
				}
				if (obj.isFlip)
				{
					ani.scaleX *= -1;
				}
				if (obj.alpha)
				{
					ani.alpha = obj.alpha;
				}
				if (obj.rota)
				{
					ani.rotation= obj.rota;
				}
			}
			else if (pathArr)
			{
				this.tweenPath(spr, pathArr, index);
			}
		}
		
		protected function startPath(res:String, ani:Animation, spr:Sprite, pathArr:Array, index:int):void
		{
			//trace("封地动画 " + res + ",  " + index, pathArr);
			EffectManager.playAnimation(res, 'up', 0, ani);
			this.tweenPath(spr, pathArr, index);
		}
		
		protected function tweenPath(spr:Sprite, pathArr:Array, index:int):void
		{
			if (!spr || spr.destroyed)
				return;
			if (pathArr.length > 0)
			{
				var path:Array = pathArr.shift();
				var speed:Number = path[0];
				var ani:Animation = spr.getChildByName("ani") as Animation;
				var actionName:String;
				
				//trace("封地动 " + index + ",  " + speed);
				if (speed == -2)
				{
					//重新运行路径
					this.resetHomeEffect(spr, index, false);
				}
				else if (speed == -1)
				{
					//重新随机位置并运行路径
					this.resetHomeEffect(spr, index);
				}
				else if (speed == 0)
				{
					//等待时间，如果其内有动画，则尝试按当前方向更换动作
					actionName = ani.actionName + "S";
					if (ani.hasActionName(actionName))
					{
						ani.play(0, true, actionName);
					}
					Laya.stage.timer.once(path[1], this, this.tweenPath, [spr, pathArr, index], false);
				}
				else
				{
					//使用该速度移动，如果其内有动画，则尝试按移动方向更换动作
					actionName = path[2] < 0 ? "up" : "down";
					if (ani.hasActionName(actionName))
					{
						ani.play(0, true, actionName, false);
					}
					
					if (path[1] >= 0)
					{
						spr.scaleX = 1;
					}
					else
					{
						spr.scaleX = -1;
					}
					var tempX:Number = path[1];
					var tempY:Number = path[2];
					var dis:Number = Math.sqrt(tempX * tempX + tempY * tempY * 1.5);
					var time:Number = dis / speed * 1000;
					Tween.to(spr, {x: spr.x + tempX, y: spr.y + tempY}, time, null, Handler.create(this, this.tweenPath, [spr, pathArr, index]));
				}
			}
		}
		
		override protected function onClickHandler(e:Event):void
		{
			super.onClickHandler(e);
			//转换成地图坐标
			var screenX:Number = e.stageX;// - HomeModel.instance.mapGrid.gridHalfW;
			var screenY:Number = e.stageY;// - HomeModel.instance.mapGrid.gridHalfH;
			screenX = screenX / this.tMap.scale - this.tMap.viewPortX;
			screenY = screenY / this.tMap.scale - this.tMap.viewPortY;
			
			var col:int = parseInt((screenX / this.mapGrid.gridW).toString());
			var row:int = parseInt((screenY / this.mapGrid.gridH).toString());
			
			var grid:MapGrid = this.mapGrid.getGrid(col, row);
			
			if (grid)
			{
				var arr:Array = grid.getEntitysByType(ConfigConstant.ENTITY_BUILD, "clickEntitys");
				for (var i:int = 0, len:int = arr.length; i < len; i++)
				{
					if (EntityBuild(arr[i]).view.containsPos(screenX, screenY))
					{
						EntityBuild(arr[i]).view.onClick();		
						this.event(EventConstant.CLICK_CLIP, EntityBuild(arr[i]).view);
					}
					else
					{
						Trace.log("没点中！" + EntityBuild(arr[i]).name);
					}
				}
				
				if (this.shopClip.containsPos(screenX, screenY)) {
					this.shopClip.onClick();
				} else if (legendShopClip.containsPos(screenX, screenY)) {
					this.legendShopClip.onClick();
				}
			}
		}
		
		override public function createClip(type:int = -1):EntityClip
		{
			return super.createClip(type);
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			Laya.loader.clearTextureRes("home/bg1.jpg");
			Laya.loader.clearTextureRes("home/bg2.jpg");
			Laya.loader.clearTextureRes("home/bg3.jpg");
			Laya.loader.clearTextureRes("home/bg4.jpg");
			
			LoadeManager.clearHeroIcon();
			Tools.destroy(this.shopClip);
			Tools.destroy(this.legendShopClip);
			super.destroy(destroyChild);
		}
	}

}