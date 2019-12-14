package
{

	/**
	 * ...
	 * @author
	 */
	public class Trace{
		public static var isOn:Boolean = false;
		public function Trace(){
			
		}
		/**
		 * 开发时候,优先用 系统的 trace
		 * 最后 会统一替换
		 */
		public static function log(...arr:Array):void{
			if(!Trace.isOn){
				return;
			}
			var len:int = arr.length;
			switch(len){
				case 1:trace(arr[0]);break;
				case 2:trace(arr[0],arr[1]);break;
				case 3:trace(arr[0],arr[1],arr[2]);break;
				case 4:trace(arr[0],arr[1],arr[2],arr[3]);break;
				case 5:trace(arr[0],arr[1],arr[2],arr[3],arr[4]);break;
				case 6:trace(arr[0],arr[1],arr[2],arr[3],arr[4],arr[5]);break;
				default:trace(arr);break;
			}
		}
	}

}