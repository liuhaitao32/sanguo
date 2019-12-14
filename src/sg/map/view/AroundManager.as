package sg.map.view {
	import laya.display.Sprite;
	import laya.map.GridSprite;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.ui.Image;
	import laya.utils.Utils;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.map.utils.MapUtils;
	import sg.map.utils.TestUtils;
	import sg.map.utils.Vector2D;
	import sg.model.ModelGame;
	import sg.scene.constant.ConfigConstant;
	import sg.scene.constant.EventConstant;
	import sg.scene.model.MapGrid;
	import sg.scene.view.TestButton;
	import ui.mapScene.AroundUI;
	import sg.model.ModelUser;
	/**
	 * 国界的类。
	 * @author light
	 */
	public class AroundManager {
		
		public var aroundData:Object = null;
		
		public static var pool:Object = {};
		
		public static var _aroundUI:AroundUI;
		
		public var around:Object = {};
		
		public var around2:Object = {};
		
		public static var instance:AroundManager = new AroundManager();
		
		public var occupy:Object = {};
		
		private var _unLock:Boolean;
		
		public static function getSprite(dir:int, type:int, mapType:String, country:int):Sprite {
			var key:String = mapType + country + "_" +dir + "_" + type;
			if (pool[key] && pool[key].length > 0) return pool[key].shift();
			else return createNewSprite(key);
		}
		
		public static function createNewSprite(key:String):Sprite {
			var image:Image = aroundUI[key];
			var sp:Sprite = new Sprite();
			sp.texture = image.source;
			sp.scale(image.scaleX, image.scaleY);
			sp.x = image.x;
			sp.y = image.y;
			sp.name = key;
			return sp;
		}
		
		public static function fillOccupySprite(key:String, sprite:Sprite, mapGrid:MapGrid):void {
			var image:Image = aroundUI[key];
			var v:Vector2D = mapGrid.toScreenPos();
			sprite.graphics.drawTexture(image.source, image.x + v.x, image.y + v.y);
			
			//sprite.graphics.drawCircle(image.x + v.x, image.y + v.y, 40, "#FF0000");
		}
		
		public static function get aroundUI():AroundUI {
			return (_aroundUI ||= new AroundUI());
		}
		
		public static function recover(sp:Sprite):void {
			pool[sp.name] ||= [];
			pool[sp.name].push(sp);
		}
		
		public function AroundManager() {
			
		}
		
		public function init():void {			
			if (!aroundData) {
				this.aroundData = ConfigConstant.mapData.around;		
				for (var name:String in this.aroundData) {
					var arr:Array = name.split("_");
					var grid:MapGrid = MapModel.instance.mapGrid.getGrid(parseInt(arr[0]), parseInt(arr[1]));
					if (!grid) continue;
					var city:EntityCity = grid.getEntitysByType(ConfigConstant.ENTITY_CITY, "occupyEntitys")[0];
					if (city) {
						city.around.push(grid);//周边的城市。
						this.changeGirdAround(grid, this.aroundData[name]);
					}
					
					
					this.changeGirdAround2(grid, this.aroundData[name]);
				}
				this._unLock = ModelGame.unlock(null, "mask_map").visible;
			}
			MapModel.instance.on(EventConstant.CITY_COUNTRY_CHANGE, this, this.changeCityAround);
			MapModel.instance.on(EventConstant.CITY_COUNTRY_CHANGE, this, this.changeCityAround2);
			MapModel.instance.on(EventConstant.CITY_DETECT, this, this.changeCityAround2);
		}
		
		private function changeCityAround(city:EntityCity, updateAround:Boolean = true):void {
			if (!city) return;//边缘-99的就不要了！
			for (var i:int = 0, len:int = city.around.length; i < len; i++) {
				var grid:MapGrid = city.around[i];
				var aroundInfo:Object = this.aroundData[grid.toString2()];
				this.changeGirdAround(grid, aroundInfo);
				
				//与他相邻的国家也更新下吧。 不找周围的对应的格子了！反正就几十个循环。
				if (updateAround) {
					for (var aroundCityId:String in aroundInfo) {
						var aroundCity:EntityCity = MapModel.instance.citys[parseInt(aroundCityId)];
						changeCityAround(aroundCity, false)
					}
				}				
			}
		}
		
		private function changeCityAround2(city:EntityCity):void {
			for (var i:int = 0, len:int = city.around.length; i < len; i++) {
				var grid:MapGrid = city.around[i];
				var aroundInfo:Object = this.aroundData[grid.toString2()];
				this.changeGirdAround2(grid, aroundInfo);
				for (var aroundCityId:String in aroundInfo) {
					//var aroundCity:EntityCity = MapModel.instance.citys[parseInt(aroundCityId)];
					//this.changeCityAround2(aroundCity, false)
					var arr:Array = aroundInfo[aroundCityId];
					for (var j:int = 0, len2:int = arr.length; j < len2; j++) {
						var arr2:Array = arr[j].split("_");
						var grid2:MapGrid = MapModel.instance.mapGrid.getGrid(grid.col + parseInt(arr2[0]), grid.row + parseInt(arr2[1]));
						if(grid2) this.changeGirdAround2(grid2, this.aroundData[grid2.toString2()]);
					}
				}			
			}
		}
		
		private function changeGirdAround(grid:MapGrid, aroundInfo:Object):void {
			var aroundDic:Object = null;
			var city:EntityCity = grid.getEntitysByType(ConfigConstant.ENTITY_CITY, "occupyEntitys")[0];
			for (var aroundCityId:String in aroundInfo) {
				var testCity:Boolean = EntityCity(MapModel.instance.citys[parseInt(aroundCityId)]) != city;//看每个城的占地。
				if ((parseInt(aroundCityId) == -99) || testCity && (EntityCity(MapModel.instance.citys[parseInt(aroundCityId)]).country != city.country/* || true*/)) {
					if (aroundDic == null) aroundDic = {};
					var arr:Array = aroundInfo[aroundCityId];
					for (var i:int = 0, len:int = arr.length; i < len; i++) {
						aroundDic[arr[i]] = true;
					}
				}
			}
			if (aroundDic) {
				this.around[grid.col + "_" + grid.row] = aroundDic;
			} else {
				delete this.around[grid.col + "_" + grid.row];
			}
		}
		
		private function changeGirdAround2(grid:MapGrid, aroundInfo:Object):void {
			var aroundDic:Object = null;
			var city:EntityCity = grid.occupyCity;
			var isDetect1:Boolean = city ? city.isDetect : false;
			
			for (var aroundCityId:String in aroundInfo) {
				
				var isDetect2:Boolean = (parseInt(aroundCityId) == -99) ? false : EntityCity(MapModel.instance.citys[parseInt(aroundCityId)]).isDetect;
				
				if ( isDetect2 != isDetect1/* || true*/) {
					if (aroundDic == null) aroundDic = {};
					var arr:Array = aroundInfo[aroundCityId];
					for (var i:int = 0, len:int = arr.length; i < len; i++) {
						aroundDic[arr[i]] = true;
					}
				}
			}
			if (aroundDic) {
				this.around2[grid.col + "_" + grid.row] = aroundDic;
			} else {
				delete this.around2[grid.col + "_" + grid.row];
			}
		}
		
		public static const ANGLE_UP:Array = [MapUtils.LEFT_TOP, MapUtils.LEFT, MapUtils.TOP];
		public static const ANGLE_RIGHT:Array = [MapUtils.RIGHT_TOP, MapUtils.TOP, MapUtils.RIGHT];
		public static const ANGLE_BOTTOM:Array = [MapUtils.RIGHT_BOTTOM, MapUtils.RIGHT, MapUtils.BOTTOM];
		public static const ANGLE_LEFT:Array = [MapUtils.LEFT_BOTTOM, MapUtils.BOTTOM, MapUtils.LEFT];
		
		public static const ANGLE_AROUND:Array = [AroundManager.ANGLE_UP, AroundManager.ANGLE_RIGHT, AroundManager.ANGLE_BOTTOM, AroundManager.ANGLE_LEFT];
		
		
		
		
		public function getGridView(grid:MapGrid, sp:Sprite, mapType:String, country:int):Sprite {
			var aroundDic:Object = this.around[grid.col + "_" + grid.row];
			
			if (!aroundDic) return null;
			
			sp ||= new Sprite();
			for (var i:int = 0, len:int = AroundManager.ANGLE_AROUND.length; i < len; i++) {
				var type:int = 0;
				var flag:Array = [false, false, false];//true代表自己的城市
				for (var j:int = 0, len2:int = AroundManager.ANGLE_AROUND[i].length; j < len2; j++) {
					var k:int = 1 << j;
					var arr:Array = MapUtils.getAround([grid.col, grid.row], AroundManager.ANGLE_AROUND[i][j]);
					if (aroundDic[arr[0] + "_" + arr[1]]) {
						type |= k;
					}else {
						flag[j] = true;
					}
				}
				if (type != 0) {
					type = (type / 2) << 0;
					if (flag[0] && type != 3 && (flag[3 - type])) continue;
					
					sp.addChild(AroundManager.getSprite(i, type, mapType, country));
				}
			}
			return sp;			
		}
		
		
		
		public function fillMiniMap(content:Array, rate:Number, drawLine:Boolean, fillAlpha:Array):void {
			var vertex:Object = {};
			var startVertex:Array = [null, null, null];
			var countryGrids:Array = [{}, {}, {}];
			TestUtils.timeStart("miniMap1");
			for (var name:String in this.around) {
				var arr:Array = name.split("_");
				var grid:MapGrid = MapModel.instance.mapGrid.getGrid(parseInt(arr[0]), parseInt(arr[1]));
				if (!grid) continue;
				var city:EntityCity = grid.occupyCity;
				if (city.country < 3) {
					countryGrids[city.country][name] = grid;
				}
			}
			TestUtils.getRumTime("miniMap1");
			var line:Array = [[Vector2D.LEFT_TOP, Vector2D.ZERO], [Vector2D.TOP, Vector2D.LEFT], [Vector2D.ZERO, Vector2D.LEFT_TOP], [Vector2D.LEFT, Vector2D.TOP]];
			
			TestUtils.timeStart("miniMap2");
			var square:Array = [Vector2D.ZERO, Vector2D.RIGHT, Vector2D.BOTTOM, Vector2D.RIGHT_BOTTOM];
			
			var masks:Object = [];
			
			for (var i:int = 0, len:int = countryGrids.length; i < len; i++) {
				var countryDic:Object = countryGrids[i];
				//把占地分类之后 整理成四角的格子信息。		
				
				//if (i != 0) continue;
				var grids:Object = {};				
				var start:Vector2D = null;	
				var vexCount:Object = {};
				for each (var item:MapGrid in countryDic) {
					//四个角都放进去。
					Vector2D.TEMP.setXY(item.col, item.row);
					var gv:Vector2D = MapUtils.tileToIso(Vector2D.TEMP, Vector2D.TEMP);
					
					for (var j:int = 0, len2:int = square.length; j < len2; j++) {
						var key:String = (gv.x + square[j].x) + "_" + (gv.y + square[j].y);
						grids[key] = true;
						
						var typeValue:int = 0;
						var aroundDic2:Object = this.around[item.toString2()]
						for (var k:int = 0, len3:int = AroundManager.ANGLE_AROUND[j].length; k < len3; k++) {
							var value:int = 1 << k;
							var arr2:Array = MapUtils.getAround([item.col, item.row], AroundManager.ANGLE_AROUND[j][k]);
							if (aroundDic2[arr2[0] + "_" + arr2[1]]) {
								typeValue |= value;
							}
						}
						if (typeValue != 0) {
							if (typeValue == 1) {
								vexCount[key] = 1;//内包含
							} else if ((typeValue / 2) << 0 == 3) {
								vexCount[key] = 2;//外包
							}
							
						}
						
					}
					
				}
				var checkFun:Function = function():Boolean {
					for (var name2:String in vexCount) {
						var arrT:Array = name2.split("_");
						start = new Vector2D(arrT[0], arrT[1]);
						return true;
					}
					return false;
				}
				masks[i] = []
				while (checkFun()) {
					//trace("----------------------------------------------------");
					var angleDir:Array = [];//判断是否是顺时针方向。
					var lastV:Vector2D = null;
					//现在 转化成点的格子。并且有起点了。
					var ra:Number = 2;
					while (grids[start.x + "_" + start.y]) {
						var key2:String = start.x + "_" + start.y;
						delete grids[key2];
						delete vexCount[key2];
						var sortNext:Array = [];
						for (var l:int = 0, len4:int = 4; l < len4; l++) {
							var v:Vector2D = MapUtils.AROUND_VECTOR_4[l];
							if (grids[(start.x + v.x) + "_" + (start.y + v.y)]) {								
								var v1:Vector2D = line[l][0];
								var v2:Vector2D = line[l][1]; 
								//相邻的两个格子。。。vx是一条线 v1 v2 对应找寻两侧格子的配置。
								/***********向量左侧格子*********/
								var xx1:int = start.x + v1.x;
								var yy1:int = start.y + v1.y
								/***********向量右侧格子*********/
								var xx2:int = start.x + v.x + v2.x;
								var yy2:int = start.y + v.y + v2.y;
								
								MapUtils.isoToTile(Vector2D.TEMP.setXY(xx1, yy1), Vector2D.TEMP);							
								var tempGrid1:MapGrid = MapModel.instance.mapGrid.getGrid(Vector2D.TEMP.x, Vector2D.TEMP.y);							
								var country1:int = tempGrid1 && tempGrid1.occupyCity ? tempGrid1.occupyCity.country : -99;
								
								MapUtils.isoToTile(Vector2D.TEMP.setXY(xx2, yy2), Vector2D.TEMP);
								var tempGrid2:MapGrid = MapModel.instance.mapGrid.getGrid(Vector2D.TEMP.x, Vector2D.TEMP.y);
								var country2:int = tempGrid2 && tempGrid2.occupyCity ? tempGrid2.occupyCity.country : -99;
								country1 = Math.min(country1, 3);
								country2 = Math.min(country2, 3);//其他大于3的对划线来说是一样的。
								if (country1 != country2 && (country1 == i || country2 == i)) {	
									sortNext.push({v:v, dir:l, country1:country1, country2:country2, start:[start.x, start.y]});
								}
							}
						}
						
						if (sortNext.length) {
							sortNext.sort(function(e1:Object, e2:Object):int {
								if (!angleDir.length) return 0;
								//带拐点的！
								if (sortNext.length > 2) {
									var lastAngle:Vector2D = angleDir[angleDir.length - 1].v;
									var tempGrid:MapGrid = null;
									/**********************************优先选择拐角************************/
									if (lastAngle != e1.v) {
										Vector2D.TEMP.copy(lastAngle);
										Vector2D.TEMP.reverse().add(e1.v).add(start);
										
										MapUtils.isoToTile(Vector2D.TEMP, Vector2D.TEMP);
										tempGrid = MapModel.instance.mapGrid.getGrid(Vector2D.TEMP.x, Vector2D.TEMP.y);
										if (i == (tempGrid && tempGrid.occupyCity ? tempGrid.occupyCity.country : -99)) return -1;
									}
									
									if (lastAngle != e2.v) {
										Vector2D.TEMP.copy(lastAngle);
										Vector2D.TEMP.reverse().add(e2.v).add(start);
										
										MapUtils.isoToTile(Vector2D.TEMP, Vector2D.TEMP);
										tempGrid = MapModel.instance.mapGrid.getGrid(Vector2D.TEMP.x, Vector2D.TEMP.y);
										if (i == (tempGrid && tempGrid.occupyCity ? tempGrid.occupyCity.country : -99)) return 1;
									}
								} else {//两个角的。
									/*************************优先于上一次拐点相等*********************/
									if (lastV == e1.v) return -1;
									if (lastV == e2.v) return 1;
								}
								
								return 0;
								
							});
							v = sortNext[0].v;
							//push顶点。
							if (lastV != v) {
								angleDir.push(sortNext[0]);
								//这个代表有3个以上拐点。 我选择最优的同时，不清除掉这个顶点！ 留给边缘下次检测用。
								if (sortNext.length > 2) {
									grids[key2] = true;
									vexCount[key2] = 1;
								}
							}
							start.x += v.x;
							start.y += v.y;
							lastV = v;
						}
					}
					
					if (!angleDir.length) continue;
					/***************************判断是挖除还是填充**********************/
					var points:Array = [];
					var isInside:int = 0;//大的在外层1 小的 在内层-1
					var sum:int = 0;//正数代表顺时针 负数代表逆时针。
					var dir:int = angleDir[0].dir;
					
					for (l = 0, len4 = angleDir.length; l < len4; l++) {
						var vexData:Object = angleDir[l];
						MapUtils.isoToTile(Vector2D.TEMP.setXY(vexData.start[0], vexData.start[1]), Vector2D.TEMP);
						MapUtils.getPos(Vector2D.TEMP.x, Vector2D.TEMP.y, Point.TEMP);
						points.push(Point.TEMP.x * rate);
						points.push((Point.TEMP.y - MapModel.instance.mapGrid.gridHalfH) * rate);
						
						//Sprite(content[1]).graphics.drawCircle(points[points.length - 2], points[points.length - 1], ra += 0.1, "#FF0000");
						//if (ra >= 20) {
							//ra = 2;
						//}
						//{v:v, dir:l, country1:country1, country2:country2, start:[start.x, start.y]
						if (l == 0) continue;
						
						var off:int = vexData.dir - dir;
						(off == -1 || off == 3) ? sum-- : sum++;
						dir = vexData.dir;
					}
					
					isInside = ((sum > 0) ? angleDir[0].country2 : angleDir[0].country1) == i ? 1 : -1;
					MapUtils.isoToTile(start, Vector2D.TEMP);
					MapUtils.getPos(Vector2D.TEMP.x, Vector2D.TEMP.y, Point.TEMP);
					points.push(Point.TEMP.x * rate);
					points.push((Point.TEMP.y - MapModel.instance.mapGrid.gridHalfH) * rate);
					points.push(points[0]);
					points.push(points[1]);					
					
					var sp:Sprite = new Sprite();
					content[0].addChild(sp);
					if (fillAlpha[0] is Array) {
						var filleColor:String = fillAlpha[(i == ModelUser.getCountryID() ? 0 : 1)][i];
						sp.graphics.drawPoly(0, 0, points, filleColor, null);
					}else {
						sp.graphics.drawPoly(0, 0, points, ConfigServer.world.COUNTRY_COLORS[i], null);
						sp.alpha = (i == ModelUser.getCountryID() ? fillAlpha[0] : fillAlpha[1]);
					}
					sp.autoSize = true;
					
					masks[i].push({points:points, sp:sp, isInside:isInside});
					
					var spLine:Sprite = new Sprite();
					
					if (drawLine) {
						spLine.graphics.drawLines(0, 0, points, ConfigServer.world.COUNTRY_COLORS[i], 1);
						if (i == ModelUser.getCountryID()) {
							content[1].addChild(spLine);
						} else {
							content[1].addChildAt(spLine, 0);
						}						
					}
					//break;
				}
			}
			
			
			for each (var maskArr:Array in masks) {
				maskArr = maskArr.sort(function(e1:Object, e2:Object):int {
					return Sprite(e1.sp).width * Sprite(e1.sp).height - Sprite(e2.sp).width * Sprite(e2.sp).height;
				});
				
				for (i = 0, len = maskArr.length; i < len; i++) {//小的
					var maskData:Object = maskArr[i];
					if (maskData.isInside == 1) continue;
					var rect1:Rectangle = Sprite(maskData.sp).getSelfBounds();
					for (j = i + 1; j < len; j++) {//大的。
						var maskData2:Object = maskArr[j];
						if (maskData2.isInside == -1) continue;
						var rect2:Rectangle = Sprite(maskData2.sp).getSelfBounds();
						var rect3:Rectangle = rect2.intersection(rect1);
						if (rect3 && rect3.equals(rect1)) {
							maskData2.sp.addChild(maskData.sp);
							Sprite(maskData2.sp).cacheAs = "bitmap";
							Sprite(maskData.sp).blendMode = "destination-out";
							break;
						}
						
					}
				}
				
			}
			
			TestUtils.getRumTime("miniMap2");
			
		}
		
		
		
		public function createOcuppy(occupyCity:EntityCity, gridSprite:GridSprite, mapGrid:MapGrid):AroundOccupyClip {
			if (!this._unLock) return null;
			var cid:int = -1;
			if (occupyCity) {
				cid = occupyCity.cityId;
			} else {
				cid = gridSprite ? gridSprite["$_GID"] || (gridSprite["$_GID"] = Utils.getGID()) : 0;
				cid += 10000;
			}
						
			AroundManager.instance.occupy[cid] ||= new AroundOccupyClip(occupyCity);
			var aound:AroundOccupyClip = AroundManager.instance.occupy[cid];
			aound.addGridSprite(gridSprite, mapGrid);
			
			return aound;
		}
		
		
		public function getAroundOccupyClipByGrid(mapGrid:MapGrid):AroundOccupyClip {
			var result:AroundOccupyClip = null;
			var city:EntityCity = mapGrid.occupyCity;
			if (city) return this.occupy[city.cityId];
			
			if (mapGrid.gridSprite && !mapGrid.gridSprite.destroyed) return this.occupy[mapGrid.gridSprite["$_GID"] + 10000];			
			return null;
			
		}
		
		public function inMask(x:Number, y:Number):Boolean {
			MapViewMain.instance.mapLayer.getTileGrid(x, y, Point.TEMP);
			var grid:MapGrid = MapModel.instance.mapGrid.getGrid(Point.TEMP.x, Point.TEMP.y);
			return grid.occupyCity && !grid.occupyCity.isDetect;
		}
		
	}

}