package sg.activities.model
{
	import sg.model.ViewModelBase;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import laya.maths.Point;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	import sg.model.ModelItem;

	/**
	 * ...
	 * @author
	 */
	public class ModelEquipBox extends ViewModelBase{

		// "equip_box": [
        //     0,    day_start
        //     0,    day_end
        //     0,    open_days
        //     null, box_key
        //     0,    lucky_val
        //     0,    buy_times
        //     0,    one_times
        //     0,    ten_times
        //     {}    shop_limit
        // ], 
		private static var sModel:ModelEquipBox = null;
		
		public static function get instance():ModelEquipBox
		{
			return sModel ||= new ModelEquipBox();
		}

		public static const pointArr:Array=[[-171,-203],[-12,-206],[145,-205],
											[-244,-95],[-95,-97],[65,-97],[214,-95],
											[-241,23],[-98,22],[66,25],[216,30]];

		public var cfg:Object;
		public var mShopList:Array;//商店列表

		public var mShopObj:Object;
		public var mBuyTimes:Number;
		public var mOneTimes:Number;
		public var mTenTimes:Number;
		
		//积分
		public function get mScore():Number{
			if(ModelManager.instance.modelUser.property.hasOwnProperty(cfg.item_id)){
				return ModelManager.instance.modelUser.property[cfg.item_id];
			}
			return 0;
		}

		
		public function ModelEquipBox(){
			cfg=ConfigServer.ploy.equip_box;
		}

		/**
		 * 开服天数
		 */
		public function get openDays():Number{
			return ModelManager.instance.modelUser.loginDateNum;
		}
		

		/**
		 * 刷新用户数据
		 */
		override public function refreshData(data:*):void{
			var arr:Array = data.equip_box;
			if (!arr is Array) return;
			mBuyTimes = arr[5];
			mOneTimes = arr[6];
			mTenTimes = arr[7];
			mShopObj  = arr[8];
			this.event(ModelActivities.UPDATE_DATA);
		}

		/**
		 * 奖池
		 */
		public function getGoods():Object{
			var n:Number=this.openDays;
			var cfgBeginTime:Object=cfg.begin_time;
			for(var s:String in cfgBeginTime){
				if(n>=cfgBeginTime[s].time[0] && n<=cfgBeginTime[s].time[1]){
					return cfg[cfgBeginTime[s].goods];
				}
			}
			return null; 
		}

		/**
		 * 活动是否开启
		 */
		override public function get active():Boolean{
			var n:Number=this.openDays;
			if(!cfg) return false;
			var cfgBeginTime:Object=cfg.begin_time;
			for(var s:String in cfgBeginTime){
				if(n>=cfgBeginTime[s].time[0] && n<=cfgBeginTime[s].time[1]){
					return true;
				}
			}
			
			return false;
		}

		/**
		 * 商店物品数据
		 */
		public function getShopData():Array{
			var arr:Array=[];
			var o:Object=this.getGoods();
			var cfgData:Array=o ? o.shop : [];
			for (var i:int = 0, len:int = cfgData.length; i < len; ++i) {
                var source:Object = {};
                var data:Array = cfgData[i];
				var n:Number=mShopObj && mShopObj.hasOwnProperty(i) ? mShopObj[i] : 0;
                source.goods_id = String(i+1);
                var is_first:Boolean=false;
				if(data[0][0] && data[0][0].indexOf("equip")!=-1){
					if(!ModelManager.instance.modelUser.equip.hasOwnProperty(data[0][0])){
						is_first=true;
					}
				}			
				source.limitTimes    = is_first ? 1 : data[1][3];
                source.reward        = is_first ? [data[0][0],data[0][1]] : [data[1][0],data[1][1]];
                source.buyTimes      = n;
                source.price         = is_first ? data[0][1] : data[1][2];
                source.originalPrice = is_first ? data[0][1] : data[1][2];
                source.needMoney     = 0;//需充值数额
                source.state         = is_first ? 1 : (n >= data[1][3]  ? 2 : 1);   // 0:不可购买(需充值多少)，1：可购买，2：已售罄
                source.key           = "equip_box";
				source.itemId        = this.cfg.item_id;
				source.totalMoney    = ModelItem.getMyItemNum(this.cfg.item_id);
				source.frist         = is_first;
                arr.push(source);
            }
			mShopList=arr;
			return arr;
		}

		public function buyGoods(index:Number, pos:Point):void{
			var obj:Object=mShopList[index];
			if(!Tools.isCanBuy(obj.itemId,obj.price)){
				return;
			}

			if(obj.limitTimes - obj.buyTimes==0){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("treasure_tips02"));//次数不足
				return ;
			}
			var _item_id:Number=obj.frist ? 0 : 1;
			ModelActivities.instance.buyGoodsWithoutHint("buy_equip_shop", {"shop_index":index,"item_index":_item_id}, pos);
			
		}


		/**
		 * 获得可回收的道具对象
		 */
		public function getRecoverItem():Object{
			var o:Object=null;
			if(this.active){
				var obj:Object=this.getGoods().recover;
				for(var s:String in obj){
					var n:Number=0;
					for(var i:int=0;i<obj[s][0].length;i++){
						n+=ModelManager.instance.modelGame.getModelEquip(obj[s][0][i]).getNeedNumById(s);
					}
					var m:Number=ModelItem.getMyItemNum(s);
					if(m-n>0){
						if(o==null) o={};
						o[s]=m-n;
					}
				}
			}
			return o;
		}

		override public function get redPoint():Boolean{
			//有商店可购买
			if(redPointShop()){
				return true;
			}
			//有可回收
			if(getRecoverItem()){
				return true;
			}
			//有免费单抽
			if(this.mOneTimes<this.getGoods().buy_one[0]){
				return true;
			}
			//有免费十抽
			if(this.mTenTimes<this.getGoods().buy_ten[0]){
				return true;
			}
			return false;
		}

		/**
		 * 商店红点
		 */
		public function redPointShop():Boolean{
			if(this.active){
				this.getShopData();
				for(var i:int=0;i<mShopList.length;i++){
					var source:Object=mShopList[i];
					//有可购买的物品
					if(source.price<=source.totalMoney){
						return true;
					}
				}
			}
			return false;
		}


		/**
		 * 活动剩余时间
		 */
		public function get time():Number{
			var n:Number=this.openDays;
			var m:Number=0;
			var cfgBeginTime:Object=cfg.begin_time;
			for(var s:String in cfgBeginTime){
				if(n>=cfgBeginTime[s].time[0] && n<=cfgBeginTime[s].time[1]){
					m=cfgBeginTime[s].time[1];
					break;
				}
			}
			if(m==0) return 0;
			else return Tools.getDayDisTime()+(m-n)*Tools.oneDayMilli;
		}

		/**
         * 获取活动剩余时间（）
         */
        public function getTime():int {
            var n:Number=this.openDays;
			var m:Number=0;
			var cfgBeginTime:Object=cfg.begin_time;
			for(var s:String in cfgBeginTime){
				if(n>=cfgBeginTime[s].time[0] && n<=cfgBeginTime[s].time[1]){
					m=cfgBeginTime[s].time[1];
					break;
				}
			}
			if(m==0) return 0;
			else return Tools.getDayDisTime()+(m-n)*Tools.oneDayMilli;
        }


	}

}