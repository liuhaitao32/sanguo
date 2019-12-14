package sg.activities.model
{
	import sg.cfg.ConfigServer;
	import sg.model.ViewModelBase;
	import sg.manager.ModelManager;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ModelRoolPay extends ViewModelBase{

		private static var sModel:ModelRoolPay = null;
		
		public static function get instance():ModelRoolPay
		{
			return sModel ||= new ModelRoolPay();
		}

		public var cfg:Object;
		private var _daysKey:String="";

		public function ModelRoolPay(){
			cfg=ConfigServer.ploy.rool_pay;
		}

		/**
		 * 刷新用户数据
		 */
		override public function refreshData(data:*):void{
			
		}

		/**
		 * 开服天数
		 */
		public function get openDays():Number{
			//开服时间
			var openTime:Number=Tools.getTimeStamp(ConfigServer.zone[""+ModelManager.instance.modelUser.zone][2]);
			//活动开启时间
			var cfgTime:Number=this.cfg.open_date ? Tools.getTimeStamp(this.cfg.open_date) : 0;
			var n:Number=ModelManager.instance.modelUser.loginDateNum;
			if(cfgTime!=0){
				var openDate:Date=new Date(openTime);
				var cfgDate:Date=new Date(cfgTime);

				var openTime2:Number=(new Date(openDate.getFullYear(),openDate.getMonth(),openDate.getDate())).getTime();
				var cfgTime2:Number=(new Date(cfgDate.getFullYear(),cfgDate.getMonth(),cfgDate.getDate())).getTime();

				if(cfgTime>=openTime){
					var m:Number=Math.floor((cfgTime2-openTime2)/Tools.oneDayMilli);
					n = n - m;
				}
			}
			
			return n;
		}

		/**
		 * 活动的key
		 */
		public function get cfgOpenKey():String{
			_daysKey="";
			if(ModelManager.instance.modelUser.records.rool_pay==null){
				return _daysKey;
			}
			var o:Object=cfg.open_days;
			for(var s:String in o){
				var arr:Array=s.split('_');
				var n1:Number=Number(arr[0]);
				var n2:Number=Number(arr[1]);
				//trace("开服天数 ",openDays,"活动时间 ",n1,"天到",n2,"天");
				if(openDays>=n1 && openDays<=n2){
					_daysKey=s;
					break;
				}
			}
			return _daysKey;
		}

		/**
		 * 活动剩余时间
		 */
		public function get lastTime():Number{
			if(_daysKey!=""){
				var arr:Array=_daysKey.split('_');
				var n1:Number=Number(arr[1]);
				return Tools.getDayDisTime()+(n1-openDays)*Tools.oneDayMilli;
			}
			return 0;
		}

		/**
		 * 具体活动内容 {"hero" "pay_money" "first_reward" "reward"}
		 */
		public function get cfgGoods():Object{
			var s:String = _daysKey;
			if(s!=""){
				return cfg[cfg.open_days[s]];
			}
			return null;
		}
		/**
		 * 奖励内容
		 */
		public function get cfgReward():Object{
			if(cfgGoods){
				if(this.getNum==0){
					return cfgGoods["first_reward"];
				}else{
					return  cfgGoods["reward"];
				}
			}
			return null;
		}

		/**
		 * 已领取个数
		 */
		public function get getNum():Number{
			var arr:Array=ModelManager.instance.modelUser.records.rool_pay;
			if(openDays>=arr[0] && openDays<=arr[1]){
				return arr[4];
			}
			return 0;
		}

		
		/**
		 * 活动是否开启 新的一天检查一次就行
		 */
		override public function get active():Boolean{
			if(ModelManager.instance.modelUser.canPay == false) return false;
			
			if(ConfigServer.ploy.rool_pay && ModelManager.instance.modelUser.pay_money>=ConfigServer.ploy.rool_pay.show_moneylimit){
				return cfgOpenKey!="";
			}
			
			
			return false;
		}

		/**
		 * 红点
		 */
		override public function get redPoint():Boolean{
			if(active){
				var m:Number=ModelManager.instance.modelUser.records.rool_pay[3];
				return Math.floor(m/this.cfgGoods.pay_money)>this.getNum;
			}
			return false;
		}
	}

}