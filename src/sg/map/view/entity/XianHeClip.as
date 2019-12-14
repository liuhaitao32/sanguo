package sg.map.view.entity {
	import laya.events.Event;
	import laya.maths.Rectangle;
	import sg.boundFor.GotoManager;
	import sg.cfg.ConfigClass;
	import sg.explore.model.ModelTreasureHunting;
	import sg.manager.EffectManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.scene.SceneMain;
	import sg.scene.model.MapGrid;
	import sg.scene.view.InputManager;
	import sg.scene.view.MapCamera;
	import sg.scene.view.entity.EntityClip;
	
	/**
	 * ...
	 * @author light
	 */
	public class XianHeClip extends EntityClip {
		
		
		public var city:EntityCity;
		
		
		public var grid:MapGrid;
		
		
		public function XianHeClip(scene:SceneMain) {
			super(scene);			
		}
		
		override public function init():void {
			super.init();
			this._ani = EffectManager.loadAnimation("glow_mining_entry", '', 0, null, "map");
			this._clip.addChild(this._ani);
			this._clip.x = MapModel.instance.mapGrid.gridHalfW;
			this._clip.y = MapModel.instance.mapGrid.gridHalfH;
			
			this.on(Event.CLICK, this, this.onClick);
			
			this.hitArea = new Rectangle(0, -40, MapModel.instance.mapGrid.gridW, MapModel.instance.mapGrid.gridH + 20);
		}
		
		override public function event(type:String, data:* = null):Boolean {
			var isClick:Boolean = (type == Event.CLICK);
			if (isClick) {
				if (!InputManager.instance.canClick) return true;
				if (data is Event) {
					Event(data).stopPropagation();
				}
			}
			return super.event(type, data);
		}
		
		override public function onClick():void {			
			super.onClick();
			if (ModelTreasureHunting.instance.active) {
				MapCamera.lookAtGrid(this.grid, 500);
				GotoManager.showView(ConfigClass.VIEW_TREASURE_HUNTING); 
			}
		}
		
		override public function show():void {
			super.show();			
			this.visible = ModelTreasureHunting.instance.active;
		}
	}

}