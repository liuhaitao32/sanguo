package sg.map.utils 
{
	import laya.maths.MathUtil;
	/**
	 * 常用的数组方法
	 * @author light
	 */
	public class ArrayUtils {
		
		public static function contains(v:*, arr:Array):Boolean {
			return arr.indexOf(v) != -1;
		}
		
		public static function push(v:*, arr:Array):Boolean {
			if (contains(v, arr)) {
				return false;
			}else {
				arr.push(v);
				return true;
			}
		}
		
		public static function remove(v:*, arr:Array):Boolean {
			var index:int = arr.indexOf(v);
			if(index != -1) {
				arr.splice(index, 1);
				return true;
			} else {
				return false;
			}
		}
		
		/**
		 * 返回根据对象指定的属性进行排序的比较函数。
		 * @param	propertys 属性列表
		 * @param	arr 原数组
		 * @param	bigFirst 如果值为true，则按照由大到小的顺序进行排序，否则按照由小到大的顺序进行排序。
		 * @param	forceNum 如果值为true，则将排序的元素转为数字进行比较。
		 * @return 排序结果数组
		 */
		public static function sortOn(propertys:Array, arr:Array, bigFirst:Boolean = false, forceNum:Boolean = true):Array {
			return arr.sort(function(a1:*, a2:*):Number{
				for (var i:int = 0, len:int = propertys.length; i < len; i++) {
					var result:Number = MathUtil.sortByKey(propertys[i], bigFirst, forceNum)(a1, a2);
					if (result != 0) return result;
				}
			});
		}
		
		
		/**
		 * 随机取得数组中的某个值
		 */
		public static function getRandomValue(arr:Array):*
		{
			if (!arr)
				return null;
			var len:int = arr.length;
			if (len == 0)
				return null;
			else if (len == 1)
				return arr[0];
			else
				return arr[Math.floor(Math.random() * len)];
		}
		
		/**
		 * 乱序数组的前N位
		 */
		public static function randomArr(arr:Array, endIndex:int = -1):void
		{
			var obj:*;
			if (endIndex == -1)
			{
				endIndex = arr.length;
			}
			for (var i:int = endIndex - 1; i > 0; i--)
			{
				var index:int = Math.floor(Math.random() * (i + 1));
				if (index == i)
					continue;
				obj = arr[i];
				arr[i] = arr[index];
				arr[index] = obj;
			}
		}
 	}

}