package sg.utils
{
	public class ArrayUtil
	{
		/**
		 * 用一个固定值填充一个数组中从起始索引到终止索引内的全部元素。不包括终止索引。
		 * eg: ArrayUtil.fill([1, 2, 3], 4, 1);            // [1, 4, 4]
		 * @param	arr 原数组。
		 * @param	value	用来填充数组元素的值。
		 * @param	start	起始索引，默认值为0。
		 * @param	end	终止索引，默认值为 arr.length。
		 * @return	修改后的数组。
		 */
		public static function fill(arr:Array, value:*, start:int = 0, end:int = null):Array {
			start |= 0;
			(Boolean(end) === false || end > arr.length) && (end = arr.length);
			while(start < end) { arr[start++] = value; }
			return arr;		    
		}
		
		/**
		 * 用一个元素（默认是null）填充当前数组，以便新的数组达到给定的长度。
		 * @param	arr	原数组。
		 * @param	targetLength	当前数组需要填充到的目标长度。如果这个数值小于当前数组的长度，则返回当前数组的浅拷贝。
		 * @param	padValue	填充的对象。
		 * @param	padEnd	是否向后填充。
		 * @return	填充后的数组。
		 */
		public static function padding(arr:Array, targetLength:int, padValue:*, padEnd:Boolean = true):Array {
			arr = [].concat(arr);
			if (arr.length < targetLength) {
				var padArr:Array = ArrayUtil.fill(new Array(targetLength - arr.length), padValue);
				return padEnd ? arr.concat(padArr) : padArr.concat(arr);
			}
			else return arr.concat();   
		}
		
		/**
		 * 递归到指定深度将所有子数组连接，并返回一个新数组。
		 * @param	arr 需要查找元素的数组。
		 * @param	depth 指定嵌套数组中的结构深度，默认值为1。
		 * @return 一个将子数组连接的新数组.
		 */
		public static function flat(arr:Array, depth:int = 1):Array {
			if (!depth is Number || depth < 1)	return arr;
			var curDep:int = 1;
			var result:Array = [];
			function recursionFun(tempArr:Array, depth:int, curDep:int):void {
				tempArr.forEach(function(item:Object):void {
					if (item is Array && curDep <= depth) {
						recursionFun(item as Array, depth, curDep + 1);
					}
					else {
						result.push(item);
					}
				});
			}
			recursionFun(arr, depth, curDep);
			return result;		    
		}
		
		/**
		 * 返回数组中满足提供的测试函数的第一个元素的值。否则返回 undefined。
		 * @param	arr 需要查找元素的数组。
		 * @param	callBack 要对数组中的每一项运行的函数。
		 * @param	thisObject 执行callback时作为this对象的值.
		 * @return
		 */
		public static function find(arr:Array, callBack:Function, thisObject:* = null):* {
			return arr.filter(callBack, thisObject)[0];		    
		}

		/**
         * 返回数组中满足提供的测试函数的第一个元素的索引。否则返回-1。
		 * @param	arr 需要查找索引的数组。
		 * @param	callBack 要对数组中的每一项运行的函数。
		 * @param	thisObject 执行callback时作为this对象的值.
		 * @return  
		 */
		public static function findIndex(arr:Array, callBack:Function, thisObject:* = null):int {
			var item:* = arr.filter(callBack, thisObject)[0];
			if (item)   return arr.indexOf(item);
			return -1;
		}

		/**
		 * 数组去重。
		 * @param	arr 需要去重的数组。
		 */
		public static function distinct(arr:Array):Array {
			var result:Array = [];
			var obj:Object = {};
			arr.forEach(function(item:*):void {
				if (!obj[item]) {
					result.push(item)
					obj[item] = 1
				}
			});
			return result
		}
  }
}