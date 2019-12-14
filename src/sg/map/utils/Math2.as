package sg.map.utils {
	/**
	 * 提供一些Math的常用算法
	 * @author light
	 */
	public class Math2 {	
		
		/**
		 * 判断两个数是否为相同的符号。
		 * @param	num1
		 * @param	num2
		 * @return
		 */
		public static function sameSign(num1:Number, num2:Number):Boolean {
			if (num1 > 0) return num2 > 0;
			if (num1 < 0) return num2 < 0;
			 return num1 == num2;
		}
		
		/**
		 * 可以对负号向下进1 对正好与原来相同。
		 * @param	num
		 * @return
		 */
		public static function ceil2(num:Number):Number {
			if (num >= 0) return Math.ceil(num);
			return -Math.ceil( -num);
		}
		
		/**
		 * 获取范围内的数字 如果超出 取临界值。
		 * @param	num 
		 * @param	max
		 * @param	min
		 * @return
		 */
		public static function range(num:Number, max:Number, min:Number):Number {
			return Math.max(min, Math.min(max, num));
		}
		
		/**
		 * 返回 min <= retult < max的数
		 * @param	min
		 * @param	max
		 * @return
		 */
		public static function randomRange(min:Number, max:Number):Number {
			return min + Math.random() * (max - min);
		}
		
		
		
		private static const rToA:Number = (1 / Math.PI * 180);		
		private static const aToR:Number = (1 /  180) * Math.PI;
		
		/**
		 * 弧度转化角度。
		 * @param	radian 弧度
		 * @return 角度
		 */
		public static function radianToAngle(radian:Number):Number { return radian * rToA }
		/**
		 * 角度转弧度。
		 * @param	angle 角度
		 * @return 弧度。
		 */
		public static function angleToRadian(angle:Number):Number { return angle * aToR; }
		/**
		 * 随机数组内的值
		 * @param	value 随机的数据 [*, *, *, *]
		 * @param	probability 随机数对应的概率[10, 30, 40, 20]
		 * @return value 数组里的随机出来的对象。
		 */
		public static function random2(value:Array, probability:Array):* {
			var sum:Number = 0;
			var arr:Array = [];
			for (var i:int = 0; i < probability.length; i++) {
				arr.push(sum += probability[i]);
			}
			var random:Number = Math.random() * sum;
			for (i = 0; i < arr.length; i++) {
				if (random <= arr[i]) break;
			}
			return value[i];
		}
		
		/**
		 * 获取范围内的数字 如果超出 取临界值。
		 * @param	num 
		 * @param	max
		 * @param	min
		 * @return
		 */
		public static function inRange(num:Number, max:Number, min:Number):Boolean {
			return num <= max && num >= min;
		}
			
	}

}