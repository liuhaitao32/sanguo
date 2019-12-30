package sg.model
{
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;

	/**
	 * ...
	 * @author
	 */
	public class ModelHonour extends ModelBase{
		
		public static const EVENT_CHANGE_STATUS:String="event_hounour_change_status";

		private static var sModel:ModelHonour = null;
		
		public static function get instance():ModelHonour{
			return sModel ||= new ModelHonour();
		}

		public var mStatus:int;//状态 -1未开启   0即将开启   1赛季中   2赛季休息日

		public var mStartTime:int;//下一次开始时间
		public var mRestTime:int;//下一次休息时间

		public function ModelHonour(){
			
		}

		private function initHounour():void{

		}

		/**
		 * 计时器  每秒调用
		 */
		public function updateHonour():void{

		}

		/**
		 * 功能是否开启
		 */
		public function isOpen():Boolean{
			var b1:Boolean = false;
			if(ConfigServer.honour){
				var n1:Number = ConfigServer.honour["switch"] != null ?  ConfigServer.honour["switch"] : -1;
				var n2:Number = ModelManager.instance.modelUser.mergeNum;
				b1 = n1>=0 && n1 <= n2;
			}
			var b2:Boolean = !ModelGame.unlock(null,"honour").stop;
			return b1 && b2;
		}
		
	}

}