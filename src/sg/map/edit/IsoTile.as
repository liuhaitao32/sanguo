package sg.map.edit {
	
import sg.map.model.entitys.EntityGreatWall;
import sg.map.model.entitys.EntityXianHe;
import sg.utils.Tools

	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import sg.map.model.entitys.EntityEstate;
	import sg.map.model.entitys.EntityHeroCatch;
	import sg.map.model.entitys.EntityMonster;
	import sg.map.utils.MapUtils;
	import sg.map.utils.TestUtils;
	import sg.map.utils.Vector2D;
	import sg.map.view.IsoObject;
	import sg.scene.constant.ConfigConstant;
	import sg.map.view.MapViewMain;
	import sg.scene.model.MapGrid;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	/**
	 * 等角瓦片(地板)类
	 * @author light
	 */
	public class IsoTile extends IsoObject {		
		/**
		 * 显示线条标志
		 */
		private var _showLineFlag:Boolean = true;
		
		/**
		 * 填充瓦片标志
		 */
		private var _fillTileFlag:String = null;
		
		
		
		private var _idText:Text = new Text();
		
		private var center:Sprite = new Sprite();
		
		public var duihao:Sprite = new Sprite();
		
		public var city:Sprite = new Sprite();
		
		/**
		 * 构造函数
		 */		
		public function IsoTile() {
		}
		
		
		/**
		 * 覆盖初始化函数 在其上面添加一个位图
		 * @param	size 所占单元格的大小
		 */
		override public function init():void {
			super.init();	
			this._fill = new Sprite();
			var w:int = this._map.tMap.tileWidth;
			var h:int = this._map.tMap.tileHeight;
			this.addChild(this._fill);
			this._fill.alpha = 0.3;
			this.draw(w, h);
			
			this.print("");
			
			this._idText.color = "#FF00FF";
			this._idText.fontSize = 40;
			this._idText.strokeColor = "#FFFFFF";
			this._idText.stroke = 3;
			this._idText.width = w;
			this._idText.height = h;
			this._idText.align = "center";
			this._idText.valign = "middle";
			
			
			this.addChild(this._idText);
			
			
			this.center.graphics.drawCircle(0.5 * w, 0.5 * h, 3, "#FF00FF");
			
			this.addChild(this.center);
			this.duihao.texture = Laya.loader.getRes("eidtTest/duihao.png");
			this.addChild(this.duihao);
			this.duihao.visible = false;
			if(MapViewMain.instance.editManager.floorData[name] == 1)
				this._fill.visible = MapViewMain.instance.editManager.isShowFill;
			MapViewMain.instance.editManager.on("fill", this, function(e):void {
				if(MapViewMain.instance.editManager.floorData[name] == 1)
					_fill.visible = MapViewMain.instance.editManager.isShowFill;
			});
			
			MapViewMain.instance.editManager.on("ocuppy", this, function(e):void {				
				city.visible = MapViewMain.instance.editManager.isShowOcuppy;
			});
			
			
			this.updateGrid();
			this.changeGrid();
			this.changeFill();
			MapViewMain.instance.editManager.on(Event.CHANGE, this, this.changeGrid);
			this.duihao.x = 50;
			this.duihao.y = 20;
			this.city.visible = MapViewMain.instance.editManager.isShowOcuppy;
			this.changeOccupy();
			this.addChild(this.city);
		}
		
		private function get mapGrid():MapGrid {
			var pos:Array = this.name.split(",");
			return MapModel.instance.mapGrid.getGrid(parseInt(pos[0]), parseInt(pos[1]));
		}
		
		private function createText(color:String, t:String):Text {
			var text:Text = new Text();
			text.text = t;
			text.color = color;
			text.fontSize = 16;				
			text.align = "center";
			text.valign = "middle";
			text.strokeColor = "#FFFFFF";
			text.stroke = 2;
			text.x = -5;
			text.y = -10;
			return text;
		}
		
		public function changeOccupy():void {
			var grid:MapGrid = this.mapGrid;
			var entityCity:EntityCity = grid.getEntitysByType(ConfigConstant.ENTITY_CITY, "occupyEntitys")[0];
			this.city.removeChildren();
			if (entityCity) {
				var iso:IsoObject = new IsoObject();
				var text:Text = this.createText("#F0000F", entityCity.cityId.toString());
				if (entityCity.cityType == ConfigConstant.CITY_TYPE_FORT) {
					iso.fill(128 / 2 * 1.5, 72 / 2 * 1.5, entityCity.editData.occupy);
					iso.x += 15;
					iso.y += 10;
					text.x += MapModel.instance.mapGrid.gridHalfW - 25;
					text.y += MapModel.instance.mapGrid.gridHalfH - 5;
				} else {
					iso.graphics.drawCircle(0, 0, 30, entityCity.editData.occupy);					
					iso.x += MapModel.instance.mapGrid.gridHalfW;
					iso.y += MapModel.instance.mapGrid.gridHalfH;
					text.x -= 10;
				}
				iso.alpha = 0.8;
				iso.addChild(text);
				this.city.addChild(iso);
			}		
			
			var estate:EntityEstate = grid.getEntitysByType(ConfigConstant.ENTITY_ESTATE)[0];
			var text2:Text = null;
			if (estate) {
				text2 = this.createText("#00FF00", Tools.getMsgById("_country37"));
			}
			
			var monster:EntityMonster = grid.getEntitysByType(ConfigConstant.ENTITY_MONSTER)[0];
			if (monster) {
				text2 = this.createText("#FF0000", Tools.getMsgById("msg_IsoTile_0"));
			}
			
			var heroCatch:EntityHeroCatch = grid.getEntitysByType(ConfigConstant.ENTITY_HERO_CATCH)[0];
			if (heroCatch) {
				text2 = this.createText("#0000FF", Tools.getMsgById("_hero_chatch_text02"));
			}
			
			var wall:EntityGreatWall = grid.getEntitysByType(ConfigConstant.ENTITY_GREAT_WALL)[0];
			if (wall) {
				text2 = this.createText("#0000FF", "密道");
			}
			
			var xianhe:EntityXianHe = grid.getEntitysByType(ConfigConstant.ENTITY_XIAN_HE)[0];
			if (xianhe) {
				text2 = this.createText("#0000FF", "仙鹤");
			}
			
			if (text2 && iso) {
				iso.addChild(text2);
				text2.y = text.y + 20;
				text2.x = text.x;	
			}
			
		}
		
		private function changeGrid():void {
			if(MapViewMain.instance.editManager.isShowAstar){
				var pos:Array = this.name.split(",");
				var grid:MapGrid = MapModel.instance.mapGrid.getGrid(parseInt(pos[0]), parseInt(pos[1]));
				var v:Vector2D = new Vector2D(grid.col, grid.row);
				v = MapUtils.tileToIso(v);
				this._text.text = v.x + "," + v.y + ("\n" + grid.node.unitsX + "," + grid.node.unitsY);// grid.node.unitsX + "," + grid.node.unitsY;
				this._text.text = v.x + "," + v.y;
			}else {
				pos = this.name.split(",");
				grid = MapModel.instance.mapGrid.getGrid(parseInt(pos[0]), parseInt(pos[1]));
				v = new Vector2D(grid.col, grid.row);
				v = MapUtils.tileToIso(v);
				
				v = MapUtils.isoToTile(v);
				if (this.name != (v.x + "," + v.y)) {
					//trace(121212);
				}
				this._text.text = this.name + "\n" + (v.x + "," + v.y);
				this._text.text = this.name;
			}
			
			this._text.visible = MapViewMain.instance.editManager.isShowGrid;
			this._line.visible = MapViewMain.instance.editManager.isShowGrid;
			this.center.visible = MapViewMain.instance.editManager.isShowGrid;
		}
		
		public function  changeFill():void {			
			this.fillTile = MapViewMain.instance.editManager.floorData[this.name] == null ? null : 
													MapViewMain.instance.editManager.floorData[this.name] == 1 ? //道路
														"#00FF00" :
														MapViewMain.instance.editManager.floorData[this.name] == 2 ? //城池
																"#FF0000" :
																"#0000FF";//小城池。
													;
			
			if(MapViewMain.instance.editManager.floorData[this.name] != null){
				if (parseInt(MapViewMain.instance.editManager.floorData[this.name].toString()) > 1){
					var str:Array = this.name.split(",");
					var entity:EntityCity = MapModel.instance.mapGrid.getGrid(parseInt(str[0]), parseInt(str[1])).getEntitysByType(ConfigConstant.ENTITY_CITY)[0];
					this._idText.text = entity.cityId.toString();
					this._idText.visible = true;
				}else {
					this._idText.text = "";
					this._idText.visible = false;
				}
			}
			else {
				this._idText.text = "";
				this._idText.visible = false;
			}
		}
		
		public function show():void {
			
			this.visible = true;
		}
		
		public function hide():void {
			this.visible = false;
		}

//————————————————————————————————————以下是private方法—————————————————————————————————————
		
		/**
		 * 变更格子状态
		 */
		private function updateGrid():void {
			this._fill.visible = this._fillTileFlag != null;
			this._line.visible = this._showLineFlag;
		}
		
//——————————————————————————————————————以下是public方法————————————————————————————————————
		
		/**
		 * 是否填充
		 */
		public function set fillTile(value:String):void {
			if (this._fillTileFlag == value) return;//节约资源
			this._fillTileFlag = value;
			this._fill.graphics.clear();
			var w:int = this._map.tMap.tileWidth;
			var h:int = this._map.tMap.tileHeight;
			if(this._fillTileFlag != null) {
				this.fill(w, h, this._fillTileFlag);
			}
			this.updateGrid();
		}
		
		/**
		 * 是否显示线条
		 */
		public function set showLine(value:Boolean):void {
			if (this._showLineFlag == value) return;//节约资源
			this._showLineFlag = value;
			this.updateGrid();
		}
	}
}