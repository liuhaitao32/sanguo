package sg.home.model.entitys {
	// import laya.debug.tools.comps.Rect;
	import laya.maths.Rectangle;
	import sg.cfg.ConfigServer;
	import sg.home.model.HomeModel;
	import sg.manager.ModelManager;
	import sg.model.ModelBuiding;
	import sg.scene.constant.ConfigConstant;
	import sg.scene.model.MapGrid;
	import sg.scene.model.entitys.EntityBase;
	import sg.utils.Tools;
	/**
	 * 
	 * @author light
	 */
	public class EntityBuild extends EntityBase {
		
		public var state:int = 0;
		
		public var model:ModelBuiding;		
		
		
		public function EntityBuild(netId:int = -1) {
			super(netId);			
		}
		
		override public function initConfig(data:* = null):void {
			super.initConfig(data);
			this.model = ModelManager.instance.modelInside.getBuildingModel(this.id);
			
			
			
			var range:Array = this.getParamConfig("rect");
			
			this.x      = range[0];
			this.y      = range[1];
			this.width  = range[2];
			this.height = range[3];
			
			var w:int = HomeModel.instance.mapGrid.gridW;
			var h:int = HomeModel.instance.mapGrid.gridH;
			
			var left:int = parseInt(((this.x - this.width / 2) / w).toString());
			var right:int = parseInt(((this.x + this.width / 2) / w).toString());
			var top:int = parseInt(((this.y - this.height / 2) / h).toString());
			var bottom:int = parseInt(((this.y + this.height / 2) / h).toString());
			
			for (var i:int = left, len:int = right + 1; i < len; i++) {
				for (var j:int = top, len2:int = bottom + 1; j < len2; j++) {
					var grid:MapGrid = HomeModel.instance.mapGrid.getGrid(i, j);
					if(grid){
						grid.addClickEntity(this);
					}
					else{
						trace('grid超出范围' + this.model.name);
					}
				}
			}
		}
		
		
		
		public function get name():String{
			return Tools.getMsgById(this.getParamConfig("name"));
		}
		
		override public function get type():int {
			return ConfigConstant.ENTITY_BUILD;
		}
		
	}

}