package sg.map.model.entitys 
{
	import laya.events.Event;
	import sg.map.model.MapModel;
	import sg.map.utils.MapUtils;
	import sg.map.utils.Vector2D;
	import sg.scene.constant.ConfigConstant;
	import sg.scene.model.MapGrid;
	import sg.scene.model.entitys.EntityBase;
	import sg.scene.view.InputManager;
	/**
	 * ...
	 * @author light
	 */
	public class EntityArena extends EntityBase {
		
		public var index:int = -1;
		
		public function EntityArena(netId:int =-1) {
			super(netId);			
		}
		
		override public function initConfig(data:* = null):void {
			super.initConfig(data);
			this.event(Event.CHANGE);
		}
		
		public function setPos():void {			
			var start:Vector2D = MapModel.instance.mapGrid.getGrid(40, 105).toScreenPos();
			var len:int = MapModel.instance.mapGrid.hypotenuse + 20;
			var offset:Vector2D = MapModel.instance.mapGrid.hypotenuseV.clone();
			offset.length = len * this.index;
			
			var pos:Vector2D = start.add(offset);
			var v:Vector2D = MapModel.instance.mapGrid.getGridByPos(pos.x, pos.y);
			this.mapGrid = MapModel.instance.mapGrid.getGrid(v.x, v.y);
			this.mapGrid.addEntity(this);
			
			this.x = pos.x - 15 - 20;
			this.y = pos.y + 15 - 15;
		}
		
		override public function get type():int {
			return ConfigConstant.ENTITY_ARENA;
		}
		
	}

}