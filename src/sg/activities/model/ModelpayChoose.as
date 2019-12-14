package sg.activities.model
{
    import sg.model.ViewModelBase;
    import laya.maths.Point;
    import sg.net.NetMethodCfg;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import sg.cfg.ConfigServer;
    import sg.utils.TimeHelper;

    public class ModelpayChoose extends ViewModelBase
    {
		// 单例
		private static var sModel:ModelpayChoose = null;
		
		public static function get instance():ModelpayChoose
		{
			return sModel ||= new ModelpayChoose();
		}
		
        public var cfg:Object;
        public var chooseData:Array;
        private var _endTime:int;
        public var goodsId:String;
        public var payCoin:Number;
        public var chooseTimes:Number;
        public function ModelpayChoose()
        {
            // 获取配置
            this.cfg = ConfigServer.ploy['pay_choose'];
            haveConfig = Boolean(cfg);
        }

        override public function refreshData(data:*):void {
            if (!haveConfig || !data.pay_choose || data.pay_choose.length === 0) return;
            chooseData = data.pay_choose;
            _endTime = ModelManager.instance.modelUser.gameServerStartTimer + Tools.oneDayMilli * chooseData[0];
            goodsId = chooseData[1];
            payCoin = chooseData[2];
            chooseTimes = chooseData[3];
            this.event(ModelActivities.UPDATE_DATA);
        }

        public function buyGoods(goodsIndex: int, pos:Point):void
        {
            pos = pos ? pos : Point.TEMP.setTo(300, 500);
            ModelActivities.instance.buyGoodsWithoutHint(NetMethodCfg.WS_SR_GET_PAY_CHOOSE_REWARD, {goods_index:goodsIndex}, pos);
        }
           
        override public function get active():Boolean {
            if (!haveConfig) return false;
            if (!chooseData || chooseData.length === 0) return false;
            var currentTime:int = ConfigServer.getServerTimer();
            if (_endTime < currentTime) return false;
            return ModelManager.instance.modelUser.canPay;
        }
           
        override public function get redPoint():Boolean {
            return this.canGetTimes > 0 && chooseTimes < cfg.limit_time;
        }
        
        public function get canGetTimes():int {
            var num:int = Math.floor(payCoin / cfg.need_pay_coin) - chooseTimes;
            return num > remainTimes ? remainTimes : num;
        }
        
        public function get remainTimes():int {
            return cfg['limit_time'] - chooseTimes;
        }
        
        public function resetGoods():void { // 重置成一个都未选中状态
            cfg[goodsId].forEach(function(item:Object):void {item.selected = false;}, this);
        }
        
        public function getListData():Array {
            return cfg[goodsId];
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