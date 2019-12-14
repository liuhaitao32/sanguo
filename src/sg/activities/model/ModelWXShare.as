package sg.activities.model
{
	import laya.events.EventDispatcher;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import sg.cfg.ConfigApp;

	/**
	 * ...
	 * @author
	 */
	public class ModelWXShare extends EventDispatcher{

		public static const EVENT_ChANGE_SHARE:String="event_change_share";
		public var cfg:Array = null;
		
		private static var sModel:ModelWXShare = null;
		
		public static function get instance():ModelWXShare
		{
			return sModel ||= new ModelWXShare();
		}

		public function ModelWXShare(){
			cfg=ConfigServer.ploy.share_reward;
		}

		public function checkActive():Boolean{
			if(ConfigServer.system_simple.share_pf && ConfigServer.system_simple.share_pf.hasOwnProperty(ConfigApp.pf) && Platform.share_on_off()){
				return true;
			}
			return false;
		}

		public function getTime():Number{
			if(getCD()==0){
				return 0;
			}
			if(ModelManager.instance.modelUser.records.wx_share){
				var o:Object=ModelManager.instance.modelUser.records.wx_share;
				if(o.time!=null){
					var n:Number=ConfigServer.getServerTimer() - Tools.getTimeStamp(o.time);
					if(n>getCD()){
						return 0;
					}else{
						return getCD()-n;
					}
				} 
			}
			return 0;
		}

		/**
		 * 今天的第几次
		 */
		public function times():Number{
			if(ModelManager.instance.modelUser.records.wx_share){
				var o:Array=ModelManager.instance.modelUser.records.wx_share;
				if(o.time==null){
					return 0;
				}
				return Tools.isNewDay(o.time) ? 0 : o.num;
			}
			return 0;
		}

		public function getCD():Number{
			return cfg[this.times()]?cfg[this.times()][0] * 60 * 1000 : 0;
		}

		public function redPoint():Boolean{
			if(times()<cfg.length){
				if(getTime()==0){
					return true;
				}
			}
			return false;
		}
	}

}