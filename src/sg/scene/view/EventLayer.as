package sg.scene.view {
	import laya.display.Node;
	import laya.display.Sprite;
	import laya.map.GridSprite;
	import laya.map.MapLayer;
	import laya.map.TiledMap;
	import laya.maths.Point;
	import laya.renders.RenderContext;
	import sg.cfg.ConfigApp;
	import sg.manager.ModelManager;
	import sg.map.model.entitys.EntityArena;
	import sg.map.model.entitys.EntityFtask;
	import sg.map.model.entitys.EntityGtask;
	import sg.map.model.entitys.EntityHeroCatch;
	import sg.map.model.entitys.EntityMonster;
	import sg.map.utils.MapUtils;
	import sg.map.utils.Vector2D;
	import sg.map.view.AroundManager;
	import sg.map.view.AroundClip;
	import sg.map.view.AroundOccupyClip;
	import sg.map.view.EstateClip;
	import sg.map.view.entity.ArenaClip;
	import sg.map.view.entity.ChangChengClip;
	import sg.map.view.entity.FtaskClip;
	import sg.map.view.entity.GtaskClip;
	import sg.map.view.entity.HeroCatchClip;
	import sg.map.view.entity.MonsterClip;
	import sg.map.view.entity.XianHeClip;
	import sg.scene.view.ui.EntityMenu;
	import sg.map.edit.IsoTile;
	import sg.scene.model.MapGrid;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.scene.constant.ConfigConstant;
	import sg.map.view.MapViewMain;
	import sg.map.view.entity.CityClip;
	import sg.scene.view.entity.EntityClip;
	import sg.scene.SceneMain;
	import sg.map.view.entity.BlessHeroClip;
	import sg.cfg.ConfigServer;
	import laya.utils.Browser;
	/**
	 * ...
	 * @author light
	 */
	public class EventLayer extends MapLayer {
		
		public var scene:SceneMain;

		private var _topLayer:Sprite = new Sprite();
		public var arenaLayer:Sprite = new Sprite();
		
		public var maskLayer:Sprite = new Sprite();
		
		///其实这个是基础层，在infoLayer、bubbleLayer、effectLayer、menuLayer之下
		public var floorLayer:Sprite = new Sprite();
		
		public var topLayer:Sprite = new Sprite();
		
		public var infoLayer:Sprite = new Sprite();
		
		public var bubbleLayer:Sprite = new Sprite();
		
		public var effectLayer:Sprite = new Sprite();
		
		public var menuLayer:Sprite = new Sprite();
		
		public static const EFFECT_LAYER:String = "effectLayer";
		
		public var menu:EntityMenu;
		
		public var renderSprites:Array = [];
		
		
		public function EventLayer() {
			
		}
		public function get offsetX():Number {
			return this._topLayer.x;	
		}
		public function get offsetY():Number {
			return this._topLayer.x;	
		}
		
		override public function render(context:RenderContext, x:Number, y:Number):void {
			var temp:Array = _showGridList.concat();
			_showGridList.push(this._topLayer);
			super.render(context, x, y);
			_showGridList = temp;			
		}
		
		public function get showGridList():Array {
			return _showGridList;
		}
		
		override public function init(layerData:*, m:TiledMap):void {
			this.menu = new EntityMenu(this.scene);
			var tMap:TiledMap = this.scene.tMap;
			layerData = {"name":"event", "opacity":1, "type":"tilelayer"};
			/*****************新增****************/
			this.addChild(this._topLayer).name = "topLayer";
			this._topLayer.addChild(this.maskLayer);
			this.maskLayer.pos(-MapModel.instance.mapGrid.gridW, -MapModel.instance.mapGrid.gridH)
			this._topLayer.addChild(this.floorLayer);
			this._topLayer.addChild(this.arenaLayer);
			this._topLayer.addChild(this.topLayer);
			this._topLayer.addChild(this.effectLayer);
			this._topLayer.addChild(this.infoLayer);
			this._topLayer.addChild(this.bubbleLayer);
			this._topLayer.addChild(this.menuLayer);
			
			this._topLayer.x = tMap.tileWidth / 2;
			this._topLayer.y = tMap.tileHeight / 2;
			super.init(layerData, tMap);
			
			tMap.mapSprite().addChild(this);
			tMap._layerArray.push(this);
			tMap._renderLayerArray.push(this);
			this._topLayer.zOrder = 9999999;
		}
		
		override public function getDrawSprite(gridX:int, gridY:int):GridSprite {
			return super.getDrawSprite(gridX, gridY);
		}
		
		
		override public function drawTileTexture(gridSprite:GridSprite, tileX:int, tileY:int):Boolean {
			if (this.scene.type != SceneMain.MAP) return false;//内城就不走这个。 直接摆上去 全都显示的。
			if (tileY >= 0 && tileY < _map.numRowsTile && tileX >= 0 && tileX < _map.numColumnsTile) {
				var display:Sprite = null;
				var grid:MapGrid = this.scene.mapGrid.getGrid(tileX, tileY);
				grid.gridSprite = gridSprite;
				if(ConfigConstant.isEdit) {
					var tile:IsoTile = new IsoTile();
					tile.name = tileX + "," + tileY;
					tile.init();
					//tile.fillTile = true;
					MapViewMain(this.scene).editManager.tiles[tile.name] = tile;	
					display = tile;
					this.addItemSprite(gridSprite, display, tileX, tileY);
				} else {	
					//城市。
					var entity:EntityCity = grid.getEntitysByType(ConfigConstant.ENTITY_CITY)[0];
					if(entity) {
						var clip:EntityClip = this.scene.createClip();
						entity.view = clip;
						clip.entity = entity;
						clip.init();
						display = clip;
						this.addItemSprite(gridSprite, display, tileX, tileY);
					}
					
					//切磋。
					var heroCatch:EntityHeroCatch = grid.getEntitysByType(ConfigConstant.ENTITY_HERO_CATCH)[0];
					if(heroCatch) {
						var heroCatchClip:HeroCatchClip = null;
						if (!heroCatch.view || heroCatch.view.destroyed) {
							heroCatchClip = new HeroCatchClip(this.scene);
							heroCatch.view = heroCatchClip;
							heroCatchClip.entity = heroCatch;
							
						}else {
							heroCatchClip = HeroCatchClip(heroCatch.view);
						}
						
						heroCatchClip.init();
						display = heroCatchClip;
						//this.addItemSprite(gridSprite, display, tileX, tileY);
					}
					//野怪。
					var monster:EntityMonster = grid.getEntitysByType(ConfigConstant.ENTITY_MONSTER)[0];
					if(monster) {
						var monsterClip:MonsterClip = new MonsterClip(this.scene);
						monster.view = monsterClip;
						monsterClip.entity = monster;
						
						monsterClip.init();
						display = monsterClip;
					}
					//民情
					var ftask:EntityFtask = grid.getEntitysByType(ConfigConstant.ENTITY_FTASK)[0];
					if(ftask) {
						var ftaskClip:FtaskClip = new FtaskClip(this.scene);
						ftask.view = ftaskClip;
						ftaskClip.entity = ftask;
						
						ftaskClip.init();
						display = ftaskClip;
					}
					
					var gtask:EntityGtask = grid.getEntitysByType(ConfigConstant.ENTITY_GTASK)[0];
					if(gtask) {
						var gtaskClip:GtaskClip = new GtaskClip(this.scene);
						gtask.view = gtaskClip;
						gtaskClip.entity = gtask;						
						gtaskClip.init();
						display = gtaskClip;
					}
					
					var arena:EntityArena = grid.getEntitysByType(ConfigConstant.ENTITY_ARENA)[0];
					if(arena) {
						var arenaClip:ArenaClip = new ArenaClip(this.scene);
						arena.view = arenaClip;
						arenaClip.entity = arena;	
						display = arenaClip;					
						//this.addItemSprite(gridSprite, display, tileX, tileY);
						arenaClip.init();
						
					}
					
					//城市内占地的。 这里就直接生成了！ 就不再找对应的entity了。
					var occupyCity:EntityCity = grid.occupyCity;
					if (occupyCity) {
						var occupyData:Object = occupyCity.occupyTile[tileX + "_" + tileY];						
						if (occupyData) {
							switch(occupyData.type) {
								case ConfigConstant.ENTITY_ESTATE:
									//产业。。。
									var estate:EstateClip = new EstateClip(this.scene);
									estate.index = occupyData.index;
									estate.city = occupyCity;
									estate.grid = grid;
									estate.init();
									display = estate;
									break;
								case ConfigConstant.ENTITY_XIAN_HE:
									var xianhe:XianHeClip = new XianHeClip(this.scene);
									xianhe.city = occupyCity;
									xianhe.grid = grid;
									xianhe.init();
									display = xianhe;
									break;
								case ConfigConstant.ENTITY_CHANG_CHENG:
									var changcheng:ChangChengClip = new ChangChengClip(this.scene);
									changcheng.city = occupyCity;
									changcheng.grid = grid;
									changcheng.init();
									display = changcheng;
									break;
							}
						
							this.addItemSprite(gridSprite, display, tileX, tileY);
						}

						// 福将挑战入口
						var cids:Array = ConfigServer.bless_hero.position[ModelManager.instance.modelUser.country];
						if (cids.indexOf(occupyCity.cityId) !== -1 && grid.node) {
							var blessHero:BlessHeroClip = new BlessHeroClip(this.scene);
							blessHero.city = occupyCity;
							blessHero.grid = grid;
							blessHero.init();
							display = blessHero;
							this.addItemSprite(gridSprite, display, tileX, tileY);
						}
						
						//占地里 计算边界线。。。
					}
					if (!ConfigApp.releaseWeiXin()) {
						var aroundClip2:AroundOccupyClip = AroundManager.instance.createOcuppy(occupyCity, gridSprite, grid);							
						if(aroundClip2) display = aroundClip2;
					}
				}
				
				var around:Object = AroundManager.instance.aroundData[tileX + "_" + tileY];
				if (around) {
					var aroundClip:AroundClip = new AroundClip();	
					aroundClip.mapType = "a";
					aroundClip.grid = grid;
					aroundClip.init();
					display = aroundClip;		
					EventGridSprite(gridSprite).addItemSprite(display);			
				}
				
				return display != null;
				
			}
			return false;
		}
		
		public function addItemSprite(gridSprite:GridSprite, display:Sprite, tileX:Number, tileY:Number):void {			
			var tX:Number = tileX * _map.tileWidth % _map.gridWidth + (tileY & 1) * _tileWidthHalf;;
			var tY:Number = tileY * _tileHeightHalf % _map.gridHeight;
			display.x = tX;
			display.y = tY;
			EventGridSprite(gridSprite).addItemSprite(display);
			gridSprite.addChild(display);
		}
		
		override public function createSprite():GridSprite {
			return new EventGridSprite(this);
		}
		
		public function addChild2(sp:Sprite, layer:String, mapGrid:MapGrid = null):Sprite {
			if (mapGrid) {
				var v:Vector2D = mapGrid.toScreenPos();
				sp.pos(v.x, v.y);
			}
			this[layer].addChild(sp);
			
			return sp;
		}
	}

}