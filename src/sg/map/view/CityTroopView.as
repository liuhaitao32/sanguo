package sg.map.view {
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import laya.maths.MathUtil;
	import laya.maths.Rectangle;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.cfg.ConfigClass;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.TestUtils;
	import sg.map.utils.Vector2D;
	import sg.map.view.entity.CityClip;
	import sg.model.ModelHero;
	import sg.model.ModelTroop;
	import sg.scene.constant.EventConstant;
	import sg.scene.view.entity.EntityClip;
	import sg.scene.view.ui.NoScaleUI;
	import sg.utils.Tools;
	
	/**
	 * ...
	 * @author light
	 */
	public class CityTroopView extends NoScaleUI {
		
		public var troops:Array = [];
		
		private var pos:Array = [Vector2D.ZERO, Vector2D.TOP, Vector2D.BOTTOM, Vector2D.RIGHT, Vector2D.RIGHT_TOP, Vector2D.RIGHT_BOTTOM, Vector2D.LEFT, Vector2D.LEFT_TOP, Vector2D.LEFT_BOTTOM];
		
		private var itemW:Number = 60.0;
		
		private var _content:Sprite = new Sprite();
		
		private var _isOpen:Boolean = false;
		
		private var _cityEntity:EntityCity;
		
		
		public function CityTroopView() {
			super();
			
		}
		
		public function init(clip:CityClip):void {
			this._cityEntity = clip.entityCity;
			this.initScene(clip.scene);
			this._cityEntity.on(EventConstant.CITY_FIRE, this, this.update);
			MapViewMain.instance.mapLayer.infoLayer.addChild(this);
			this.x = clip.entityCity.x + clip.entityCity.width / 2;
			this.y = clip.entityCity.y;
			this.addChild(this._content);
			this.resize();			
			this.checkView();
		}
		
		private function checkView():void {
			(this.troops.length < 3) ? this.show() : this.hide();
		}
		
		public function addTroop(troop:ModelTroop):void {	
			//for (var i:int = 0, len:int = 2; i < len; i++) {
				var troopView:CityTroopViewItem = new CityTroopViewItem(troop, this._cityEntity);
				this._content.addChild(troopView);
				troopView.on(Event.CLICK, this, onClickHandler, [troopView]);
				troopView.hitArea = new Rectangle( -this.itemW / 2, -this.itemW / 2, this.itemW, this.itemW);
				troop.on(EventConstant.TROOP_UPDATE, this, this.update);
				troop.on(EventConstant.FIGHT_FINISH_FIGHT, this, this.update);
				troop.on(EventConstant.TROOP_REMOVE, this, this.update);
				troop.on(EventConstant.TROOP_ADD_NUM, this, this.update);
				this.troops.push(troopView);
				this.sortPower();
				this.sortContent();			
				this.update();
			//}
			
			
		}
		
		private function sortPower():void {
			this.troops = this.troops.sort(function(item1:CityTroopViewItem, item2:CityTroopViewItem):Number {				
				var hmd1:ModelHero = ModelManager.instance.modelGame.getModelHero(item1.troop.hero);
				var hmd2:ModelHero = ModelManager.instance.modelGame.getModelHero(item2.troop.hero);
				return MathUtil.sortBigFirst(hmd1.getPower(), hmd2.getPower());
			});
			
		}
		
		private function sortContent():void {
			if (this._isOpen) {
				var targetPos:Array = this.getTargetPos();
				targetPos = ArrayUtils.sortOn([1], targetPos, true);
				for (var i:int = 0, len:int = targetPos.length; i < len; i++) {
					this._content.addChild(this.troops[targetPos[2]]);
				}
			} else {
				for (i = this.troops.length - 1; i > -1; i--) {
					this._content.addChild(this.troops[i]);
				}
			}
		}
		
		private function onClickHandler(item:CityTroopViewItem):void {
			if (this.troops.length > 2 && !this._isOpen) {
				this.show();
			} else {
				if(item.troop.isReadyFight || item.troop.state == ModelTroop.TROOP_STATE_MONSTER){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("fight_troop_turn_fighting"));//"正在战斗中"
				} else {
					ViewManager.instance.showView(ConfigClass.VIEW_TROOP_EDIT, item.troop);
				}				
				this.checkView();
			}
			
		}
		
		public function removeTroop(troop:ModelTroop):void {
			for (var i:int = 0, len:int = this.troops.length; i < len; i++) {
				var troopView:CityTroopViewItem = this.troops[i];
				if (troopView.troop == troop) {
					this._content.removeChild(troopView);
					ArrayUtils.remove(troopView, this.troops);
					troop.off(EventConstant.TROOP_UPDATE, this, this.update);
					troop.off(EventConstant.FIGHT_FINISH_FIGHT, this, this.update);
					troop.off(EventConstant.TROOP_REMOVE, this, this.update);
					Tools.destroy(troopView);
					this.sortPower();
					this.sortContent();
					this.checkView();
					break;
				}
			}			
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			while (this.troops.length) {
				this.removeTroop(this.troops.shift().troop);
			}
			
			this._cityEntity.off(EventConstant.CITY_FIRE, this, this.update);
			this.timer.clear(this, this.hide);
			Laya.stage.off(Event.CLICK, this, this.hide);
			super.destroy(destroyChild);			
		}
		
		public function update():void {
			for (var i:int = this.troops.length - 1; i > -1; i--) {
				var item:CityTroopViewItem = CityTroopViewItem(this.troops[i]);
				if (item.troop.deaded) {
					item.destroy();
					this.troops.splice(i, 1);					
				} else {
					item.update();
				}
			}
			
			this.checkView();
		}
		
		public function show():void {
			this._isOpen = true;
			var targetPos:Array = this.getTargetPos();
			for (var i:int = 0, len:int = targetPos.length; i < len; i++) {
				CityTroopViewItem(troops[i]).state_txt.visible = true;
				if(this.troops.length >= 3) this.troops[i].pos(0, 0);
				Tween.to(this.troops[i], {x:targetPos[i][0], y:targetPos[i][1]}, Math.random() * 200 + 200, null, null, 0, true);
				this.troops[i].visible = true;
			}
			this.sortContent();
			if (this.troops.length >= 3) {
				this.timer.once(2000, this, this.hide);
				Laya.stage.once(Event.CLICK, this, this.hide);
			}
			
		}
		
		private function getTargetPos():Array {		
			//不想走脑子动态计算了~ 反正就3种 写死了就好。	
			var targetPos:Array = [];
			if (this.troops.length == 2) {
				targetPos.push([0, -itemW / 2, 0]);
				targetPos.push([0, itemW / 2, 1]);
			} else {
				for (var i:int = 0, len:int = this.troops.length; i < len; i++) {
					targetPos.push([pos[i].x * itemW, pos[i].y * itemW, i]);
				}
			}
			return targetPos;
		}
		
		public function hide():void {
			this._isOpen = false;			
			this.timer.clear(this, this.hide);
			Laya.stage.off(Event.CLICK, this, this.hide);
			for (var i:int = 0, len:int = troops.length; i < len; i++) {
				CityTroopViewItem(troops[i]).state_txt.visible = (i == 0);
				if (i < 3) {
					Tween.to(troops[i], {x:i * 2, y:i * -2}, 300, null, null, 0, true);
				} else {
					Tween.to(troops[i], {x:0, y:0}, 300, null, Handler.create(this, function(item:CityTroopViewItem):void {
						item.visible = false;
					}, [troops[i]]), 0, true);
				}
				
			}
			this.sortContent();
		}
	}

}