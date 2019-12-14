package sg.activities.model
{
    import laya.events.EventDispatcher;
    import laya.utils.Handler;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.manager.ViewManager;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.net.NetSocket;
    import sg.model.ModelUser;
    import sg.utils.Tools;
    import sg.map.utils.ArrayUtils;
    import sg.cfg.ConfigClass;
    import sg.utils.ObjectUtil;
    import laya.maths.Point;
    import sg.utils.TimeHelper;
    import sg.model.ViewModelBase;
    import sg.model.ModelEquip;

    public class ModelFreeBill extends ViewModelBase
    {
		// 单例
		private static var sModel:ModelFreeBill = null;
		
		public static function get instance():ModelFreeBill
		{
			return sModel ||= new ModelFreeBill();
		}
		
        private var _cfg:Object = null;
        private var _actId:String = '';
        public var limitNum:int = 0; // 剩余购买次数
        private var _buyTimes:int = 0;  // 购买(剩余购买次数)的次数
        private var _limitDict:Object;
        private var _rewardList:Array; // 已领取的奖励
        public var freeList:Array; // 免单记录
        public var listData:Array = []; // 列表数据源
        private var startTime:Number = 0; // 开始时间
        private var endTime:Number = 0; // 结束时间
        public var actState:Number = 0; // 活动状态 0：未开启，1：进行中，2：已结束
        
        public function ModelFreeBill()
        {
            _cfg = ConfigServer.ploy['limit_free'];
            haveConfig = Boolean(_cfg);
            actState = 0; // 初始活动状态
        }

        /**
         * 全部商品
         */
        public function getGoodsData():void {
            var goods:Object = this.getGoods()['goods'];
            for (var i:int = 1; i < 999; ++i) {
                var source:Object = goods[i];
                if (source) {
                    source.goods_id = i;
                    source.state = 0;   // 0:不可购买，1：可购买，2：已售罄
                    listData.push(source);
                }
                else {
                    break;
                }
            }
            Laya.timer.frameLoop(60, this, this._refreshActState);
            this._refreshActState();
        }
        private function _refreshActState():void {
            // 开启时间段
            var beginTimes:Array = _cfg['begin_time'];
            var currentTime:int = ConfigServer.getServerTimer(); // 当前时间
            var date:Date = new Date(currentTime);
            var tempTime:int = new Date(date.getFullYear(), date.getMonth(), date.getDate()).getTime(); // 当天的凌晨
            var deviation:Number = ConfigServer.system_simple.deviation * Tools.oneMinuteMilli; // 偏移时间
            startTime = endTime = 0; // 重置起始时间
            var current_time:Number = currentTime - tempTime;
            var start_time:Number = 0;
            var end_time:Number = 0;
            var flag:Boolean = false;
            var len:int = beginTimes.length;
            for(var i:int = 0; i < len; i++)
            {
                var element:Array = beginTimes[i];
                start_time = (element[0] * 60 + element[1]) * Tools.oneMinuteMilli;
                end_time = (element[2] * 60 + element[3]) * Tools.oneMinuteMilli;

                if (current_time < end_time) {
                    // 判断是否在一个区间
                    if (current_time < deviation && end_time <= deviation) {
                        flag = true;
                        break;
                    }
                    else if (current_time >= deviation && end_time > deviation) {
                        flag = true;
                        break;
                    }
                }
            }
            if (flag) { // 判断是否存在活动
                startTime = start_time + tempTime;
                endTime = end_time + tempTime;
            }

            if (flag && currentTime < startTime) { // 活动未开启
                if (actState !== 0) {
                    actState = 0;
                    this.event(ModelActivities.UPDATE_DATA);
                }
            }
            else if (flag && startTime < endTime) { // 活动进行中
                if (actState !== 1) {
                    actState = 1;
                    this.event(ModelActivities.UPDATE_DATA);
                }
            }
            else { // 活动已结束
                if (actState !== 2) {
                    actState = 2;
                    Laya.timer.clear(this, this._refreshActState);
                    this.event(ModelActivities.UPDATE_DATA);
                    ModelActivities.instance.event(ModelActivities.REFRESH_LIST);
                }
            }
        }

        override public function refreshData(limit_free:*):void {
            if (!haveConfig)    return;
            _actId = limit_free[0];
            limitNum = limit_free[1];
            _buyTimes = limit_free[2];
            _limitDict = limit_free[3];
            freeList = limit_free[4];
            _rewardList = limit_free[5];
            this.checkActId() && this.listData.length === 0 && this.getGoodsData();
            for (var i:int = 0, len:int = listData.length; i < len; ++i) {
                var source:Object = listData[i];
                source.state = 1;
                source.buyTimes = _limitDict[source.goods_id];
                source.buyTimes || (source.buyTimes = 0);
                if (source.buyTimes >= source.limit) {
                    source.state = 2;
                }
            }
            this.event(ModelActivities.UPDATE_DATA);
        }

        public function getRewardData():Array
        {
            var goods:Object = this.getGoods();
            var temp:Array = [];
            var count_reward:Object = goods['count_reward'];
            var keys:Array = ObjectUtil.keys(count_reward);
            var len:int = keys.length;
            for(var i:int = 0; i < len; i++)
            {
                var key:String = keys[i];
                var source:Object = {
                    'needNum': parseInt(key),
                    'reward':count_reward[key]
                };
                temp.push(source);
            }
            return temp;
        }

        /**
         * 检查活动Id是否合法
         */
        public function checkActId():Boolean {
            var goodsId:Object = _cfg.open_days[_actId];
            if (!goodsId) {
                // console.warn("FreeBill: ID don't exist.");
                return false;
            }
            if (!this.getGoods()) {
                // console.warn("FreeBill: Goods don't exist.");
                return false;
            }
            return true;
        }

        public function getGoods():Object
        {
            var goodsId:String = _cfg.open_days[_actId];
            return _cfg[goodsId];
        }

        public function getBuyGooodsTimes():int
        {
            var values:Array = ObjectUtil.values(_limitDict);
            var sum:int = 0;
            values.forEach(function (num:int):void {sum += num}, this);
            return sum;
        }

        public function get rewardList():Array
        {
            return _rewardList;
        }

        public function buyGoods(goods_id:String, pos:Point):void
        {
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            var currentCoin:int = modelUser.coin;
            var sGoods:Object = this.getGoods()['goods'][goods_id];
            if (actState === 0) {
                // 活动未开启
                ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0057'));
            } else if (actState === 2) {
                // 活动已结束
                ViewManager.instance.showTipsTxt(Tools.getMsgById('happy_tips07'));
            } else if (currentCoin < sGoods['price']) {
                ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0060'));
            } else if (limitNum <= 0) {
                ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0073'));
            } else {
                var iid:String = ObjectUtil.keys(sGoods.reward)[0];
                if(ModelEquip.canBuyEquipItem(iid, true)) {
                    NetSocket.instance.send(NetMethodCfg.WS_SR_BUY_LIMIT_FREE, {'goods_id': goods_id}, Handler.create(this, this.buyGoodsCB), pos);
                }
            }
        }

        private function buyGoodsCB(re:NetPackage):void {
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            var currentCoin:int = modelUser.coin;
            var receiveData:Object = re.receiveData;
            var currentCoinTemp:int = receiveData.user.coin;
			var gift_dict:* = receiveData['gift_dict'];

            if (currentCoin === currentCoinTemp) {
                ViewManager.instance.showView(ConfigClass.VIEW_FREE_BILL_Reward, gift_dict);
            }
            else {
                var pos:Point = re.otherData;
                ViewManager.instance.showIcon(gift_dict, pos.x, pos.y);
            }

			modelUser.updateData(receiveData);
        }

        public function buyTimes():void
        {
            ModelActivities.instance.sendMethod(NetMethodCfg.WS_SR_BUY_LIMIT_FREE_TIMES);
        }

        public function getReward(count_num: int):void
        {
            ModelActivities.instance.sendMethod(NetMethodCfg.WS_SR_GET_LIMIT_FREE_COUNT_REWARD, {'count_num': count_num});
        }

        public function get canBuy():Boolean {
            return actState === 1 && limitNum > 0 && this.listData.some(function(item:Object):Boolean { 
                return item.limit > item.buyTimes && ModelEquip.canBuyEquipItem(ObjectUtil.keys(item.reward)[0]);
            }, this);
        }

        public function haveReward():Boolean
        {
            var totalBuyTimes:int = this.getBuyGooodsTimes();
            var rewardNum:int = 0;
            var count_reward:Object = this.getGoods()['count_reward'];
            var keys:Array = ObjectUtil.keys(count_reward);
            var len:int = keys.length;
            for(var i:int = 0; i < len; i++)
            {
                var key:String = keys[i];
                if (totalBuyTimes >= parseInt(key)) {
                    rewardNum++;
                }
            }
            return _rewardList.length < rewardNum;
        }

		/**
		 * 是否激活
		 */
		override public function get active():Boolean {
			if (!haveConfig)    return false;
            var haveAct:Boolean = Number(this._actId) === ModelManager.instance.modelUser.getGameDate();
            
            return haveAct && this.checkActId() && (actState !==2 || this.haveReward()); // 活动未结束或奖励未领取
		}

		/**
		 * 是否需要显示红点
		 */
		override public function get redPoint():Boolean {
			return active && (this.haveReward() || this.canBuy);
		}

        public function getBeginTimes():Array
        {
            var beginTimes:Array = _cfg['begin_time'];
            var arr:Array = [];
            var len:int = beginTimes.length;
            for(var i:int = 0; i < len; i++)
            {
                var element:Array = beginTimes[i];
                var startH:* = element[0];
                var startM:* = element[1];
                var endH:* = element[2];
                var endM:* = element[3];
                startM < 10 && (startM = '0' + startM);
                endM < 10 && (endM = '0' + endM);
                arr.push(startH + ':' + startM + '-' + endH + ':' + endM);
            }
            return arr;
        }

        /**
         * 检测活动是否开启
         */
        public function checkStart():Boolean {
            return actState >= 1;
        }

        /**
         * 获取活动剩余时间
         */
        public function getRemainingTime():String
        {
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
            (startTime === currentTime || endTime === currentTime) && this.event(ModelActivities.UPDATE_DATA);
            return TimeHelper.formatTime(remainingTime);
        }

        public function get timesPrice():int {
            return _cfg['buy_limit'][_buyTimes];
        }

        public function get all_limit():int {
            return _cfg['all_limit'];
        }

        public function get remainTimes():int {
            return _cfg['buy_limit'].length - _buyTimes - 1;
        }
    }
}