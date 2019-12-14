package sg.utils
{
	import laya.utils.Pool;

	/**
	 * ...
	 * @author
	 */
	public class ObjectSingle{
		public static var sDic:Object = {};
		public static function getObject(id:String,cls:Class):*{
			if(!sDic.hasOwnProperty(id)){
				sDic[id] = new cls();
			}
			return sDic[id];
		}
		public static function getObjectByArr(arr:Array):*{
			return getObject(arr[0],arr[1]);
		}
		public static function clear():void{
			ObjectSingle.sDic = {};
		}
		
	}

}