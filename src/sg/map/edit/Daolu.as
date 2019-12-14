package sg.map.edit {
	// import laya.debug.tools.comps.Rect;
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import sg.map.view.MapViewMain;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.scene.constant.ConfigConstant;
	import ui.EditPropertyUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class Daolu extends Sprite {
		public var isDestroy:Boolean = false;
		public var path:Array;
		public var city1:EntityCity;
		public var city2:EntityCity;
		public var daolu_type:int;
		public var dist:Number = -1;
		public var text:Text = new Text();
		public function Daolu() {
			var sp:Sprite = new Sprite();
			sp.texture = Laya.loader.getRes("eidtTest/daolu.png");
			this.addChild(sp);
			sp.scale(0.3, 0.3);
			sp.x = -160 * 0.3;
			sp.y = -140 * 0.3;
			this.text.strokeColor = "#000000";
			this.text.stroke = 5;
			this.text.fontSize = 25;
			this.text.color = "#FFFFFF";
			this.addChild(this.text);
			this.graphics.drawCircle(0, 0, 20, "#FF0000");
			
		}
		
		public function init(property:EditPropertyUI):void {
			city1.once(Event.CLOSE, this, function(e:Event):void{
				isDestroy = true;
				removeSelf();
			});
			
			city2.once(Event.CLOSE, this, function(e:Event):void{
				isDestroy = true;
				removeSelf();
			});
			
			var this2:Daolu = this;
			this.on(Event.CLICK, this, function(e:Event):void{
				e.stopPropagation();
				MapViewMain.instance.editManager.setDaolu(this2);
				//显示属性面板。
			});
			
			
			Laya.timer.callLater(this, this.addToStage);
			
			this.hitArea = new Rectangle(-320 * 0.3 / 2, -293 * 0.3 / 2, 320 * 0.3, 293 * 0.3);
			this.updateText();
			this.text.x = -this.text.textWidth / 2;
			this.text.y = -this.text.textHeight / 2;
			this.cacheAs = "bitmap";
		}
		
		private function addToStage():void 
		{
			var p1:Point = new Point();
			var p2:Point = new Point();	
			MapViewMain.instance.mapLayer.getPos(this.city1.mapGrid.col, this.city1.mapGrid.row, p1);
			MapViewMain.instance.mapLayer.getPos(this.city2.mapGrid.col, this.city2.mapGrid.row, p2);
			
			var center:Point = new Point((p2.x - p1.x ) / 2, (p2.y - p1.y ) / 2)
			
			var w:int = MapViewMain.instance.tMap.tileWidth;
			var h:int = MapViewMain.instance.tMap.tileHeight;
			
			this.x = p1.x + center.x;
			this.y = p1.y + center.y;		
			
			//道路水路
			var color:String = this.daolu_type?"#00FFFF":"#FFCC83";
			this.graphics.drawLine(0, 0, p1.x - this.x, p1.y - this.y , color, 10);
			this.graphics.drawLine(0, 0, p2.x - this.x, p2.y - this.y , color, 10);
			
			MapViewMain.instance.mapLayer.topLayer.addChild(this);
		}
		
		public function updateText():void{			
			this.text.text = (this.dist == -1 ? (this.path.length - 1) * ConfigConstant.WAY_DIST_UNIT : this.dist).toString();
		}
		
		public function getData(easy:Boolean):Object {
			var result:Object = {};
			if(this.dist != -1 && this.dist != (this.path.length - 1) * ConfigConstant.WAY_DIST_UNIT){
				result.dis = this.dist;
			} else if (easy) {
				result.dis = (this.path.length - 1) * ConfigConstant.WAY_DIST_UNIT;
			}
			
			if (this.daolu_type == 1) result.water = 1;
			if (!easy) result.path = this.path;
			
			return result;
		}
		
	}

}