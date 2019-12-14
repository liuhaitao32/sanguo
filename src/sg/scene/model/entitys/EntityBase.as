package sg.scene.model.entitys {
	import interfaces.IClear;
	import laya.display.Sprite;
	import laya.events.EventDispatcher;
	import sg.scene.constant.EventConstant;
	import sg.scene.model.MapGrid;
	import sg.map.model.MapModel;
	import sg.scene.view.entity.EntityClip;
	
	/**
	 * ...
	 * @author light
	 */
	public class EntityBase extends EventDispatcher implements IClear {
		
		public var netId:int = -1;
		
		public var id:String;
		
		protected var _cleared:Boolean = false;
		
		public var view:EntityClip;
		
		public var _data:* = null;
		public var x:Number = 0;
		public var y:Number = 0;
		public var width:Number = 0;
		public var height:Number = 0;
		
		public var name:String;		
		
		public var mapGrid:MapGrid;
		
		public function EntityBase(netId:int = -1) {
			this.netId = netId;
		}
		
		public function initConfig(data:* = null):void {
			this._data = data;
		}
		
		
		public function getParamConfig(param:String):*{
			return this._data[param];
		}
		
		public function setData(data:*):void {
			this.netId = data.netId;
			this.id = data.id;
		}
		
		public function getData():Object {
			var result:Object = {};
			result.netId = this.netId;
			result.id = this.id;
			return result;
		}
		
		public function get type():int {
			return -1;
		}
		
		public function get cleared():Boolean {
			return this._cleared;
		}
		
		public function clear():void{
			this._cleared = true;
			this.event(EventConstant.DEAD);
			this.offAll();
		}
		
		
	}

}