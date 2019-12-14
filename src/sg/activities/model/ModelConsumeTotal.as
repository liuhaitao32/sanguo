package sg.activities.model
{
    import sg.model.ViewModelBase;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.utils.ObjectUtil;
    import sg.utils.Tools;
    import sg.utils.TimeHelper;

    public class ModelConsumeTotal extends ViewModelBase
    {
		// 单例
		private static var sModel:ModelConsumeTotal = null;
		
		public static function get instance():ModelConsumeTotal
		{
			return sModel ||= new ModelConsumeTotal();
		}
		
        private var cfg:Object;
        private var _actId:String = "0_0";
        public var receive_list:Array;
        private var _endTime:Number;
        public var use_coin:Number;
        public function ModelConsumeTotal()
        {
            // 获取配置
            this.cfg = ConfigServer.ploy['consume'];
            haveConfig = Boolean(cfg);
        }

        override public function refreshData(data:*):void {
            if (!haveConfig || !data.coin_consume || !data.coin_consume is Array) return;
            var consume:Array = data.coin_consume;
            _actId = consume[0];
            if (this.active === false) return;
            use_coin = consume[2];
            receive_list = consume[3];
            var endDay:int = parseInt(_actId.match(/\d+_(\d+)/)[1]);
            _endTime = ModelManager.instance.modelUser.gameServerStartTimer + Tools.oneDayMilli * endDay;

            this.event(ModelActivities.UPDATE_DATA);
        }

        public function checkReward():Boolean
        {
            var keys:Array = ObjectUtil.keys(this.getRewardData());
            for(var i:int = 0, len:int = keys.length; i < len; i++)
            {
                var key:int = parseInt(keys[i]);
                if (use_coin >= key && receive_list.indexOf(key) === -1) return true;
            }
            return false;
        }

        /**
         * 全部活动奖励
         */
        public function getRewardData():Array {
            return this.getConfig()["reward"];
        }

        override public function get active():Boolean {
            if (!haveConfig) return false;
            if (_actId === "0_0") return false;
            var currentTime:int = ConfigServer.getServerTimer();
            if (_endTime < currentTime) return false;
            return true;
        }

        override public function get redPoint():Boolean {
            return this.checkReward();
        }

        public function getId():String
        {
            return this._actId;
        }

        public function getConfig():Object
        {
            return cfg[cfg.open_days[_actId]];
        }

        /**
         * 获取活动剩余时间
         */
        public function getRemainingTime():int
        {
            var currentTime:int = ConfigServer.getServerTimer();
            var mergeTime:int = ModelAfficheMerge.instance.mergeTime;
            var remainingTime:int = (mergeTime && mergeTime < _endTime ? mergeTime: _endTime) - currentTime;
            return remainingTime < 0 ? 0 : remainingTime;
        }

        /**
         * 获取活动剩余时间（字符串）
         */
        public function getTimeString():String
        {
            return TimeHelper.formatTime(this.getRemainingTime());
        }
    }
}