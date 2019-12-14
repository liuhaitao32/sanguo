package sg.map.utils {
	import laya.maths.Point;
	/**
	 * 向量 
	 * @author light
	 */
	public class Vector2D {
		
		public static const TEMP:Vector2D = new Vector2D();
		public static const TEMP1:Vector2D = new Vector2D();
		public static const TEMP2:Vector2D = new Vector2D();
		
		public static const TOP:Vector2D = new Vector2D(0, -1);
		public static const RIGHT:Vector2D = new Vector2D(1, 0);
		public static const BOTTOM:Vector2D = new Vector2D(0, 1);
		public static const LEFT:Vector2D = new Vector2D( -1, 0);
		
		public static const ZERO:Vector2D = new Vector2D(0, 0);
		
		public static const LEFT_TOP:Vector2D = new Vector2D(-1, -1);
		public static const RIGHT_TOP:Vector2D = new Vector2D(1, -1);
		public static const LEFT_BOTTOM:Vector2D = new Vector2D(-1, 1);
		public static const RIGHT_BOTTOM:Vector2D = new Vector2D(1, 1);
		
		private var _x:Number;
		
		private var _y:Number;
		
		public function Vector2D(x:Number = 0, y:Number = 0) {
			this._x = Number(x);
			this._y = Number(y);
		}
		
		public static function lerp (v1:Vector2D, v2:Vector2D, rate:Number, result:Vector2D):void {
			result.copy(v2);
			result.subtract (v1).multiply (rate).add (v1);
		}
		
		public static function createVector(x:Number, y:Number):Vector2D {
			return new Vector2D(x, y);
		}
		
		public function copy(v:Vector2D):void {
			this.setXY(v.x, v.y);
		}
		
		public static function toVector(str:String, sign:String = "_", result:Vector2D = null):Vector2D {
			result ||= new Vector2D();
			var arr:Array = str.split(sign);
			result.setXY(arr[0], arr[1]);
			return result;
		}
		
		public function setPoint(p:Point):void{
			this._x = p.x;
			this._y = p.y;
		}
		
		public function setTempPoint():void{
			this._x = Point.TEMP.x;
			this._y = Point.TEMP.y;
		}
		
		/**
		 * 复制一个vector2D
		 * @return 一个向量的副本
		 */
		public function clone():Vector2D {
			return new Vector2D(this._x, this._y);
		}
		
		/**
		 * 让向量的长度值为0
		 * @return 当前向量
		 */
		public function zero():Vector2D {
			this._x = 0;
			this._y = 0;
			return this;
		}
		
		/**
		 * 判断当前向量是否长度是0
		 * @return true是 false非
		 */
		public function isZero():Boolean {
			return this._x == 0 && this._y == 0;
		}
		
		/**
		 * 设置向量的长度
		 */
		public function set length(value:Number):void {
			var a:Number = this.angle;
			this._x = Math.cos(a) * value;
			this._y = Math.sin(a) * value;
		}
		
		/**
		 * 获取当前向量的长度
		 */
		public function get length():Number {
			return Math.sqrt(this.lengthSQ);
		}
		
		/**
		 * 获取向量的平方
		 */
		public function get lengthSQ():Number {
			return this._x * this._x + this._y * this._y;
		}
		
		/**
		 * 设置向量角度 (弧度制)
		 */
		public function set angle(value:Number):void {
			var len:Number = this.length;
			this._x = Math.cos(value) * len;
			this._y = Math.sin(value) * len;
		}
		
		/**
		 * 旋转向量
		 * @param	value
		 * @return
		 */
		public function rotate(value:Number):Vector2D {
			var newX:Number = this._x * Math.cos(value) - this._y * Math.sin(value);
			var newY:Number = this._x * Math.sin(value) + this._y * Math.cos(value);			
			this._x = newX;
			this._y = newY;
			return this;
		}
		
		/**
		 * 获取向量的角度 (弧度制)
		 */
		public function get angle():Number {
			return Math.atan2(this._y, this._x);
		}
		
		/**
		 * 把这个向量变成单位向量 保留角度
		 * @return 当前类引用
		 */
		public function normalize():Vector2D {
			var len:Number = this.length;
			if (0 == len) {
				this._x = 1;
				return this;
			}
			this._x /= len;
			this._y /= len;
			return this;
		}
		
		/**
		 * 判断长度是否为单位向量 1
		 * @return true 是 false 非
		 */
		public function isNormalized():Boolean {
			return 1.0 == this.length;
		}
		       
		/**
		 * 截断长度
		 * @param	max 与这个max值比较，如果比他大，则截断，选取小的值
		 * @return
		 */
		public function truncate(max:Number):Vector2D {
			this.length = Math.min(max, this.length);
			return this;
		}
		
		/**
		 * 反转这个向量
		 * @return 当前引用
		 */
		public function reverse():Vector2D {
			this._x = -this._x;
			this._y = -this._y;
			return this;
		}
		
		/**
		 * 计算当前点与给出的点的乘积
		 * @param	v2 一个vector2D的实例
		 * @return 返回当前点与指定的点的乘积
		 */
		public function dotProd(v2:Vector2D):Number {
			return this._x * v2.x + this._y * v2._y
		}
		
		/**
		 * 求出两个向量之间的角度
		 * 向量公式 a * b = |a| * |b| * cos(θ) 
		 * a b为单位向量 a * b = cos(θ); θ = acos(a * b);
		 * @param	v1
		 * @param	v2
		 * @return
		 */
		public static function angleBetween(v1:Vector2D, v2:Vector2D):Number {
			if (!v1.isNormalized()) v1 = v1.clone().normalize();
			if (!v2.isNormalized()) v2 = v2.clone().normalize();
			return Math.acos(v1.dotProd(v2));
		}
		
		/**
		 * 确定给出的向量是在右边还是在坐标
		 * 以当前向量方向上给出左右 只需判断是否与垂直同向就行！
		 * @param	v2 给出的向量
		 * @return -1 左边 +1 右边
		 */
		public function sign(v2:Vector2D):int {
			return this.perp.dotProd(v2) < 0 ? -1 : 1;
		}
		
		/**
		 * 返回垂直于当前向量的向量
		 */
		public function get perp():Vector2D {
			return new Vector2D( -this._y, x);
		}
		
		/**
		 * 计算当前向量与给出向量的距离
		 * @param	v2 给出向量
		 * @return 根据参数返回与给出向量的距离
		 */
		public function dist(v2:Vector2D):Number {
			return Math.sqrt(this.distSQ(v2));
		}
		
		/**
		 * 计算当前向量与给出的向量距离的平方
		 * @param	v2 给出的向量
		 * @return 根据参数返回与给出向量的距离的平方
		 */
		public function distSQ(v2:Vector2D):Number {
			var dx:Number = v2.x - this._x;
			var dy:Number = v2.y - this._y;
			return dx * dx + dy * dy;
		}
		
		/**
		 * 添加一个向量到当前向量
		 * @param	v2 给出向量
		 * @return 返回this
		 */
		public function add(v2:Vector2D):Vector2D {
			this._x += v2.x;
			this._y += v2.y;
			return this;
		}
		
		/**
		 * 当前向量减去给出向量 创建一个新的向量返回 不改变原向量
		 * @param	v2 给出向量
		 * @return 返回this
		 */
		public function subtract(v2:Vector2D):Vector2D {
			this._x -= v2.x;
			this._y -= v2.y;
			return this;
		}
		
		/**
		 * 当前向量乘以value值
		 * @param	value 
		 * @return 返回 this
		 */
		public function multiply(value:Number):Vector2D {
			this._x *= value;
			this._y *= value;
			return this;
		}
		
		/**
		 * 当前向量除以value值
		 * @param	value 
		 * @return 返回 this
		 */
		public function divide(value:Number):Vector2D {
			this._x /= value;
			this._y /= value;
			return this;
		}
		
		/**
		 * 判断当前向量与给出的向量是否相等
		 * @param	v2 给出的向量
		 * @return true 相等 false 不能
		 */
		public function equals(v2:Vector2D, epsilon:Number=0.000001):Boolean {
			return Math.abs(x - v2.x) < epsilon && Math.abs(y - v2.y) < epsilon;
		}
		
		/**
		 * 设置x值
		 */
		public function set x(value:Number):void {
			this._x = value;
		}
		
		/**
		 * 获得x值
		 */
		public function get x():Number {
			return this._x;
		}
		
		/**
		 * 设置y值
		 */
		public function set y(value:Number):void {
			this._y = value;
		}
		
		/**
		 * 获取y值
		 */
		public function get y():Number {
			return this._y;
		}
		
		/**
		 * toString方法
		 * @return 返回说明向量的字符串;
		 */
		public function toString():String {
			return "[Vector2D(x:" + this._x + "y:" + this._y + ")]";
		}
		
		/**
		 * 设置向量x y
		 * @param	x
		 * @param	y
		 */
		public function setXY(x:Number, y:Number):Vector2D {
			this._x = Number(x);
			this._y = Number(y);
			return this;
		}
		
		/**
		 * 投影到某向量上的长度。
		 * @param	axis
		 * @return
		 */
		public function projectionOn(axis:Vector2D):Number {
			return this.dotProd(axis.clone().normalize())
		}
		
		/**
		 * 投影到某向量上的然后返回此轴上的对应长度的向量。
		 * @param	axis
		 * @return 当前轴向量 大小与投影大小一致 方向与轴相同。
		 */
		public function projectionVector(axis:Vector2D):Vector2D {
			axis = axis.clone();
			axis.length = Math.abs(this.projectionOn(axis));
			return axis;
		}
		
		
		/**
		 * 矢量叉积。
		 * @param	v
		 * @return 正数代表在右边 负数代表在右边。 0代表 180 与 0之间。
		 */
		public function crossProduct(v:Vector2D):Number {
			return this._x * v.y - this._y * v.x;
		}
		
	}

}