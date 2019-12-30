package sg.activities.model
{
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.model.ModelItem;
	import sg.utils.Tools;
	import laya.utils.Handler;
	import sg.net.NetPackage;

	/**
	 * ...
	 * @author
	 */
	public class ModelDial extends ModelDialBse{

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
		 * 活动倒计时（剩余时间）
		 */
		override public function get remainTime():String{
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
		 * 抽奖
		 */
        override public function drawReward(handler:Handler):void {
            this.sendMethod('get_random_dial', {}, Handler.create(this, function(np:NetPackage):void {
				var receiveData:* = np.receiveData;
				ModelManager.instance.modelUser.updateData(np.receiveData);
				var gift_dict:* = receiveData && receiveData.gift_dict_list;
				var mIndex:int = 0;
				var n:Number=np.receiveData.random_num[0];
				var m:Number=np.receiveData.random_num[1];
				if(n==0){
					mIndex = awardList[0].indexOf(m);
				}else if(n==1){
					mIndex = awardList[0].length + awardList[1].indexOf(m);
				}else if(n==2){
					mIndex = awardList[0].length + awardList[1].length + awardList[2].indexOf(m);
				}
				handler.runWith({mIndex: mIndex, gift_dict: gift_dict});
			}));
        }

		override public function get redPoint():Boolean{
			if(mGetTimes==0){
				return true;
			}
			return false;
		}

        override public function get awardList():Array {
            return mAwradList;
		}

        override public function get addCfg():Object{
            return this.jackpot.add;
        }

        override public function get awardCfg():Array {
            return jackpot.award;
		}

        override public function get canGetTimes():int {
            return mCanGetTimes;
		}

        override public function get getTimes():int {
            return mGetTimes;
		}

        override public function get buyNum():int {
            return Number(cfg.buy_num) * 10;
		}

        override public function get payMoney():int {
            return mPayMoney;
		}

        override public function get tips():String {
            return cfg.tips;
        }
	}

}