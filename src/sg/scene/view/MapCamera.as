package sg.scene.view 
{
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.utils.Browser;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.cfg.ConfigApp;
	import sg.guide.view.GuideFocus;
	import sg.home.model.HomeModel;
	import sg.home.model.entitys.EntityBuild;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.map.model.entitys.EntityCity;
	import sg.map.utils.Vector2D;
	import sg.map.view.EstateClip;
	import sg.map.view.MapViewMain;
	import sg.scene.constant.ConfigConstant;
	import sg.scene.constant.EventConstant;
	import sg.scene.model.MapGrid;
	import sg.map.model.MapModel;
	import sg.map.utils.Math2;
	import sg.scene.SceneMain;
	import sg.scene.view.entity.EntityClip;
	/**
	 * ...
	 * @author light
	 */
	public class MapCamera {
		
		private static var _scene:SceneMain;		
		
		private static var _speed:Number = 0;		
		
		public static var targetPos:Vector2D = new Vector2D();
		
		public static var inertia:Vector2D = new Vector2D();
		
		private static var tween:Tween;
		
		private static var _fastLimit:Number = 10;
		
		public static function get lock():Boolean {
			return tween != null;
		}
		
		public static function get fast():Boolean {
			return _speed > _fastLimit;
		}
		
		
		
		public static function set speed(value:Number):void {
			var isFast:Boolean = MapCamera.fast;			
			_speed = value;
			if (isFast && !MapCamera.fast) {
				_scene.event(EventConstant.SPEED_LOW);
			}
		}
		
		public static function get speed():Number {
			return _speed;
		}
		
		public static function initScene(scene:SceneMain):void {
			_scene = scene;
			_speed = 0;
			clearTween();
			if (scaleTween) {
				scaleTween.clear();
				scaleTween = null;
			}
		}
		
		private static function moveViewPort(x:Number, y:Number):void {
			_scene.tMap.moveViewPort(x, y);
			_scene.event(EventConstant.MOVE_CHANGE);
		}
		
		
		public static function move(moveX:Number, moveY:Number, time:Number = 0, handler:Handler = null):void {
			clearTween();
			_scene.event(EventConstant.BEFORE_MOVE);
			if (time == 0) {
				moveViewPort(moveX, moveY);
				handler && handler.run();
			} else {
				targetPos.setXY( -_scene.tMap.viewPortX, -_scene.tMap.viewPortY);
				
				tween = Tween.to(targetPos, {x:moveX, y:moveY, update:new Handler(MapCamera, function():void{
					Vector2D.TEMP.setXY( -_scene.tMap.viewPortX, -_scene.tMap.viewPortY);					
					moveViewPort(targetPos.x, targetPos.y);
					speed = Vector2D.TEMP.subtract(targetPos).length;
				})}, time, Ease.circOut, new Handler(MapCamera, function():void {
					tween = null;
					speed = 0;
					handler && handler.run();
				}), 0, true);
			}
			
		}
		
		private static function moveChange():void {			
			inertia.length *= 0.9;
			speed = inertia.length;
			if (_speed < 1) {
				speed = 0;
				Laya.timer.clear(MapCamera, moveChange);
			} else {
				moveViewPort(-_scene.tMap.viewPortX - inertia.x, -_scene.tMap.viewPortY - inertia.y);
			}
		}
		
		
		
		public static function lookAtCity(cityId:int, time:Number = 0, handler:Handler = null):void {
			if(MapModel.instance.citys[cityId]){
				MapCamera.lookAtGrid(EntityCity(MapModel.instance.citys[cityId]).mapGrid, time, handler);
			}
		}
		
		public static function lookAtGrid(grid:MapGrid, time:Number = 0, handler:Handler = null):void {
			_scene.mapLayer.getPos(grid.col, grid.row, Point.TEMP);
			lookAtPos(Point.TEMP.x + MapModel.instance.mapGrid.gridHalfW, Point.TEMP.y + MapModel.instance.mapGrid.gridHalfH, time, handler);
		} 
		
		public static function lookAtGtask(cityId:String, time:Number = 0):void {
			lookAtGrid(EntityCity(MapModel.instance.citys[cityId]).gtask.mapGrid, time);
		}
		
		public static function lookAtEstate(cityId:String, index:int, time:Number = 0, handler:Handler = null):void {
			var entityData:Object = ConfigConstant.mapData.city[cityId];
			lookAtGrid(MapModel.instance.mapGrid.getGrid(entityData.estate[index].x, entityData.estate[index].y), time, handler);
		}
		
		public static function lookAtPos(x:Number, y:Number, time:Number = 0, handler:Handler = null):void {
			var h:Number = ConfigApp.isPC ? Laya.stage.height / 2 : (Browser.height / 2) * (Laya.stage.width / Browser.width);
			move(x - (Laya.stage.width / 2) / _scene.tMap.scale, y - h  / _scene.tMap.scale, time, handler);
		}
		
		public static function lookAtDisplay(sp:Sprite, time:Number = 0, handler:Handler = null):void {
			if(sp){
				lookAtPos(sp.x + _scene.tMap.tileWidth / 2, sp.y + _scene.tMap.tileHeight / 2, time, handler);
			}
		}
		
		public static function lookAtFtask(cityId:int, time:Number = 500):void {
			lookAtGrid(EntityCity(MapModel.instance.citys[cityId]).ftaskEntity.mapGrid, time);
		}
		
		public static function lookAtBuild(id:String, time:Number = 500, effect:Boolean = false, handler:Handler = null):void {
			var view:EntityClip = EntityBuild(HomeModel.instance.builds[id]).view;
			MapCamera.lookAtDisplay(view, time, handler);
			if (effect) {
				GuideFocus.focusIn(view, new Rectangle(-40, -30, 80, 60));
			}
		}
		
		public static var scaleTween:Tween = null;
		
		public static function zoom(scale:Number):void {			
			if (scaleTween) {
				scaleTween.clear();
				scaleTween = null;
			}
			
			_scene.tMap.scale = Math2.range(_scene.tMap.scale + scale, _scene.maxScale + _scene.springMaxScale, _scene.minScale - _scene.springMinScale);
			
			//move(-_scene.tMap.viewPortX, -_scene.tMap.viewPortY);
			_scene.event(EventConstant.SCALE_CHANGE);
		}
		
		
		public static function zoomTweenReset():void {
			var targetScale:Number = Math2.range(_scene.tMap.scale, _scene.maxScale, _scene.minScale);
			if (_scene.tMap.scale != targetScale) {
				scaleTween = Tween.to(_scene.tMap, {"scale":targetScale, update:new Handler(MapCamera, function():void{					
					_scene.event(EventConstant.SCALE_CHANGE);
				})}, 500, Ease.quadOut, new Handler(MapCamera, function():void {
					_scene.event(EventConstant.SCALE_CHANGE);
					scaleTween = null;
				}));
			}
			
		}
		
		private static function clearTween():void {
			if (tween) {
				tween.clear();
				tween = null;
			}
			clearMove();
		}
		
		public static function clearMove():void {
			speed = 0;
			Laya.timer.clear(MapCamera, moveChange);			
		}
		
		public static function startMove():void {
			if (ConfigConstant.isEdit) return;
			clearTween();
			
			MapCamera.inertia.length = speed = Math.min(MapCamera.inertia.length * 1, 150);
			Laya.timer.frameLoop(1, MapCamera, moveChange);
		}
	}

}