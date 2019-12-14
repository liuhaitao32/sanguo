package sg.festival.model
{
    import sg.model.ViewModelBase;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.utils.TimeHelper;
    import sg.utils.Tools;
    import sg.net.NetMethodCfg;
    import sg.utils.ObjectUtil;
    import sg.model.ModelItem;

    public class ModelFestivalExchange extends ViewModelBase
    {
		// 单例
		private static var sModel:ModelFestivalExchange = null;
		
		public static function get instance():ModelFestivalExchange {
			return sModel ||= new ModelFestivalExchange();
		}
		
        private var _cfg:Object = null;
        public var goods_limit:Object = {};
        public function ModelFestivalExchange() {
        }

        /**
         * 设置配置数据
         */
        public function initCfg():void {
            var actCfg:Object = ModelFestival.instance.actCfg;
            var cfgData:Object = actCfg.act[ModelFestival.TYPE_EXCHANGE];
            _cfg = cfgData;
        }

        /**
         * 更新数据
         */
        public function checkData(exchange:Object):void {
            goods_limit = exchange.goods_limit;
        }

        public function get goodsData():Array {
            var arr:Array = [];
            var i:int = 1;
            while(_cfg.goods[i]) {
                var obj:Object = _cfg.goods[i];
                obj.goods_id = i;
                obj.buyTimes = goods_limit[i] || 0;
                arr.push(obj);
                i++;
            }
            return arr;
        }

        public function get refreshTimeCount():Number {
            var day_fresh:Array = _cfg.day_fresh;
            var currentTime:int = ConfigServer.getServerTimer();
            var date:Date = new Date(currentTime - currentTime % Tools.oneMinuteMilli);
            date.setHours(day_fresh[0]);
            date.setMinutes(day_fresh[1]);
            var nearestTime:Number = date.getTime();
            if (nearestTime < currentTime)  nearestTime += Tools.oneDayMilli;
            return nearestTime - currentTime;
        }

        public function get cfg():Object {
            return _cfg;
        }

        override public function get active():Boolean {
            return Boolean(_cfg);
        }

        /**
         * 检测红点
         */
        override public function get redPoint():Boolean {
            return active && this.goodsData.some(function(data:Object):Boolean {
                return (data.buyTimes < data.limit || data.limit === -1) && data.need.every(function(need:Array):Boolean { return ModelItem.getMyItemNum(need[0]) >= need[1] }, this);
            }, this);
        }

        /**
         * 领奖
         */
        public function exchangeGood(id:String):void {
            ModelFestival.instance.sendMethod(NetMethodCfg.WS_SR_FESTIVAL_EXCHANGE, {goods_id: String(id)});
        }
    }
}