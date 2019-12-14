package sg.activities.model
{
	import laya.maths.MathUtil;
	import sg.model.ViewModelBase;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.model.ModelItem;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ModelDial extends ViewModelBase{

		private static var sModel:ModelDial = null;
		
		public static function get instance():ModelDial
		{
			return sModel ||= new ModelDial();
		}

		public var cfg:Object;
		public var mDays:Number=0;
		public var mPayMoney:Number=0;
		public var mGetTimes:Number=0;
		public var mAwradList:Array;
		public var mRecrodList:Array;
		public var mCanGetTimes:Number=0;
		public function ModelDial(){
			cfg=ConfigServer.ploy.dial;
		}

		/**
		 * 刷新用户数据
		 */
		override public function refreshData(data:*):void{
			var arr:Array = data.dial;
			if (!arr is Array) return;
			mDays=arr[0];
			mPayMoney=arr[1];
			mGetTimes=arr[2];
			mAwradList=arr[3];
			mRecrodList=arr[4];
			mCanGetTimes=Math.floor(this.mPayMoney/this.cfg.buy_num)+1;
			this.event(ModelActivities.UPDATE_DATA);
		}


		/**
		 * 活动倒计时
		 */
		public function get time():String{
			//return Tools.getTimeStyle(Tools.gameDay0hourMs(ConfigServer.getServerTimer())+cfg.time*Tools.oneHourMilli);
			return Tools.getTimeStyle(Tools.getDayDisTime());
		}

		/**
		 * 开服天数
		 */
		public function get openDays():Number{
			return ModelManager.instance.modelUser.loginDateNum;
		}

		/**
		 * 活动是否开启
		 */
		override public function get active():Boolean{
			if(!cfg) return false;
			if(cfg.reward.hasOwnProperty(openDays)){
				return true;
			}
			return false;
		}

		/**
		 * 奖池
		 */
		public function get jackpot():Object{
			if(cfg.reward.hasOwnProperty(this.mDays)){
				return ConfigServer.ploy.reward_house[cfg.reward[this.mDays]];
			}
			return null; 
		}

		/**
		 * 选择的奖励
		 */
		public function get giftArr():Array{
			var arr:Array=[];
			for(var i:int=0;i<this.mAwradList.length;i++){
				var a:Array=this.jackpot.award[i][2];
				var aa:Array=this.mAwradList[i];
				for(var j:int=0;j<aa.length;j++){
					arr.push([a[aa[j]],i==2]);
				}
			}
			return arr;
		}

		/**
		 * 额外奖励列表
		 */
		public function getAddList():Array{
			var obj:Object=this.jackpot.add;
			var arr:Array=[];
			for(var s:String in obj){
				arr.push([Number(s),obj[s]]);
			}
			arr.sort(MathUtil.sortByKey("0",false,false));
			return arr;
		}

		/**
		 * 抽奖记录
		 */
		public function getRecrodsList():Array{
			var arr:Array=[];
			for(var i:int=0;i<this.mRecrodList.length;i++){
				var a:Array=this.mRecrodList[i];
				var item:String="";
				for(var s:String in a[1]){
					item=ModelItem.getItemName(s)+"x"+a[1][s]+"  ";
				}
				var str:String=Tools.getMsgById("dial_text13",[Tools.dateFormat(a[0]),item]);
				arr.push(str);
			}
			return arr;
		}

		override public function get redPoint():Boolean{
			if(mGetTimes==0){
				return true;
			}
			return false;
		}
	}

}