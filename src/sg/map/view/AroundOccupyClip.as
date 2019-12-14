package sg.map.view {
	import laya.display.Sprite;
	import laya.map.GridSprite;
	import sg.manager.ModelManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.MapUtils;
	import sg.model.ModelOfficial;
	import sg.scene.constant.EventConstant;
	import sg.scene.model.MapGrid;
	import sg.scene.view.EventGridSprite;
	
	/**
	 * ...
	 * @author light
	 */
	public class AroundOccupyClip extends Sprite {
		
		private var _gridSprites:Array = [];
		
		private var _entity:EntityCity;
		
		private var aroundClips:Array = [];
		
		private var occupyGrids:Array = [];
		
		private var _isShow:Boolean = false;
		
		public function AroundOccupyClip(city:EntityCity) {
			this.init(city);
			
		}
		
		
		public function init(city:EntityCity):void {
			this._entity = city;
			if (!this._entity) return;
			
			city.on(EventConstant.CITY_DETECT, this, this.update, [true]);
			city.on(EventConstant.CITY_COUNTRY_CHANGE, this, this.update, [true]);
			
			if (city.cityId < 0) {
				//检查襄阳站突然开启。 直接update一下。
				ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_HIDE_XYZ, this, this.update, [true]);
				ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_SHOW_XYZ, this, this.update, [true]);
				//結束的時候。。 
			}
		}
		
		public function update(renderAround:Boolean = false):void {		
			this.graphics.clear();			
			if (!this.isDetect) {
				for (var i:int = 0, len:int = this.occupyGrids.length; i < len; i++) {
					this.renderOne(this.occupyGrids[i]);
				}
				if (this._isShow) this.show();
			}
			
			if (!renderAround) return;
			var arounds:Array = [];
			//周边的也更新一下。
			for (i = 0, len = this._entity.around.length; i < len; i++) {
				var grid:MapGrid = this._entity.around[i];
				var aroundInfo:Object = AroundManager.instance.aroundData[grid.toString2()];
				
				for (var aroundCityId:String in aroundInfo) {
					var arr:Array = aroundInfo[aroundCityId];
					for (var j:int = 0, len2:int = arr.length; j < len2; j++) {
						var arr2:Array = arr[j].split("_");
						var grid2:MapGrid = MapModel.instance.mapGrid.getGrid(grid.col + parseInt(arr2[0]), grid.row + parseInt(arr2[1]));
						if (grid2) {
							var around:AroundOccupyClip = AroundManager.instance.getAroundOccupyClipByGrid(grid2);						
							if (around) ArrayUtils.push(around, arounds);
						}
						
					}
				}			
			}
			
			for (i = 0, len = arounds.length; i < len; i++) {
				arounds[i].update();
			}
		}
		
		
		public function renderOne(grid:MapGrid):void {
			var aroundDic:Object = AroundManager.instance.around2[grid.col + "_" + grid.row];
			if (!aroundDic) {
				AroundManager.fillOccupySprite("a_4_4", this, grid);
				return;
			}
			var onlyOne:Boolean = true;
			var gridArr:Array = [];
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
				
				
				var angles:Array = [];
				if (type != 0) {
					type = (type / 2) << 0;
					//if (flag[0] && type != 3 && (flag[3 - type])) continue;
					
					if (type == 3) {//圆角
						
					} else if (type == 0) {//对面角
						angles.push({dir:i, type:4});//补一个下面的角度。
					} else {//其他直接用尖角代替。
						type = 4;
					}
					
					angles.push({dir:i, type:type});
				} else {
					angles.push({dir:i, type:4});//补一个下面的角度。
				}
				gridArr.push(angles);
			}
			
			if (!gridArr.length)  {//不是边界 直接填。
				AroundManager.fillOccupySprite("a_4_4", this, grid);
			} else {
				for (i = 0, len = gridArr.length; i < len; i++) {
					for (j = 0, len2 = gridArr[i].length; j < len2; j++) {
						angles = gridArr[i][j];					
						var key:String = "a_" + angles["dir"] + "_" + angles["type"];
						AroundManager.fillOccupySprite(key, this, grid);
					}
					
				}
			}
			
		}
		
		
		public function addGridSprite(gridSprite:GridSprite, grid:MapGrid):void {
			if (ArrayUtils.push(gridSprite, this._gridSprites)){
				EventGridSprite(gridSprite).addItemSprite(this);
			}
			
			//if (!this._entity) {//代表边缘检查。 所以 直接画就好了。
			if (ArrayUtils.push(grid, this.occupyGrids)) {
				this.renderOne(grid);
			}
			//}
		}
		
		private function get isDetect():Boolean {
			return this._entity ? this._entity.isDetect : false;
		}
		
		public function show():void {
			if (!this.isDetect && !this.parent) {
				MapViewMain.instance.mapLayer.maskLayer.addChildAt(this, 0);				
			}
			this._isShow = true;
		}
		
		public function hide():void {			
			var isShow:Boolean = false;
			for (var i:int = 0, len:int = this._gridSprites.length; i < len; i++) {
				if (this._gridSprites[i].enabled) {
					isShow = true;
					break;
				}
			}
			if (!isShow) {
				this.removeSelf();
				this._isShow = false;
			}
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			if (this._entity) {				
				this._entity.off(EventConstant.CITY_DETECT, this, this.update);
				this._entity.off(EventConstant.CITY_COUNTRY_CHANGE, this, this.update);
				if (this._entity.cityId < 0) {
					//检查襄阳站突然开启。 直接update一下。
					ModelManager.instance.modelOfficel.off(ModelOfficial.EVENT_HIDE_XYZ, this, this.update);
					ModelManager.instance.modelOfficel.off(ModelOfficial.EVENT_SHOW_XYZ, this, this.update);
					//結束的時候。。 
				}
			}
			
			
			super.destroy(destroyChild);			
		}
		
	}

}