package sg.activities.model
{
    import sg.model.ViewModelBase;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.model.ModelUser;
    import sg.net.NetMethodCfg;
    import sg.utils.ObjectUtil;
    import sg.utils.Tools;

    public class ModelFund extends ViewModelBase
    {
		// 单例
		private static var sModel:ModelFund = null;
		
		public static function get instance():ModelFund
		{
			return sModel ||= new ModelFund();
		}
		
        public var cfg:Object;
        private var totalReward:Object;
        private var listData:Array = [];
        private var _finished:Boolean = false;
        private var _alreadyBuy:Boolean = false;
        private var _haveReward:Boolean = false;
        public function ModelFund()
        {
            // 获取配置
            this.cfg = ConfigServer.ploy['fund'];
            haveConfig = Boolean(cfg);
            if (haveConfig) {
                this.mergeReward();
                this._createListData();
            }
        }

        /**
         * 合并所有奖励
         */
        private function mergeReward():void {
            this.totalReward = {};
            var rewardArr:Array = this.getRewardData();
            for(var i:int = 0, len:int = rewardArr.length; i < len; ++i) {
                var obj:Object = rewardArr[i];
                var key:String =ObjectUtil.keys(obj)[0];
                var reward:Array = [key, obj[key]];
                var rewardName:String = reward[0]; 
                var rewardNum:int = reward[1]; 
                if (totalReward[rewardName])    totalReward[rewardName] += rewardNum;
                else    totalReward[rewardName] = rewardNum;
            }
        }

        private function _createListData():void {
            var rewardArr:Array = this.getRewardData();
            for (var i:int = 0, len:int = rewardArr.length; i < len; ++i) {
                var source:Object = {};
                source.index = i;
                source.name = Tools.getMsgById('_jia0046', [i+1]);
                source.reward = rewardArr[i];
                source.state = 0; // 0:不可领奖、1：可领奖、2：已领奖
                listData.push(source);
            }
        }

        /**
         * 更新数据
         */
        override public function refreshData(data:*):void {
            if (!haveConfig || !data.fund)  return;
            var fund:Object = data.fund;
            var receive_index:Array = fund.receive_index;
            receive_index || (receive_index = []); // 容错处理
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            this._finished = fund.is_finish;
            this._haveReward = false;
            _alreadyBuy = fund.time !== null;
            var buyTime:int = 0; // 基金购买日期
            var currentTime:int = 0; // 当前日期
            if (fund.time) {
                buyTime = modelUser.getGameDate(Tools.getTimeStamp(fund.time)); // 基金购买日期
                currentTime = modelUser.getGameDate(); // 当前日期
            }
            
            for (var i:int = 0, len:int = listData.length; i < len; ++i) {
                var source:Object = listData[i];
                var received:Boolean = receive_index.indexOf(i) > -1;
                source.state = received ? 2 : (_alreadyBuy && currentTime >= (buyTime + i) ? 1 : 0);
                (source.state === 1) && (this._haveReward = true);
            }
            this.event(ModelActivities.UPDATE_DATA);
        }

        override public function get active():Boolean {
            return ModelManager.instance.modelUser.canPay && haveConfig && !_finished;
        }

        /**
         * 检测红点
         */
        override public function get redPoint():Boolean {
            return haveConfig && (_haveReward || this.isCanBuy());
        }

        public function getReward(index:int):void {
            ModelActivities.instance.sendMethod(NetMethodCfg.WS_SR_GET_FUND_GIFT, {'index':index});
        }

        public function buyFund():void {
            ModelActivities.instance.sendMethod(NetMethodCfg.WS_SR_BUY_FUND);
        }

        /**
         * 获取列表数据源
         */
        public function getListData():Array {
            return listData;
        }

        public function isCanBuy():Boolean
        {
            return !_alreadyBuy && this.getAlreadyPayNum() >= this.getNeedPayNum();            
        }

        /**
         * 获取已支付金额
         */
        public function getAlreadyPayNum():int {
            return ModelManager.instance.modelUser.records['pay_money'] * 10;
        }

        /**
         * 获取需要充值的金额
         */
        public function getNeedPayNum():int {
            return parseInt(cfg['need_pay_money']) * 10;
        }

        /**
         * 获取需要支付的黄金
         */
        public function getBuyCoin():int {
            return cfg['buy'];
        }

        /**
         * 全部活动奖励
         */
        public function getRewardData():Array {
            return this.cfg['reward'];
        }

        /**
         * 合并之后的奖励
         */
        public function getTotalReward():Object {
            return totalReward;
        }
    }
}