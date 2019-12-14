package sg.activities.model
{
	import laya.maths.MathUtil;
	import laya.maths.Point;
	import sg.model.ViewModelBase;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	

	/**
	 * ...
	 * @author
	 */
	public class ModelTreasure extends ViewModelBase{

		private static var sModel:ModelTreasure = null;
		
		public static function get instance():ModelTreasure
		{
			return sModel ||= new ModelTreasure();
		}

		public var cfg:Object;
		public var mDays:Number;
		public var mBuyTimesOne:Number=0;
		public var mBuyTimesFive:Number=0;
		public var mScore:Number=0;
		public var mShopObj:Object;
		private var mShopList:Array;

		public function ModelTreasure(){
			cfg=ConfigServer.ploy.treasure;
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
		public function get time():String{
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

		/**
		 * 奖池数据
		 */
		public function getAwradList():Array{
			var arr:Array=[];
			var award:Array=this.jackpot.award;
			for(var i:int=0;i<award.length;i++){
				var b:Boolean=award[i][3] && award[i][3]==1;
				arr.push([award[i][1],award[i][2],b]);
			}
			return arr;
		}

		/**
		 * 商店物品数据
		 */
		public function getShopData():Array{
			var arr:Array=[];
			var cfgData:Array=this.jackpot.treasure_shop;
			for (var i:int = 0, len:int = cfgData.length; i < len; ++i) {
                var source:Object = {};
                var data:Array = cfgData[i];
				var n:Number=mShopObj.hasOwnProperty(i)?mShopObj[i]:0;
                source.goods_id      = String(i+1);
                source.limitTimes    = data[3];				
                source.reward        = [data[0],data[1]];
                source.buyTimes      = n;
                source.price         = data[2];
                source.originalPrice = data[2];
                source.needMoney     = 0;
                source.state         = n>=data[3]?2:1;   // 0:不可购买，1：可购买，2：已售罄
                source.key           = "treasure";
				source.itemId        = "";
				source.totalMoney    = this.mScore;
                arr.push(source);
            }
			mShopList=arr;
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

		public function buyGoods(index:Number, pos:Point):void{
			var obj:Object=mShopList[index];
			if(obj.price>obj.totalMoney){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("treasure_tips01"));//积分不足
				return ;
			}
			if(obj.limitTimes - obj.buyTimes==0){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("treasure_tips02"));//次数不足
				return ;
			}
			ModelActivities.instance.buyGoodsWithoutHint("buy_treasure_shop", {"shop_index":index}, pos);
			/*
			NetSocket.instance.send("buy_treasure_shop",{"shop_index":index},new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
			}));
			*/
		}

		override public function get redPoint():Boolean{
			if(red_point_shop()){
				return true;
			}
			if(red_point_free_time()){
				return true;
			}
			return false;
		}

		/**
		 * 商店红点
		 */
		public function red_point_shop():Boolean{
			var arr:Array=(this.jackpot.treasure_shop as Array).concat();
			arr.sort(MathUtil.sortByKey("2"),false,false);
			var min:Number=arr[0][2];
			if(mScore>=min){
				return true;
			}
			return false;
		}

		/**
		 * 是否可以免费抽取
		 */
		public function red_point_free_time():Boolean{
			var n1:Number=this.cfg.buy_one[0]-this.mBuyTimesOne;
			var n5:Number=this.cfg.buy_five[0]-this.mBuyTimesFive;
			if(n1>0 || n5>0){
				return true;
			}
			return false;
		}
	}

}