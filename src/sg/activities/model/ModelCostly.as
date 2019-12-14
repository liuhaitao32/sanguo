package sg.activities.model
{
	import sg.model.ViewModelBase;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ModelCostly  extends ViewModelBase{

		private static var sModel:ModelCostly = null;
		private var mKey:String;
		public static function get instance():ModelCostly
		{
			return sModel ||= new ModelCostly();
		}

		public var cfg:Object;

		public function ModelCostly(){
			mKey = "";
			cfg = ConfigServer.ploy.costly;

		}

		/**
		 * 刷新用户数据
		 */
		override public function refreshData(data:*):void{
			
		}

		/**
		 * 活动是否开启
		 */
		override public function get active():Boolean{
			if(cfg==null) return false;
			for(var s:String in cfg){
				var o:Object = cfg[s];
				if(o.date){
					// var dt:Date = new Date(ConfigServer.getServerTimer());
					// var dt1:Date = new Date(o.date[0][0],o.date[0][1]+1,o.date[0][2]);
					// var dt2:Date = new Date(o.date[1][0],o.date[1][1]+1,o.date[1][2]);
					var n:Number = ConfigServer.getServerTimer();
					var n1:Number = new Date(o.date[0][0],o.date[0][1]+1,o.date[0][2]).getTime();
					var n2:Number = new Date(o.date[1][0],o.date[1][1]+1,o.date[1][2]).getTime() + Tools.oneDayMilli;
					if(n>n1 && n<n2){
						mKey = s;
						return true;
					}
				}
				if(o.days){
					var num:Number = ModelManager.instance.modelUser.loginDateNum;
					if(num>=o.days[0] && num<o.days[0]+o.days[1]){
						mKey = s;
						return true;
					}
				}
			}
			
			return false;
		}

		/**
		 * 红点
		 */
		override public function get redPoint():Boolean{
			return false;
		}

		public function getText():String{
			var s:String = "";
			var n1:Number = 0;
			var n2:Number = 0;
			if(mKey!=""){
				var arr:Array = ModelManager.instance.modelUser.records.costly;
				n1 = arr!=null && mKey==arr[0] ? arr[1] : 0;
				n2 = cfg ? cfg[mKey].max : 0;
			}
			return Tools.getMsgById("sale_pay_17",[n1,n2]);
		}
	}

}