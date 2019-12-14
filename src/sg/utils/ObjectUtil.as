package sg.utils
{
    public class ObjectUtil
    {
        /**
         * 对象拷贝
         * sourceObj    源对象
         * deep        是否进行深拷贝，默认是浅拷贝
         */
        public static function clone(sourceObj:Object, deep:Boolean = false):Object {
            if (typeof sourceObj !== 'object') return sourceObj;
            var obj:Object = sourceObj is Array ? [] : {};
            if (deep) return JSON.parse(JSON.stringify(sourceObj));
            for(var key:String in sourceObj) {
                var element:Object = sourceObj[key];
                obj[key] = element;
            }
            return obj;
        }

        /**
         * 合并多个对象
         */
        public static function mergeObjects(objArr:Array):Object {
            var tempObj:Object = {};
            var len:int = objArr.length;
            for(var i:int = 0; i < len; i++) {
                var obj:Object = objArr[i];
                for(var key:String in obj) {
                    if (tempObj.hasOwnProperty(key) && obj[key] is Number && tempObj[key] is Number) {
                        tempObj[key] += obj[key];
                    }
                    else {
                        tempObj[key] = obj[key];
                    }
                }
            }
            return tempObj;
        }

        /**
         * 获取对象的所有键
		 * @param	obj
		 * @return Array
         */
        public static function keys(obj:Object):Array {
            var keys:Array = [];
            for(var key:String in obj) {
                obj.hasOwnProperty(key) && keys.push(key);
            }
            return keys;
        }

		/**
         * 获取对象的所有键对应的值
		 * @param	obj
		 * @return Array
		 */
		public static function values(obj:Object):Array {
            var arr:Array = [];
            for (var key:* in obj) {
                obj.hasOwnProperty(key) && arr.push(obj[key]);
            }
            return arr;
		}

		/**
         * 获取一个给定对象自身可枚举属性的键值对数组
		 * @param	obj
		 * @return Array
		 */
		public static function entries(obj:Object):Array {
            var arr:Array = [];
            for (var key:* in obj) {
                obj.hasOwnProperty(key) && arr.push([key, obj[key]]);
            }
            return arr;
		}

        /**
         * 取类名，不包括包名
         */
        public static function className(obj:Object):String {
            return obj['__className'].match(/\.\b([^.]+)$/)[1];
        }
    }
}