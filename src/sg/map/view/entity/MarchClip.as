package sg.map.view.entity {
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.resource.Texture;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import sg.guide.model.ModelGuide;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.model.MapModel;
	import sg.map.utils.Math2;
	import sg.map.view.AroundManager;
	import sg.map.view.MarchInfo;
	import sg.model.ModelBuiding;
	import sg.model.ModelHero;
	import sg.model.ModelScience;
	import sg.model.ModelSettings;
	import sg.model.ModelTroop;
	import sg.model.ModelTroopManager;
	import sg.model.ModelUser;
	import sg.scene.SceneMain;
	import sg.scene.constant.EventConstant;
	import sg.scene.model.MapGrid;
	import sg.scene.model.entitys.EntityBase;
	import sg.map.model.entitys.EntityCity;
	import sg.map.model.entitys.EntityMarch;
	import sg.map.utils.MapUtils;
	import sg.map.utils.Vector2D;
	import sg.map.view.MapViewMain;
	import sg.scene.view.InputManager;
	import sg.scene.view.MarchPathManager;
	import sg.scene.view.entity.EntityClip;
	import sg.utils.Tools;
	/**
	 * ...
	 * @author light
	 */
	public class MarchClip extends EntityClip {
		
		private var turnPoints:Array = [];
		
		private var tween:Tween;
		
		private var index:int = 0;
		
		private var _way:Array = [];
		
		private var _animation:MarchMatrixClip;
		
		
		
		public function MarchClip(scene:SceneMain) {
			super(scene);			
		}
		
		private function get isShow():Boolean {
			return !(!ModelSettings.instance.modelActive && this.entityMarch.country == ModelManager.instance.modelUser.country && !ModelManager.instance.modelTroopManager.troops[this.entityMarch.id]);
		}
		
		override public function init():void {
			super.init();
			if (this.entityMarch.hero == "hero826" || this.entityMarch.hero == "hero827") {
				MapViewMain.instance.mapLayer.topLayer.addChildAt(this, 0);
			} else {
				MapViewMain.instance.mapLayer.topLayer.addChild(this);
			}
			this.on(Event.CLICK, this, this.onClick);
			//InputManager.pierceEvent(this);
			var scales:Number = this.entityMarch.isCountry_army ? ConfigServer.world["marchScale"][2] : (this.entityMarch.isMine ? ConfigServer.world["marchScale"][0] : ConfigServer.world["marchScale"][1]);
			this.scale(scales, scales);
			var w:Number = 100 * scales;
			this.hitArea = new Rectangle( -w / 2, -w, w, w);
			this.checkShow();
			ModelSettings.instance.on(ModelSettings.CHANGE_MODEL, this, this.checkShow);
		}
		
		private function checkShow():void {
			var s:Boolean = this.isShow;
			this.visible = s;
		}
		
		
		override public function event(type:String, data:* = null):Boolean {
			if (type == Event.CLICK && (!InputManager.instance.canClick)) {
				return true;
			}
			return super.event(type, data) && false;
		}
		
		override public function onClick():void {
			if (ModelGuide.forceGuide()) return;
			if (this.entityMarch.uid == ModelManager.instance.modelUser.mUID){
				ViewManager.instance.showView(ConfigClass.VIEW_TROOP_EDIT,ModelManager.instance.modelTroopManager.troops[this.entityMarch.id]);
			} else {
				ModelManager.instance.modelUser.selectUserInfo(this.entityMarch.uid);
			}
			
		}
		
		override public function get entity():EntityBase {
			return super.entity;
		}
		
		override public function set entity(value:EntityBase):void {
			super.entity = value;
			this._animation = new MarchMatrixClip();
			
			var armyScale:Number = this.entityMarch.isCountry_army ? ConfigServer.system_simple.scale_matrix.countryArmy : ConfigServer.system_simple.scale_matrix.army;
			var heroScale:Number = this.entityMarch.isCountry_army ? ConfigServer.system_simple.scale_matrix.countryHero : 
																		this.entityMarch.isMine ? 
																			ConfigServer.system_simple.scale_matrix.hero1 :
																			ConfigServer.system_simple.scale_matrix.hero2;
			
			this._animation.init(this.entityMarch.hero, this.entityMarch.isMine, this.entityMarch.isMine, true, this.entityMarch.title, this.entityMarch.country, this.entityMarch.isCountry_army, heroScale, armyScale);
			
			this._clip.addChild(this._animation);
			
			var ani:Animation;
			//套装
			if (this.entityMarch.group) {
				var cfg:Object = ConfigServer.effect.group[this.entityMarch.group];
				if (cfg) {
					ani = EffectManager.loadAnimation(cfg.hero, 'map', 0, null, "map");
					ani.blendMode = 'lighter';
					this._clip.addChild(ani);
				}
			}
			//觉醒
			if (this.entityMarch.awaken) {
				ani = EffectManager.loadAnimation('awaken', 'map', 0, null, "map");
				ani.blendMode = 'lighter';
				this._clip.addChildAt(ani,0);
			}
			
			this._entity.on(EventConstant.MARCH_RATE_CHANGE, this, this.onRateChangeHandler);
			this._entity.on(EventConstant.TROOP_MARCH_RECALL, this, this.onRecallHandler);
			this._entity.on(EventConstant.REPEAT, this, this.repeatHandler);
			this._entity.once(EventConstant.DEAD, this, this.clear);
			
			
			
			this.setUI();
			var march:EntityMarch = this.entityMarch;
			var setCity:Function = function(sp:Sprite, ec:EntityCity):void {
				sp.x = ec.x;
				sp.y = ec.y;
				_scene.mapLayer.topLayer.addChild(sp);
				_way.push(sp);
			}
			MarchPathManager.instance.setMarch(this, false);
			
			if (march.isMine) {
				var startSp:Sprite = new Sprite();
				//startSp.graphics.drawCircle(0, 0, 10, "FF0000");
				setCity(startSp, march.startCity);
				setCity(EffectManager.loadAnimation("building_aim", (march.position <= 100 ? "in|stand" : "stand"), 0, null, "map"), march.endCity);
			}
			
			this.move();
		}
		
		/**
		 * 这个是由timer的类里派发的。
		 * @param	index
		 */
		private function repeatHandler(index:int):void {
			if (index < 4) return;
			this.move();
			this.setUI();
		}
		
		private function setUI():void {
			var totalTime:* = this.entityMarch.remainTime(0);
			if (this.entityMarch.state == ModelTroop.TROOP_STATE_RECALL) {
				this._animation.marchInfo.initUI(totalTime - this.entityMarch.remainTime(), totalTime);
			} else {
				this._animation.marchInfo.initUI(this.entityMarch.remainTime(), totalTime);
			}
			
		}
		
		
		private function onRecallHandler(e:Event):void {
			this.turnPoints = this.turnPoints.slice(0, this.index);
			for (var i:int = 0, len:int = this.turnPoints.length - 1; i < len; i++) {
				this.turnPoints[i][2] = this.turnPoints[i + 1][2];
				this.turnPoints[i][3] = this.turnPoints[i + 1][3];
			}
			this.turnPoints = this.turnPoints.reverse();
			
			this.turnPoints.shift();
			this.index = 0;
			var t:Number = this.tween ? this.tween.usedTimer : 0;			
			this.startTween();
			if (this.tween){
				this.tween.duration = t;
			}
			this.setUI();
		}
		
		private function onRateChangeHandler(e:Number):void {
			if (this.tween) this.tween.scale = 1 / (e);
			this.setUI();
		}
		
		private function move(b:Boolean = true):void {
			var march:EntityMarch = this.entityMarch;
			if (march.cleared) return;
			if (march.isFinish) {
				var vv:Vector2D = EntityCity(MapModel.instance.citys[march.marchData[march.marchData.length - 1][0]]).mapGrid.toScreenPos();
				this.pos(vv.x, vv.y);
				
				this.removeSelf();
				return;
			}
			var citys:Array = march.currCity();
			
			var pathData:Object = EntityCity.getPathDataById(citys[0], citys[1]);
			var path:Array = null;
			if (!pathData) {
				path = [
						Vector2D(EntityCity(MapModel.instance.citys[citys[0]]).mapGrid.toString2()),
						Vector2D(EntityCity(MapModel.instance.citys[citys[1]]).mapGrid.toString2())
					];
			} else {
				path = pathData.path.concat();
				if(parseInt(citys[0]) > parseInt(citys[1])) {
					path = path.reverse();
				}
			}
			
			
			
			
			var currCityDist:int = march.position - march.getDistByIndex(march.index - 1);//距离上一个城市已经走了距离。
			
			var dist:int = march.marchData[march.index][2];
			
			//已经走了格子数 = 已经走的距离 / 每个格子所占的距离
			var gridDist:Number = 1.0 * dist / (path.length - 1);//单位格子的距离
			var gridIndex:Number = (currCityDist / gridDist);//已经走了格子数量
			
			var grid1:Vector2D = Vector2D.toVector(path[parseInt(gridIndex.toString())]);
			var grid2:Vector2D = Vector2D.toVector(path[parseInt(gridIndex.toString()) + 1]);
			
			var p1:Vector2D = new Vector2D();
			MapViewMain.instance.mapLayer.getPos(grid1.x, grid1.y, Point.TEMP);
			p1.setPoint(Point.TEMP);
			var p2:Vector2D = new Vector2D();
			MapViewMain.instance.mapLayer.getPos(grid2.x, grid2.y, Point.TEMP);
			p2.setPoint(Point.TEMP);
			var gridRate:Number = gridIndex - parseInt(gridIndex.toString());
			Vector2D.lerp(p1, p2, gridRate, Vector2D.TEMP);
			if(b){
				this.x = Vector2D.TEMP.x;
				this.y = Vector2D.TEMP.y;	
			}
			
			
			this.index = 0;	
			this.turnPoints = [];
			if (this.tween) this.tween.clear();
			//先push之前走的路程
			turnPoints = this.turnPoints.concat(this.getAllTurnPath(currCityDist, march.index));
			
			//再检测之后走的路程。
			for (var i:int = march.index + 1, len:int = march.marchData.length - 1; i < len; i++) {
				turnPoints = this.turnPoints.concat(this.getAllTurnPath(0, i));
			}
			
			
			this.startTween();
		}
		
		
		
		private function startTween():void {
			if (this.tween) this.tween.clear();
			this.tween = null;
			
			if (this.turnPoints.length == this.index) return;
			
			var path:Array = this.turnPoints[this.index];
			this.index++;
			//turnArr.push([grid1, i, iii, ut]);
			var grid:Vector2D = path[0];
			var t:Number = path[2] * path[3] / this.entityMarch.rate;
			var isWater:Boolean = path[5];
			if (t == 0) {
				this.startTween();
			}else{
				if (this.turnPoints.length == this.index) t += 1;
				MapViewMain.instance.mapLayer.getPos(grid.x, grid.y, Point.TEMP);
				this.tween = Tween.to(this, {x:Point.TEMP.x, y:Point.TEMP.y}, t * 1000, null, new Handler(this, this.startTween), 0, false, false);
				var dir:Array = this.y > Point.TEMP.y ? [0, 3] : [1, 2];
				this._animation.changeShip(isWater);
				this._animation.changeDir(this.x < Point.TEMP.x ? dir[0] : dir[1]);
			}
		}
		
		
		public function getAllTurnPath(pos:Number, i:int):Array {
			var march:EntityMarch = this.entityMarch;
			
			var result:Array = [];
			
			var city1:int = parseInt(march.marchData[i][0]);
			var city2:int = parseInt(march.marchData[i + 1][0]);				
			
			
			
			var pathData:Object = EntityCity.getPathDataById(city1, city2);
			var isWater:Boolean = false;
			var path:Array = null;
			if (!pathData) {
				path = [
						Vector2D(EntityCity(MapModel.instance.citys[city1]).mapGrid.toString2()),
						Vector2D(EntityCity(MapModel.instance.citys[city2]).mapGrid.toString2())
					];
			} else {
				path = pathData.path.concat();
				if(city1 > city2) {
					path = path.reverse();
				}
				isWater = (pathData.water == 1);
			}
			
			var turnArr:Array = [];
			
			var f:int = 0;
			var ut:Number = 1.0 * march.marchData[i][2] / march.marchData[i][1] / (path.length - 1);//一个格子的时间
			
			//已经走了格子数 = 已经走的距离 / 每个格子所占的距离
			var gridDist:Number = 1.0 * march.marchData[i][2] / (path.length - 1);//单位格子的距离
			var gridIndex:Number = (pos / gridDist);//已经走了格子数量
			
			var gridRate:Number = gridIndex - parseInt(gridIndex.toString());
			
			var iii:Number = gridRate ? 1 - gridRate : 0;
			
			for (var j:int = Math.ceil(gridIndex), len2:int = path.length - 1; j < len2; j++) {
				
				var grid1:Vector2D = Vector2D.toVector(path[j]);
				var grid2:Vector2D = Vector2D.toVector(path[j + 1]);
				
				var gridX1:Vector2D = MapUtils.tileToIso(grid1);
				var gridX2:Vector2D = MapUtils.tileToIso(grid2);
				
				if(f == 0) {
					f = gridX1.x == gridX2.x ? 1 : -1;
					turnArr.push([grid1, i, iii, ut, j, isWater]);
					iii = 0;
				} else if((f == 1 && gridX1.x != gridX2.x) || (f == -1 && gridX1.y != gridX2.y)) {
					turnArr.push([grid1, i, iii, ut, j, isWater]);
					f = -f;
					iii = 0;
				}
				iii++;
			}
			var grid:Vector2D = Vector2D.toVector(path[path.length - 1]);
			turnArr.push([grid, path.length - 1, iii, ut, j, isWater]);
			return turnArr;
			
		}
		
		public function get entityMarch():EntityMarch {
			return this.entity as EntityMarch;
		}
		
		override public function get visible():Boolean {
			return super.visible;
		}
		
		override public function set visible(value:Boolean):void {
			if (value) {//还要检查脚底下是否在迷雾里。
				if (this.entityMarch.country != ModelUser.getCountryID()) {//不是我国的军队。
					if (AroundManager.instance.inMask(this.x + MapModel.instance.mapGrid.gridHalfW, this.y + MapModel.instance.mapGrid.gridHalfH)) {
						value = false;
					}
				}
			}
			super.visible = value;
		}
		
		override public function clear():void {
			if (this._cleared) return;
			super.clear();
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			super.destroy(destroyChild);
			var way:Array = this._way;
			Laya.timer.callLater(way, function():void {
				for (var i:int = 0, len:int = way.length; i < len; i++) {
					Tools.destroy(Sprite(way[i]));
				}
			});
			MarchPathManager.instance.setMarch(this, true);
			
			this._entity.off(EventConstant.MARCH_RATE_CHANGE, this, this.onRateChangeHandler);
			this._entity.off(EventConstant.TROOP_MARCH_RECALL, this, this.onRecallHandler);
			this._entity.off(EventConstant.DEAD, this, this.clear);
			this._entity.off(EventConstant.REPEAT, this, this.repeatHandler);
			this.entityMarch.view = null;
		}
	}

}