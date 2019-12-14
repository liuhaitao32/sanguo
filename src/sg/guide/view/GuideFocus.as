package sg.guide.view {
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.net.Loader;
	import laya.utils.Tween;

	import sg.manager.AssetsManager;
	import sg.manager.ViewManager;
	import sg.map.model.MapModel;
	import sg.map.utils.Vector2D;
	import sg.scene.model.MapGridManager;
	import sg.scene.view.InputManager;
	import sg.scene.view.entity.EntityClip;
	import sg.utils.ArrayUtil;
	/**
	 * ...
	 * @author light
	 */
	public class GuideFocus {
		
		public var focus:Array = [];
		
		private var content:Sprite = new Sprite();
		
		private var _rect:Rectangle = new Rectangle();
		
		private var _target:Sprite;
		private var _counter:int;
		private var _isShowing:Boolean;
		public function GuideFocus() {
			var scales:Array = [[1, 1], [1, -1], [ -1, -1], [ -1, 1]];
			
			for (var i:int = 0, len:int = 4; i < len; i++) {
				var sp:Sprite = new Sprite();
				sp.texture = Loader.getRes(AssetsManager.getAssetsUI('guidsquare.png'));
				sp.pivot(sp.texture.sourceWidth / 2, sp.texture.sourceWidth / 2);	
				sp.scale(scales[i][0], scales[i][1]);
				this.focus.push(sp);
				content.addChild(sp);
			}
		}
		
		public function _focusIn(target:Sprite = null, rect:Rectangle = null, autoHide:Boolean = true):void {			
			rect ||= target.getSelfBounds();
			this._focusOut();
			this.content.pos(0, 0);	
			this._rect.setTo(rect.x, rect.y, rect.width, rect.height);
			this._target = target;
			Laya.stage.off(Event.MOUSE_DOWN, this, this._focusOut);
			InputManager.instance.off('PIERCE_EVENT', this, this._focusOut);
			if (autoHide) {
				Laya.stage.once(Event.MOUSE_DOWN, this, this._focusOut);
				InputManager.instance.once('PIERCE_EVENT', this, this._focusOut);
			}
			ViewManager.instance.mLayerGuide.addChild(this.content);
			Laya.timer.frameLoop(1, this, this._onTimer);
			this._counter = 0;
			Tween.to(this.content, {alpha:1}, 200);
			this._isShowing = true;
		}
		
		private function _onTimer():void {
			if (this._target) {
				var p:Point = this._target.localToGlobal(Point.TEMP.setTo(0, 0));
				this.content.pos(p.x, p.y);
			}

			function sign (x:Number):Number {
				x = +x ;// convert to a number
				if (x === 0 || isNaN(x))
					return x;
				return x > 0 ? 1 : -1;
			}
			
			var arr:Array = [[this._rect.right, this._rect.y], [this._rect.right, this._rect.bottom], [this._rect.x, this._rect.bottom], [this._rect.x, this._rect.y]];
			var center:Vector2D = new Vector2D(this._rect.x + this._rect.width / 2, this._rect.y + this._rect.height / 2);
			this._counter++;
			for (var i:int = 0, len:int = this.focus.length; i < len; i++) {
				var xx:Number = arr[i][0];
				var yy:Number = arr[i][1];
				var speed:Number = 0.1;
				var size:Number = 3;
				var offset:Number = Math.sin(_counter * speed) * size;
				xx += sign(xx - center.x) * offset;
				yy += sign(yy - center.y) * offset;
				
				this.focus[i].pos(xx, yy);			
			}
		}
		
		public function _focusOut():void {
			Laya.timer.clear(this, this._onTimer);
			Tween.clearTween(this.content);
			this.content.removeSelf();
			this._counter = 0;
			this.content.alpha = 0;
			this._isShowing = false;
		}
		
		public static function isVisible():Boolean {
			instance ||= new GuideFocus();
			return instance._isShowing;
		}
		
		public static var instance:GuideFocus;
		
		public static function focusOut():void {
			if (!instance) return;
			instance._focusOut();
		}
		
		public static function focusIn(target:Sprite = null, rect:Rectangle = null, autoHide:Boolean = true):void {
			instance ||= new GuideFocus();
			instance._focusIn(target, rect, autoHide);
		}

		/**
		 * 提示某个显示对象
		 */		
		public static function focusInSprite(target:Sprite, autoHide:Boolean = true):void {
			var parent:Sprite = target.parent as Sprite;
			var pos:Point = parent.localToGlobal(Point.TEMP.setTo(target.x, target.y));
			var oriX:Number = pos.x;
			var oriY:Number = pos.y;
			var w:Number = target.width;
			var h:Number = target.height;
			if (target['anchorX'])	(oriX -= w * target['anchorX']);
			if (target['anchorY'])	(oriY -= h * target['anchorY']);
			GuideFocus.focusIn(null, Rectangle.TEMP.setTo(oriX, oriY, w, h), autoHide);
		}

		/**
		 * 提示菜单
		 */
		public static function focusInMenu(view:EntityClip, menuName:String, autoHide:Boolean = true, delay:int = 500):void
		{
			view.onClick();
			Laya.timer.once(delay, null, function ():void {
				if (!view.scene.mapLayer)	return;
				var menuItem:Sprite = ArrayUtil.find(view.scene.mapLayer.menu.menus, function(item:Sprite):Boolean{return item.name == menuName;});
				if (menuItem) {
					var pos:Point = Point.TEMP.setTo(menuItem.x, menuItem.y);
					(menuItem.parent as Sprite).localToGlobal(pos);
					var w:Number = 58;
					var h:Number = 58;
					var oriX:Number = pos.x - w * 0.4;
					var oriY:Number = pos.y - h * 0.4;
					GuideFocus.focusIn(null, Rectangle.TEMP.setTo(oriX, oriY, w, h), autoHide);
				}
			});
		}
		
		/**
		 * 提示建筑
		 */
		public static function focusInBuild(view:EntityClip, autoHide:Boolean = true):void {
			var pos:Point = (view.parent as Sprite).localToGlobal(Point.TEMP.setTo(view.x, view.y));
			var w:Number = 80;
			var h:Number = 60;
			var oriX:Number = pos.x - w * 0.5;
			var oriY:Number = pos.y - h * 0.5;
			GuideFocus.focusIn(null, Rectangle.TEMP.setTo(oriX, oriY, w, h), autoHide);
		}
		
		/**
		 * 提示城市
		 */
		public static function focusInCity(view:EntityClip, autoHide:Boolean = true):void {
			var pos:Point = (view.parent as Sprite).localToGlobal(Point.TEMP.setTo(view.x, view.y));
			var mapGrid:MapGridManager = MapModel.instance.mapGrid;
			var scale:Number = view.scene.tMap.scale;
			// var w:Number = view['entity'].width * scale;
			// var h:Number = view['entity'].height * scale;
			var w:Number = mapGrid.gridW * scale;
			var h:Number = mapGrid.gridH * scale;
			// w = h = 1;
			var oriX:Number = pos.x - w * 0;
			var oriY:Number = pos.y - h * 0;
			GuideFocus.focusIn(null, Rectangle.TEMP.setTo(oriX, oriY, w, h), autoHide);
		}
		
		/**
		 * 提示产业
		 */
		public static function focusInEstate(view:EntityClip, autoHide:Boolean = true):void {
			var pos:Point = (view.parent as Sprite).localToGlobal(Point.TEMP.setTo(view.x, view.y));
			var mapGrid:MapGridManager = MapModel.instance.mapGrid;
			var scale:Number = view.scene.tMap.scale;
			var w:Number = mapGrid.gridW * scale;
			var h:Number = mapGrid.gridH * scale;
			var oriX:Number = pos.x - w * 0;
			var oriY:Number = pos.y - h * 0;
			GuideFocus.focusIn(null, Rectangle.TEMP.setTo(oriX, oriY, w, h), autoHide);
		}
		
	}

}