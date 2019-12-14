package sg.scene.view.entity {
	import laya.display.Animation;
	import laya.display.Node;
	import laya.display.Sprite;
	import laya.map.GridSprite;
	import laya.maths.Point;
	import laya.utils.Pool;
	import laya.utils.Tween;
	import sg.cfg.ConfigServer;
	import sg.manager.EffectManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.MapUtils;
	import sg.map.utils.Vector2D;
	import sg.map.view.IsoObject;
	import sg.map.view.MapViewMain;
	import sg.scene.SceneMain;
	import sg.scene.constant.EventConstant;
	import sg.scene.model.entitys.EntityBase;
	import sg.scene.view.EventGridSprite;
	import sg.scene.view.MapCamera;
	
	/**
	 * 实体的视图类
	 * @author light
	 */
	public class EntityClip extends IsoObject {
		
		protected var _entity:EntityBase;
		
		protected var _scene:SceneMain;
		
		
		protected var _clip:Sprite = new Sprite();
		
		private var _poolDisplay:Array = [];
		
		protected var _ani:Animation;
		
		public function EntityClip(scene:SceneMain) {
			this._scene = scene;
		}
		
		//public function get stageX():Number {
			//return (this.x - this._scene.tMap.viewPortX - this._scene.tMap.tileWidth / 2) * this._scene.tMap.scale;
		//}
		//
		//public function get stageY():Number {
			//return (this.y - this._scene.tMap.viewPortY - this._scene.tMap.tileHeight / 2) * this._scene.tMap.scale;
		//}
		
		public override function init():void {
			super.init();
			this.addChildAt(this._clip, 0);
		}
		
		public function toScreenPos():Vector2D {		
			return this._entity.mapGrid.toScreenPos();
		}
		
		public function getRes(name:String, createFun:Function):* {
			var result:Sprite = Pool.getItemByCreateFun(name, createFun);
			result.name = name;
			this._poolDisplay.push(result);
			return result;
		}
		
		public function getSprite(name:String):Sprite {
			var sp:Sprite = this.getRes(name, function():Sprite {
						var r:Sprite = new Sprite();
						if(name != "empty")
							r.texture = Laya.loader.getRes(name);
						return r;
					});
			sp.scale(1, 1);
			sp.pos(0, 0);
			sp.pivot(0, 0);
			return sp;
		}
		
		public function getHeroAnimation(hero:String, dir:int):Animation {
			var ani:Animation = this.getRes(hero, function():Animation {
				return EffectManager.loadHeroAnimation(hero, true, "map");
			});
			
			var scaleFlag:Boolean = ArrayUtils.contains(dir, [0, 1]);
			var dirFlag:Boolean = ArrayUtils.contains(dir, [0, 3]);
			ani.play(0, true, dirFlag ? "up" : "down"); 
			ani.scaleX = scaleFlag ? 1 : -1;
			return ani;
		}
		
		public function getAnimation(name:String):Animation {
			return this.getRes(name, function():Animation {
				return EffectManager.loadAnimation(name, '', 0, null, "map");
			});
		}
		
		public function getMatrix(num:int, res:String, dir:int, scaleType:String = null):Sprite {
			var scale:Number = !ConfigServer.system_simple.scale_matrix ? 1 : ConfigServer.system_simple.scale_matrix[scaleType];
			var sourceDist:Number = Math.sqrt(Math.pow(MapModel.instance.mapGrid.gridHalfW, 2) + Math.pow(MapModel.instance.mapGrid.gridHalfH, 2));
			var pandding:Number = 10;
			var xx:Number = num;
			var yy:Number = num;
			var rate:Number = ((sourceDist - pandding * 2) / xx) / sourceDist;
			var scaleFlag:Boolean = ArrayUtils.contains(dir, [0, 1]);
			var dirFlag:Boolean = ArrayUtils.contains(dir, [0, 3]);
			var sp:Sprite = this.getSprite("emptySp");
			for (var i:int = 0, len:int = xx; i < len; i++) {
				for (var j:int = 0, len2:int = yy; j < len2; j++) {
					var v:Vector2D = MapUtils.isoToTile(new Vector2D(i, j), Vector2D.TEMP);
					MapViewMain.instance.mapLayer.getPos(v.x, v.y, Point.TEMP);					
					v.setPoint(Point.TEMP);
					v.length *= rate;
					var ani:Animation = this.getAnimation(res);
					var num2:int = parseInt((Math.random() * 50).toString());
					ani.play(num2, true, dirFlag ? "up" : "down");
					sp.addChild(ani);
					ani.pos(v.x, v.y);
					ani.scaleX = scaleFlag ? scale : -scale;
					ani.scaleY = scale;
				}
			}
			sp.pivot(0, Math.min(yy - 1, 1) * 10 + (yy - 2) * 5);
			return sp;
		}
		
		public function getHeroMatrix(num:int, res:String, dir:int, heroId:String, scaleType:String = null):Sprite {
			var container:Sprite = this.getSprite("empty");
			var soldier:Sprite = this.getMatrix(num, res, dir, scaleType);
			var hero:Animation = this.getHeroAnimation(heroId, dir);
			
			container.addChild(soldier);
			container.addChild(hero);
			
			var v3:Vector2D = MapUtils.getAroundHypotenuse(dir);
			v3.reverse();
			//v3是全局坐标。。。转化到对应的格子上			
			soldier.x = v3.x;
			soldier.y = v3.y;	
			
			
			var tray:Sprite = this.getAnimation("run_enemy");
			tray.x = v3.x;
			tray.y = v3.y;
			
			container.addChildAt(tray, 0);
			
			return container;
		}
		
		override public function onClick():void {
			if(this._entity) MapCamera.lookAtGrid(this._entity.mapGrid, 500);			
			this._scene.event(EventConstant.CLICK_CLIP, this);
		}
		
		public function containsPos(screenX:Number, screenY:Number):Boolean {
			return Math.abs((screenX - this._entity.x) * this._entity.height) + Math.abs((screenY - this._entity.y) * this._entity.width ) < this._entity.width * this._entity.height * 0.5;
		}
		
		public function show():void {
			this.recover();//避免重复调用！ 连续调用多次 也不会有问题。 先清为净
		}
		
		public function hide():void {
			this.recover();
			
		}
		
		private function recover():void {
			while (this._poolDisplay.length) {
				var node:Node = Sprite(this._poolDisplay.shift()).removeSelf();
				Pool.recover(node.name, node);
			}
		}
		
		public function get entity():EntityBase {
			return this._entity;
		}
		
		public function set entity(value:EntityBase):void {
			this._entity = value;
			if (this._entity.mapGrid) {				
				this.zOrder = this._entity.mapGrid.row * 128 + this._entity.mapGrid.col;
			}
		}
		
		public function get scene():SceneMain {
			return this._scene;
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			this.recover();//先回收到对象池里去。再清除！
			if (this.parent is EventGridSprite) EventGridSprite(this.parent).removeItemSprite(this);
			//if (this._entity) this._entity.view = null;
			super.destroy(destroyChild);
		}
		
		public function reset():void {
			if (this.visible) this.show();
		}
		
	}

}