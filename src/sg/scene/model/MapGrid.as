package sg.scene.model {
	import laya.map.GridSprite;
	import laya.maths.Point;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.MapUtils;
	import sg.map.utils.Vector2D;
	import sg.scene.constant.ConfigConstant;
	import sg.scene.model.entitys.EntityBase;
	import sg.map.model.astar.AstarNode;
	/**
	 * ...
	 * @author light
	 */
	public class MapGrid {
		
		public var node:AstarNode;
		
		public var col:int;
		public var row:int;
		
		public var entitys:Object = {};
		
		public var clickEntitys:Object = {};
		
		public var occupyEntitys:Object = {};
		
		public var gridSprite:GridSprite = null;
		
		public function toString2():String {
			return this.col + "_" + this.row;
		}
		
		public function MapGrid(col:int, row:int) {
			this.col = col;
			this.row = row;
		}
		
		public function removeEntity(entity:EntityBase):void {
			var arr:Array = this.getEntitysByType(entity.type);
			var index:int = arr.indexOf(entity);
			if (index != -1) arr.splice(index, 1);
		}
		
		public function addEntity(entity:EntityBase):void {
			this.getEntitysByType(entity.type).push(entity);
		}
		
		public function addClickEntity(entity:EntityBase):void {
			this.getEntitysByType(entity.type, "clickEntitys").push(entity);
		}
		
		public function addOccupyEntity(entity:EntityBase):void {
			this.getEntitysByType(entity.type, "occupyEntitys").push(entity);
		}
		
		public function removeClickEntity(entity:EntityBase):void {
			ArrayUtils.remove(entity, this.getEntitysByType(entity.type, "clickEntitys"));
		}
		
		public function removeOccupyEntity(entity:EntityBase):void {
			ArrayUtils.remove(entity, this.getEntitysByType(entity.type, "occupyEntitys"));
		}
		
		public function get occupyCity():EntityCity {
			return this.getEntitysByType(ConfigConstant.ENTITY_CITY, "occupyEntitys")[0];
		}
		
		public function getEntitysByType(type:int, pro:String = "entitys"):Array{
			if (this[pro][type] == null) this[pro][type] = [];
			return this[pro][type] as Array;
		}
		
		public function toScreenPos():Vector2D {
			MapUtils.getPos(this.col, this.row);
			var v:Vector2D = new Vector2D();
			v.setTempPoint();
			return v;
		}
	}

}