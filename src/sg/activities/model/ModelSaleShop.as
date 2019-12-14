package sg.activities.model
{
    import laya.maths.Point;
    import sg.model.ViewModelBase;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.manager.ViewManager;
    import sg.net.NetMethodCfg;
    import sg.utils.ArrayUtil;
    import sg.utils.Tools;
    import sg.utils.TimeHelper;

    public class ModelSaleShop extends ViewModelBase
    {
		// 单例
		private static var sModel:ModelSaleShop = null;
		
		public static function get instance():ModelSaleShop
		{
			return sModel ||= new ModelSaleShop();
		}
		
        public var cfg:Object;
        private var actId:String;
        private var pay_money:Number;
        private var start_time:Object;
        private var end_time:Object;
        private var limit_dict:Object;
        private var listData:Array = [];
        public function ModelSaleShop()
        {
            // 获取配置
            this.cfg = ConfigServer.ploy['act_sale_shop'];
            haveConfig = Boolean(cfg);
        }

        private function _createListData():void {
            var dataArr:Array = this.getGoodsData();
            for (var i:int = 0, len:int = dataArr.length; i < len; ++i) {
                var source:Object = {};
                var data:Object = dataArr[i];
                source.goods_id = String(i+1);
                source.limitTimes = data.limit;
                source.reward = data.reward;
                source.buyTimes = 0;
                source.price = data.price[0];
                source.originalPrice = data.price[1];
                source.needMoney = data.price[2];
                source.state = 0;   // 0:不可购买，1：可购买，2：已售罄
                source.key="sale";
                source.totalMoney = ModelManager.instance.modelUser.coin;
                listData.push(source);
            }
        }

        override public function refreshData(data:*):void {
            if (!haveConfig || !data || !data.sale_shop)  return;
            data = data.sale_shop;
            actId = data[0];
            pay_money = data[1];
            start_time = data[2];
            end_time = data[3];
            limit_dict = data[4];
            this.checkActId() && this.listData.length === 0 && this._createListData();

            for (var i:int = 0, len:int = listData.length; i < len; ++i) {
                var source:Object = listData[i];
                if (pay_money >= source.needMoney) {
                    source.state = 1;
                    source.buyTimes = limit_dict[source.goods_id];
                    source.buyTimes || (source.buyTimes = 0);
                    if (source.buyTimes >= source.limitTimes) {
                        source.state = 2;
                    }
                    source.totalMoney = ModelManager.instance.modelUser.coin;
                }
            }
            this.event(ModelActivities.UPDATE_DATA);
        }

        /**
         * 检查活动Id是否合法
         */
        public function checkActId():Boolean {
            var goodsId:Object = cfg.open_days[actId];
            if (!goodsId) {
                // console.warn("SaleShop: ID don't exist.");
                return false;
            }
            if (!cfg[goodsId]) {
                // console.warn("SaleShop: Goods don't exist.");
                return false;
            }
            return true;
        }
        
        /**
         * 全部商品
         */
        public function getGoodsData():Array {
            var goods:Object = cfg[cfg.open_days[actId]];
            var tempArr:Array = [];
            for (var i:int = 1; i < 999; ++i) {
                var singleGoods:Object = goods[i];
                if (singleGoods) {
                    tempArr.push(singleGoods);
                }
                else {
                    break;
                }
            }
            return tempArr;
        }
        
        public function buyGoods(goods_id:String, pos:Point):void {
            var data:Object = ArrayUtil.find(listData, function(item:Object):Boolean{return item.goods_id == goods_id;});
            if (!this.checkStart()) {
                // 活动未开启
                ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0057'));
            }
            else if (pay_money < data.needMoney) {
                // 充值条件不满足
                ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0059'));
            }
            else if (ModelManager.instance.modelUser.coin < data.price) {
                // 黄金不足
                ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0060'));
            }
            else {
                ModelActivities.instance.buyGoodsWithoutHint(NetMethodCfg.WS_SR_BUY_SALE_SHOP, {'goods_id': goods_id}, pos);
            }
        }

        /**
         * 获取列表数据源
         */
        public function getListData():Array {
            return listData;
        }

        override public function get active():Boolean {
            if (!haveConfig)    return false;
            var endTime:Number = Tools.getTimeStamp(end_time);
            var currentTime:int = ConfigServer.getServerTimer();
            return ModelManager.instance.modelUser.canPay && this.checkActId() && currentTime < endTime;
        }

        /**
         * 检测红点
         */
        override public function get redPoint():Boolean
        {
            if (!active || !this.checkStart()) {
                return false;
            }
            for(var i:int = 0, len:int = listData.length; i < len; i++)
            {
                var element:Object = listData[i];
                if (element.needMoney <= this.pay_money && element.buyTimes < element.limitTimes) {
                    return true;
                }
            }
            return false;
        }
        /**
         * 获取已支付金额
         */
        public function getAlreadyPayNum():int {
            return pay_money;
        }

        /**
         * 检测活动是否开启
         */
        public function checkStart():Boolean {
            var startTime:Number = Tools.getTimeStamp(start_time);
            var currentTime:int = ConfigServer.getServerTimer();
            return currentTime > startTime;
        }
        
        /**
         * 获取活动剩余时间
         */
        public function getRemainingTime():String
        {
            var startTime:Number = Tools.getTimeStamp(start_time);
            var endTime:Number = Tools.getTimeStamp(end_time);
            var currentTime:int = ConfigServer.getServerTimer();
            var remainingTime:int = 0
            if (startTime > currentTime) {
                remainingTime = startTime - currentTime;
            }
            else if(endTime > currentTime) {
                remainingTime = endTime - currentTime;
            }
            else {
                // 活动结束
                remainingTime = 0;
            }
            return TimeHelper.formatTime(remainingTime);
        }
    }
}