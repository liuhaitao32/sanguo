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
    import sg.utils.Tools;
    import sg.utils.TimeHelper;
    import sg.model.ModelGame;

    public class ModelOnlineReward extends EventDispatcher
    {
        static public const REMOVE_SELF:String = 'remove_self';

		// 单例
		private static var sModel:ModelOnlineReward = null;
		
		public static function get instance():ModelOnlineReward
		{
			return sModel ||= new ModelOnlineReward();
		}

        /**
         * 获取距离下次可领奖的时间
		 * @return 剩余时间的毫秒数（非负数）,以及总时间
         */
        public static function getRemainingTime():Array
        {
            var _this:ModelOnlineReward = ModelOnlineReward.instance;
            return [_this.millisecond, _this.totalMillisecond];
        }
		
        /**
         * 检测是否存在可领取奖励
         */
        public static function haveReward():Boolean
        {
            var _this:ModelOnlineReward = ModelOnlineReward.instance;
            return _this.active && _this.getRewardIndex() < 4 && _this.totalMillisecond > 0 && _this.millisecond === 0;
        }
		
        private var data:Object = {};
        private var cfg:Object = null;
        private var millisecond:int = 0;
        private var totalMillisecond:int = 0;
        public function ModelOnlineReward()
        {
            this.cfg = ConfigServer.ploy['act_online'];
            this._initModel();
        }

        private function _initModel():void {
            if (!cfg) return;
            var online_reward:Array = ModelManager.instance.modelUser.records['online_reward'];
            if (!online_reward || online_reward.length < 2) return;
            var index:int = this.data['index'] = online_reward[0];
            if (index === 4)    return;
            var rewardData:* = this.cfg['online'][index];
            this.totalMillisecond = rewardData['cd'] * 60000;
            this.data['time'] = Tools.getTimeStamp(online_reward[1]) + this.totalMillisecond;
            this.data['reward'] = rewardData['reward'];
            this.data['pay_reward'] = rewardData['pay_reward'];
            this.getTime();
        }

        public function refreshData(online_reward:*):void {
            if (!cfg)   return;
            var index:int = this.data['index'] = online_reward[0];
            if (index === 4) {
                this.totalMillisecond = 0;
                this.event(ModelOnlineReward.REMOVE_SELF);
                return;
            }
            var rewardData:* = this.cfg['online'][index];
            this.totalMillisecond = rewardData['cd'] * 60000;
            this.data['time'] = Tools.getTimeStamp(online_reward[1]) + this.totalMillisecond;
        }

        public function getTime():int {
            var timeOffset:int = new Date(this.data['time']).getTime() - ConfigServer.getServerTimer();
            this.millisecond = timeOffset >= 0 ? timeOffset : 0;
            return millisecond;
        }

        public function getRewardIndex():int {
            return this.data['index'];
        }

        public function get active():Boolean  {
            return ModelManager.instance.modelUser.canPay && !ModelGame.unlock(null, 'pay').stop;
        }

        public function extraRewardFlag():Boolean
        {
            return ModelManager.instance.modelUser.records.pay_money >= this.cfg['pay_money'];
        }

		/**
		 * 领取奖励
		 */
		public function getReward():void
		{
			//领取奖励，告知服务器
			NetSocket.instance.send(NetMethodCfg.WS_SR_GET_ONLINE_REWARD, {}, Handler.create(this, this.getRewardCB));
		}
		
		/**
		 * 领奖的回调
		 * @param	re
		 */
		private function getRewardCB(re:NetPackage):void
		{
			var receiveData:* = re.receiveData;
            var gift_dict:* = receiveData['gift_dict'];
			ModelManager.instance.modelUser.updateData(receiveData);
			
			ViewManager.instance.showRewardPanel(gift_dict, this.data['index'] === 4 ? this.showTips : null);
		}

        public function getConfig():Object {
            return this.cfg;            
        }

        private function showTips():void
        {
            this.totalMillisecond = -1;
			ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0045'));
        }
		
    }
}