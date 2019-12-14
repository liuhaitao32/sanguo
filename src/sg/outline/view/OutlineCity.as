package sg.outline.view {
	import laya.display.Sprite;
	import laya.filters.ColorFilter;
	import laya.ui.Label;
	import sg.cfg.ConfigServer;
	import sg.map.model.entitys.EntityCity;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.TestUtils;
	import sg.scene.SceneMain;
	import sg.scene.view.entity.EntityClip;
	import ui.mapScene.OutlineCityInfoUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class OutlineCity extends EntityClip {
		
		public var info:OutlineCityInfoUI;
		public var testLabel1:Label;
		public var testLabel2:Label;
		
		public var glow:Sprite;
		
		public var _gray:Boolean = false;
		
		public function get entityCity():EntityCity {
			return this._entity as EntityCity;
		}
		
		public function OutlineCity(scene:SceneMain) {
			super(scene);			
		}
		
		override public function init():void {
			
			super.init();
			this.zOrder = 0;
			var cityType:String = this.entityCity.cityType.toString();
			var w:Number = 0;
			var h:Number = 0;
			
			
			if (this.entityCity.country < 3) {
				var sp2:Sprite = new Sprite();
				sp2.texture = Laya.loader.getRes("map2/minimap_" + cityType + ".png");
				sp2.filters = [new ColorFilter(ConfigServer.world.COUNTRY_COLOR_FILTER_MATRIX[this.entityCity.country])];
				
				if (sp2.texture) {
					w = sp2.texture.sourceWidth;
					h = sp2.texture.sourceHeight;
				}
				this._clip.addChild(sp2);
				this.glow = sp2;
				this.gray = this._gray;
			}
			
			
			var sp1:Sprite = new Sprite();
			sp1.texture = Laya.loader.getRes("map2/minimap_" + cityType + "_1" + ".png");
			
			if (sp1.texture) {
				if (w == 0) {
					w = sp1.texture.sourceWidth;
					h = sp1.texture.sourceHeight;
				}
				sp1.x = (w - sp1.texture.sourceWidth) / 2;
				sp1.y = (h - sp1.texture.sourceHeight) / 2;
			}
			
			this._clip.addChild(sp1);
			
			
			
			
			this._clip.pivotX = w / 2;
			this._clip.pivotY = h / 2;
			
			if (ArrayUtils.contains(this.entityCity.cityType, [3, 4, 5, 9])) {
				this.info = new OutlineCityInfoUI();
				this.info.y = this._clip.pivotY - 5;
				this.addChild(this.info);
				this.info.name_txt.text = this.entityCity.name;
				
				if (this.entityCity.cityType == 3){
					this.info.scale(0.8, 0.8);
					this.info.name_txt.color = '#DDDDDD';
				}
				else if (this.entityCity.cityType == 4){
					//this.info.name_txt.color = '#FFDD88';
					this.info.name_txt.strokeColor = '#FFCC00';
					this.info.name_txt.stroke = 2;
				}
				else if (this.entityCity.cityType == 5){
					this.info.scale(1.1, 1.1);
					this.info.name_txt.strokeColor = ConfigServer.world.COUNTRY_COLORS[this.entityCity.faithCountry];
					this.info.name_txt.stroke = 2;
					//this.info.name_txt.bold = true;
				}
				else if (this.entityCity.cityType == 9){
					this.info.name_txt.color = '#FFCC00';
					this.info.scale(1.2, 1.2);
					this.info.name_txt.bold = true;
				}
			}
			if (TestUtils.isTestShow){
				this.testLabel1 = new Label();
				this.testLabel1.text = this.entityCity.cityId.toString();
				this.testLabel1.color = '#FFFFEE';
				this.testLabel1.strokeColor = '#333333';
				this.testLabel1.stroke = 3;
				this.testLabel1.anchorX = 0.5;
				this.testLabel1.align = 'center';
				this.addChild(this.testLabel1);
				
				//找到国战任务三国两两国界线显示
				if (entityCity.getLimitLevel() < 0){
					this.testLabel1.color = '#EE5533';
					return;
				}
				var arr:Array = this.getCityGaugeArr(entityCity);
				if (arr){
					var color:String;
					if (arr[0] == 0) color = '#00FFFF';
					else if (arr[0] == 1) color = '#FFFF00';
					else color = '#FF33FF';
					var dis:int = arr[1];
					
					this.testLabel1.color = color;

					this.testLabel2 = new Label();
					this.testLabel2.text = '【' + (dis + 1).toString() + '】';
					this.testLabel2.color = Math.abs(dis+0.5-arr[2])<1?'#FFFFFF':color;
					this.testLabel2.strokeColor = '#333333';
					this.testLabel2.stroke = 3;
					this.testLabel2.anchorX = 0.5;
					this.testLabel2.y = 11;
					this.testLabel2.align = 'center';
					this.testLabel2.fontSize = (12-Math.abs(dis+0.5-arr[2])*1.2)+6;
					this.testLabel2.bold = Math.abs(dis+0.5-arr[2])<1;
					this.addChild(this.testLabel2);
					
				}
			}
			
			
		}
		/**
		 * 返回该城池在国战任务三国两两国界线的[类别,距离,中点]
		 */
		public function getCityGaugeArr(entityCity:EntityCity):Array {
			var city_gauge:Array = ConfigServer.system_simple.fight_task.city_gauge;	
			var iLen:int = city_gauge.length;
			for (var i:int = 0; i < iLen; i++) 
			{
				var lineArr:Array = city_gauge[i][1];
				var jLen:int = lineArr.length;
				for (var j:int = 0; j < jLen; j++) 
				{
					var pointArr:Array = lineArr[j];
					var kLen:int = pointArr.length;
					for (var k:int = 0; k < kLen; k++) 
					{
						var cid:String = pointArr[k];
						if (entityCity.cityId.toString() == cid){
							return [i,j,jLen/2];
						}
					}
				}
			}
			return null;
		}
		
		public function set gray(value:Boolean):void {
			this._gray = value;
			
			if (!this.glow) return;
			this.glow.visible = !value;			
		}
		
		public function get gray():Boolean {
			return this._gray;
		}
		
	}

}