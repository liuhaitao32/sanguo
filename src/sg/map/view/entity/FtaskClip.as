package sg.map.view.entity {
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import sg.manager.EffectManager;
	import sg.manager.ViewManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityFtask;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.MapUtils;
	import sg.map.utils.Math2;
	import sg.map.utils.TestUtils;
	import sg.map.utils.Vector2D;
	import sg.map.view.FtaskInfo;
	import sg.map.view.MapViewMain;
	import sg.scene.SceneMain;
	import sg.scene.constant.EventConstant;
	import sg.scene.view.EventGridSprite;
	import sg.scene.view.MapCamera;
	import sg.scene.view.entity.EntityClip;
	import sg.scene.view.ui.Bubble;
	import sg.utils.Tools;
	import ui.com.building_tips10UI;
	import ui.com.building_tips2UI;
	import ui.mapScene.FtaskInfoUI;
	
	/**
	 * 民情
	 * @author light
	 */
	public class FtaskClip extends EntityClip {
		
		
		public function get ftaskEntity():EntityFtask { return EntityFtask(this._entity); }
		
		
		public var bubble:Bubble;
		
		public var info:FtaskInfo;
		
		public var gridSprite:Sprite = new Sprite();
		
		public function FtaskClip(scene:SceneMain) {
			super(scene);			
			this.info = new FtaskInfo(scene);
			this.bubble = new Bubble(this);
		}
		
		override public function init():void {
			super.init();
			//this._clip.addChild(EffectManager.loadHeroAnimation(this.monster.heroId));
			
			this.bubble.on(Event.CLICK, this, this.onClick);
			
			this.ftaskEntity.on(EventConstant.DEAD, this, this.clear);
			this.visible = true;
			this._clip.x += this._scene.mapGrid.gridHalfW;
			this._clip.y += this._scene.mapGrid.gridHalfH;// + 10;
			
			
			
			this.addChildAt(this.gridSprite, 0);
			this.gridSprite.texture = Laya.loader.getRes("map2/qiecuo.png");
			
			if (this.ftaskEntity.mapGrid.gridSprite && !this.ftaskEntity.mapGrid.gridSprite.destroyed) {
				MapViewMain.instance.mapLayer.addItemSprite(this.ftaskEntity.mapGrid.gridSprite, this, this.ftaskEntity.mapGrid.col, this.ftaskEntity.mapGrid.row);
				
				//重新调整下吧。 一般都在左上角 所以 一定是下面的。 懒得让策划调城池大小了。
				EventGridSprite(this.parent).addChildAt(this, 0);
				
				if (this.ftaskEntity.task_type == 1) {
					//重新计算下。 在左上角。
					var v1:Vector2D = new Vector2D();
					MapViewMain.instance.mapLayer.getPos(this.ftaskEntity.city.mapGrid.col, this.ftaskEntity.city.mapGrid.row, Point.TEMP);
					v1.setTempPoint();
					var v2:Vector2D = new Vector2D();
					MapViewMain.instance.mapLayer.getPos(this.ftaskEntity.mapGrid.col, this.ftaskEntity.mapGrid.row, Point.TEMP);
					v2.setTempPoint();
					
					var v3:Vector2D = v2.clone().subtract(v1);
					v3.length = MapModel.instance.mapGrid.halfhypotenuse * this.ftaskEntity.city.size + MapModel.instance.mapGrid.halfhypotenuse;
					v3.add(v1);
					//v3是全局坐标。。。转化到对应的格子上
					this.x = v3.x - this.ftaskEntity.mapGrid.gridSprite.x;
					this.y = v3.y - this.ftaskEntity.mapGrid.gridSprite.y;
					this.ftaskEntity.x = v3.x;
					this.ftaskEntity.y = v3.y;
					
					
					Point.TEMP.setTo(v3.x, v3.y);
					
					this.bubble.setData({icon:this.ftaskEntity.ftask.showObj.item, ui:building_tips10UI, flagText:Tools.getMsgById("pctask_npc_name04"), flagBg:"ui/img_icon_36.png"});
					
				} else {
					//this._clip.addChild(EffectManager.loadAnimation(this.ftaskEntity.modelRes, "down"));
					this._scene.mapLayer.getPos(this.ftaskEntity.mapGrid.col, this.ftaskEntity.mapGrid.row, Point.TEMP);
					this.bubble.setData({icon:"ui/home_05.png", ui:building_tips10UI, flagText:Tools.getMsgById("msg_FtaskClip_0"), flagBg:"ui/img_icon_36.png"});
				}
				
				var infoData:Object = {};
				if (this.ftaskEntity.task_type == 1) {
					//难度。
					infoData.label = this.ftaskEntity.name + "·" + Tools.getMsgById(["alien_easy", "alien_normal", "alien_trouble"][this.ftaskEntity.mode]);				
					infoData.color = ["#82a5ff", "#cc5dff", "#ffd02d"][this.ftaskEntity.mode];
				} else {
					infoData.color = "#FFFFFF";
					infoData.label = this.ftaskEntity.name;
				}
				this.info.setData(infoData);
				
				
				this.bubble.x = Point.TEMP.x;
				this.bubble.y = Point.TEMP.y - this._scene.mapGrid.gridHalfH - 10;			
				
				this.info.x = Point.TEMP.x;
				this.info.y = Point.TEMP.y + this._scene.mapGrid.gridHalfH - 15;
			
				
				if (this.ftaskEntity.mapGrid.gridSprite.visible) {
					this.show();
				} else {
					this.hide();
				}
			}
			
			//this.draw(this.monster.width, this.monster.height);
			//this._line.x += 64;
			//this._line.y += 72 / 2;
		}
		
		override public function toScreenPos():Vector2D {
			if (this.ftaskEntity.task_type == 1) {
				return Vector2D.TEMP.setXY(this._entity.x, this._entity.y).clone();
			} else {
				return super.toScreenPos();
			}
		}
		
		override public function onClick():void {
			super.onClick();
			
			var v:Vector2D = this.toScreenPos();
			MapCamera.lookAtPos(v.x + this._scene.mapGrid.gridHalfW, v.y + this._scene.mapGrid.gridHalfH, 500);		
			
			if (!this.ftaskEntity.city.myCountry) {
				ViewManager.instance.showTipsTxt(Tools.getMsgById("ftaskNotCountry"));
				return;
			}
			if (this.ftaskEntity.city.fire) {
				ViewManager.instance.showTipsTxt(Tools.getMsgById("ftaskFire"));
				return;
			}
				
			this.ftaskEntity.ftask.clickOther(v);			
		}
		
		public override function show():void {			
			super.show();
			this.bubble.visible = true;		
			this.info.visible = true;
			this.visible = true;
			this.bubble.resize();
			this.info.resize();
			this._clip.addChild(this.getMatrix(this.ftaskEntity.matrix.x, this.ftaskEntity.modelRes, 1, "ftask"));
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
			this.ftaskEntity.off(EventConstant.DEAD, this, this.clear);			
			super.destroy(destroyChild);
			Tools.destroy(this.bubble);
			this.ftaskEntity.view = null;
		}
		
	}

}