package sg.festival.model
{
    import sg.model.ViewModelBase;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.utils.TimeHelper;
    import sg.utils.Tools;
    import sg.net.NetMethodCfg;
    import sg.utils.ObjectUtil;
    import laya.maths.Point;
    import sg.activities.model.ModelActivities;
    import sg.model.ModelItem;
    import sg.manager.ViewManager;
    import laya.utils.Handler;

    public class ModelFestivalLuckShop extends ViewModelBase
    {
		// 单例
		private static var sModel:ModelFestivalLuckShop = null;
		
		public static function get instance():ModelFestivalLuckShop {
			return sModel ||= new ModelFestivalLuckShop();
		}
		
        private var _cfg:Object = null;
        public var goods_dict:Object = null;
        public var time_key:Number;
        public var buy_times:Number;
        public var refresh_times:Number;
        public function ModelFestivalLuckShop() {
        }

        /**
         * 设置配置数据
         */
        public function initCfg():void {
            var actCfg:Object = ModelFestival.instance.actCfg;
            var cfgData:Object = actCfg.act[ModelFestival.TYPE_LUCK_SHOP];
            _cfg = cfgData;
        }

        /**
         * 更新数据
         */
        public function checkData(luckshop:Object):void {
            goods_dict = luckshop.goods_dict;
            refresh_times = luckshop.refresh_times;
            buy_times = luckshop.buy_times;
            time_key = luckshop.time_key;
            Laya.timer.clear(this, this._autoRefresh);
            Laya.timer.once(this.refreshTimeCount + 1000, this, this._autoRefresh);
        }

        private function _autoRefresh():void {
            ModelFestival.instance.notifyServer();
        }

        public function get goodsData():Array {
            var arr:Array = [];
            for(var i:int = 1; i <= 6; i++) {
                var sData:Array = goods_dict[i];
                var obj:Object = ObjectUtil.clone(_cfg.goods[i][sData[0]]);
                obj.goods_id = i;
                obj.buyTimes = sData[1];
                obj.discount = sData[2]; // 折扣
                arr.push(obj);
            }
            return arr;
        }

        public function get refreshTimeCount():Number {
            var day_fresh:Array = _cfg.day_fresh;
            var currentTime:int = ConfigServer.getServerTimer();
            var day_fresh_Arr:Array = day_fresh.map(function(arr:Array):Number {
                var date:Date = new Date(currentTime - currentTime % Tools.oneMinuteMilli);
                date.setHours(arr[0]);
                date.setMinutes(arr[1]);
                return date.getTime();
            }, this); // 一天中每次刷新的时间点
            var nearestTime:Number = 0;
            for (var i:int = 0, len:int = day_fresh_Arr.length; i < len; ++i) {
                if (day_fresh_Arr[i] > currentTime) {
                    nearestTime = day_fresh_Arr[i];
                    break;
                }
            }
            if (nearestTime === 0)  nearestTime = day_fresh_Arr[0] + Tools.oneDayMilli;
            return nearestTime - currentTime;
        }

        public function get cfg():Object {
            return _cfg;
        }

        override public function get active():Boolean {
            return Boolean(_cfg) && this.goods_dict;
        }

        /**
         * 检测红点
         */
        override public function get redPoint():Boolean {
            return active && canBuy && this.goodsData.some(function(item:Object):Boolean {
                return item.buyTimes < item.limit && ModelItem.getMyItemNum(item.price[0]) >= item.price[1] * item.discount * 0.1 && item.discount === 1;
            }, this);
        }

        /**
         * 刷新
         */
        public function refreshGoods():void {
            var costArr:Array = _cfg.cost_refresh;
            var index:int = refresh_times >= costArr.length ? costArr.length - 1 : refresh_times;
            var cost:Array = costArr[index];
            if (cost[1]) {
                ViewManager.instance.showAlert(Tools.getMsgById("_gtask1"), Handler.create(this, this.refreshGoods2), cost, "", false, false, 'suibianlawusuowei'); // 刷新商品
            }
            else {
                this.refreshGoods2();
            }
        }
        
        private function refreshGoods2(num:int = 0):void { // 取消传的1，确定传的0
            if (num === 0) {
                if (canBuy) {
                    ModelFestival.instance.sendMethod(NetMethodCfg.WS_SR_REFRESH_LUCKSHOP);
                } else {
                    ViewManager.instance.showTipsTxt(Tools.getMsgById('_public33'));
                }
            }
        }

        /**
         * 领奖
         */
        public function buyGoods(id:String, pos:Point):void {
            if (canBuy) {
                ModelActivities.instance.buyGoodsWithoutHint(NetMethodCfg.WS_SR_FESTIVAL_LUCKSHOP, {time_key: time_key, goods_id: String(id)}, pos);
            } else {
                ViewManager.instance.showTipsTxt(Tools.getMsgById('_public33'));
            }
        }

        private function get canBuy():Boolean {
            return !(_cfg.all_limit > 0 && buy_times >= _cfg.all_limit);
        }
    }
}