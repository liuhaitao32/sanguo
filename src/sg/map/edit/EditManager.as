package sg.map.edit {
	// import laya.debug.tools.JsonTool;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.events.KeyBoardManager;
	import laya.events.Keyboard;
	import laya.map.GridSprite;
	import laya.maths.Point;
	import laya.net.LocalStorage;
	import laya.ui.Button;
	import laya.utils.Browser;
	import laya.utils.Handler;
	import sg.map.model.entitys.EntityCityTile;
	import sg.map.model.entitys.EntityEstate;
	import sg.map.model.entitys.EntityGreatWall;
	import sg.map.model.entitys.EntityHeroCatch;
	import sg.map.model.entitys.EntityMonster;
	import sg.map.model.entitys.EntityXianHe;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.MapUtils;
	import sg.map.view.AroundManager;
	import sg.map.view.IsoObject;
	import sg.map.view.entity.CityClip;
	import sg.scene.view.InputManager;
	import sg.map.view.MapViewMain;
	import sg.scene.model.MapGrid;
	import sg.scene.model.MapGridManager;
	import sg.map.model.MapModel;
	import sg.scene.model.entitys.EntityBase;
	import sg.map.model.entitys.EntityCity;
	import sg.scene.constant.ConfigConstant;
	import sg.map.edit.IsoTile;
	import sg.map.model.astar.AstarNode;
	import sg.map.utils.TestUtils;
	import sg.scene.view.TestButton;
	import ui.EditMenuUI;
	import ui.EditPropertyUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class EditManager extends Sprite	{
		
		public var bg_img:GridSprite = new GridSprite();
		
		public var isShowAstar:Boolean = false;
		
		public var isShowGrid:Boolean = true;		
		
		
		public var tiles:Object = {};
		
		public var floorData:Object = {};
		
		
		private var _editEntity:Boolean = false;
		
		private var _lastGrid:MapGrid;
		
		private var _currCity:EntityCity;
		
		private var _menu:EditMenuUI;
		
		private var _property:EditPropertyUI;
		
		private var citys:Array = [];
		
		
		public var cityCount:int = 0;
		public var cityData:Array;
		
		
		private var daolu:Object = {};
		
		public var daoluData:Object = {};
		
		public var isShowFill:Boolean = true;
		
		public var isShowOcuppy:Boolean = false;
		
		
		
		public function EditManager() {
			
		}
		
		public function init():void{
			this.width = Laya.stage.width;
			this.height = Laya.stage.height;
			this.mouseThrough = true;
			MapViewMain.instance.minScale = 0.1;
			MapViewMain.instance.maxScale = 3;
			Laya.timer.once(1000, this, this.resetView);			
			
			
			this._menu = new EditMenuUI();
			this._property = new EditPropertyUI();
			this._property.mouseThrough = true;
			this.addChild(this._menu);
			this.addChild(this._property);
			this._menu.astarChange_btn.clickHandler = new Handler(this, this.changeGrid);
			this._property.del_btn.clickHandler = new Handler(this, function():void{
				var index:int = citys.indexOf(_currCity);
				citys.splice(index, 1);
				_currCity.mapGrid.removeEntity(_currCity);
				var nn:String = _currCity.mapGrid.col + "," + _currCity.mapGrid.row;
				floorData[nn] = 1;
				if (tiles[nn]) IsoTile(tiles[nn]).changeFill();					
				_currCity.event(Event.CLOSE);
				_currCity.clear();
				_currCity = null;
				_property.visible = false;
				this.changeDaoLu();
			});
			this._menu.daolu_btn.clickHandler = new Handler(this, function():void {
				isShowFill = !isShowFill;
				event("fill");
			})
			this._menu.img_slider.on(Event.CHANGE, this, function():void {
				bg_img.alpha = _menu.img_slider.value / _menu.img_slider.max;
			});
			
			
			this._menu.lu_btn.clickHandler = new Handler(this, function():void {
				this._menu.lu_btn.label = this._menu.lu_btn.label == "隐藏连接" ? "显示连接" : "隐藏连接";
				this.changeDaoLu();
			});
			
			bg_img.alpha = _menu.img_slider.value / _menu.img_slider.max;
			this._menu.hideGrid_btn.clickHandler = new Handler(this, this.changeGrid2);
			
			this._menu.check_btn.clickHandler = new Handler(this, this.checkCity);
			
			//Laya.stage.on(Event.MOUSE_DOWN, this, this.onMouseDown);
			InputManager.instance.offAll();
			InputManager.instance.on(Event.CLICK, this, this.mouseClick);
			Laya.stage.on(Event.MOUSE_MOVE, this, this.mouseMove);
			Laya.stage.on(Event.MOUSE_UP, this, this.mouseUp);
			this._property.visible = false;
			this._property.close_btn.clickHandler = new Handler(this, function():void{				
				_property.visible = false;
			});
			
			this._property.id_txt.on(Event.INPUT, this, function():void{
				_currCity.cityId = parseInt(_property.id_txt.text);
				IsoTile(tiles[_currCity.mapGrid.col + "," + _currCity.mapGrid.row]).changeFill();
			});
			
			this._property.daolu_input.on(Event.INPUT, this, function():void{
				selectDaolu.dist = parseInt(_property.daolu_input.text);
				selectDaolu.updateText();
			});
			
			this._property.cityType_combox.on(Event.CHANGE, this, function(e):void{
				_currCity.cityType = _property.cityType_combox.selectedIndex;
				var nnn:String = _currCity.mapGrid.col + "," + _currCity.mapGrid.row;
				floorData[nnn] = _currCity.cityType + 2;
				IsoTile(tiles[_currCity.mapGrid.col + "," + _currCity.mapGrid.row]).changeFill();
			});
			
			this._property.close_btn.clickHandler = new Handler(this, function():void{				
				_property.visible = false;
			});
			
			this._property.type_com.on(Event.CHANGE, this, function(e):void{
				selectDaolu.daolu_type = _property.type_com.selectedIndex;
			});
			
			this._property.shudi_btn.clickHandler = new Handler(this, this.changeCityButtonState, [1]);
			this._property.chanye_btn.clickHandler = new Handler(this, this.changeCityButtonState, [2]);
			this._property.yeguai_btn.clickHandler = new Handler(this, this.changeCityButtonState, [3]);
			this._property.qiecuo_btn.clickHandler = new Handler(this, this.changeCityButtonState, [4]);
			this._property.midao_btn.clickHandler = new Handler(this, this.changeCityButtonState, [5]);
			this._property.xianhe_btn.clickHandler = new Handler(this, this.changeCityButtonState, [6]);
			
			this._menu.save_btn.clickHandler = new Handler(this, this.saveHandler);
			this._menu.fabu_btn.clickHandler = new Handler(this, this.fabuHandler);
			this._menu.occupy_btn.clickHandler = new Handler(this, function():void {
				isShowOcuppy = !isShowOcuppy;
				event("ocuppy");
			});
			
			this.resize();
			
			
			
			var cityDic:Object = {};
			MapModel.instance.citys = cityDic;//重新指向一个引用。
			if(this.cityData != null) {
				for (var i:int = 0, len:int = cityData.length; i < len; i++) {
					var entity:EntityCity = new EntityCity();
					entity.setData(cityData[i]);
					this.citys.push(entity);
					cityDic[entity.cityId] = entity;
					
				}
			}
			AroundManager.instance.init();
			if(this.daoluData != null) {
				for (var key:String in this.daoluData) {
					var daolu:Daolu = new Daolu();
					var citys22:Array = key.split("_");
					daolu.city1 = cityDic[citys22[0]];
					daolu.city2 = cityDic[citys22[1]];
					daolu.name = key;
					daolu.path = this.daoluData[key]["path"];
					daolu.path = daolu.path.map(function(a:String, index:int, arr:Array):String{return a.replace(",", "_")});
					if(this.daoluData[key]["dis"]){
						daolu.dist = this.daoluData[key]["dis"];
					}
					
					if(this.daoluData[key]["water"]){
						daolu.daolu_type = this.daoluData[key]["water"];
					}
					daolu.init(this._property);
					this.daolu[key] = daolu;
				}
			}
			
			this._menu.lu_btn.label = "隐藏连接";
			this.changeDaoLu();
			this._menu.lu_btn.label = "显示连接";
			this.changeDaoLu();
		}
		
		private function changeCityButtonState(state:int):void {
			this._currCity.editData.state = state;
			
			var arr:Array = [this._property.shudi_btn, this._property.chanye_btn, this._property.yeguai_btn, this._property.qiecuo_btn, this._property.midao_btn, this._property.xianhe_btn];
			
			for (var i:int = 0, len:int = arr.length; i < len; i++) {				
				Button(arr[i]).selected = (i == state - 1);
			}
			
		}
		
		private function changeCityButton():void {
			if (this._currCity) {
				this._property.shudi_btn.label = "属地(" + this._currCity.editData.occupy2.length + ")";
				
				this._property.yeguai_btn.label = "野怪(" + (this._currCity.monster == null ? 0 : 1) + ")";
				
				this._property.qiecuo_btn.label = "切磋(" + (this._currCity.heroCatch == null ? 0 : 1) + ")";
				
				this._property.chanye_btn.label = "产业(" + (this._currCity.estates.length) + ")";
				
				this._property.midao_btn.label = "密道(" + (this._currCity.greateWall == null ? 0 : 1) + ")";
				this._property.xianhe_btn.label = "仙鹤(" + (this._currCity.xianHe == null ? 0 : 1) + ")";
			}
			
		}
		
		private function getRange():Object {
			var result:Object = {};
			var waijie:Array = [];
			for (var i:int = 0, len:int = this.citys.length; i < len; i++) {
				var city:EntityCity = this.citys[i];
				for (var j:int = 0, len2:int = city.editData.occupy2.length; j < len2; j++) {
					var pos:Array = city.editData.occupy2[j].split("_");
					var dic:Object = null;
					for (var k:int = 0, len3:int = MapUtils.AROUND.length; k < len3; k++) {
						var arr:Array = MapUtils.getAround(pos, MapUtils.AROUND[k]);
						var xx:Number = parseInt(pos[0]) + parseInt(arr[0]);
						var yy:Number = parseInt(pos[1]) + parseInt(arr[1]);
						var grid:MapGrid = MapModel.instance.mapGrid.getGrid(xx, yy);
						if (grid) {
							var city2:EntityCity = grid.getEntitysByType(ConfigConstant.ENTITY_CITY, "occupyEntitys")[0];
							var cityId:int = city2 ? city2.cityId : -99;
							if (city2 != city) {
								if (!dic) dic = {};
								dic[cityId] ||= [];
								dic[cityId].push(arr[0] + "_" + arr[1]);	
								if (cityId == -99) ArrayUtils.push(xx + "_" + yy, waijie);							
							}
						} else {
							if (!dic) dic = {};
							cityId = -99;
							dic[cityId] ||= [];
							dic[cityId].push(arr[0] + "_" + arr[1]);
						}
						
					}
					if (dic) {
						result[city.editData.occupy2[j]] = dic;
					}
				}
			}
			
			
			
			for (j = 0, len2 = waijie.length; j < len2; j++) {
				pos = waijie[j].split("_");
				dic = null;
				for (k = 0, len3 = MapUtils.AROUND.length; k < len3; k++) {
					arr = MapUtils.getAround(pos, MapUtils.AROUND[k]);
					xx = parseInt(pos[0]) + parseInt(arr[0]);
					yy = parseInt(pos[1]) + parseInt(arr[1]);
					grid = MapModel.instance.mapGrid.getGrid(xx, yy);
					if (grid) {
						city2 = grid.getEntitysByType(ConfigConstant.ENTITY_CITY, "occupyEntitys")[0];
						cityId = city2 ? city2.cityId : -99;
						if (cityId != -99) {
							if (!dic) dic = {};
							dic[cityId] ||= [];
							dic[cityId].push(arr[0] + "_" + arr[1]);
						}
					} else {
						if (!dic) dic = {};
						cityId = -99;
						dic[cityId] ||= [];
						dic[cityId].push(arr[0] + "_" + arr[1]);
					}
				}
				if (dic) {
					result[waijie[j]] = dic;
				}
			}
			
			
			return result;
		}
		
		private function getCityRange():Object {
			return null;
		}
		
		private function resetView():void {
			Laya.stage.removeChildren();
			Laya.stage.addChild(MapViewMain.instance);
			Laya.stage.addChild(this);
			TestButton.init();
		}
		
		private function fabuHandler():void {
			var path:Object = this.getPathData();
			
			var city:Object = {};
			
			for (var i:int = 0, len:int = this.citys.length; i < len; i++) {
				var c:EntityCity = this.citys[i];
				var o:Object = {"pos":c.mapGrid.col + "_" + c.mapGrid.row};
				c.setOccupyData(o);				
				city[c.cityId] = o;
			}
			
			var data:Object = {"path":path, "city":city, "around":this.getRange()};
			TestUtils.downLoadTxt(JSON.stringify(data), "mapData");
			
			TestUtils.downLoadTxt(JSON.stringify({"path":this.getPathData(true)}), "server");
			
		}
		
		private var selectDaolu:Daolu;
		public function setDaolu(daolu:Daolu):void {
			this.selectDaolu = daolu;
			property.daolu_container.visible = true;
			property.city_container.visible = false;
			property.type_com.selectedIndex = daolu.daolu_type;
			property.daolu_input.text = this.selectDaolu.dist != -1 && this.selectDaolu.dist != (this.selectDaolu.path.length - 1) * ConfigConstant.WAY_DIST_UNIT ? (this.selectDaolu.dist).toString() : ((this.selectDaolu.path.length - 1) * ConfigConstant.WAY_DIST_UNIT) + "(默认)" ;
			property.name_txt.text = selectDaolu.name;
			this._property.visible = true;
		}
		
		private function checkDaolu():void{			
			for (var name:String in this.daolu) {
				if(Daolu(this.daolu[name]).isDestroy) {
					delete this.daolu[name];
				}
			}
		}
		
		private function changeDaoLu():void {
			this.checkDaolu();
			if (this._menu.lu_btn.label == "显示连接") {				
				for (var name2:String in this.daolu) {
					Daolu(this.daolu[name2]).visible = false;
				}
			} else {
				var okCity:Array = this.getLianjieChengShi();
				var newDaoLu:Object = {};
				for (var i:int = 0, len:int = okCity.length; i < len; i++) {
					var city:EntityCity = okCity[i];
					for (var j:int = 0, len2:int = city.nearCitys.length; j < len2; j++) {					
						var city2:EntityCity = EntityCity(city.nearCitys[j]);					
						
						var a1:int = parseInt(city.cityId.toString());
						var a2:int = parseInt(city2.cityId.toString());
						if (a1 > a2) continue;
						var n:String = a1 > a2 ? a2 + "_" + a1 : a1 + "_" + a2;
						
						if (this.daolu[n]) {
							Daolu(this.daolu[n]).visible = true;
							newDaoLu[n] = this.daolu[n];
							delete this.daolu[n];
							continue;
						}
						var n1:AstarNode = a1 < a2 ? city.mapGrid.node : city2.mapGrid.node;
						var n2:AstarNode = a1 > a2 ? city.mapGrid.node : city2.mapGrid.node;
						
						MapModel.instance.mapGrid.astarFind.search4(n1, n2);
						var daolu:Daolu = new Daolu();
						daolu.name = n;
						this.daolu[n] = daolu;
						daolu.path = MapModel.instance.mapGrid.astarFind.path.map(function(nnn:AstarNode):String{return nnn.grid.col + "_" + nnn.grid.row; });
						daolu.city1 = a1 > a2 ? city2 : city;
						daolu.city2 = a2 > a1 ? city2 : city;			
						daolu.init(this._property);						
						
						newDaoLu[n] = this.daolu[n];
						delete this.daolu[n];
					}
				}
				
				
				for (var name:String in this.daolu) {
					Daolu(this.daolu[name]).removeSelf();
				}
				
				this.daolu = newDaoLu;
			}
		}
		
		
		private function getLianjieChengShi():Array {			
			var gridManager:MapGridManager = MapModel.instance.mapGrid;
			for (var i:int = 0, len:int = gridManager.grids.length; i < len; i++) {
				for (var j:int = 0, len2:int = gridManager.grids[i].length; j < len2; j++) {
					var grid:MapGrid = gridManager.grids[i][j];
					grid.node.walkable = false;
				}
			}
			for (var key:String in this.floorData) {				
				var strs:Array = key.split(",");				
				gridManager.getGrid(parseInt(strs[0]), parseInt(strs[1])).node.walkable = true;
			}
			//A星基础完成。
			this.citys = this.citys.sort(function(e1:EntityCity, e2:EntityCity):int{
				var a1:Number = e1.cityId;
				var a2:Number = e2.cityId;
				return a1 - a2;				
			});
			return this.citys[this.citys.length - 1] != null ? gridManager.astarFind.checkCity(this.citys[this.citys.length - 1]) : [];
			
		}
		
		private function checkCity():void {
			var okCity:Array = this.getLianjieChengShi();
			for (var name:String in this.tiles) {
				this.tiles[name].duihao.visible = false;
			}
			
			for (var k:int = 0, len3:int = this.citys.length; k < len3; k++) {
				var city:EntityCity = this.citys[k];
				var isoTile:IsoTile = this.tiles[city.mapGrid.col + "," + city.mapGrid.row];
				if(isoTile){
					if(-1 == okCity.indexOf(city) ){//没联通的。
						isoTile.duihao.visible = false;
					} else {
						isoTile.duihao.visible = true;
					}	
				}
				
			}
			
		}
		
		private function saveHandler():void {
			var obj:Object = {"floor":this.floorData, "cityCount":this.cityCount, "cityData":this.citys.map(function(d:EntityCity, i:int, arr:Array):Object{return d.getData(); }), "path":this.getPathData(), "around":this.getRange()};
			var str:String = JSON.stringify(obj);
			LocalStorage.setItem("editMap", str);			
			TestUtils.downLoadTxt(str, "edit");	
		}
		
		private function getPathData(easy:Boolean = false):Object {
			var path:Object = {};
			this.changeDaoLu();
			
			for (var name:String in this.daolu) {
				path[name] = Daolu(this.daolu[name]).getData(easy);
			}
			return path;
		}
		
		
		private function mouseClick(e:Event):void {	
			var screenX:Number = e.stageX;// ;
			var screenY:Number = e.stageY;//;
			screenX = screenX / MapViewMain.instance.tMap.scale - MapViewMain.instance.tMap.viewPortX - MapViewMain.instance.mapGrid.gridHalfW;
			screenY = screenY / MapViewMain.instance.tMap.scale - MapViewMain.instance.tMap.viewPortY - MapViewMain.instance.mapGrid.gridHalfH;
			
			MapViewMain.instance.mapLayer.getTilePositionByScreenPos(e.stageX, e.stageY, Point.TEMP);
			var grid:MapGrid = MapModel.instance.mapGrid.getGrid(Point.TEMP.x, Point.TEMP.y);
			
			
			var name:String = grid.col + "," + grid.row;
			if (this.floorData[name] != null && parseInt(this.floorData[name].toString()) > 1) {//生成城市
				this.setCity(grid.getEntitysByType(ConfigConstant.ENTITY_CITY)[0]);
				//更新弹板
			}else if (e.altKey) {				 
				this.floorData[name] = 2;
				var entity:EntityCity = new EntityCity();
				this.citys.push(entity);
				cityCount++;
				entity.cityId = cityCount;
				//entity.cityId = "test";
				entity.mapGrid = grid;
				grid.addEntity(entity);
				if (this.tiles[name] != null) {
					IsoTile(this.tiles[name]).changeFill();
				}
				this.changeDaoLu();
			} else if (this._currCity != null && this._currCity.editData.state > 1) {
				//只能在自己的属地：
				if (grid.getEntitysByType(ConfigConstant.ENTITY_CITY, "occupyEntitys")[0] == this._currCity) {
					if (this._currCity.editData.state == 2 && !grid.getEntitysByType(ConfigConstant.ENTITY_XIAN_HE)[0] && !grid.getEntitysByType(ConfigConstant.ENTITY_GREAT_WALL)[0] && !grid.getEntitysByType(ConfigConstant.ENTITY_HERO_CATCH)[0] && !grid.getEntitysByType(ConfigConstant.ENTITY_MONSTER)[0]) {
						var estate:EntityEstate = grid.getEntitysByType(ConfigConstant.ENTITY_ESTATE)[0];
						if (estate) {
							grid.removeEntity(estate);
							ArrayUtils.remove(estate, _currCity.estates);
						}else {
							estate = new EntityEstate();
							estate.city = this._currCity;							
							estate.x = grid.col;
							estate.y = grid.row;
							estate.mapGrid = grid;
							this._currCity.estates.push(estate);
							grid.addEntity(estate);
						}
					} else if(this._currCity.editData.state == 3 && !grid.getEntitysByType(ConfigConstant.ENTITY_XIAN_HE)[0] && !grid.getEntitysByType(ConfigConstant.ENTITY_GREAT_WALL)[0] && !grid.getEntitysByType(ConfigConstant.ENTITY_HERO_CATCH)[0] && !grid.getEntitysByType(ConfigConstant.ENTITY_ESTATE)[0]) {
						var monster:EntityMonster = grid.getEntitysByType(ConfigConstant.ENTITY_MONSTER)[0];
						
						if (monster) {
							grid.removeEntity(monster);
							this._currCity.monster = null;
						} else if(this._currCity.monster == null){
							monster = new EntityMonster();
							monster.city = this._currCity;
							monster.x = grid.col;
							monster.y = grid.row;
							monster.mapGrid = grid;
							this._currCity.monster = monster;
							grid.addEntity(monster);
						}
					} else if(this._currCity.editData.state == 4 && !grid.getEntitysByType(ConfigConstant.ENTITY_XIAN_HE)[0] && !grid.getEntitysByType(ConfigConstant.ENTITY_GREAT_WALL)[0] && !grid.getEntitysByType(ConfigConstant.ENTITY_MONSTER)[0] && !grid.getEntitysByType(ConfigConstant.ENTITY_ESTATE)[0]) {
						var heroCatch:EntityHeroCatch = grid.getEntitysByType(ConfigConstant.ENTITY_HERO_CATCH)[0];
						if (heroCatch) {
							grid.removeEntity(heroCatch);
							this._currCity.heroCatch = null;
						}  else if(this._currCity.heroCatch == null) {
							heroCatch = new EntityHeroCatch();
							heroCatch.city = this._currCity;
							heroCatch.x = grid.col;
							heroCatch.y = grid.row;
							heroCatch.mapGrid = grid;
							this._currCity.heroCatch = heroCatch;
							grid.addEntity(heroCatch);
						}
					} else if(this._currCity.editData.state == 5 && !grid.getEntitysByType(ConfigConstant.ENTITY_XIAN_HE)[0] && !grid.getEntitysByType(ConfigConstant.ENTITY_HERO_CATCH)[0] && !grid.getEntitysByType(ConfigConstant.ENTITY_MONSTER)[0] && !grid.getEntitysByType(ConfigConstant.ENTITY_ESTATE)[0]) {
						var wall:EntityGreatWall = grid.getEntitysByType(ConfigConstant.ENTITY_GREAT_WALL)[0];
						if (wall) {
							grid.removeEntity(wall);
							this._currCity.greateWall = null;
						}  else if(this._currCity.greateWall == null) {
							wall = new EntityGreatWall();
							wall.city = this._currCity;
							wall.x = grid.col;
							wall.y = grid.row;
							wall.mapGrid = grid;
							this._currCity.greateWall = wall;
							grid.addEntity(wall);
						}
					} else if(this._currCity.editData.state == 6 && !grid.getEntitysByType(ConfigConstant.ENTITY_GREAT_WALL)[0] && !grid.getEntitysByType(ConfigConstant.ENTITY_HERO_CATCH)[0] && !grid.getEntitysByType(ConfigConstant.ENTITY_MONSTER)[0] && !grid.getEntitysByType(ConfigConstant.ENTITY_ESTATE)[0]) {
						var xianHe:EntityXianHe = grid.getEntitysByType(ConfigConstant.ENTITY_XIAN_HE)[0];
						if (xianHe) {
							grid.removeEntity(xianHe);
							this._currCity.xianHe = null;
						}  else if(this._currCity.xianHe == null) {
							xianHe = new EntityXianHe();
							xianHe.city = this._currCity;
							xianHe.x = grid.col;
							xianHe.y = grid.row;
							xianHe.mapGrid = grid;
							this._currCity.xianHe = xianHe;
							grid.addEntity(xianHe);
						}
					}
					
					if (this.tiles[name] != null) {
						IsoTile(this.tiles[name]).changeOccupy();
					}
					this.changeCityButton();
				}
				
				
				
			}
		}
		
		private function mouseUp(e:Event):void {
			this._lastGrid = null;
		}
		
		private function mouseMove(e:Event):void {
			if(KeyBoardManager.hasKeyDown(Keyboard.A) && this.isShowFill) {
				MapViewMain.instance.mapLayer.getTilePositionByScreenPos(e.stageX, e.stageY, Point.TEMP);
				var grid:MapGrid = MapModel.instance.mapGrid.getGrid(Point.TEMP.x, Point.TEMP.y);
				if (grid != null && this._lastGrid != grid) {
					var name:String = grid.col + "," + grid.row;
					if (this.floorData[name] != null) {
						if(this.floorData[name] == 1) {
							delete this.floorData[name];	
						}
						
					}else{
						this.floorData[name] = 1;
					}
					
					var tile:IsoTile = this.tiles[name] as IsoTile;
					tile.changeFill();
					this._lastGrid = grid;
				}
			} else if (KeyBoardManager.hasKeyDown(Keyboard.S)){
				if (this._currCity && this._currCity.editData.state == 1) {					
					MapViewMain.instance.mapLayer.getTilePositionByScreenPos(e.stageX, e.stageY, Point.TEMP);
					var grid2:MapGrid = MapModel.instance.mapGrid.getGrid(Point.TEMP.x, Point.TEMP.y);
					if (grid2 != null && this._lastGrid != grid2) {
						var city11:EntityCity = grid2.getEntitysByType(ConfigConstant.ENTITY_CITY, "occupyEntitys")[0];		
						var tile2:IsoTile = this.tiles[grid2.col + "," + grid2.row] as IsoTile;			
						var key:String = grid2.col + "_" + grid2.row;
						if (city11 == null) {
							grid2.addOccupyEntity(this._currCity);
							ArrayUtils.push(key, this._currCity.editData.occupy2);
							tile2.changeOccupy();
							this.changeCityButton();
						} else if(this._currCity == city11){
							grid2.removeOccupyEntity(this._currCity);
							var cityTile:EntityCityTile;
							ArrayUtils.remove(key, this._currCity.editData.occupy2);
							cityTile = grid2.getEntitysByType(ConfigConstant.ENTITY_MONSTER)[0];
							if (cityTile) {
								this._currCity.monster = null;
								grid2.removeEntity(cityTile);
							}
							
							cityTile = grid2.getEntitysByType(ConfigConstant.ENTITY_HERO_CATCH)[0];
							if (cityTile) {
								this._currCity.heroCatch = null;
								grid2.removeEntity(cityTile);
							}
							cityTile = grid2.getEntitysByType(ConfigConstant.ENTITY_GREAT_WALL)[0];
							if (cityTile) {
								this._currCity.greateWall = null;
								grid2.removeEntity(cityTile);
							}
							cityTile = grid2.getEntitysByType(ConfigConstant.ENTITY_XIAN_HE)[0];
							if (cityTile) {
								this._currCity.xianHe = null;
								grid2.removeEntity(cityTile);
							}
							cityTile = grid2.getEntitysByType(ConfigConstant.ENTITY_ESTATE)[0];
							if (cityTile) {
								ArrayUtils.remove(cityTile, this._currCity.estates);
								grid2.removeEntity(cityTile);
							}
							
							tile2.changeOccupy();
							this.changeCityButton();
						}
						this._currCity.editData.occupySet = 1;
						this._lastGrid = grid2;
					}
				}
			} else {
				this._lastGrid = null;
			}
		}
		
		private function editEntityHandler():void {			
			this._editEntity = true;
		}
		
		private function resize():void{
			//this._menu.x = Laya.stage.width - this._menu.width - 30;
			//this._menu.y = 50;
			//this._property.scale(0.8, 0.8);
			
			//this._property.x = (Laya.stage.width - this._property.width ) / 2;
			//this._property.y = Laya.stage.height - this._property.height;
			//TestUtils.drawTest(this._property);
		}
		
		private function changeGrid2():void {
			this.isShowGrid = !this.isShowGrid;
			this.event(Event.CHANGE);
		}
		
		private function changeGrid():void {
			this.isShowAstar = !this.isShowAstar;
			this.event(Event.CHANGE);
		}
		
		
		public function get property():EditPropertyUI {
			return this._property;
		}
		
		private function setCity(entity:EntityCity):void {
			this._currCity = entity;
			changeCityButtonState(1)
			this._property.cityType_combox.selectedIndex = (this._currCity.cityType > 0 ? 1 : 0);
			this._property.id_txt.text = this._currCity.cityId.toString();
			this._property.city_container.visible = true;
			this._property.daolu_container.visible = false;
			this._property.visible = true;
			
			this._property.chanye_btn.visible = this._property.qiecuo_btn.visible = this._property.yeguai_btn.visible = this._property.midao_btn.visible = this._property.xianhe_btn.visible = this._currCity.cityType > 0;
			this.changeCityButton();
		}
	}

}