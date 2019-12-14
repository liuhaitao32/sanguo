package sg.map.view{
	import interfaces.IClear;
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.maths.Point;
	import sg.map.model.MapModel;
	import sg.map.utils.TestUtils;
	import sg.map.utils.Vector2D;
	import sg.map.view.MapViewMain;
	
	/**
	 * 等角对象
	 * @author light
	 */
	public class IsoObject extends Sprite implements IClear {
		
		protected var _map:MapViewMain;
		
		
		protected var _fill:Sprite;
		
		protected var _line:Sprite;
		
		protected var _text:Text;
		
		private var _logStr:String = "";
		
		protected var _cleared:Boolean = false;
		
//————————————————————————————————————以下是方法————————————————————————————————————————————
		/**
		 * 构造函数
		 * @param	size
		 */
		public function IsoObject() {
			this._map = MapViewMain.instance;
		}
		
		/**
		 * 初始化
		 * @param	size
		 */
		public function init():void {
			
		}
		
		public function onClick():void {
			
		}
		
		public function draw(w:Number, h:Number):void {
			if (!TestUtils.isTestShow) return;
			this._line ||= new Sprite();
			var hw:Number = w * 0.5;
			var hh:Number = h * 0.5;
			this._line.graphics.drawLines(0, 0, [0, -hh, hw, 0, 0, hh, -hw, 0, 0, -hh], "#000000", 2);
			this.addChild(_line);
		}	
		
		public function fill(w:Number, h:Number, color:String):void {
			this._fill ||= new Sprite();
			this.addChild(this._fill);
			this._fill.graphics.drawPath(0, 0, [
						["moveTo", 0, h * 0.5],
						["lineTo", w * 0.5, 0],
						["lineTo", w, h * 0.5],
						["lineTo", w * 0.5, h],
						["lineTo", 0, h * 0.5],
						["closePath"]
					],
					{
						fillStyle: color
					});		
		}
		
		public function print(str:*, clear:Boolean = false, strokeColor:String = '#333333'):void {			
			if (!TestUtils.isTestShow) return;
			if(this._text == null) {
				this._text = new Text();
				this._text.color = "#FFFFFF";
				this._text.fontSize = 16;
				this._text.width = MapModel.instance.mapGrid.gridW;
				this._text.height = MapModel.instance.mapGrid.gridH;
				this._text.align = "center";
				this._text.valign = "middle";
				this._text.scrollY = this._text.maxScrollY;
				if(strokeColor){
					this._text.stroke = 3;
					this._text.strokeColor = strokeColor;
				}
				this.addChild(this._text);
			}
			if (clear) this._logStr = "";
			this._logStr += str.toString();
			this._text.text = this._logStr;
		}
		
		public function get cleared():Boolean {
			return this._cleared;
		}
		
		public function clear():void {
			this._cleared = true;
			this.destroy(true);
		}
			
	}

}