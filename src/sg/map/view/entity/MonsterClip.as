package sg.map.view.entity {
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.utils.Ease;
	import laya.utils.Tween;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityHeroCatch;
	import sg.map.model.entitys.EntityMonster;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.MapUtils;
	import sg.map.utils.TestUtils;
	import sg.map.utils.Vector2D;
	import sg.map.view.HeroCatchInfo;
	import sg.map.view.MapViewMain;
	import sg.map.view.MonsterInfo;
	import sg.model.ModelClimb;
	import sg.scene.SceneMain;
	import sg.scene.constant.EventConstant;
	import sg.scene.view.EventGridSprite;
	import sg.scene.view.MapCamera;
	import sg.scene.view.entity.EntityClip;
	import sg.scene.view.ui.Bubble;
	import sg.utils.Tools;
	import sg.view.com.ComPayType;
	import ui.com.building_tips10UI;
	import ui.com.building_tips2UI;
	import ui.com.building_tips5UI;
	import sg.festival.model.ModelFestival;
	import sg.model.ModelItem;
	
	/**
	 * 异族入侵 名将来袭
	 * @author light
	 */
	public class MonsterClip extends EntityClip {
		
		public function get monster():EntityMonster { return EntityMonster(this._entity); }
		
		
		public var bubble:Bubble;
		
		public var info:MonsterInfo;
		
		public var gridSprite:Sprite = new Sprite();
		
		private var _fire:Animation;
		
		public function MonsterClip(scene:SceneMain) {
			super(scene);		
			this.bubble = new Bubble(this);
			this.info = new MonsterInfo(scene);
			//TestUtils.drawTest(this);
		}
		
		override public function init():void {
			super.init();
			//this._clip.addChild(EffectManager.loadHeroAnimation(this.monster.heroId));
			
			this.bubble.on(Event.CLICK, this, this.onClick);
			this.monster.climb.on(ModelClimb.EVENT_PK_NPC_VIEW_UPDATE, this, this.updateHandler);
			
			this.monster.on(EventConstant.DEAD, this, this.clear);
			this.updateHandler(1);
			this.visible = true;
			this._clip.x += this._scene.mapGrid.gridHalfW;
			this._clip.y += this._scene.mapGrid.gridHalfH;
			this.addChildAt(this.gridSprite, 0);
			this.gridSprite.texture = Laya.loader.getRes("map2/qiecuo.png");
			
			if (this.monster.mapGrid.gridSprite && !this.monster.mapGrid.gridSprite.destroyed) {
				MapViewMain.instance.mapLayer.addItemSprite(this.monster.mapGrid.gridSprite, this, this.monster.mapGrid.col, this.monster.mapGrid.row);
				//重新调整下吧。 一般都在左上角 所以 一定是下面的。 懒得让策划调城池大小了。
				EventGridSprite(this.parent).addChildAt(this, 0);
				//重新计算下。 在左上角。
				var v1:Vector2D = new Vector2D();
				MapViewMain.instance.mapLayer.getPos(this.monster.city.mapGrid.col, this.monster.city.mapGrid.row, Point.TEMP);
				v1.setTempPoint();
				var v2:Vector2D = new Vector2D();
				MapViewMain.instance.mapLayer.getPos(this.monster.mapGrid.col, this.monster.mapGrid.row, Point.TEMP);
				v2.setTempPoint();
				
				var v3:Vector2D = v2.clone().subtract(v1);
				v3.length = MapModel.instance.mapGrid.halfhypotenuse * this.monster.city.size + MapModel.instance.mapGrid.halfhypotenuse;
				v3.add(v1);
				//v3是全局坐标。。。转化到对应的格子上
				this.x = v3.x - this.monster.mapGrid.gridSprite.x;
				this.y = v3.y - this.monster.mapGrid.gridSprite.y;
				this.monster.x = v3.x;
				this.monster.y = v3.y;
				
				
				Point.TEMP.setTo(v3.x, v3.y);
				this.bubble.x = Point.TEMP.x;
				this.bubble.y = Point.TEMP.y - this._scene.mapGrid.gridHalfH - 10;			
				
				this.info.x = Point.TEMP.x;
				this.info.y = Point.TEMP.y + this._scene.mapGrid.gridHalfH - 15;
			
				
				if (this.monster.mapGrid.gridSprite.visible) {
					this.show();
				} else {
					this.hide();
				}
			}
			
			//this.draw(this.monster.width, this.monster.height);
			//this._line.x += 64;
			//this._line.y += 72 / 2;
		}
		
		override public function containsPos(screenX:Number, screenY:Number):Boolean {
			return super.containsPos(screenX, screenY);
		}
		
		override public function toScreenPos():Vector2D {
			return Vector2D.TEMP.setXY(this.monster.x, this.monster.y).clone();
		}
		
		private function updateHandler(e:int):void {	
			if (e == 0) return;
			this.info.setData(this.monster);
			if (this.bubble.name != this.monster.climb.icon || e==2) {
				var icon:ComPayType = null;
				if (this.monster.climb.isCaptain()) {//名将来袭
					icon = this.bubble.setData({ui:building_tips5UI, type:0, heroId:this.monster.climb.icon, flagText:Tools.getMsgById("_public85"), flagBg:"ui/img_icon_38.png"});
				} else {
					var arr:Array=ModelFestival.getRewardInterfaceByKey("pk_npc");					
					icon = this.bubble.setData({ui:building_tips10UI, icon:arr.length!=0 ?ModelItem.getIconUrl(arr[0]) : this.monster.climb.icon, flagText:Tools.getMsgById("msg_MonsterClip_0"), flagBg:"ui/img_icon_36.png"});
					
				}
				this.bubble.name = this.monster.climb.icon;
			}
			
			if (!this.monster.climb.pk_npc_fight_ing && this.monster.climb.pk_npc_award) {
				var sp:Sprite = new Sprite();
				this.bubble.addChild(sp);
				sp.texture = Laya.loader.getRes("ui/icon_paopao2.png");
				sp.pivot(sp.texture.sourceWidth / 2, 0);
				sp.y = -100;
				var glow:Animation = EffectManager.loadAnimation("glow041", '', 0, null, "map");
				this.monster.climb.isCaptain() ? glow.pos(32, 32) :glow.pos(35, 35);
				this.bubble.getChildByName("icon")["effect_sp"].addChild(glow);
				
			}
			if (this.monster.climb.pk_npc_fight_ing) {
				if (!this._fire) {
					this._fire = EffectManager.loadAnimation("field_operations", '', 0, null, "map");
					this._fire.x = MapModel.instance.mapGrid.gridHalfW;
					this._fire.y = MapModel.instance.mapGrid.gridHalfH;
				} else {
					this._fire.play();
				}
				this.addChild(this._fire);
				
			} else {				
				if (this._fire) {
					this._fire.removeSelf();
					this._fire.stop();
				}
			}
		}
		
		override public function onClick():void {
			super.onClick();
			var v:Vector2D = this.toScreenPos();
			MapCamera.lookAtPos(v.x + this._scene.mapGrid.gridHalfW, v.y + this._scene.mapGrid.gridHalfH, 500);
			
			if (!this.monster.city.myCountry) {
				ViewManager.instance.showTipsTxt(Tools.getMsgById("monsterNotCountry"));
				return;
			}
			if (this.monster.city.fire) {
				ViewManager.instance.showTipsTxt(Tools.getMsgById("monsterFire"));
				return;
			}
			
			this.monster.climb.pk_npc_click(v);
		}
		
		public override function show():void {			
			super.show();
			this.bubble.visible = true;		
			this.info.visible = true;
			this.visible = true;
			this._clip.addChild(this.getMatrix(this.monster.matrix.x, this.monster.modelRes, this.monster.climb.isCaptain() ? 2 : 1, "monster"));
			this.bubble.resize();
			this.info.resize();
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
			this.monster.climb.off(ModelClimb.EVENT_PK_NPC_VIEW_UPDATE, this, this.updateHandler);
			
			this.monster.off(EventConstant.DEAD, this, this.clear);
			
			super.destroy(destroyChild);
			Tools.destroy(this.bubble);
			//this.monster.off(EventConstant.HERE_CATCH, this, this.updateHandler);
			this.monster.view = null;
			//this.monster.on(EventConstant.HERE_CATCH, this.changeHandler);
		}
	}

}