package sg.activities.model
{
	import laya.maths.MathUtil;
	import laya.maths.Point;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	

	/**
	 * ...
	 * @author
	 */
	public class ModelTreasure extends ModelTreasureBase {

		private static var sModel:ModelTreasure = null;
		
		public static function get instance():ModelTreasure
		{
			return sModel ||= new ModelTreasure();
		}

		public var mDays:Number;

		public function ModelTreasure(){
			cfg=ConfigServer.ploy.treasure;
			key = ModelTreasureBase.KEY_TREASURE;
			buy_method = 'buy_treasure';
			buy_method_shop = 'buy_treasure_shop';
		}

		/**
		 * 刷新用户数据
		 */
		override public function refreshData(data:*):void{
			var arr:Array = data.treasure;
			if (!arr is Array) return;
			mDays=arr[0];
			mBuyTimesOne=arr[1];
			mBuyTimesFive=arr[2];
			mScore=arr[3];
			mShopObj=arr[4];
			this.event(ModelActivities.UPDATE_DATA);
		}


		/**
		 * 活动倒计时(到新的一天的时间)
		 */
		override public function get remainTime():String{
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
			return ConfigServer.ploy.reward_house[cfg.reward[mDays]];
			return null; 
		}

        override public function get awardList():Array {
			return this.getAwradList();
        }

        override public function get addCfg():Object{
            return jackpot.add;
        }

        override public function get shopCfg():Array{
            return jackpot.treasure_shop;
        }

        override public function get awardCfg():Array {
            return jackpot.award;
		}
	}

}