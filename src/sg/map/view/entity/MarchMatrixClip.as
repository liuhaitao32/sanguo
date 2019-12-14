package sg.map.view.entity {
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.maths.Point;
	import sg.cfg.ConfigServer;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityMarch;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.MapUtils;
	import sg.map.utils.TestUtils;
	import sg.map.utils.Vector2D;
	import sg.map.view.MapViewMain;
	import sg.map.view.MarchInfo;
	import sg.model.ModelBuiding;
	import sg.model.ModelHero;
	import sg.utils.Tools;
	/**
	 * ...
	 * @author light
	 */
	public class MarchMatrixClip extends Sprite {
		
		private var _hero:Animation;
		
		private var _armys:Array = [[], []];
		
		private var _armysContent:Sprite = new Sprite();
		
		private var _tray:Animation;
		
		private var _title:Sprite;
		
		private var _titleText:Text;
		
		public var marchInfo:MarchInfo = new MarchInfo();
		
		private var _ship:Animation;
		
		private var countryArmy:Boolean = false;
		
		public function MarchMatrixClip() {
			//TestUtils.drawTest(this);
		}
		
		public function init(heroId:String, showProgress:Boolean, showArmy:Boolean, showFlag:Boolean, title:String = null, country:int = -1, countryArmy:Boolean = false, heroScale:Number = 1, armyScale:Number = 1):void {
			heroScale ||= 1;
			armyScale ||= 1;
			//this.countryArmy = countryArmy = true;
			this.countryArmy = countryArmy;
			var hmd:ModelHero = ModelManager.instance.modelGame.getModelHero(heroId);
			
			//护国军临时就用一队。 但是位置会偏移。 所以 我在动画文件里改了。
			if (showArmy || countryArmy) {
				this.addChild(this._tray = EffectManager.loadAnimation("run_tray", '', 0, null, "map"));
				for (var i:int = 0, len:int = this.countryArmy ? 2 : 3; i < len; i++) {
					var ani:Animation = EffectManager.loadAnimation(countryArmy ? ConfigServer.country_army["model"][1] : "army" + hmd.army[1] + "" + ModelBuiding.getArmyCurrGradeByType(hmd.army[1]) + "s", '', 0, null, "map");
					ani.scale(armyScale, armyScale);
					this._armys[1].push(ani);
					if (!countryArmy || true) {
						ani = EffectManager.loadAnimation(countryArmy ? ConfigServer.country_army["model"][1] : "army" + hmd.army[0] + "" + ModelBuiding.getArmyCurrGradeByType(hmd.army[0]) + "s", '', 0, null, "map");
						ani.scale(armyScale, armyScale);
						this._armys[0].push(ani);						
					} else {
						Sprite(this._armys[1][i]).pivot(-10, -10);
					}
				}
			}
			
			this.addChild(this._armysContent);
			//this._tray.pivot(MapModel.instance.mapGrid.gridHalfW, MapModel.instance.mapGrid.gridHalfH);
			this._hero = EffectManager.loadHeroAnimation(heroId);
			
			this._hero.scale(heroScale, heroScale);
			this.marchInfo.visible = showProgress;
			//显示旗子
			if (showFlag) {
				this._title = new Sprite();
				this.addChild(this._title);
				//str = "title001";
				//显示称号。
				if (title) {
					this._titleText = new Text();
					this.changeTitle(title);
					this._titleText.fontSize = 14;
					this._titleText.color = "#FFFFFF";
					this._title.pivotX = this._title.texture.sourceWidth / 2 - 35;
					this.addChild(this._titleText);
					this._title.pivotY = 95 + 30;
				} else {
					this._title.texture = Laya.loader.getRes("ui/run_flag" + country + ".png");
					this._title.pivotY = 95;
					this._title.pivotX = this._title.texture.sourceWidth / 2;
					
				}
				
				
			}
			
			
			this.addChild(this.marchInfo);
			this.marchInfo.y = -40;
			this.marchInfo.x = 30;
			//this.addChild(this._hero);
		}
		public function changeTitle(title:String):void{
			this._titleText.text = Tools.getMsgById(title);		
			this._title.texture = Laya.loader.getRes("ui/" + ConfigServer.title[title]["flag_icon"] + ".png");
		}
		
		
		public function changeShip(b:Boolean):void {
			if (b) {
				if (!this._ship) {
					this._ship = EffectManager.loadAnimation("hero_99s", '', 0, null, "map");
					this._armysContent.addChild(this._ship);
				}
				this.marchInfo.x = 0;
			}
			
			if (this._ship) this._ship.visible = b;
			if (this._tray) this._tray.visible = !b;
			this._hero.visible = !b
			for (var i:int = 0, len:int = this._armys.length; i < len; i++) {
				for (var j:int = 0, len2:int = this._armys[i].length; j < len2; j++) {
					this._armys[i][j].visible = !b;
				}
			}
		}
		
		public function changeDir(dir:int):void {
			//dir = 2;
			var scaleFlag:Boolean = ArrayUtils.contains(dir, [0, 1]);
			var dirFlag:Boolean = ArrayUtils.contains(dir, [0, 3]);
			
			MapUtils.changeDir(this._hero, dir);
			if (this._ship) {
				MapUtils.changeDir(this._ship, dir);
			}
			
			if (this._ship && this._ship.visible) {				 
				this.marchInfo.x = 0;
			} else {
				this.marchInfo.x = scaleFlag ? -40 : 40;
			}
			
			this.getMatrix(dir, this._armys[0], new Vector2D(this.countryArmy ? this.offsetArr2[dir][0] : this.offsetArr[dir][0], this.countryArmy ? this.offsetArr2[dir][1] : this.offsetArr[dir][1]));
			this.getMatrix(dir, this._armys[1], new Vector2D(this.countryArmy ? this.offsetArr2[dir][2] : this.offsetArr[dir][2], this.countryArmy ? this.offsetArr2[dir][3] : this.offsetArr[dir][3]));
			
			var v:Vector2D = MapUtils.getAroundHypotenuse(dir);
			v.reverse();
			if(this._tray) this._tray.pos(v.x, v.y);
			
			var sortContent:Array = [];
			for (var i:int = 0, len:int = this._armys.length; i < len; i++) {
				for (var j:int = 0, len2:int = this._armys[i].length; j < len2; j++) {
					sortContent.push(this._armys[i][j]);
				}
			}
			
			sortContent = ArrayUtils.sortOn(["y"], sortContent);
			sortContent.push(this._hero);
			for (var k:int = 0, len3:int = sortContent.length; k < len3; k++) {
				this._armysContent.addChild(sortContent[k]);
			}
			
			if (this._title) {
				if (scaleFlag) {
					this._title.scaleX = -1;
					if (this._titleText) this._titleText.pos(20 - 75, -83 - 30);
					if (this.countryArmy && (!_ship || !this._ship.visible)) {
						//this._title.pivotY = 95 + 30;
						//this._title.pivotX = this._title.texture.sourceWidth / 2 - 80;
					}
					
				} else {
					this._title.scaleX = 1;
					if (this._titleText) this._titleText.pos( -76 + 75, -83 - 30);					
					if (this.countryArmy && (!_ship || !this._ship.visible)) {
						//this._title.pivotY = 95 - 50;
						//this._title.pivotX = this._title.texture.sourceWidth / 2 - 80;
					}
				}
			}
			
		}
		/**
		 * 不想用脑子算了，烦躁， 直接写死了 差不多就行了。
		 */
		private var offsetArr2:Array = [[-63 , 20, -90 - 15, 36 + 10], [-70, -15, -95 - 20, -35 - 5 ], [40, -38, 60 + 20, -50 - 15], [50 - 10, 30 + 10, 63 + 20, 53 + 15]];
		private var offsetArr:Array = [[-63 , 20, -90, 36], [-70, -15, -95, -35], [40, -38, 60, -50], [50 - 10, 30 + 10, 63, 53]];
		
		public function getMatrix(dir:int, arr:Array, offset:Vector2D):void {
			var sourceDist:Number = Math.sqrt(Math.pow(MapModel.instance.mapGrid.gridHalfW, 2) + Math.pow(MapModel.instance.mapGrid.gridHalfH, 2));
			var pandding:Number = 0;
			var xx:Number = this.countryArmy ? 2 : 3;
			
			
			var rate:Number = ((sourceDist - pandding * 2) / xx) / sourceDist;
			for (var i:int = 0, len:int = arr.length; i < len; i++) {
				var v:Vector2D = MapUtils.AROUND_VECTOR_4[1 - dir % 2].clone();
				v.multiply(i);				
				v = MapUtils.isoToTile(v, v);
				MapUtils.getPos(v.x, v.y, Point.TEMP);					
				v.setPoint(Point.TEMP);
				v.length *= rate;
				var ani:Animation = arr[i];	
				MapUtils.changeDir(ani, dir);
				v.add(offset);
				ani.pos(v.x, v.y);
			}
		}
		
	}

}