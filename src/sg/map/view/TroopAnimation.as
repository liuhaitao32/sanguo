package sg.map.view {
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.EventDispatcher;
	import laya.events.MouseManager;
	import laya.utils.Handler;
	import laya.utils.Pool;
	import laya.utils.Tween;
	import sg.cfg.ConfigServer;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.map.utils.TestUtils;
	import sg.map.utils.Vector2D;
	import sg.map.view.entity.MarchMatrixClip;
	import sg.model.ModelTroop;
	import sg.scene.constant.EventConstant;
	import sg.scene.model.entitys.EntityBase;
	import sg.utils.Tools;
	
	/**
	 * ...
	 * @author light
	 */
	public class TroopAnimation extends EventDispatcher {
		
		private var troops:Object = {};
		
		private var _destroyed:Boolean = false;
		
		private var _time:Number;
		
		public function TroopAnimation() {
			this._time = (ConfigServer.world.fieldFightRunTime?ConfigServer.world.fieldFightRunTime:2) * 1000;
		}
		
		public function move(troop:ModelTroop, v2:Vector2D, callBack:Handler):void {
			var v1:Vector2D = new Vector2D();
			v1.copy(troop.entityCity.mapGrid.toScreenPos());
			MouseManager.enabled = false;
			
			var content:Sprite = new Sprite();
			
			this.troops[troop.id] = content;
			MapViewMain.instance.mapLayer.topLayer.addChild(content);
			content.pos(v1.x, v1.y);
			
			var animation:MarchMatrixClip = new MarchMatrixClip();
			animation.init(troop.hero, true, true, true, troop.getModelHero().getTitleStatus(), troop.entityCity.country);
			content.addChild(animation).name = "ani";
			var dir:Array = content.y > v2.y ? [0, 3] : [1, 2];
			animation.changeDir(content.x < v2.x ? dir[0] : dir[1]);
			animation.marchInfo.initUI(this._time / 1000, this._time / 1000);
			
			Tween.to(content, {x:v2.x, y:v2.y}, this._time, null, Handler.create(this, function():void{
				MouseManager.enabled = true;
				animation.visible = false;
				if(callBack) callBack.run();
			}));
			
			
		}
		
		public function back(troopId:String):void {
			var content:Sprite = this.troops[troopId];			
			if (!content) return;
			var troop:ModelTroop = ModelManager.instance.modelTroopManager.troops[troopId];					
			if (troop) {		
				var v1:Vector2D = Vector2D.TEMP;
				v1.copy(troop.entityCity.mapGrid.toScreenPos());	
				var animation:MarchMatrixClip = content.getChildByName("ani") as MarchMatrixClip;			
				animation.visible = true;
				animation.marchInfo.initUI(this._time / 1000, this._time / 1000);
				
				var dir:Array = content.y > v1.y ? [0, 3] : [1, 2];
				animation.changeDir(content.x < v1.x ? dir[0] : dir[1]);
				
				Tween.to(content, {x:v1.x, y:v1.y}, this._time, null, Handler.create(this, function():void {
					recoverAnimation(content);
				}));
			} else {
				this.recoverAnimation(content);
			}			
			delete this.troops[troopId];
		}
		
		
		private function recoverAnimation(sp:Sprite):void {
			Tools.destroy(sp);
		}
		
		public static function backTroop(heros:Array):void {
			
			if (!MapViewMain.instance) return;
			if(ModelManager.instance.modelGame.isInside) return;
			for (var i:int = 0, len:int = heros.length; i < len; i++) {
				var troopId:String = ModelManager.instance.modelUser.mUID + "&" + heros[i];
				MapViewMain.instance.troopAnimation.back(troopId);
			}
			
		}
		
		public static function moveTroop(heros:Array, v:Vector2D, callBack:Handler):void {
			if (!MapViewMain.instance) return;
			if(ModelManager.instance.modelGame.isInside){
				if(callBack){
					callBack.run();
				}
				return;
			}
			for (var i:int = 0, len:int = heros.length; i < len; i++) {
				var troopId:String = ModelManager.instance.modelUser.mUID + "&" + heros[i];
				var troop:ModelTroop = ModelManager.instance.modelTroopManager.troops[troopId];	
				if (troop) {
					MapViewMain.instance.troopAnimation.move(troop, v, callBack);
					callBack = null;
				}
			}
			
		}
		
		public function destroy():void {
			this._destroyed = true;
			for (var troop:String in this.troops) {
				Tween.clearAll(this.troops[troop]);
				recoverAnimation(this.troops[troop]);
			}
			this.troops = null;
		}
		
		public function get destroyed():Boolean {
			return this._destroyed;
		}
		
	}

}