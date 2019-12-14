package sg.scene.view {
	import laya.display.Sprite;
	import laya.maths.Point;
	import laya.resource.Texture;
	import sg.manager.ModelManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.map.model.entitys.EntityMarch;
	import sg.map.utils.MapUtils;
	import sg.map.utils.Math2;
	import sg.map.utils.Vector2D;
	import sg.map.view.MapViewMain;
	import sg.map.view.entity.MarchClip;
	import sg.scene.constant.EventConstant;
	import sg.scene.view.entity.EntityClip;
	import sg.utils.Tools;
	import sg.model.ModelUser;
	/**
	 * ...
	 * @author light
	 */
	public class MarchPathManager {
		
		public var citys:Object = {};
		
		public var marchPathCount:Object = {};
		
		public static const instance:MarchPathManager = new MarchPathManager();
		
		public function MarchPathManager() {
			
		}
		
		public function clearAll():void {
			this.citys = {};
			this.marchPathCount = {};
		}
		
		public function setMarch(march:MarchClip, cleared:Boolean):void {
			cleared ? this.clearWay(march) : this.setWay(march);
		}
		
		
		
		private function setWay(marchClip:MarchClip):void {
			var march:EntityMarch = marchClip.entityMarch;
			
			var isEnemy:Boolean = false;
			//友军不显示虚线。
			if (march.country == ModelUser.getCountryID()){
				if(!ModelManager.instance.modelTroopManager.troops[march.id]) return;
			} else {
				if (EntityCity(MapModel.instance.citys[march.marchData[march.marchData.length - 1][0]]).country == ModelUser.getCountryID()) {
					isEnemy = true;
				} else {
					return;
				}
			}
			
			for (var i:int = 0, len:int = march.marchData.length - 1; i < len; i++) {
				var city1:int = parseInt(march.marchData[i][0]);
				var city2:int = parseInt(march.marchData[i + 1][0]);
				var key:String = EntityCity.getConnectKey(city1, city2);				
				this.citys[key] ||= [[0, null], [0, null]];
				//var isEnemy2:Boolean = false;
				if (EntityCity(MapModel.instance.citys[city1]).country != EntityCity(MapModel.instance.citys[city2]).country) {
					isEnemy = true;
				}
				var flag:int = isEnemy ? 0 : 1;
				var arr:Array = citys[key][flag];
				if (arr[0] == 0) {
					arr[1] = this.createPath(city1, city2, isEnemy);
				}
				arr[0]++;
				this.marchPathCount[march.id] ||= [];
				this.marchPathCount[march.id].push(flag);
			}			
		}
		
		private function clearWay(marchClip:MarchClip):void {
			var march:EntityMarch = marchClip.entityMarch;
			if (!this.marchPathCount[march.id]) return;
			for (var i:int = 0, len:int = march.marchData.length - 1; i < len; i++) {
				var city1:int = parseInt(march.marchData[i][0]);
				var city2:int = parseInt(march.marchData[i + 1][0]);
				var key:String = EntityCity.getConnectKey(city1, city2);
				var flag:int = this.marchPathCount[march.id][i];
				var arr:Array = citys[key][flag];
				arr[0]--;
				if (arr[0] == 0) {
					while (arr[1].length) {
						Tools.destroy(arr[1].shift());
					}
				}
			}
			delete this.marchPathCount[march.id];
			
		}
		
		
		public function createPath(city1:int, city2:int, isEnemy:Boolean):Array {
			//city1 = 146;
			//city2 = 149;
			var ways:Array = EntityCity.getAllTurnPath(city1, city2);
			var t:Texture = isEnemy ? Laya.loader.getRes("map2/xuxian02.png") : Laya.loader.getRes("map2/xuxian01.png");
			var result:Array = [];
			for (var j:int = 0, len2:int = ways.length - 1; j < len2; j++) {
				//turnArr.push([grid1, i, iii, ut, j]);
				var grid1:Vector2D = ways[j][0];
				var grid2:Vector2D = ways[j + 1][0].clone();					
				
				MapUtils.getPos(grid1.x, grid1.y, Point.TEMP);
				grid1.setPoint(Point.TEMP);
				MapUtils.getPos(grid2.x, grid2.y, Point.TEMP);
				grid2.setPoint(Point.TEMP);					
				
				grid2.subtract(grid1);
				
				var sp:Sprite = new Sprite();
				var n:Number = Math.ceil(grid2.length / t.width);
				var pos:Array = [];
				for (var k:int = 0, len3:int = n; k < len3; k++) {
					sp.graphics.drawTexture(t, k * t.width, -t.height / 2);
				}
				//if (ways[j][1] == -1) {
					sp.autoSize = true;
					sp.scale(grid2.length / sp.width, grid2.length / sp.width);
				//}
				
				sp.rotation = Math2.radianToAngle(grid2.angle);
				
				
				MapViewMain.instance.mapLayer.floorLayer.addChildAt(sp, 0);
				sp.x = grid1.x;
				sp.y = grid1.y;
				result.push(sp);
			}
			return result;
		}
		
		
	}

}