package sg.map.view.entity {
	import laya.events.Event;
	import laya.maths.Point;
	import sg.manager.ViewManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityGtask;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.TestUtils;
	import sg.map.view.FtaskInfo;
	import sg.map.view.MapViewMain;
	import sg.model.ModelTask;
	import sg.scene.SceneMain;
	import sg.scene.constant.EventConstant;
	import sg.scene.view.entity.EntityClip;
	import sg.scene.view.ui.Bubble;
	import sg.utils.Tools;
	import ui.com.building_tips10UI;
	import ui.com.building_tips2UI;
	
	/**
	 * 政务
	 * @author light
	 */
	public class GtaskClip extends EntityClip {
		
		
		public function get gtask():EntityGtask { return EntityGtask(this._entity); }		
		
		public var bubble:Bubble;
		
		public var info:FtaskInfo;
		
		public function GtaskClip(scene:SceneMain) {
			super(scene);		
			this.bubble = new Bubble(this);
			this.info = new FtaskInfo(scene);
		}
		
		override public function init():void {
			super.init();
			
			this.bubble.on(Event.CLICK, this, this.onClick);
			
			this.gtask.on(EventConstant.DEAD, this, this.clear);
			this._clip.x += this._scene.mapGrid.gridHalfW;
			this._clip.y += this._scene.mapGrid.gridHalfH;
			
			if (this.gtask.mapGrid.gridSprite && !this.gtask.mapGrid.gridSprite.destroyed) {
				MapViewMain.instance.mapLayer.addItemSprite(this.gtask.mapGrid.gridSprite, this, this.gtask.mapGrid.col, this.gtask.mapGrid.row);
				this._scene.mapLayer.getPos(this.gtask.mapGrid.col, this.gtask.mapGrid.row, Point.TEMP);
				
				this.bubble.setData({icon:this.gtask.icon, ui:building_tips10UI, flagText:Tools.getMsgById("lvup06_3_name"), flagBg:"ui/img_icon_38.png"});				
				this.info.setData({label:this.gtask.name, color:"#FFFFFF"});
				
				this.bubble.x = Point.TEMP.x;
				this.bubble.y = Point.TEMP.y - this._scene.mapGrid.gridHalfH - 10;			
				
				this.info.x = Point.TEMP.x;
				this.info.y = Point.TEMP.y + this._scene.mapGrid.gridHalfH - 15;
			
				
				if (this.gtask.mapGrid.gridSprite.visible) {
					this.show();
				} else {
					this.hide();
				}
			}
			
		}
		
		
		override public function onClick():void {
			super.onClick();
			if (!this.gtask.city.myCountry) {
				ViewManager.instance.showTipsTxt(Tools.getMsgById("gtaskNotCountry"));
				return;
			}
			if (this.gtask.city.fire) {
				ViewManager.instance.showTipsTxt(Tools.getMsgById("gtaskFire"));
				return;
			}
			ModelTask.gTask_click(this.gtask.city.cityId.toString(),this.toScreenPos());
		}
		
		public override function show():void {			
			super.show();
			this.bubble.visible = true;		
			this.info.visible = true;
			this.visible = true;
			this.bubble.resize();
			this.info.resize();
			this._clip.addChild(this.getMatrix(this.gtask.matrix.x, this.gtask.modelRes, 1, "gtask"));
			this.addChildAt(this.getSprite("map2/qiecuo_1.png"), 0);
			ArrayUtils.push(this.bubble, this._scene.bubbles);	
			ArrayUtils.push(this.info, this._scene.bubbles);
		}
		
		public override function hide():void {
			super.hide();
			ArrayUtils.remove(this.bubble, this._scene.bubbles);	
			ArrayUtils.remove(this.info, this._scene.bubbles);
			this.bubble.visible = false;
			this.info.visible = false;
			this.visible = false;
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			this.hide();
			this.gtask.off(EventConstant.DEAD, this, this.clear);
			
			super.destroy(destroyChild);
			Tools.destroy(this.bubble);
			this.gtask.view = null;
		}
		
	}

}