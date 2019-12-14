package sg.scene 
{
	import interfaces.IClear;
	import laya.display.Node;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.map.TiledMap;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.utils.Browser;
	import laya.utils.Handler;
	import sg.cfg.ConfigApp;
	import sg.scene.constant.EventConstant;
	import sg.scene.interfaces.IResizeUI;
	import sg.scene.model.MapGrid;
	import sg.scene.model.MapGridManager;
	import sg.scene.view.EventLayer;
	import sg.scene.view.InputManager;
	import sg.scene.view.MapCamera;
	import sg.scene.view.TestButton;
	import sg.scene.view.entity.EntityClip;
	
	/**
	 * ...
	 * @author light
	 */
	public class SceneMain extends Sprite {
		
		public static const HOME:int = 0;
		public static const MAP:int = 1;
		public static const MINI_MAP:int = 2;
		
		public var tMap:TiledMap = new TiledMap();

		public var mapLayer:EventLayer;
		
		public var mapGrid:MapGridManager;
		
		public var minScale:Number = 0;
		public var maxScale:Number = 0;
		
		public var springMinScale:Number = 0.05;
		public var springMaxScale:Number = 0.2;
		
		public var type:int = -1;
		
		public var bubbles:Array = [];
		
		public function SceneMain() {
			
		}
		
		public function initScene(name:String):void {
			this.name = Math.random().toString();
			MapCamera.initScene(this);
			//tMap.enableMergeLayer = true;
			//自动缓存没有动画的地块
            //tMap.autoCache = true;
            //自动缓存的类型,地图较大时建议使用normal
            this.tMap.autoCacheType = "normal";
            //消除缩放导致的缝隙,也就是去黑边，1.7.7版本新增的优化属性
            this.tMap.antiCrack = true;
            //创建Rectangle实例，视口区域
            var viewRect:Rectangle = new Rectangle(0, 0, Laya.stage.width, Laya.stage.height);
			//var viewRect:Rectangle = new Rectangle(0, 0, 640, 1280);
            //创建TiledMap地图，加载orthogonal.json后，执行回调方法onMapLoaded()
			var size:Point = new Point(parseInt((512 / this.mapGrid.gridW).toString()) * this.mapGrid.gridW, parseInt((512 / this.mapGrid.gridH).toString()) * this.mapGrid.gridH);
			
			//this.hitArea = new Rectangle(0, 0, Browser.width, Browser.height);			
			this.hitArea = new Rectangle(0, 0, Laya.stage.width, Laya.stage.height);
            this.size(Laya.stage.width, Laya.stage.height);
			
			this.mapLayer = new EventLayer();
			this.mapLayer.scene = this;
			InputManager.instance.scene = this;
			InputManager.instance.on(Event.CLICK, this, onClickHandler);
			this.on(EventConstant.SCALE_CHANGE, this, function(e:Event):void {
				for (var i:int = 0, len:int = bubbles.length; i < len; i++) {
					if (IResizeUI(bubbles[i]).visible) IResizeUI(bubbles[i]).resize();
				}
			});
			if (!ConfigApp.isPC) {
				this.tMap.createMap(name + ".json",viewRect, Handler.create(this,initMap), new Rectangle(150, -30, -50, -50), size, true);
			} else {
				this.tMap.createMap(name + ".json",viewRect, Handler.create(this,initMap), new Rectangle(150, -30 + 50, -50, -50 + 50), size, true);
			}
			
            //this.tMap.createMap(name + ".json",viewRect, Handler.create(this,initMap), new Rectangle(230, 60, 200, 200), size, true);
		}
		
		
		protected function onClickHandler(e:Event):void {
			Trace.log(this.name);
		}
		
		protected function initMap():void {			
			this.addChild(this.tMap.mapSprite());
			
			//this.tMap.mapSprite().alpha = 0.9;
			this.tMap.setViewPortPivotByScale(0,0);
			InputManager.instance.enaled = true;
			
			this.mapLayer.init(null, this.tMap);
			this.tMap.scale = 1;
			
			//this.graphics.drawCircle(0, 0, 10000, "#FF0000");
		}
		
		public function createClip(type:int = -1):EntityClip {
			return null;
		}
		
		
		override public function destroy(destroyChild:Boolean = true):void {	
			InputManager.instance.enaled = false;
			
			InputManager.instance.off(Event.CLICK, this, onClickHandler);
			this.tMap.destroy();
			this.mapGrid = null;
			this.mapLayer = null;
			this.tMap = null;
			super.destroy(destroyChild);
			
		}
		
	}

}