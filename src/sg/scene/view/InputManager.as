package sg.scene.view {
	import laya.events.Event;
	import laya.events.EventDispatcher;
	import laya.events.KeyBoardManager;
	import laya.events.Keyboard;
	import laya.maths.Point;
	import laya.utils.Browser;
	import laya.utils.TimeLine;
	import laya.utils.Tween;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.utils.TestUtils;
	import sg.map.utils.Vector2D;
	import sg.map.view.MapViewMain;
	import sg.scene.SceneMain;
	import sg.scene.model.MapGrid;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityMarch;
	import sg.scene.view.MapCamera;
	
	/**
	 * ...
	 * @author light
	 */
	public class InputManager extends EventDispatcher {
		
		private var lastDistance:Number = 0;
		
		public var zoomFlag:Boolean = false;
		
        private var mLastMouseX:Number;
        private var mLastMouseY:Number;
		
		private var _isDrag:Boolean = false;
		
		private var _enaled:Boolean = false;
		
		private var _isDown:Boolean = false;
		
		private var lastMouse:Array = [];
		
		private var _scene:SceneMain;
		
		/**
		 * 代表当前是否处于拖拽 如果是拖拽，那么对应的按钮就不派发click事件。
		 */
		public var canClick:Boolean = false;
		
		private var _canDrag:Boolean = true;
		
		public static var instance:InputManager = new InputManager();
		
		public function InputManager() {
			KeyBoardManager.enabled = true;		
			if (!TestUtils.isTestShow) return;
			Laya.timer.frameLoop(1, this, function():void{				
				if (KeyBoardManager.hasKeyDown(Keyboard.UP)) {
					MapViewMain.instance.tMap.mapSprite().y -= 30;
				} else if (KeyBoardManager.hasKeyDown(Keyboard.DOWN)) {
					MapViewMain.instance.tMap.mapSprite().y += 30;
				} else if (KeyBoardManager.hasKeyDown(Keyboard.LEFT)) {
					MapViewMain.instance.tMap.mapSprite().x -= 30;
				} else if (KeyBoardManager.hasKeyDown(Keyboard.RIGHT)) {
					MapViewMain.instance.tMap.mapSprite().x += 30;
				}
				
			});
		}
		
		public static function pierceEvent(ed:EventDispatcher):void {

			ed.on(Event.MOUSE_DOWN, ed, function(e):void{
				Event(e).stopPropagation(); 
				InputManager.instance.event('PIERCE_EVENT');
			});
			ed.on(Event.MOUSE_UP, ed, function(e):void{Event(e).stopPropagation(); });
		}
		
		private function mouseWheel(e:Event):void {
			if (ViewManager.instance.getCurrentPanel()) return;
			this.scene.tMap.setViewPortPivotByScale(e.stageX / Laya.stage.designWidth, e.stageY / Laya.stage.designHeight);
			MapCamera.zoom(e.delta * 0.01);
			MapCamera.zoomTweenReset();
		}
		
		private function mouseUp(e:Event):void {			
			Laya.stage.off(Event.MOUSE_MOVE, this, this.onMouseMove);
			if (this._isDown) {
				//有可能点击事件被其他人阻止了。 这里还原一下之前的数值。
				this._scene.timer.callLater(this, function():void {				
					lastMouse.length = 0;
					zoomFlag = false;
					isDrag = false;
					_isDown = false;
				})
			}
			
		}
		
        private function mouseClick(e:Event):void {
			if (!this._isDown) return;
			if (!this.zoomFlag) {
				if (!this.isDrag) {
					this.event(Event.CLICK, e);
				} else {
					if (this._canDrag && this.lastMouse.length>0 && this.lastMouse[0] is Array && (this.lastMouse[0] as Array).length>1) {
						MapCamera.inertia.setXY(e.stageX - this.lastMouse[0][0], e.stageY - this.lastMouse[0][1]);
						for (var i:int = 1, len:int = this.lastMouse.length; i < len; i++) {
							var dx:Number = e.stageX - this.lastMouse[i][0];
							var dy:Number = e.stageY - this.lastMouse[i][1];
							if (MapCamera.inertia.lengthSQ < (Math.pow(dx, 2) + Math.pow(dy, 2))) {
								MapCamera.inertia.setXY(dx, dy);
							}
						}
						var a:int = 20;			
						if (MapCamera.inertia.lengthSQ > a * a) {					
							MapCamera.startMove();
						}
					}
				}
			}
			MapCamera.zoomTweenReset();
			this.lastMouse.length = 0;
			this.zoomFlag = false;
			this.isDrag = false;
			this._isDown = false;
			
        }
		
		
		private function onMouseDown(e:Event = null):void {
			this._isDown = true;
			this.scene.mapLayer.menu.hide();			
			this.lastMouse.length = 0;
			this.zoomFlag = false;
			var touches:Array = e.touches;
			this.canClick = true;
			if (touches) {				
				if (touches.length == 1) {					
					this.setLastMouse(Laya.stage.mouseX, Laya.stage.mouseY);
				}else if (touches.length == 2){
					this.zoomFlag = true;
					this.canClick = false;
					lastDistance = getDistance(touches);
					var centerX:Number = (touches[0].stageX - touches[1].stageX) * 0.5 + touches[1].stageX;
					var centerY:Number = (touches[0].stageY - touches[1].stageY) * 0.5 + touches[1].stageY;
					this.scene.tMap.setViewPortPivotByScale(centerX / Laya.stage.designWidth, centerY / Laya.stage.designHeight);	
				}else {
					return;
				}
				
			} else {//鼠标上
				this.setLastMouse(Laya.stage.mouseX, Laya.stage.mouseY);
			}
			MapCamera.clearMove();
			Laya.stage.on(Event.MOUSE_MOVE, this, this.onMouseMove);
		}
		
		private function setLastMouse(x:Number, y:Number):void {
			mLastMouseX = x;
			mLastMouseY = y;
			this.lastMouse.push([x, y]);
			while (this.lastMouse.length > 3) {
				this.lastMouse.shift();
			}
		}
		
		private function isDoubleTouch(e:Event):Boolean {
			var touches:Array = e.touches;
			return e.touches && e.touches.length == 2;
		}
		
		private function onMouseMove(e:Event = null):void {
			if (e.ctrlKey) return;
			if (e.touches && e.touches.length > 2) return;
			if (zoomFlag) {	
				if (this.isDoubleTouch(e) && this._canDrag) {
					var distance:Number = getDistance(e.touches);
					//判断当前距离与上次距离变化，确定是放大还是缩小
					const factor:Number = 0.001;
					MapCamera.zoom((distance - lastDistance) * factor);				
					lastDistance = distance;
				}
				this.canClick = false;
			} else {
				var disX:Number = Laya.stage.mouseX - mLastMouseX;
				var disY:Number = Laya.stage.mouseY - mLastMouseY;
				
				if(!this.isDrag){
					this.isDrag = (disX * disX + disY * disY > 10 * 10);
				}
				
				//细微的移动不算！
				if(this.isDrag) {
					this.canClick = false;
					var moveX:Number = ( -this.scene.tMap.viewPortX - (disX) / this.scene.tMap.scale);
					var moveY:Number = ( -this.scene.tMap.viewPortY - (disY) / this.scene.tMap.scale);
					//移动地图视口
					if (this._canDrag) MapCamera.move(moveX, moveY);
					this.setLastMouse(Laya.stage.mouseX, Laya.stage.mouseY);
				}
				
			}			
		}

		
		/**计算两个触摸点之间的距离*/
		private function getDistance(points:Array):Number {
			var distance:Number = 0;
            if (points && points.length == 2) {
				var dx:Number = points[0].stageX - points[1].stageX;
				var dy:Number = points[0].stageY - points[1].stageY;
				distance = Math.sqrt(dx * dx + dy * dy);
			}
			return distance;
		}
		
        /**
         *  改变视口大小
         *  重设地图视口区域
         */    
        private function resize():void {
            //改变视口大小
            this.scene.tMap.changeViewPort(-this.scene.tMap.viewPortX, -this.scene.tMap.viewPortY, Browser.width, Browser.height);
        }
		
		public function get enaled():Boolean {
			return this._enaled;
		}
		
		public function set enaled(value:Boolean):void {
			this._enaled = value;
			if(this._enaled) {				
				this.scene.on(Event.MOUSE_DOWN, this, this.onMouseDown);
				Laya.stage.on(Event.CLICK, this, this.mouseClick);
				Laya.stage.on(Event.MOUSE_UP, this, this.mouseUp);
				Laya.stage.on(Event.MOUSE_WHEEL, this, this.mouseWheel);
				
				Laya.stage.on(Event.KEY_UP, this, onKeyUp);
			}else {				
				this.scene.off(Event.MOUSE_DOWN, this, this.onMouseDown);
				Laya.stage.off(Event.CLICK, this, this.mouseClick);
				Laya.stage.off(Event.MOUSE_UP, this, this.mouseUp);
				Laya.stage.off(Event.MOUSE_WHEEL, this, this.mouseWheel);
				
				Laya.stage.off(Event.KEY_UP, this, onKeyUp);
			}
		}
		
		public function get scene():SceneMain {
			return this._scene;
		}
		
		public function set scene(value:SceneMain):void {			
			if (this._scene) this._scene.off(Event.MOUSE_DOWN, this, this.onMouseDown);			
			this._scene = value;
		}
		
		public function get isDrag():Boolean {
			return this._isDrag;
		}
		
		public function set isDrag(value:Boolean):void {
			if (this._isDrag == value) return;
			this._isDrag = value;
			this.event(Event.DRAG_MOVE);
		}
		
		public function set canDrag(value:Boolean):void {
			this._canDrag = value;
			if (!value){
				Laya.stage.off(Event.MOUSE_MOVE, this, this.onMouseMove);
				Laya.stage.off(Event.MOUSE_WHEEL, this, this.mouseWheel);
			} else {
				Laya.stage.on(Event.MOUSE_WHEEL, this, this.mouseWheel);
			}
		}
		
		private function onKeyUp(e:Event):void {
			if(e.keyCode == Keyboard.A) {
				for (var i:int = 0, len:int = 4; i < len; i++) {
					for (var name:String in MapModel.instance.marchs) {
						// ModelManager.instance.modelTroopManager.sendSpeedUpTroops(EntityMarch(MapModel.instance.marchs[name]).hero, 2);				
					}
				}
			}else{
				for (name in MapModel.instance.marchs) {
					// ModelManager.instance.modelTroopManager.sendSpeedUpTroops(EntityMarch(MapModel.instance.marchs[name]).hero, 2);				
				}
			}
		}
	}

}