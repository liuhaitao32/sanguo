package sg.festival.model
{
    import sg.model.ViewModelBase;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.utils.TimeHelper;
    import sg.utils.Tools;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.activities.model.ModelActivities;
    import laya.maths.Point;

    public class ModelFestivalAddUp extends ViewModelBase
    {
		public static const TYPE_REWARD:String = 'reward';         // 累充RMB的奖励（一次性奖励）
		public static const TYPE_LOOP:String   = 'loop_reward';    // 小累充奖励（循环奖励）
		public static const TYPE_BIG:String    = 'big_reward';     // 大累充奖励（一次性奖励）

		// 单例
		private static var sModel:ModelFestivalAddUp = null;
		
		public static function get instance():ModelFestivalAddUp {
			return sModel ||= new ModelFestivalAddUp();
		}
		
        private var _cfg:Object = null;
        public var payMoney:int = 0;
        public var loopReward:int = 0;
        public var bigReward:int = 0;
        public var rewardList:Array = null;
        public var on_time:int = 0;
        public var off_time:int = 0;
        public function ModelFestivalAddUp() {
        }

        /**
         * 设置配置数据
         */
        public function initCfg():void {
            var actCfg:Object = ModelFestival.instance.actCfg;
            var cfgData:Object = actCfg.act[ModelFestival.TYPE_ADD_UP];
            _cfg = cfgData;
            on_time = Tools.getTimeStamp(_cfg.on_time);
            off_time = Tools.getTimeStamp(_cfg.off_time);
        }

        /**
         * 更新数据
         */
        public function checkData(add_up_big:int, add_up_loop:int, add_up_pay:int, add_up_reward:Array):void {
            payMoney = add_up_pay;
            bigReward = add_up_big;
            loopReward = add_up_loop;
            rewardList = add_up_reward;
        }

        public function getLoopRewardData():Array {
            var reward:Object = _cfg.loop_reward.reward;
            return ModelManager.instance.modelProp.getRewardProp(reward);
        }

        public function get cfg():Object {
            return _cfg;
        }

        public function get bigRewardState():int {
            if (payMoney < cfg.big_reward.pay)  return 0;
            return bigReward + 1;
        }

        public function get loopRewardActive():Boolean {
            return this.loopRewardData[0] > 0;
        }

        public function get loopRewardData():Array {
            var totalNum:int = Math.floor(payMoney / cfg.loop_reward.pay);
            return [totalNum - loopReward, totalNum];
        }

        override public function get active():Boolean {
            return ModelManager.instance.modelUser.canPay && Boolean(_cfg);
        }

        /**
         * 检测红点
         */
        override public function get redPoint():Boolean {
            if (!active)  return false;
            var _this:ModelFestivalAddUp = this;
            var normalRewardActive:Boolean = _cfg.reward.some(function(item:Array, index:int):Boolean {
                return _this.payMoney >= item[0] && _this.rewardList.indexOf(index) === -1;
            });
            return normalRewardActive || loopRewardActive || bigRewardState === 1;
        }

        /**
         * 领奖
         */
        public function getReward(reward_type:String, index:int = null):void {
            ModelFestival.instance.sendMethod(NetMethodCfg.WS_SR_FESTIVAL_ADDUP_REWARD, {reward_type: reward_type, reward_index: index});
        }

        /**
         * 领取循环奖励
         */
        public function getLoopReward(pos:Point):void {
            loopRewardActive && ModelActivities.instance.buyGoodsWithoutHint(NetMethodCfg.WS_SR_FESTIVAL_ADDUP_REWARD, {reward_type: ModelFestivalAddUp.TYPE_LOOP}, pos);
        }
    }
}