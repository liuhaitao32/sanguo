package sg.model
{
	import laya.events.EventDispatcher;

	/**
	 * ...
	 * @author
	 */
	public class ModelBase extends EventDispatcher{
		public var data:Object;
		public var mData:Object;
		public var mClassType:int = -1;
		public function ModelBase(){
			
		}
	}

}