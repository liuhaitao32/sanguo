package sg.activities.model
{
    import laya.events.EventDispatcher;

    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import sg.utils.ObjectUtil;
    import sg.net.NetMethodCfg;
    import laya.maths.Point;
    import sg.model.ViewModelBase;
    import sg.model.ModelItem;
    import sg.model.ModelEquip;
    import sg.utils.TimeHelper;

    public class ModelExchange extends ViewModelBase
    {
		// 单例
		private static var sModel:ModelExchange = null;
		
		public static function get instance():ModelExchange
		{
			return sModel ||= new ModelExchange();
		}
		
        public var cfg:Object;
        private var shopData:Array;
        private var _endTime:Number;
        public var goodsData:Array;
        public function ModelExchange()
        {
            // 获取配置
            this.cfg = ConfigServer.ploy['exchange_shop'];
            haveConfig = Boolean(cfg);
        }

        override public function refreshData(data:*):void {
            if (!haveConfig || !data.exchange_shop || data.exchange_shop.length === 0) return;
            shopData = data.exchange_shop;
            _endTime = ModelManager.instance.modelUser.gameServerStartTimer + Tools.oneDayMilli * shopData[0];
            goodsData = shopData[1];

            this.event(ModelActivities.UPDATE_DATA);
        }
        
		override public function get active():Boolean {
            if (!haveConfig || !shopData || shopData.length === 0) return false;
            var currentTime:int = ConfigServer.getServerTimer();
            if (_endTime < currentTime) return false;
            return ModelManager.instance.modelUser.canPay;
        }
        
		override public function get redPoint():Boolean {
            if (!haveConfig)    return false;
            for(var i:int = 0, len:int = goodsData.length; i < len; i++) {
                var goodsId:Object = goodsData[i][0];
                if (goodsId && checkRedByShopIndex(i))  return true;
            }
            return false;
        }

        public function checkRedByShopIndex(shopIndex:int):Boolean {
            var goodsId:Object = goodsData[shopIndex][0];
            var buyData:Object = goodsData[shopIndex][1];
            if (!goodsId) return false;
            var goodsList:Array = cfg.shoplists[shopIndex][goodsId];
            var consume_items:Array = cfg['consume_items'];
            var itemId:String = consume_items[shopIndex];
            var num:int = ModelItem.getMyItemNum(itemId);
            for(var i:int = 0, len:int = goodsList.length; i < len; i++) {
                var goodsCfg:Object = goodsList[i];
                var buyTimes:int = 0;
                if (buyData[i] is Number) buyTimes = buyData[i];
                if (buyTimes < goodsCfg.limit && num >= goodsCfg.price) {
			        var iId:String = ModelManager.instance.modelProp.getRewardProp(goodsCfg.reward)[0][0];
                    var equipModel:ModelEquip = ModelManager.instance.modelGame.getModelEquip(iId);
                    if (equipModel && equipModel.isMine()) continue;
                    return ModelEquip.canBuyEquipItem(iId);
                }
            }
            return false;
        }

        public function buyGoods(shopIndex: int, goodsIndex: int, pos:Point):void {
            pos = pos ? pos : Point.TEMP.setTo(300, 500);
            ModelActivities.instance.buyGoodsWithoutHint(NetMethodCfg.WS_SR_GET_EXCHANGE_REWARD, {shop_index:shopIndex, goods_index:goodsIndex}, pos);
        }

        /**
         * 获取活动剩余时间
         */
        public function getRemainingTime():int {
            var currentTime:int = ConfigServer.getServerTimer();
            var mergeTime:int = ModelAfficheMerge.instance.mergeTime;
            var remainingTime:int = (mergeTime && mergeTime < _endTime ? mergeTime: _endTime) - currentTime;
            return remainingTime < 0 ? 0 : remainingTime;
        }

        /**
         * 获取活动剩余时间（字符串）
         */
        public function getTimeString():String {
            return TimeHelper.formatTime(this.getRemainingTime());
        }
    }
}